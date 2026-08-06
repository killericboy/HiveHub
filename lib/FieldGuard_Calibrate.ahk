; ================================================================
;  FieldGuard_Calibrate.ahk
;  Run this tiny script WHILE standing on a BSS field.
;  It samples the screen and prints colour values to copy into
;  FG_SkyColorSample, FG_FieldColorSample, and FG_SampleRegionPct.
;
;  Usage:
;    1. Load into Roblox on the field you want to guard.
;    2. Position your character in the middle of the field.
;    3. Run this script.  Press F8 to capture.
;    4. A MsgBox will show the recommended values.
; ================================================================

#Requires AutoHotkey v2.0
#Include Gdip_All.ahk
#Include Roblox.ahk

pToken := Gdip_Startup()
OnExit((*) => Gdip_Shutdown(pToken))

F8:: CalibrateFieldColors()

CalibrateFieldColors() {
    if !GetRobloxClientPos() {
        MsgBox "Roblox window not found.", "Calibrate", 0x40030
        return
    }

    ; Capture a 200×120 region around screen centre-bottom (the floor zone)
    cx := windowX + windowWidth  // 2
    cy := windowY + Round(windowHeight * 0.60)
    w  := 200, h := 120

    ; Take screenshot
    chdc := CreateCompatibleDC()
    hbm  := CreateDIBSection(w, h, chdc)
    obm  := SelectObject(chdc, hbm)
    hhdc := GetDC()
    BitBlt(chdc, 0, 0, w, h, hhdc, cx - w//2, cy - h//2)
    ReleaseDC(hhdc)
    pBM := Gdip_CreateBitmapFromHBITMAP(hbm)
    SelectObject(chdc, obm), DeleteObject(hbm), DeleteDC(chdc)

    ; Analyse pixels
    Gdip_LockBits(pBM, 0, 0, w, h, &stride, &scan0, &bmpData, 1)

    rSum := gSum := bSum := 0
    skyR := skyG := skyB := 0
    fieldR := fieldG := fieldB := 0
    total := 0, skyCount := 0, fieldCount := 0

    loop w * h {
        px := Mod(A_Index-1, w)
        py := (A_Index-1) // w
        argb := Gdip_GetLockBitPixel(scan0, px, py, stride)
        r := (argb>>16)&0xFF, g := (argb>>8)&0xFF, b := argb&0xFF
        total++

        ; Categorise by dominant channel
        if (b > r+30 && b > g+10 && b > 90)        ; sky-blue family
            skyR += r, skyG += g, skyB += b, skyCount++
        else if (g > r-20 && g > b+10 && g > 40)   ; green field family
            fieldR += r, fieldG += g, fieldB += b, fieldCount++
    }

    Gdip_UnlockBits(pBM, &bmpData), Gdip_DisposeImage(pBM)

    ; Build output
    report := "=== FieldGuard Calibration Results ===`n`n"

    if skyCount > 0 {
        avgSkyR := skyR // skyCount
        avgSkyG := skyG // skyCount
        avgSkyB := skyB // skyCount
        skyHex  := Format("0x{1:02X}{2:02X}{3:02X}", avgSkyR, avgSkyG, avgSkyB)
        report .= "Sky colour (off-field indicator):`n"
                . "  FG_SkyColorSample  := " skyHex "`n"
                . "  FG_SkyTolerance    := 45`n`n"
    } else {
        report .= "[No sky pixels found in sample — you may be fully on the field]`n`n"
    }

    if fieldCount > 0 {
        avgFR  := fieldR // fieldCount
        avgFG  := fieldG // fieldCount
        avgFB  := fieldB // fieldCount
        fldHex := Format("0x{1:02X}{2:02X}{3:02X}", avgFR, avgFG, avgFB)
        report .= "Field tile colour:`n"
                . "  FG_FieldColorSample := " fldHex "`n"
                . "  FG_FieldTolerance   := 40`n`n"
    }

    ; Screen-space region as percentages
    rx1 := (cx - w//2 - windowX) / windowWidth
    ry1 := (cy - h//2 - windowY) / windowHeight
    rx2 := (cx + w//2 - windowX) / windowWidth
    ry2 := (cy + h//2 - windowY) / windowHeight
    report .= "Sample region (FG_SampleRegionPct):`n"
            . "  [" Format("{:.2f}", rx1) ", " Format("{:.2f}", ry1)
            .  ", " Format("{:.2f}", rx2) ", " Format("{:.2f}", ry2) "]`n`n"
    report .= "Copy these values into FieldGuard.ahk global declarations."

    MsgBox report, "FieldGuard Calibration", 0x40000
}
