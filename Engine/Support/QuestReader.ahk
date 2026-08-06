; ================================================================
;  QuestReader.ahk  —  engine\support\
;  Uses RapidOCR (PaddleOCR-based) for reliable game-font reading.
;  Supports any resolution — coordinates scale from 800x600 base.
; ================================================================

#Include ..\..\lib\Pin.ahk
#Include ..\..\lib\TextRender.ahk

global BASE_W := 800, BASE_H := 600

global QUEST_OCR_BASE_X := 128
global QUEST_OCR_BASE_Y := 270
global QUEST_OCR_BASE_W := 200
global QUEST_OCR_BASE_H := 160

global RANK_OCR_BASE_X := 340
global RANK_OCR_BASE_Y := 120
global RANK_OCR_BASE_W := 300
global RANK_OCR_BASE_H := 40

; Recalibrated from actual OCR log data at 1920x1058 resolution.
; Slot 1 first-line ref-y≈286, Slot 2≈314, Slot 3≈341, Slot 4≈372.
; Old bands had Slot 3 starting at 347 so Slot 3 content (ref-y≈341) bled into Slot 2.
global QUEST_BANDS_800 := [[275, 308], [309, 336], [337, 367], [368, 425]]

; ── CRITICAL: persist TextRender so GC doesn't destroy the window ──
; TextRender creates a layered window. AHK ref-count calls
; __Delete -> DestroyWindow the moment the local var goes out of scope
; UNLESS a global holds the reference. g_ocrDebugRender is that ref.
global g_ocrDebugRender := 0
global g_ocrDebugRenderRank := 0

IsDebugMode() {
    global cfg
    try return cfg.Has("debugMode") ? !!cfg["debugMode"] : false
    return false
}

IsOcrLogEnabled() {
    global cfg
    try return cfg.Has("ocrLogEnabled") ? !!cfg["ocrLogEnabled"] : false
    return false
}

GetRobloxGeometry(hWnd) {
    WinGetClientPos(&cx, &cy, &cw, &ch, "ahk_id " hWnd)
    return {cx: cx, cy: cy, cw: cw, ch: ch,
            sx: cw / BASE_W, sy: ch / BASE_H}
}

ReadAllQuestSlots(hWnd) {
    global g_ocrDebugRender
    result := ["", "", "", ""]

    try {
        g := GetRobloxGeometry(hWnd)
    } catch {
        return result
    }

    ocrX := g.cx + Round(QUEST_OCR_BASE_X * g.sx)
    ocrY := g.cy + Round(QUEST_OCR_BASE_Y * g.sy)
    ocrW := Round(QUEST_OCR_BASE_W * g.sx)
    ocrH := Round(QUEST_OCR_BASE_H * g.sy)

    if IsDebugMode()
        try Pin(ocrX, ocrY, ocrX + ocrW, ocrY + ocrH, 3000, "b2 cYellow flash0")

    try {
        ocrObj := RapidOcr.FromRect(ocrX, ocrY, ocrW, ocrH)
    } catch as err {
        WriteOcrLog("ERROR: RapidOcr.FromRect failed — " err.Message)
        return result
    }

    if !ocrObj || !ocrObj.Lines.Length {
        WriteOcrLog("No lines returned from OCR")
        return result
    }

    WriteOcrLog("=== OCR CAPTURE ===")
    WriteOcrLog("Rect: " ocrX "," ocrY " " ocrW "x" ocrH)
    WriteOcrLog("Raw text: " ocrObj.text)

    if IsDebugMode()
        try g_ocrDebugRender := TextRender(
            ocrObj.text,
            "x" (ocrX + ocrW + 5) " y" ocrY " w400 t4000 s11"
        )

    bands := []
    for _, b in QUEST_BANDS_800
        bands.Push([g.cy + Round(b[1] * g.sy),
                    g.cy + Round(b[2] * g.sy)])

    slotText := ["", "", "", ""]
    for _, line in ocrObj.Lines {
        txt := Trim(line.text)
        WriteOcrLog("  Line y=" line.y " text=" txt)
        if !RegExMatch(txt, "[a-zA-Z]{2,}")
            continue
        ; Skip panel header/footer text that isn't a quest
        if RegExMatch(txt, "i)^(earn.{0,2}star|you\s+have|you\s+are|rank\s*\d+)")
            continue
        ly := line.y
        Loop 4 {
            b := bands[A_Index]
            if ly >= b[1] && ly <= b[2] {
                slotText[A_Index] .= (slotText[A_Index] = "" ? "" : " ") txt
                break
            }
        }
    }

    WriteOcrLog("--- Slot results ---")
    Loop 4 {
        result[A_Index] := NormalizeOCRText(Trim(slotText[A_Index]))
        WriteOcrLog("Slot " A_Index ": [" result[A_Index] "]")
    }
    WriteOcrLog("===================")

    return result
}

ReadCurrentRankText(hWnd) {
    global g_ocrDebugRenderRank

    try {
        g := GetRobloxGeometry(hWnd)
    } catch {
        return ""
    }

    ocrX := g.cx + Round(RANK_OCR_BASE_X * g.sx)
    ocrY := g.cy + Round(RANK_OCR_BASE_Y * g.sy)
    ocrW := Round(RANK_OCR_BASE_W * g.sx)
    ocrH := Round(RANK_OCR_BASE_H * g.sy)

    if IsDebugMode()
        try Pin(ocrX, ocrY, ocrX + ocrW, ocrY + ocrH, 3000, "b2 cCyan flash0")

    try {
        ocrObj := RapidOcr.FromRect(ocrX, ocrY, ocrW, ocrH)
    } catch as err {
        WriteOcrLog("ERROR: Rank RapidOcr.FromRect failed — " err.Message)
        return ""
    }

    if !ocrObj || !ocrObj.Lines.Length {
        WriteOcrLog("Rank OCR: no lines returned")
        return ""
    }

    WriteOcrLog("=== RANK OCR CAPTURE ===")
    WriteOcrLog("Rect: " ocrX "," ocrY " " ocrW "x" ocrH)
    WriteOcrLog("Raw text: " ocrObj.text)
    WriteOcrLog("========================")

    if IsDebugMode()
        try g_ocrDebugRenderRank := TextRender(
            ocrObj.text,
            "x" (ocrX + ocrW + 5) " y" (ocrY + ocrH + 10) " w400 t4000 s11 cCyan"
        )

    return ocrObj.text
}

NormalizeOCRText(text) {
    text := RegExReplace(text, "i)breake?b[a-z]*", "breakables")
    text := RegExReplace(text, "i)&mond|diam[o0]nd",  "diamond")
    text := RegExReplace(text, "i)su[^p]?[^e]?r",     "superior")
    text := RegExReplace(text, "i)\bni[nm]i\b",        "mini")
    text := RegExReplace(text, "i)\b[sc]t\s+area\b",   "best area")
    text := RegExReplace(text, "i)\bcorne[rt]\b",       "comet")
    return text
}

ExtractAmount(ocrText) {
    ocrText := RegExReplace(ocrText, "27 SO", "2750")
    ocrText := RegExReplace(ocrText, "\bS\b",  "5")
    ocrText := RegExReplace(ocrText, "\bSO\b", "50")
    ocrText := RegExReplace(ocrText, "\bSS\b", "55")

    if RegExMatch(ocrText, "\(x(\d+)\)", &m)
        return Integer(m[1])
    if RegExMatch(ocrText, "(\b\d+(?:\.\d+)?)[kK]\b", &m)
        return Round(Float(m[1]) * 1000)
    if RegExMatch(ocrText, "\b(\d[\d,]*)\b", &m)
        return Integer(StrReplace(m[1], ",", ""))
    return 1
}