; ================================================================
;  PS99 Macro  v1.0.0  —  Rank Quest Macro by Killericboy
; ================================================================

#Requires AutoHotkey v2.0
#SingleInstance Force
#MaxThreads 4

#Include ..\lib\Gdip_All.ahk
#Include ..\lib\Gdip_ImageSearch.ahk
#Include ..\lib\HyperSleep.ahk
#Include ..\lib\Roblox.ahk
#Include ..\lib\WebView2.ahk
#Include ..\lib\JSON.ahk
#Include ..\lib\RapidOCR.ahk
#Include support\QuestReader.ahk
#Include support\Quests.ahk
#Include support\Ranks.ahk
#Include support\Zones.ahk

SendMode "Event"
CoordMode "Mouse", "Client"
CoordMode "Pixel", "Client"

; ── Developer mode — set true here to force-enable the Dev tab ──
global DEV_MODE_FORCE := false

; ── Runtime state ─────────────────────────────────────────────
global running      := false
global paused       := false
global currentLoop  := 0
global currentZone  := 0
global currentArea  := "-"
global currentQuest := "-"
global currentAction:= "-"
global currentRank  := "-"
global loopStartTime:= 0
global lastReconnectTick := 0

global windowX := 0, windowY := 0, windowWidth := 0, windowHeight := 0

; ── Config ────────────────────────────────────────────────────
global cfg := Map(
    ; General
    "numberOfLoops",        20,
    "eggsAtOnce",           73,
    "delayModifier",        1.2,
    "eatFruit",             true,

    ; Quest star toggles
    "do1Star",              true,
    "do2Star",              true,
    "do3Star",              true,
    "do4Star",              true,

    ; Gamepasses
    "hasVip",               false,
    "hasAutoFarm",          false,
    "hasDoubleStars",       false,
    "hasShinyHoverboard",   false,

    ; Reconnect
    "reconnectAfterLoops",  true,
    "reconnectSeconds",     45,
    "privateServerCode",    "",

    ; Timing (seconds)
    "timePinata",           10,
    "timeLuckyBlock",       10,
    "timeCoinJar",          10,
    "timeComet",            10,
    "timeMiniChests",       30,
    "timeBreakables",       30,
    "timeDiamonds",         30,
    "timeSuperiorChests",   30,
    "timeDiamondBreak",     30,

    ; Zone boosts
    "useFlagBestZone",      true,
    "useSprinklerBestZone", true,

    ; Keybinds
    "keyLuckyBlock",        "l",
    "keyCoinJar",            "j",
    "keyComet",              "c",
    "keyPinata",             "p",
    "keySprinkler",          "r",
    "keyPartyBox",           "b",
    "keyQuestFlag",          "0",
    "keyFlagLastZone",       "z",
    "keyPotion3",            "3",
    "keyPotion4",            "4",
    "keyPotion5",            "5",

    ; Upgrade targets
    "petToGolden",          "Elegant Eagle",
    "petToRainbow",         "Elegant Eagle",
    "potionToUpgrade",      "Potion II",
    "enchantToUpgrade",     "Tap Power II",
    "potionsPerUpgrade",    4,
    "enchantsPerUpgrade",   5,
    "stdPetsForGolden",     10,
    "goldenPetsForRainbow", 10,
    "rareEggHatches",       5,

    ; Profile helpers
    "profileName",          "",
    "selectedProfile",      "",

    ; ── Developer settings ─────────────────────────────────────
    "debugMode",            false,   ; OCR overlay + Pin highlights
    "ocrLogEnabled",        true,    ; Write OCR text to ocr.log
    "debugLogEnabled",      true,    ; Write activity to debug.log
)

; ── Constants ─────────────────────────────────────────────────
MACRO_VERSION := "1.0.0"
JSON_PATH     := A_ScriptDir "\..\settings\profiles.json"
DEBUG_LOG_PATH := A_ScriptDir "\..\settings\debug.log"
OCR_LOG_PATH   := A_ScriptDir "\..\settings\ocr.log"
PS99_PLACE_ID := "8737899170"
BEST_ZONE     := 219
RARE_EGG_ZONE := 209
FLAG_ZONES    := [200, 201, 202, 203, 204]
UI_PATH       := SubStr(A_ScriptDir, 1, InStr(A_ScriptDir, "\",, -1) - 1) "\ui\index.html"

; ── Quest icons ───────────────────────────────────────────────
getSetting(key) {
    global cfg
    keyMap := Map(
        "HasGamepassVip",        "hasVip",
        "HasGamepassSuperDrops", "hasSuperDrops"
    )
    if !IsSet(cfg) || !keyMap.Has(key)
        return "false"
    return cfg[keyMap[key]] ? "true" : "false"
}

global QUEST_ICONS := Map(
    "7",    "💎",  "9",    "💎",  "14",   "🧪",  "15",   "✨",
    "20",   "🥚",  "21",   "🧱",  "31",   "🫙",  "33",   "🚩",
    "34-1", "🧪",  "34-2", "🧪",  "34-3", "🧪",  "35",   "🍎",
    "37",   "🫙",  "38",   "☄️",  "39",   "📦",  "40",   "🌟",
    "41",   "🌈",  "42",   "🌀",  "43",   "🎉",  "44",   "🍀",
    "66",   "📦",  "?",    "❓",  "wait", "⏳"
)

global questSlots := [
    Map("stars",1,"enabled",true,"questId","?","questName","Unknown","status","?","amount",1,"priority",0,"zone","-"),
    Map("stars",2,"enabled",true,"questId","?","questName","Unknown","status","?","amount",1,"priority",0,"zone","-"),
    Map("stars",3,"enabled",true,"questId","?","questName","Unknown","status","?","amount",1,"priority",0,"zone","-"),
    Map("stars",4,"enabled",true,"questId","?","questName","Unknown","status","?","amount",1,"priority",0,"zone","-"),
]

; ── Log buffer + file writing ──────────────────────────────────
global logLines := []

WriteDebugLog(msg) {
    global cfg, DEBUG_LOG_PATH
    if !cfg.Has("debugLogEnabled") || !cfg["debugLogEnabled"]
        return
    ts := FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss")
    try FileAppend "[" ts "] " msg "`n", DEBUG_LOG_PATH, "UTF-8"
}

WriteOcrLog(msg) {
    global cfg, OCR_LOG_PATH
    if !cfg.Has("ocrLogEnabled") || !cfg["ocrLogEnabled"]
        return
    ts := FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss")
    try FileAppend "[" ts "] " msg "`n", OCR_LOG_PATH, "UTF-8"
}

AddLog(msg) {
    global logLines
    ts := FormatTime(A_Now, "HH:mm:ss")
    line := "[" ts "] " msg
    logLines.Push(line)
    if logLines.Length > 50
        logLines.RemoveAt(1)
    JS('window.PS99.addLog("[' ts '] ' EscJ(msg) '")')
    WriteDebugLog(msg)
}

; ── WebView2 globals ──────────────────────────────────────────
global G        := 0
global wvc      := 0
global wv2      := 0
global wv2ready := false
global navToken := 0
global msgToken := 0

; ================================================================
;  GUI + WebView2 SETUP
; ================================================================
BuildGUI() {
    global G, wvc, wv2, wv2ready, navToken, msgToken, currentProfile

    G := Gui("+AlwaysOnTop -MaximizeBox", "PS99 Macro v" MACRO_VERSION " [" currentProfile "]")
    G.BackColor := "0d0a1a"
    G.OnEvent("Close", (*) => ExitApp())
    G.OnEvent("Size",  OnGuiSize)
    G.Show("w680 h520")

    global G_hwnd := G.Hwnd

    dllFolder := (A_PtrSize = 8) ? "\64bit\" : "\32bit\"
    wv2dll := A_ScriptDir dllFolder "WebView2Loader.dll"
    if !FileExist(wv2dll)
        wv2dll := A_ScriptDir "\WebView2Loader.dll"

    wvc := WebView2.create(G.Hwnd, , , , , , wv2dll)
    wv2 := wvc.CoreWebView2

    uiFile := "file:///" StrReplace(UI_PATH, "\", "/")
    wv2.Navigate(uiFile)

    navToken := wv2.add_NavigationCompleted(OnNavCompleted)
    msgToken := wv2.add_WebMessageReceived(OnWebMessage)

    iconFile := A_ScriptDir "\..\assets\logo.ico"
    if FileExist(iconFile) {
        TraySetIcon iconFile
        SendMessage 0x80, 0, DllCall("LoadImage","Ptr",0,"Str",iconFile,"UInt",1,"Int",16,"Int",16,"UInt",0x50),, "ahk_id " G.Hwnd
        SendMessage 0x80, 1, DllCall("LoadImage","Ptr",0,"Str",iconFile,"UInt",1,"Int",32,"Int",32,"UInt",0x50),, "ahk_id " G.Hwnd
    }

    G.Show()
}

OnGuiSize(GuiObj, MinMax, Width, Height) {
    global wvc
    if wvc && MinMax != -1
        wvc.Fill()
}

OnNavCompleted(sender, args) {
    global wv2ready, DEV_MODE_FORCE
    wv2ready := true
    PushStateToJS()
    JS_RefreshDetected()
    ; If DEV_MODE_FORCE is set in code, auto-unlock dev tab
    if DEV_MODE_FORCE
        JS("window.PS99.unlockDevTab()")
    ; Quest load is NOT triggered here — only on Start and Refresh buttons
}

OnWebMessage(sender, args) {
    raw := args.TryGetWebMessageAsString()
    if !raw
        return
    try {
        msg  := JSON.parse(raw)
        fn   := msg["cmd"]
        data := msg.Has("data") && msg["data"] != "" ? msg["data"] : ""
    } catch {
        colonPos := InStr(raw, ":")
        if colonPos {
            fn   := SubStr(raw, 1, colonPos - 1)
            data := SubStr(raw, colonPos + 1)
        } else {
            fn   := raw
            data := ""
        }
    }
    switch fn {
        case "Save":                 JS_Save(data)
        case "StartMacro":           StartMacro()
        case "PauseMacro":           PauseMacro()
        case "StopMacro":            StopMacro()
        case "RefreshQuests":        RefreshQuests()
        case "RefreshDetected":      JS_RefreshDetected()
        case "JoinServer":           JoinServer()
        case "TestReconnect":        DoReconnect()
        case "AddProfile":           AddProfile(data)
        case "LoadSelectedProfile":  LoadSelectedProfile(data)
        case "DeleteProfile":        DeleteProfile(data)
        case "SetQuestEnabled":      SetQuestEnabled(data)
        case "SaveDevSettings":      SaveDevSettings(data)
        case "ClearDebugLog":        ClearDebugLog()
        case "ClearOcrLog":          ClearOcrLog()
        case "CaptureRewardsButton": CaptureRewardsButton()
        case "UnlockDevTab":         ; JS-side only, no AHK action needed
    }
}

JS(script) {
    global wv2, wv2ready
    if wv2ready
        wv2.ExecuteScriptAsync(script)
}

EscJ(s) => StrReplace(StrReplace(StrReplace(s, "\", "\\"), '"', '\"'), "`n", "\n")

; ── Developer settings handler ────────────────────────────────
SaveDevSettings(data) {
    global cfg
    try cfg["debugMode"]       := data["debugMode"] ? 1 : 0
    try cfg["ocrLogEnabled"]   := data["ocrLogEnabled"] ? 1 : 0
    try cfg["debugLogEnabled"] := data["debugLogEnabled"] ? 1 : 0
    SaveProfile()
    AddLog("Dev settings saved — debugMode=" (cfg["debugMode"] ? "ON" : "OFF")
        . " ocrLog=" (cfg["ocrLogEnabled"] ? "ON" : "OFF")
        . " debugLog=" (cfg["debugLogEnabled"] ? "ON" : "OFF"))
}

ClearDebugLog() {
    global DEBUG_LOG_PATH
    try FileDelete DEBUG_LOG_PATH
    AddLog("debug.log cleared")
}

ClearOcrLog() {
    global OCR_LOG_PATH
    try FileDelete OCR_LOG_PATH
    AddLog("ocr.log cleared")
}

; ── Push all config state to JS ───────────────────────────────
PushStateToJS(*) {
    global cfg, currentProfile, wv2ready, DEV_MODE_FORCE
    if !wv2ready
        return

    profiles    := GetProfileList()
    profileJSON := "["
    for i, n in profiles
        profileJSON .= (i > 1 ? "," : "") '"' EscJ(n) '"'
    profileJSON .= "]"

    b(k) => cfg[k] ? "true" : "false"

    json := "{"
    json .= '"numberOfLoops":'        cfg["numberOfLoops"]        ","
    json .= '"eggsAtOnce":'           cfg["eggsAtOnce"]           ","
    json .= '"delayModifier":'        cfg["delayModifier"]        ","
    json .= '"eatFruit":'             b("eatFruit")               ","
    json .= '"do1Star":'              b("do1Star")                ","
    json .= '"do2Star":'              b("do2Star")                ","
    json .= '"do3Star":'              b("do3Star")                ","
    json .= '"do4Star":'              b("do4Star")                ","
    json .= '"hasVip":'               b("hasVip")                 ","
    json .= '"hasAutoFarm":'          b("hasAutoFarm")            ","
    json .= '"hasDoubleStars":'       b("hasDoubleStars")         ","
    json .= '"hasShinyHoverboard":'   b("hasShinyHoverboard")     ","
    json .= '"reconnectAfterLoops":'  b("reconnectAfterLoops")    ","
    json .= '"reconnectSeconds":'     cfg["reconnectSeconds"]     ","
    json .= '"privateServerCode":"'   EscJ(cfg["privateServerCode"]) '",'
    json .= '"useFlagBestZone":'      b("useFlagBestZone")        ","
    json .= '"useSprinklerBestZone":' b("useSprinklerBestZone")   ","
    json .= '"timePinata":'           cfg["timePinata"]           ","
    json .= '"timeLuckyBlock":'       cfg["timeLuckyBlock"]       ","
    json .= '"timeCoinJar":'          cfg["timeCoinJar"]          ","
    json .= '"timeComet":'            cfg["timeComet"]            ","
    json .= '"timeMiniChests":'       cfg["timeMiniChests"]       ","
    json .= '"timeBreakables":'       cfg["timeBreakables"]       ","
    json .= '"timeDiamonds":'         cfg["timeDiamonds"]         ","
    json .= '"timeSuperiorChests":'   cfg["timeSuperiorChests"]   ","
    json .= '"timeDiamondBreak":'     cfg["timeDiamondBreak"]     ","
    json .= '"keyLuckyBlock":"'       EscJ(cfg["keyLuckyBlock"])   '",'
    json .= '"keyCoinJar":"'          EscJ(cfg["keyCoinJar"])      '",'
    json .= '"keyComet":"'            EscJ(cfg["keyComet"])        '",'
    json .= '"keyPinata":"'           EscJ(cfg["keyPinata"])       '",'
    json .= '"keySprinkler":"'        EscJ(cfg["keySprinkler"])    '",'
    json .= '"keyPartyBox":"'         EscJ(cfg["keyPartyBox"])     '",'
    json .= '"keyQuestFlag":"'        EscJ(cfg["keyQuestFlag"])    '",'
    json .= '"keyFlagLastZone":"'     EscJ(cfg["keyFlagLastZone"]) '",'
    json .= '"keyPotion3":"'          EscJ(cfg["keyPotion3"])      '",'
    json .= '"keyPotion4":"'          EscJ(cfg["keyPotion4"])      '",'
    json .= '"keyPotion5":"'          EscJ(cfg["keyPotion5"])      '",'
    json .= '"petToGolden":"'         EscJ(cfg["petToGolden"])     '",'
    json .= '"petToRainbow":"'        EscJ(cfg["petToRainbow"])    '",'
    json .= '"potionToUpgrade":"'     EscJ(cfg["potionToUpgrade"]) '",'
    json .= '"enchantToUpgrade":"'    EscJ(cfg["enchantToUpgrade"])    '",'
    json .= '"potionsPerUpgrade":'    cfg["potionsPerUpgrade"]     ","
    json .= '"enchantsPerUpgrade":'   cfg["enchantsPerUpgrade"]    ","
    json .= '"stdPetsForGolden":'     cfg["stdPetsForGolden"]      ","
    json .= '"goldenPetsForRainbow":' cfg["goldenPetsForRainbow"]  ","
    json .= '"rareEggHatches":'       cfg["rareEggHatches"]        ","
    json .= '"profiles":'             profileJSON                  ","
    json .= '"currentProfile":"'      EscJ(currentProfile)         '",'
    ; Developer settings
    json .= '"debugMode":'            b("debugMode")               ","
    json .= '"ocrLogEnabled":'        b("ocrLogEnabled")           ","
    json .= '"debugLogEnabled":'      b("debugLogEnabled")         ","
    json .= '"devModeForce":'         (DEV_MODE_FORCE ? "true" : "false")
    json .= "}"

    JS("window.PS99.loadState(" json ")")
    PushQuestSlots()
}

PushQuestSlots() {
    global questSlots
    arr := "["
    for i, slot in questSlots {
        icon     := QUEST_ICONS.Has(slot["questId"]) ? QUEST_ICONS[slot["questId"]] : "❓"
        amount   := slot.Has("amount")   ? slot["amount"]   : 1
        priority := slot.Has("priority") ? slot["priority"] : 0
        zone     := slot.Has("zone")     ? slot["zone"]     : "-"
        arr .= (i > 1 ? "," : "") "{"
        arr .= '"stars":'    slot["stars"] ","
        arr .= '"enabled":'  (slot["enabled"] ? "true" : "false") ","
        arr .= '"questId":"'   EscJ(slot["questId"])   '",'
        arr .= '"questName":"' EscJ(slot["questName"]) '",'
        arr .= '"icon":"'      EscJ(icon)               '",'
        arr .= '"status":"'    EscJ(slot["status"])     '",'
        arr .= '"amount":'     amount                    ","
        arr .= '"priority":'   priority                  ","
        arr .= '"zone":"'      EscJ(zone)                '"'
        arr .= "}"
    }
    arr .= "]"
    JS("window.PS99.loadQuestSlots(" arr ")")
}

SetCurrentActivity() {
    global currentLoop, cfg, currentZone, currentArea, currentQuest, currentAction, currentRank
    loopStr := currentLoop "/" cfg["numberOfLoops"]
    JS('window.PS99.setActivity("' EscJ(loopStr) '","' EscJ(String(currentZone)) '","' EscJ(currentArea) '","' EscJ(currentQuest) '","' EscJ(currentAction) '","' EscJ(currentRank) '")')
}

; ── Roblox install type detection ─────────────────────────────
DetectRobloxInstallType() {
    local A_LocalAppData := EnvGet("LOCALAPPDATA")
    cmd := ""
    for regKey in [
        "HKCU\SOFTWARE\Classes\roblox-player\shell\open\command",
        "HKCU\SOFTWARE\Classes\roblox\shell\open\command",
        "HKCR\roblox-player\shell\open\command",
        "HKCR\roblox\shell\open\command"
    ] {
        try {
            cmd := RegRead(regKey)
            if cmd != ""
                break
        }
    }
    if cmd != "" {
        if InStr(cmd, "Bloxstrap",, 1)
            return "Bloxstrap"
        if InStr(cmd, "WindowsApps",, 1)
            return "UWP / Store"
        if InStr(cmd, "RobloxPlayer",, 1) || InStr(cmd, "RobloxStudio",, 1)
            return "Web Version"
    }
    if FileExist(A_LocalAppData "\Bloxstrap\Bloxstrap.exe")
        return "Bloxstrap"
    if DirExist(A_LocalAppData "\Roblox\Versions")
        return "Web Version"
    try {
        loop files A_ProgramFiles "\WindowsApps\ROBLOX*", "D"
            return "UWP / Store"
    }
    return ""
}

JS_RefreshDetected() {
    installType := DetectRobloxInstallType()
    isRunning   := (GetRobloxHWND() != 0)
    if installType = "" {
        JS('window.PS99.setDetected("Not detected", false)')
        return
    }
    label := installType (isRunning ? " ●" : "")
    JS('window.PS99.setDetected("' EscJ(label) '", true)')
}

DetectionTick() {
    global wv2ready
    if wv2ready
        JS_RefreshDetected()
}

SetTimer(DetectionTick, 2000)

JS_Save(data) {
    global cfg
    ParseJSONIntoCfg(data)
    SaveProfile()
}

ParseJSONIntoCfg(json) {
    global cfg
    ; If AHK passed a parsed Map (from JSON.parse in OnWebMessage), stringify it back
    if json is Map
        json := JSON.stringify(json)
    for key in ["numberOfLoops","eggsAtOnce","reconnectSeconds","potionsPerUpgrade",
                "enchantsPerUpgrade","stdPetsForGolden","goldenPetsForRainbow","rareEggHatches",
                "timePinata","timeLuckyBlock","timeCoinJar","timeComet","timeMiniChests",
                "timeBreakables","timeDiamonds","timeSuperiorChests","timeDiamondBreak"] {
        if RegExMatch(json, '"' key '"\s*:\s*([\d.]+)', &m)
            cfg[key] := IsInteger(m[1]) ? Integer(m[1]) : Float(m[1])
    }
    for key in ["delayModifier"] {
        if RegExMatch(json, '"' key '"\s*:\s*([\d.]+)', &m)
            cfg[key] := Float(m[1])
    }
    for key in ["eatFruit","do1Star","do2Star","do3Star","do4Star",
                "hasVip","hasAutoFarm","hasDoubleStars","hasShinyHoverboard",
                "reconnectAfterLoops","useFlagBestZone","useSprinklerBestZone",
                "debugMode","ocrLogEnabled","debugLogEnabled"] {
        if RegExMatch(json, '"' key '"\s*:\s*(true|false)', &m)
            cfg[key] := (m[1] = "true")
    }
    for key in ["privateServerCode","keyLuckyBlock","keyCoinJar","keyComet","keyPinata",
                "keySprinkler","keyPartyBox","keyQuestFlag","keyFlagLastZone",
                "keyPotion3","keyPotion4","keyPotion5",
                "petToGolden","petToRainbow","potionToUpgrade","enchantToUpgrade",
                "profileName","selectedProfile"] {
        if RegExMatch(json, '"' key '"\s*:\s*"((?:[^"\\]|\\.)*)"', &m)
            cfg[key] := StrReplace(StrReplace(m[1], '\"', '"'), "\\", "\")
    }
}

; ================================================================
;  GENERIC IMAGE-BASED BUTTON DETECTION
; ================================================================
; Any button can be detected+clicked by giving ClickImageButton() an
; image name that lives in Assets\Detection\<name>.png. It tries, in order:
;   1) GDIP template match against a live screenshot of the Roblox window
;   2) a pixel-color scan (optional — pass one or more colors)
;   3) a hardcoded 800x600-base fallback coordinate (optional)
; ----------------------------------------------------------------

; Root folder for all detection template images.
DetectionAssetDir() {
    return A_ScriptDir "\..\Assets\Detection"
}

; Searches for a needle image on screen within the Roblox client area.
; Returns true and sets foundX/foundY (SCREEN coordinates) to the
; matched button's centre if found.
FindImageOnScreen(needleFile, &foundX, &foundY, variation := 15) {
    foundX := 0, foundY := 0
    hWnd := GetRobloxHWND()
    if !hWnd || !FileExist(needleFile)
        return false

    WinGetClientPos(&cx, &cy, &cw, &ch, "ahk_id " hWnd)
    pBitmapH := Gdip_BitmapFromScreen(cx "|" cy "|" cw "|" ch)
    pBitmapN := Gdip_CreateBitmapFromFile(needleFile)
    if !pBitmapH || !pBitmapN {
        try Gdip_DisposeImage(pBitmapH)
        try Gdip_DisposeImage(pBitmapN)
        return false
    }

    nW := Gdip_GetImageWidth(pBitmapN)
    nH := Gdip_GetImageHeight(pBitmapN)
    found := Gdip_ImageSearch(pBitmapH, pBitmapN, &outList, 0, 0, 0, 0, variation, , 1)
    Gdip_DisposeImage(pBitmapH)
    Gdip_DisposeImage(pBitmapN)

    if found > 0 && outList != "" {
        parts := StrSplit(outList, ",")
        foundX := cx + Integer(parts[1]) + nW // 2
        foundY := cy + Integer(parts[2]) + nH // 2
        return true
    }
    return false
}

; ── Common detect-and-click helper ──────────────────────────────
ClickImageButton(imageName, fallbackX := "", fallbackY := "", variation := 15, fallbackColors := "", searchX1 := 0, searchY1 := 0, searchX2 := 0, searchY2 := 0) {
    hWnd := GetRobloxHWND()
    if !hWnd {
        WriteDebugLog("ClickImageButton(" imageName "): Roblox not found")
        return false
    }

    WinGetClientPos(&cx, &cy, &cw, &ch, "ahk_id " hWnd)
    sx := cw / 800, sy := ch / 600
    needleFile := DetectionAssetDir() "\" imageName ".png"

    ; 1. GDIP image search (screen coords, since FindImageOnScreen returns screen coords)
    if FindImageOnScreen(needleFile, &bx, &by, variation) {
        WriteDebugLog("ClickImageButton(" imageName "): image match at " bx "," by)
        CoordMode "Mouse", "Screen"
        Click bx, by
        CoordMode "Mouse", "Client"
        return true
    }

    ; 2. Pixel colour scan fallback (screen coords)
    if fallbackColors != "" {
        colors := (fallbackColors is Array) ? fallbackColors : [fallbackColors]
        x1 := cx + Round((searchX1 ? searchX1 : 0) * sx)
        y1 := cy + Round((searchY1 ? searchY1 : 0) * sy)
        x2 := cx + Round((searchX2 ? searchX2 : 800) * sx)
        y2 := cy + Round((searchY2 ? searchY2 : 600) * sy)
        CoordMode "Pixel", "Screen"
        for col in colors {
            if PixelSearch(&fx, &fy, x1, y1, x2, y2, col, 25) {
                WriteDebugLog("ClickImageButton(" imageName "): pixel match at " fx "," fy)
                CoordMode "Pixel", "Client"
                CoordMode "Mouse", "Screen"
                Click fx, fy
                CoordMode "Mouse", "Client"
                return true
            }
        }
        CoordMode "Pixel", "Client"
    }

    ; 3. Hardcoded fallback — client-relative coords (Mouse is Client by default)
    if fallbackX != "" && fallbackY != "" {
        WriteDebugLog("ClickImageButton(" imageName "): using fallback client coords")
        Click Round(fallbackX * sx), Round(fallbackY * sy)
        return true
    }

    WriteDebugLog("ClickImageButton(" imageName "): no detection method succeeded")
    return false
}

; Captures a region of the Roblox window (800x600-base ref coords) and
; saves it as Assets\Detection\<name>.png, for later use with ClickImageButton().
CaptureButtonImage(name, refX, refY, refW, refH) {
    hWnd := GetRobloxHWND()
    if !hWnd {
        AddLog("CaptureButtonImage: Roblox not found")
        return false
    }
    WinGetClientPos(&cx, &cy, &cw, &ch, "ahk_id " hWnd)
    sx := cw / 800, sy := ch / 600
    capX := cx + Round(refX * sx), capY := cy + Round(refY * sy)
    capW := Round(refW * sx),      capH := Round(refH * sy)
    pBitmap := Gdip_BitmapFromScreen(capX "|" capY "|" capW "|" capH)
    assetDir := DetectionAssetDir()
    if !DirExist(assetDir)
        DirCreate assetDir
    Gdip_SaveBitmapToFile(pBitmap, assetDir "\" name ".png")
    Gdip_DisposeImage(pBitmap)
    AddLog("Saved image: Assets\Detection\" name ".png")
    return true
}

; ── Rank Rewards button now uses the common helper ───────────────
; Template lives at Assets\Detection\rewardbutton.png
FindAndClickRewardsButton(hWnd) {
    ClickImageButton("rewardbutton", 706, 425, 15,
        [0x4BBF26, 0x56CC2A, 0x22C55E, 0x3CB849, 0x62C935, 0x4CAF50],
        450, 300, 800, 520)
}

CaptureRewardsButton() {
    ; Captures the area where the Rewards button usually sits (ref 610,380 170x70)
    CaptureButtonImage("rewardbutton", 610, 380, 170, 70)
    JS('window.PS99.addLog("[DEV] Rewards button image saved → Assets\\Detection\\rewardbutton.png")')
}

; ================================================================
;  ROBLOX HELPERS
; ================================================================
ResizeRoblox() {
    try {
        hWnd := WinGetID("ahk_exe RobloxPlayerBeta.exe")
    } catch {
        AddLog("ResizeRoblox: Roblox not found")
        return
    }
    WinRestore hWnd
    WinMove 0, 0, 800, 600, hWnd
    Sleep 300
}

; ================================================================
;  PIXEL / TIMING HELPERS
; ================================================================
Delay(sec) {
    global cfg
    return Integer(sec * cfg["delayModifier"] * 1000)
}

WaitSec(sec) => HyperSleep(Delay(sec))

LoopMs(ms) {
    global running, paused
    elapsed := 0
    while elapsed < ms {
        if !running
            return
        while paused {
            if !running
                return
            Sleep 50
        }
        HyperSleep(500)
        elapsed += 500
    }
}

PixelIs(x, y, color, tol := 2) {
    return PixelSearch(&_x, &_y, x, y, x, y, color, tol)
}

PixelFind(x1, y1, x2, y2, color, tol := 5, &fx := 0, &fy := 0) {
    return PixelSearch(&fx, &fy, x1, y1, x2, y2, color, tol)
}

IsDisconnected() {
    ActivateRoblox()
    return !PixelIs(81, 24, 0xFFFFFF, 2)
}

CheckConnection() {
    if IsDisconnected() {
        AddLog("⚠ Disconnection detected — reconnecting")
        DoReconnect()
    }
}

; ================================================================
;  ZONE NAVIGATION
; ================================================================
TeleportToZone(zoneId) {
    global currentZone
    if currentZone = zoneId
        return
    AddLog("Teleporting to zone " zoneId)
    ActivateRoblox()
    Send "t"
    HyperSleep(800)
    Send "^a"
    Send zoneId
    HyperSleep(600)
    Send "{Enter}"
    HyperSleep(2500)
    currentZone := zoneId
    SetCurrentActivity()
}

UseZoneBoosts() {
    global cfg
    ActivateRoblox()
    if cfg["useFlagBestZone"] {
        Send cfg["keyFlagLastZone"]
        HyperSleep(300)
    }
    if cfg["useSprinklerBestZone"] {
        Send cfg["keySprinkler"]
        HyperSleep(300)
    }
}

GoToBestZone() {
    global currentArea, cfg
    TeleportToZone(BEST_ZONE)
    currentArea := "Best Zone"
    SetCurrentActivity()
    if cfg["hasAutoFarm"] {
        Send "e"
        HyperSleep(300)
    }
    UseZoneBoosts()
}

; ================================================================
;  RANK READING
; ================================================================
DetectCurrentRank() {
    global currentRank
    hWnd := GetRobloxHWND()
    if !hWnd
        return
    text := ReadCurrentRankText(hWnd)
    if text = "" {
        currentRank := "-"
        return
    }
    details := getRankDetails(text)
    currentRank := (details.rankNumber != "-") ? ("#" details.rankNumber " " details.rankName) : "-"
    WriteDebugLog("Detected rank: " currentRank " (raw: " text ")")
    SetCurrentActivity()
}

; ================================================================
;  QUEST READING
; ================================================================
MatchQuestId(ocrText) {
    for questId, questItem in QUEST_DATA {
        if questItem["Regex"] != "" && RegExMatch(ocrText, questItem["Regex"])
            return questId
    }
    return "?"
}

RefreshQuests(*) {
    global questSlots, cfg, wv2ready, G_hwnd
    if !wv2ready
        return

    AddLog("Refreshing quests...")

    ; Minimize macro window so it doesn't cover the Roblox quest panel during OCR
    WinMinimize "ahk_id " G_hwnd
    Sleep 250

    ActivateRoblox()
    CloseAll()

    hWnd := GetRobloxHWND()
    if hWnd = 0 {
        WinRestore "ahk_id " G_hwnd
        AddLog("Roblox not found")
        return
    }

    FindAndClickRewardsButton(hWnd)
    Sleep 750

    DetectCurrentRank()

    rawTexts := ReadAllQuestSlots(hWnd)

    CloseAll()

    ; Restore macro window now that scan is complete
    WinRestore "ahk_id " G_hwnd
    Sleep 150

    starToggles := [cfg["do1Star"], cfg["do2Star"], cfg["do3Star"], cfg["do4Star"]]
    multiplier  := cfg["hasDoubleStars"] ? 2 : 1

    Loop 4 {
        slot := questSlots[A_Index]
        slot["stars"]   := A_Index * multiplier
        slot["enabled"] := starToggles[A_Index]

        ocrText := rawTexts[A_Index]

        if ocrText != "" {
            id       := MatchQuestId(ocrText)
            data     := QUEST_DATA.Has(id) ? QUEST_DATA[id] : QUEST_DATA.Default
            icon     := QUEST_ICONS.Has(id) ? QUEST_ICONS[id] : "❓"
            slot["questId"]   := id
            slot["questName"] := data["Name"]
            slot["icon"]      := icon
            slot["status"]    := data["Status"]
            slot["zone"]      := data["Zone"]
            ; Quests 40/41 go to best egg zone, not Void world — correct display
            if (id = "40" || id = "41")
                slot["zone"] := "Best"
            slot["priority"]  := QUEST_PRIORITY.Has(id) ? QUEST_PRIORITY[id] : 0
            slot["amount"]    := ExtractAmount(ocrText)
            AddLog("Slot " A_Index ": [" id "] " data["Name"] " ×" slot["amount"])
        } else {
            slot["questId"]   := "?"
            slot["questName"] := "Unknown"
            slot["icon"]      := "❓"
            slot["status"]    := "?"
            slot["zone"]      := "-"
            slot["priority"]  := 0
            slot["amount"]    := 1
        }
        questSlots[A_Index] := slot
    }

    CloseAll()
    PushQuestSlots()
    AddLog("Quest refresh complete")
}

SetQuestEnabled(data) {
    global questSlots, cfg
    if RegExMatch(data, "(\d):(\w+)", &m) {
        idx := Integer(m[1])
        enabled := (m[2] = "true")
        if idx >= 1 && idx <= 4
            questSlots[idx]["enabled"] := enabled
        cfg["do" idx "Star"] := enabled
        SaveProfile()
    }
}

; ================================================================
;  ITEM USE HELPERS
; ================================================================
UseKey(keybind) {
    if !keybind
        return false
    ActivateRoblox()
    Send keybind
    HyperSleep(400)
    if PixelFind(434, 287, 438, 291, 0xFFB436, 5) {
        Send "{Escape}"
        HyperSleep(300)
        return false
    }
    return true
}

OpenInventory() {
    ActivateRoblox()
    Send "i"
    HyperSleep(700)
}

CloseAll() {
    ActivateRoblox()
    hWnd := GetRobloxHWND()
    if hWnd {
        WinGetClientPos(,, &cw, &ch, "ahk_id " hWnd)
        x1 := Round(590 * cw / 800), y1 := Round(100 * ch / 600)
        x2 := Round(760 * cw / 800), y2 := Round(125 * ch / 600)
    } else {
        x1 := 590, y1 := 100, x2 := 760, y2 := 125
    }
    Loop 5 {
        if PixelFind(x1, y1, x2, y2, 0xFF155F, 5, &fx, &fy) {
            Click fx, fy
            HyperSleep(250)
        } else {
            break
        }
    }
}

; ================================================================
;  QUEST HANDLERS
; ================================================================
QuestEarnDiamonds() {
    GoToBestZone()
    currentAction := "Earning Diamonds"
    SetCurrentActivity()
    LoopMs(Delay(cfg["timeDiamonds"]))
}

QuestDiamondBreakables() {
    GoToBestZone()
    currentAction := "Breaking Diamond Breakables"
    SetCurrentActivity()
    LoopMs(Delay(cfg["timeDiamondBreak"]))
}

QuestCollectPotions(amount) {
    GoToBestZone()
    currentAction := "Collecting Potions"
    SetCurrentActivity()
    AddLog("Upgrading " amount " times with " cfg["potionToUpgrade"])
    Send "e"
    HyperSleep(1000)
    Loop amount {
        if !running
            break
        Send "{Enter}"
        HyperSleep(400)
    }
    CloseAll()
}

QuestCollectEnchants(amount) {
    GoToBestZone()
    currentAction := "Collecting Enchants"
    SetCurrentActivity()
    Send "e"
    HyperSleep(1000)
    Loop amount {
        if !running
            break
        Send "{Enter}"
        HyperSleep(400)
    }
    CloseAll()
}

QuestHatchBestEgg(amount) {
    global cfg, currentArea
    TeleportToZone(BEST_ZONE)
    currentArea   := "Best Egg"
    currentAction := "Hatching Best Egg"
    SetCurrentActivity()

    ActivateRoblox()
    Send "{d down}"
    HyperSleep(Delay(1))
    Send "{d up}"
    Send "f"
    HyperSleep(800)

    hatchesNeeded := Ceil(amount / cfg["eggsAtOnce"])
    AddLog("Hatching " amount " pets — " hatchesNeeded " hatches")

    Loop hatchesNeeded {
        if !running
            break
        currentAction := "Hatching Best Egg (" A_Index "/" hatchesNeeded ")"
        SetCurrentActivity()
        Click 191, 451
        HyperSleep(Delay(3))
        LoopMs(2000)
        CheckConnection()
    }
    CloseAll()
}

QuestBreakBreakables() {
    GoToBestZone()
    currentAction := "Breaking Breakables"
    SetCurrentActivity()
    LoopMs(Delay(cfg["timeBreakables"]))
}

QuestUseFlags(amount) {
    global currentArea
    flagsUsed := 0
    for zoneId in FLAG_ZONES {
        if !running
            break
        TeleportToZone(zoneId)
        currentArea   := "Flag Zone " zoneId
        currentAction := "Using Flags (" flagsUsed "/" amount ")"
        SetCurrentActivity()
        Loop 8 {
            Click 300 + A_Index*30, 330
            HyperSleep(80)
        }
        Loop {
            if !running || flagsUsed >= amount
                break
            if !UseKey(cfg["keyQuestFlag"])
                break
            flagsUsed++
            currentAction := "Using Flags (" flagsUsed "/" amount ")"
            SetCurrentActivity()
        }
        CloseAll()
        if flagsUsed >= amount
            break
    }
    AddLog("Used " flagsUsed "/" amount " flags")
}

QuestUsePotions(questId, amount) {
    keybind := (questId = "34-1") ? cfg["keyPotion3"]
             : (questId = "34-2") ? cfg["keyPotion4"]
             : cfg["keyPotion5"]
    ActivateRoblox()
    Loop amount {
        if !running
            break
        currentAction := "Using Potions (" A_Index "/" amount ")"
        SetCurrentActivity()
        Send keybind
        HyperSleep(500)
    }
    AddLog("Used " amount " potions")
}

QuestEatFruit(amount) {
    fruits := ["Apple","Banana","Orange","Pineapple","Rainbow Fruit","Watermelon"]
    perFruit := Ceil(amount / 6)
    for fruit in fruits {
        if !running
            break
        currentAction := "Eating Fruit — " fruit
        SetCurrentActivity()
        OpenInventory()
        Click 418, 154
        HyperSleep(200)
        Send "^a"
        Send fruit
        HyperSleep(600)
        Loop perFruit {
            if !running
                break
            Click "Right", 200, 280
            HyperSleep(200)
            Click 200, 340
            HyperSleep(300)
        }
        CloseAll()
    }
}

QuestBreakCoinJars(amount) {
    GoToBestZone()
    Loop amount {
        if !running
            break
        currentAction := "Breaking Coin Jars (" A_Index "/" amount ")"
        SetCurrentActivity()
        if !UseKey(cfg["keyCoinJar"])
            break
        LoopMs(Delay(cfg["timeCoinJar"]))
    }
}

QuestBreakComets(amount) {
    GoToBestZone()
    Loop amount {
        if !running
            break
        currentAction := "Breaking Comets (" A_Index "/" amount ")"
        SetCurrentActivity()
        if !UseKey(cfg["keyComet"])
            break
        deadline := DateAdd(A_Now, cfg["timeComet"], "Seconds")
        Loop {
            if A_Now > deadline || !running
                break
            if PixelFind(140, 280, 660, 400, 0x00A6FB, 5, &fx, &fy)
                Click fx, fy
            HyperSleep(50)
        }
    }
}

QuestBreakMiniChests() {
    GoToBestZone()
    currentAction := "Breaking Mini-Chests"
    SetCurrentActivity()
    LoopMs(Delay(cfg["timeMiniChests"]))
}

QuestBreakSuperiorChests() {
    GoToBestZone()
    currentAction := "Breaking Superior Mini-Chests"
    SetCurrentActivity()
    LoopMs(Delay(cfg["timeSuperiorChests"]))
}

QuestMakeGoldenPets(amount) {
    GoToBestZone()
    currentAction := "Making Golden Pets (×" amount ")"
    SetCurrentActivity()
    Send "e"
    HyperSleep(1000)
    Loop amount {
        if !running
            break
        Click 400, 300
        HyperSleep(500)
    }
    CloseAll()
}

QuestMakeRainbowPets(amount) {
    GoToBestZone()
    currentAction := "Making Rainbow Pets (×" amount ")"
    SetCurrentActivity()
    Send "e"
    HyperSleep(1000)
    Loop amount {
        if !running
            break
        Click 400, 300
        HyperSleep(500)
    }
    CloseAll()
}

QuestHatchRarePet() {
    global currentArea
    TeleportToZone(RARE_EGG_ZONE)
    currentArea   := "Rare Egg Zone"
    currentAction := "Hatching Rare Eggs"
    SetCurrentActivity()
    Send "f"
    HyperSleep(800)
    Loop cfg["rareEggHatches"] {
        if !running
            break
        currentAction := "Hatching Rare Egg (" A_Index "/" cfg["rareEggHatches"] ")"
        SetCurrentActivity()
        Click 191, 451
        HyperSleep(Delay(3))
        LoopMs(2000)
    }
    CloseAll()
}

QuestBreakPinatas(amount) {
    GoToBestZone()
    Loop amount {
        if !running
            break
        currentAction := "Breaking Piñatas (" A_Index "/" amount ")"
        SetCurrentActivity()
        if !UseKey(cfg["keyPinata"])
            break
        deadline := DateAdd(A_Now, cfg["timePinata"], "Seconds")
        Loop {
            if A_Now > deadline || !running
                break
            if PixelFind(140, 200, 660, 400, 0xFF00FF, 5, &fx, &fy)
                Click fx, fy
            HyperSleep(50)
        }
    }
}

QuestBreakLuckyBlocks(amount) {
    GoToBestZone()
    Loop amount {
        if !running
            break
        currentAction := "Breaking Lucky Blocks (" A_Index "/" amount ")"
        SetCurrentActivity()
        if !UseKey(cfg["keyLuckyBlock"])
            break
        deadline := DateAdd(A_Now, cfg["timeLuckyBlock"], "Seconds")
        Loop {
            if A_Now > deadline || !running
                break
            if PixelFind(140, 0, 660, 400, 0xEFB4FB, 5, &fx, &fy)
                Click fx, fy
            else if PixelFind(140, 280, 660, 400, 0x00ACFF, 5, &fx, &fy)
                Click fx, fy
            else if PixelFind(140, 280, 660, 400, 0xFFA300, 5, &fx, &fy)
                Click fx, fy
            HyperSleep(50)
        }
    }
}

EatFruitBonus() {
    global cfg
    if !cfg["eatFruit"]
        return
    AddLog("Eating fruit (bonus)")
    fruits := ["Apple","Banana","Orange","Pineapple","Rainbow Fruit","Watermelon"]
    for fruit in fruits {
        if !running
            break
        OpenInventory()
        Click 418, 154
        HyperSleep(200)
        Send "^a"
        Send fruit
        HyperSleep(600)
        Click "Right", 200, 280
        HyperSleep(200)
        Click 200, 340
        HyperSleep(300)
        CloseAll()
    }
}

DoQuest(questId, questName, amount := 1) {
    global currentQuest
    currentQuest  := questName
    SetCurrentActivity()
    AddLog("▶ Quest: " questName " ×" Round(amount, 0))

    switch questId {
        case "7":    QuestEarnDiamonds()
        case "9":    QuestDiamondBreakables()
        case "14":   QuestCollectPotions(amount)
        case "15":   QuestCollectEnchants(amount)
        case "20":   QuestHatchBestEgg(amount)
        case "21":   QuestBreakBreakables()
        case "33":   QuestUseFlags(amount)
        case "34-1",
             "34-2",
             "34-3":  QuestUsePotions(questId, amount)
        case "35":   QuestEatFruit(amount)
        case "37":   QuestBreakCoinJars(amount)
        case "38":   QuestBreakComets(amount)
        case "39":   QuestBreakMiniChests()
        case "40":   QuestMakeGoldenPets(amount)
        case "41":   QuestMakeRainbowPets(amount)
        case "42":   QuestHatchRarePet()
        case "43":   QuestBreakPinatas(amount)
        case "44":   QuestBreakLuckyBlocks(amount)
        case "66":   QuestBreakSuperiorChests()
        default:
            currentAction := "Waiting for Quest"
            SetCurrentActivity()
            LoopMs(5000)
    }
}

; ================================================================
;  RECONNECT
; ================================================================
JoinServer(*) {
    global cfg, PS99_PLACE_ID
    code := Trim(cfg["privateServerCode"])
    url  := "roblox://experiences/start?placeId=" PS99_PLACE_ID
    if code != ""
        url .= "&linkCode=" code
    try Run url
}

DoReconnect(*) {
    global running, lastReconnectTick, cfg
    lastReconnectTick := A_TickCount
    if running
        StopMacro()
    HyperSleep(500)
    AddLog("Reconnecting to PS99...")
    JoinServer()
    AddLog("Waiting " cfg["reconnectSeconds"] "s for game to load...")
    Sleep cfg["reconnectSeconds"] * 1000
    ActivateRoblox()
    CloseAll()
}

; ================================================================
;  STATS UPDATER
; ================================================================
UpdateStats() {
    global running, loopStartTime, currentLoop, cfg
    if !running
        return
    elapsed := A_TickCount - loopStartTime
    m := Format("{:02}", Floor(elapsed / 60000))
    s := Format("{:02}", Floor(Mod(elapsed / 1000, 60)))
    JS('window.PS99.setStats("' m ':' s ' | Loop ' currentLoop '/' cfg["numberOfLoops"] '")')
}

; ================================================================
;  MACRO LIFECYCLE
; ================================================================
StartMacro(*) {
    global running, paused, loopStartTime, currentLoop, currentZone
    if running
        return
    if !GetRobloxClientPos() {
        MsgBox "Roblox window not found.", "PS99 Macro", 0x40030
        return
    }
    running        := true
    paused         := false
    currentLoop    := 0
    currentZone    := 0
    loopStartTime  := A_TickCount

    JS('window.PS99.setStatus("RUNNING")')
    JS('window.PS99.setPauseBtn("⏸  Pause  (F8)")')
    AddLog("Macro started")

    SetTimer UpdateStats, 500
    ; Refresh quests NOW on Start
    RefreshQuests()
    SetTimer MacroLoop, -1
}

PauseMacro(*) {
    global running, paused
    if !running
        return
    paused := !paused
    if paused {
        JS('window.PS99.setStatus("PAUSED")')
        JS('window.PS99.setPauseBtn("▶  Resume  (F8)")')
        AddLog("Paused")
    } else {
        JS('window.PS99.setStatus("RUNNING")')
        JS('window.PS99.setPauseBtn("⏸  Pause  (F8)")')
        ActivateRoblox()
        AddLog("Resumed")
    }
}

StopMacro(*) {
    global running, paused, currentQuest, currentAction
    running       := false
    paused        := false
    currentQuest  := "-"
    currentAction := "-"
    SetTimer UpdateStats, 0
    JS('window.PS99.setStatus("STOPPED")')
    JS('window.PS99.setPauseBtn("⏸  Pause  (F8)")')
    JS('window.PS99.setStats("-")')
    SetCurrentActivity()
    AddLog("Macro stopped")
}

MacroLoop() {
    global running, paused, currentLoop, cfg, questSlots

    AddLog("Entering quest loop")

    Loop cfg["numberOfLoops"] {
        if !running
            break
        while paused {
            if !running
                break
            Sleep 100
        }
        currentLoop := A_Index
        SetCurrentActivity()

        bestSlot := ""
        priorityOrder := ["20","44","43","38","21","37","66","39","40","41","42","33",
                          "34-1","34-2","34-3","35","14","15","7","9","?"]
        for questId in priorityOrder {
            for slot in questSlots {
                if slot["enabled"] && slot["questId"] = questId {
                    bestSlot := slot
                    break 2
                }
            }
        }

        if bestSlot != "" && bestSlot["questId"] != "?" {
            DoQuest(bestSlot["questId"], bestSlot["questName"], 1)
        } else {
            AddLog("No active quest found — waiting 5s")
            currentAction := "Waiting for Quest"
            SetCurrentActivity()
            LoopMs(5000)
        }

        CheckConnection()

        if currentZone = BEST_ZONE {
            ActivateRoblox()
            Send "q"
            HyperSleep(200)
        }
    }

    if !running
        return

    EatFruitBonus()

    if cfg["reconnectAfterLoops"] {
        AddLog("Loop complete — reconnecting")
        DoReconnect()
        Reload
    } else {
        AddLog("All loops complete!")
        StopMacro()
    }
}

; ================================================================
;  HOTKEYS
; ================================================================
F9::  StartMacro()
F8::  PauseMacro()
F10:: StopMacro()
F12:: ExitApp()

OnExit(CleanupOnExit)
CleanupOnExit(*) {
    global running
    running := false
    AddLog("Exiting")
}

; ================================================================
;  PROFILE SYSTEM
; ================================================================
LoadProfilesJSON() {
    global JSON_PATH
    if !FileExist(JSON_PATH) {
        root := Map("profiles", Map("Default", Map()))
        SaveProfilesJSON(root)
        return root
    }
    try {
        raw := FileRead(JSON_PATH, "UTF-8")
        return JSON.parse(raw)
    } catch {
        return Map("profiles", Map("Default", Map()))
    }
}

SaveProfilesJSON(root) {
    global JSON_PATH
    dirPath := SubStr(JSON_PATH, 1, InStr(JSON_PATH, "\",, -1) - 1)
    if !DirExist(dirPath)
        DirCreate(dirPath)
    raw := JSON.stringify(root, , "  ")
    try FileDelete JSON_PATH
    FileAppend raw, JSON_PATH, "UTF-8"
}

GetProfileList() {
    root := LoadProfilesJSON()
    list := []
    for name, _ in root["profiles"]
        list.Push(name)
    return list.Length > 0 ? list : ["Default"]
}

CfgToMap() {
    global cfg
    m := Map()
    for key, val in cfg
        m[key] := val
    return m
}

MapToCfg(m) {
    global cfg
    G(key, def) {
        try return m[key]
        return def
    }
    for key, defaultVal in cfg
        cfg[key] := G(key, defaultVal)
}

LoadProfile(name) {
    global currentProfile, cfg
    currentProfile := name
    root     := LoadProfilesJSON()
    profiles := root["profiles"]
    if profiles.Has(name)
        try MapToCfg(profiles[name])
    root["lastUsed_" A_UserName] := name
    SaveProfilesJSON(root)
    try WinSetTitle "PS99 Macro v" MACRO_VERSION " [" name "]", "ahk_id " G_hwnd
    JS('document.title = "PS99 Macro v' MACRO_VERSION ' [' name ']"')
    PushStateToJS()
}

SaveProfile() {
    global currentProfile
    SaveNamedProfile(currentProfile)
}

SaveNamedProfile(name) {
    root                   := LoadProfilesJSON()
    root["profiles"][name] := CfgToMap()
    root["lastUsed_" A_UserName] := name
    SaveProfilesJSON(root)
}

AddProfile(nameRaw := "") {
    global cfg, currentProfile
    name := Trim(StrReplace(nameRaw, '"', ''))
    if name = ""
        name := Trim(cfg["profileName"])
    if name = ""
        return
    root   := LoadProfilesJSON()
    exists := root["profiles"].Has(name)
    currentProfile := name
    SaveNamedProfile(name)
    JS('window.PS99.setProfileFeedback("' (exists ? "Saved" : "Created") ': ' EscJ(name) '", true)')
    PushStateToJS()
}

LoadSelectedProfile(nameRaw := "") {
    global cfg
    name := Trim(StrReplace(nameRaw, '"', ''))
    if name = ""
        name := Trim(cfg["selectedProfile"])
    if name = "" {
        MsgBox "Select a profile first.", "PS99 Macro", 0x40030
        return
    }
    LoadProfile(name)
    JS('window.PS99.setProfileFeedback("Loaded: ' EscJ(name) '", true)')
}

DeleteProfile(nameRaw := "") {
    global cfg, currentProfile
    name := Trim(StrReplace(nameRaw, '"', ''))
    if name = ""
        name := Trim(cfg["selectedProfile"])
    if name = "Default" {
        MsgBox "Cannot delete Default.", "PS99 Macro", 0x40030
        return
    }
    root     := LoadProfilesJSON()
    profiles := root["profiles"]
    if profiles.Has(name)
        profiles.Delete(name)
    root["profiles"] := profiles
    if root.Has("lastUsed_" A_UserName) && root["lastUsed_" A_UserName] = name
        root["lastUsed_" A_UserName] := "Default"
    SaveProfilesJSON(root)
    if currentProfile = name
        LoadProfile("Default")
    JS('window.PS99.setProfileFeedback("Deleted: ' EscJ(name) '", false)')
    PushStateToJS()
}

; ================================================================
;  STARTUP
; ================================================================
if !IsSet(pToken) || !pToken
    pToken := Gdip_Startup()
OnExit((*) => Gdip_Shutdown(pToken))

global currentProfile := "Default"
try {
    root0       := LoadProfilesJSON()
    userKey     := "lastUsed_" A_UserName
    lastProfile := root0.Has(userKey) ? root0[userKey] : "Default"
    list0       := GetProfileList()
    found       := false
    for n in list0
        if n = lastProfile
            found := true
    LoadProfile(found ? lastProfile : "Default")
}

BuildGUI()