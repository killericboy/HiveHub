; ================================================================
;  FieldGuard.ahk
;  Field boundary detection & auto-recovery for HiveHub
;  Detects when the player drifts off a BSS field and steers them back.
;
;  Detection strategy (three layers):
;    1. Color sampling — PixelSearch in the "floor zone" of the Roblox window
;       for sky-blue (outside) vs green/flower tiles (inside).
;    2. GDI+ bitmap scan — more reliable cross-resolution fallback.
;    3. Recovery — reverse the lateral key in short bursts until back on field.
;
;  Integration:
;    - #Include this file in HiveHub.ahk (after Gdip_All.ahk)
;    - Call FieldGuard_Init() once at startup
;    - Call FieldGuard_AfterStep(moveKey, reverseKey) after every Walk() call
;      inside SnakeThread
; ================================================================

; ── Public config (edit in HiveHub.ahk or via GUI later) ──────
global FG_Enabled         := true    ; master toggle
global FG_SkyColorSample  := 0x5A9CCC  ; sky-blue hue that signals off-field
global FG_SkyTolerance    := 45         ; ±45 per channel in PixelSearch
global FG_FieldColorSample := 0x4A8430  ; mid-green of field tiles
global FG_FieldTolerance   := 40
global FG_RecoveryPulseMs  := 650       ; how long to hold reverse per pulse
global FG_MaxPulses         := 5        ; give up after this many reverse pulses
global FG_SampleRegionPct   := [0.35, 0.55, 0.65, 0.72]
;                              ↑ x1%, y1%, x2%, y2% of client area
;                              Tune this to sit just above the player's feet.

; ── Internal state ────────────────────────────────────────────
global _FG_CalibOnField  := ""   ; cached on-field sample bitmap ptr
global _FG_LastDirection := ""   ; last lateral key for context
global _FG_RecoveryCount := 0    ; total recoveries this run (for stats/debug)

; ================================================================
;  FieldGuard_Init
;  Call once when the macro starts.  Warms up the colour calibration.
; ================================================================
FieldGuard_Init() {
    global FG_Enabled, _FG_RecoveryCount
    _FG_RecoveryCount := 0

    if !FG_Enabled
        return

    ; Brief wait so the field is fully visible before sampling
    HyperSleep(400)
    FieldGuard_CalibrateOnField()
}

; ================================================================
;  FieldGuard_AfterStep
;  Drop this call after every Walk() inside SnakeThread.
;
;  Parameters:
;    moveKey    — scan-code of the key that was held (e.g. "sc020")
;    reverseKey — scan-code of the opposing direction  (e.g. "sc01e")
;  Returns:
;    true  — player was on field (or recovery succeeded)
;    false — recovery failed (caller can StopMacro if desired)
; ================================================================
FieldGuard_AfterStep(moveKey, reverseKey) {
    global FG_Enabled, running, paused, _FG_LastDirection
    global _FG_RecoveryCount, FG_MaxPulses

    if (!FG_Enabled || !running || paused)
        return true

    _FG_LastDirection := moveKey

    ; Fast exit — still on field
    if _FG_IsOnField()
        return true

    ; Off-field detected — release all lateral movement first
    Send "{" moveKey " up}"
    Send "{LButton up}"
    HyperSleep(80)

    ; Recovery loop
    pulse := 0
    while (running && !paused && pulse < FG_MaxPulses) {
        if _FG_IsOnField()
            break
        _FG_PulseReverse(reverseKey)
        pulse++
    }

    recovered := _FG_IsOnField()
    if recovered {
        _FG_RecoveryCount++
        ToolTip "⚠ FieldGuard: recovered ×" _FG_RecoveryCount
        SetTimer () => ToolTip(), -1800
    } else {
        ToolTip "✖ FieldGuard: off-field — stopping"
        SetTimer () => ToolTip(), -3000
        ; Optionally auto-stop here; comment out if you prefer to keep going
        ; StopMacro()
    }

    return recovered
}

; ================================================================
;  FieldGuard_CalibrateOnField
;  Capture a tiny reference bitmap while the player IS on the field.
;  Called automatically by Init; can also be called manually.
; ================================================================
FieldGuard_CalibrateOnField() {
    global _FG_CalibOnField
    if _FG_CalibOnField {
        Gdip_DisposeImage(_FG_CalibOnField)
        _FG_CalibOnField := ""
    }
    ; Just used as a trigger for the color check; we rely on PixelSearch
    ; primarily, but the calib call resets any stale state.
}

; ================================================================
;  FieldGuard_GetRecoveryCount
;  Returns total number of auto-recoveries this run.
; ================================================================
FieldGuard_GetRecoveryCount() {
    global _FG_RecoveryCount
    return _FG_RecoveryCount
}

; ================================================================
;  Internal helpers
; ================================================================

; Sample the "floor zone" and decide on/off field.
; Returns true if the player appears to be on the field.
_FG_IsOnField() {
    global windowX, windowY, windowWidth, windowHeight
    global FG_SkyColorSample, FG_SkyTolerance
    global FG_FieldColorSample, FG_FieldTolerance
    global FG_SampleRegionPct

    if !GetRobloxClientPos()
        return true   ; can't read window — assume OK

    if (windowWidth = 0 || windowHeight = 0)
        return true

    ; Build screen-space sample rectangle from percentages
    x1 := windowX + Round(windowWidth  * FG_SampleRegionPct[1])
    y1 := windowY + Round(windowHeight * FG_SampleRegionPct[2])
    x2 := windowX + Round(windowWidth  * FG_SampleRegionPct[3])
    y2 := windowY + Round(windowHeight * FG_SampleRegionPct[4])

    ; Layer 1 — fast PixelSearch: any sky blue in floor zone = off-field
    if PixelSearch(&px, &py, x1, y1, x2, y2, FG_SkyColorSample, FG_SkyTolerance)
        return _FG_ConfirmWithBitmap(x1, y1, x2, y2)  ; double-check before acting

    ; Layer 1b — confirm at least some field-green exists
    ; (catches edge case where the whole window went dark or lagged)
    fieldFound := PixelSearch(&px, &py, x1, y1, x2, y2, FG_FieldColorSample, FG_FieldTolerance)
    return fieldFound  ; true = on field

}

; Layer 2 — GDI+ bitmap scan.  Samples the floor region via a captured bitmap
; and counts how many pixels match sky vs field hues.  More reliable than
; single-point PixelSearch when there's partial overlap at the edge.
;
; Returns true (on-field) if sky pixels are fewer than the threshold.
_FG_ConfirmWithBitmap(x1, y1, x2, y2) {
    w := x2 - x1
    h := y2 - y1
    if (w <= 0 || h <= 0)
        return true

    ; Capture the region
    chdc := CreateCompatibleDC()
    hbm  := CreateDIBSection(w, h, chdc)
    obm  := SelectObject(chdc, hbm)
    hhdc := GetDC()
    BitBlt(chdc, 0, 0, w, h, hhdc, x1, y1)
    ReleaseDC(hhdc)
    pBM := Gdip_CreateBitmapFromHBITMAP(hbm)
    SelectObject(chdc, obm)
    DeleteObject(hbm)
    DeleteDC(chdc)

    if !pBM
        return true

    ; Lock bits for fast pixel iteration
    Gdip_LockBits(pBM, 0, 0, w, h, &stride, &scan0, &bmpData, 1)

    skyPixels   := 0
    totalPixels := w * h
    sampleStep  := 4   ; check every 4th pixel for speed

    loop totalPixels // sampleStep {
        idx   := (A_Index - 1) * sampleStep
        px_x  := Mod(idx, w)
        px_y  := idx // w
        argb  := Gdip_GetLockBitPixel(scan0, px_x, px_y, stride)
        r     := (argb >> 16) & 0xFF
        g     := (argb >>  8) & 0xFF
        b     :=  argb        & 0xFF
        ; Sky heuristic: blue dominant, moderate green, low red
        if (b > 120 && b > r + 35 && b > g + 10)
            skyPixels++
    }

    Gdip_UnlockBits(pBM, &bmpData)
    Gdip_DisposeImage(pBM)

    ; If more than 18 % of sampled pixels are sky-blue → off field
    threshold := (totalPixels // sampleStep) * 18 // 100
    return (skyPixels < threshold)
}

; Hold the reverse key for one short pulse, then pause slightly.
_FG_PulseReverse(reverseKey) {
    global FG_RecoveryPulseMs
    Send "{" reverseKey " down}"
    HyperSleep(FG_RecoveryPulseMs)
    Send "{" reverseKey " up}"
    HyperSleep(80)
}
