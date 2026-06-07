; ================================================================
;  HiveHub Macro  V1.4.0  —  by Killericboy
;  UI: WebView2 (thqby's WebView2.ahk) + HTML/CSS
; ================================================================

#Requires AutoHotkey v2.0
#SingleInstance Force
#MaxThreads 4

#Include Gdip_All.ahk
#Include Gdip_ImageSearch.ahk
#Include HyperSleep.ahk
#Include Roblox.ahk
#Include Walk.ahk
#Include FieldGuard.ahk
#Include WebView2.ahk
#Include JSON.ahk

SendMode "Event"
CoordMode "Mouse", "Screen"
CoordMode "Pixel", "Screen"

; ── Key scan codes ────────────────────────────────────────────
FwdKey    := "sc011"
LeftKey   := "sc01e"
BackKey   := "sc01f"
RightKey  := "sc020"
RotLeft   := "sc033"
RotRight  := "sc034"
SC_LShift := "sc02a"

; ── Walk.ahk globals ──────────────────────────────────────────
base_movespeed := 16
hasty_guard    := false
gifted_hasty   := false

; ── Runtime state ─────────────────────────────────────────────
running           := false
paused            := false
cycleCount        := 0
currentRow        := 0
currentPass       := 0
runStartTime      := 0
camRotated        := 0
shiftLockActive   := false
lastReconnectTick := 0

windowX := 0, windowY := 0, windowWidth := 0, windowHeight := 0

; ── Config map ────────────────────────────────────────────────
cfg := Map(
    "baseSpeed",          16,
    "direction",          1,
    "lengthIdx",          3,
    "width",              3,
    "camAlign",           1,
    "camSteps",           1,
    "shiftLock",          false,
    "autoHarvest",        true,
    "keyDelay",           20,
    "hotbarEnable",       false,
    "hotbarInterval",     30,
    "hotbarKeys",         Map(),
    "privServer",         "",
    "joinMethod",         1,
    "reconnectEnable",    false,
    "reconnectHours",     0,
    "reconnectHH",        0,
    "reconnectMM",        0,
    "fallbackPublic",     true,
    "pubServer",          "https://www.roblox.com/games/15579077077/Hive-Hub",
    "profileName",        "",
    "selectedProfile",    "",
    "fieldGuardEnable",   true,
    "fieldGuardSkyColor", 0x5A9CCC,
    "fieldGuardFldColor", 0x4A8430
)

; ── Constants ─────────────────────────────────────────────────
HIVEHUB_URL    := "https://www.roblox.com/games/15579077077/Hive-Hub"
JSON_PATH      := A_ScriptDir "\..\settings\profiles.json"
BSS_PLACE_ID   := "1537690962"
currentProfile := "Default"

UI_PATH := SubStr(A_ScriptDir, 1, InStr(A_ScriptDir, "\",, -1) - 1) "\ui\index.html"

SizeNames := ["XS","S","M","L","XL"]
SizeTiles  := [2, 3, 5, 7, 10]

GetLengthTiles() => SizeTiles[cfg["lengthIdx"]]
GetWidthTiles()  => cfg["width"]

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
    global G, wvc, wv2, wv2ready, currentProfile, navToken, msgToken

    G := Gui("+AlwaysOnTop", "HiveHub Macro v1.4.0 [" currentProfile "]")
    G.BackColor := "0d1825"
    G.OnEvent("Close", (*) => ExitApp())
    G.OnEvent("Size",  OnGuiSize)
    G.Show("w540 h430")

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

    iconFile := A_ScriptDir "\..\assets\bee.ico"
    if FileExist(iconFile) {
        TraySetIcon iconFile
        SendMessage 0x80, 0, DllCall("LoadImage","Ptr",0,"Str",iconFile,"UInt",1,"Int",16,"Int",16,"UInt",0x50),, "ahk_id " G.Hwnd
        SendMessage 0x80, 1, DllCall("LoadImage","Ptr",0,"Str",iconFile,"UInt",1,"Int",32,"Int",32,"UInt",0x50),, "ahk_id " G.Hwnd
    }
}

OnGuiSize(GuiObj, MinMax, Width, Height) {
    global wvc
    if (wvc && MinMax != -1)
        wvc.Fill()
}

OnNavCompleted(sender, args) {
    global wv2ready
    wv2ready := true
    PushStateToJS()
    JS_RefreshDetected()
}

OnWebMessage(sender, args) {
    msg := args.TryGetWebMessageAsString()
    if !msg
        return

    colonPos := InStr(msg, ":")
    if colonPos {
        fn   := SubStr(msg, 1, colonPos - 1)
        data := SubStr(msg, colonPos + 1)
    } else {
        fn   := msg
        data := ""
    }

    switch fn {
        case "Save":                  JS_Save(data)
        case "StartMacro":            StartMacro()
        case "PauseMacro":            PauseMacro()
        case "StopMacro":             StopMacro()
        case "JoinPrivate":           JoinPrivate()
        case "JoinPublic":            JoinPublic()
        case "TestReconnect":         DoReconnect()
        case "RefreshRobloxDetected": JS_RefreshDetected()
        case "OpenWebVersion":        Run HIVEHUB_URL
        case "AddProfile":            AddProfile(data)
        case "LoadSelectedProfile":   LoadSelectedProfile(data)
        case "DeleteProfile":         DeleteProfile(data)
    }
}

JS(script) {
    global wv2, wv2ready
    if wv2ready
        wv2.ExecuteScriptAsync(script)
}

PushStateToJS(*) {
    global cfg, currentProfile, wv2ready
    if !wv2ready
        return

    profiles    := GetProfileList()
    profileJSON := "["
    for i, n in profiles
        profileJSON .= (i > 1 ? "," : "") '"' EscJ(n) '"'
    profileJSON .= "]"

    keys := "{"
    for k, v in cfg["hotbarKeys"]
        keys .= '"' k '":' (v ? "true" : "false") ","
    keys := RTrim(keys, ",") "}"

    sl  := cfg["shiftLock"]        ? "true" : "false"
    ah  := cfg["autoHarvest"]      ? "true" : "false"
    he  := cfg["hotbarEnable"]     ? "true" : "false"
    re  := cfg["reconnectEnable"]  ? "true" : "false"
    fp  := cfg["fallbackPublic"]   ? "true" : "false"
    fge := cfg["fieldGuardEnable"] ? "true" : "false"

    json := "{"
    json .= '"baseSpeed":'        cfg["baseSpeed"]       ","
    json .= '"direction":'        cfg["direction"]        ","
    json .= '"lengthIdx":'        cfg["lengthIdx"]        ","
    json .= '"width":'            cfg["width"]            ","
    json .= '"camAlign":'         cfg["camAlign"]         ","
    json .= '"camSteps":'         cfg["camSteps"]         ","
    json .= '"shiftLock":'        sl                      ","
    json .= '"autoHarvest":'      ah                      ","
    json .= '"keyDelay":'         cfg["keyDelay"]         ","
    json .= '"hotbarEnable":'     he                      ","
    json .= '"hotbarInterval":'   cfg["hotbarInterval"]   ","
    json .= '"hotbarKeys":'       keys                    ","
    json .= '"privServer":"'      EscJ(cfg["privServer"])  '",'
    json .= '"joinMethod":'       cfg["joinMethod"]       ","
    json .= '"reconnectEnable":'  re                      ","
    json .= '"reconnectHours":'   cfg["reconnectHours"]   ","
    json .= '"reconnectHH":'      cfg["reconnectHH"]      ","
    json .= '"reconnectMM":'      cfg["reconnectMM"]      ","
    json .= '"fallbackPublic":'   fp                      ","
    json .= '"pubServer":"'       EscJ(cfg["pubServer"])   '",'
    json .= '"fieldGuardEnable":' fge                     ","
    json .= '"profiles":'         profileJSON             ","
    json .= '"currentProfile":"'  EscJ(currentProfile)    '"'
    json .= "}"

    JS("window.HiveHub.loadState(" json ")")
}

EscJ(s) => StrReplace(StrReplace(StrReplace(s, "\", "\\"), '"', '\"'), "`n", "\n")

JS_Save(data) {
    global cfg
    ParseJSONIntoCfg(data)
    SaveProfile()
}

ParseJSONIntoCfg(json) {
    global cfg

    for key in ["baseSpeed","direction","lengthIdx","width","camAlign","camSteps",
                "keyDelay","hotbarInterval","joinMethod","reconnectHours",
                "reconnectHH","reconnectMM","fieldGuardSkyColor","fieldGuardFldColor"] {
        if RegExMatch(json, '"' key '"\s*:\s*([\d.x]+)', &m)
            cfg[key] := Float(m[1])
    }
    for key in ["shiftLock","autoHarvest","hotbarEnable","reconnectEnable",
                "fallbackPublic","fieldGuardEnable"] {
        if RegExMatch(json, '"' key '"\s*:\s*(true|false)', &m)
            cfg[key] := (m[1] = "true")
    }
    for key in ["privServer","pubServer","profileName","selectedProfile"] {
        if RegExMatch(json, '"' key '"\s*:\s*"((?:[^"\\]|\\.)*)"', &m)
            cfg[key] := StrReplace(StrReplace(m[1], '\"', '"'), "\\", "\")
    }
    if RegExMatch(json, '"hotbarKeys"\s*:\s*\{([^}]*)\}', &km) {
        keys := Map()
        raw  := km[1]
        p    := 1
        while RegExMatch(raw, '"(\d+)"\s*:\s*(true|false)', &pair, p) {
            keys[pair[1]] := (pair[2] = "true")
            p := pair.Pos + pair.Len
        }
        cfg["hotbarKeys"] := keys
    }
}

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
        JS('window.HiveHub.setDetected("Not detected", false)')
        return
    }
    label := installType (isRunning ? " ●" : "")
    JS('window.HiveHub.setDetected("' EscJ(label) '", true)')
}

; ================================================================
;  SHIFTLOCK
; ================================================================
EnableShiftLock() {
    global shiftLockActive, SC_LShift
    if shiftLockActive
        return
    ActivateRoblox()
    Send "{" SC_LShift "}"
    Sleep 300
    shiftLockActive := true
}

DisableShiftLock() {
    global shiftLockActive, SC_LShift
    if !shiftLockActive
        return
    ActivateRoblox()
    Send "{" SC_LShift "}"
    Sleep 200
    shiftLockActive := false
}

; ================================================================
;  CAMERA
; ================================================================
RotateCamera(dir, steps) {
    global RotLeft, RotRight, camRotated
    if steps = 0
        return
    key := (dir = "Right") ? RotRight : RotLeft
    Send "{" key " " steps "}"
    camRotated += (dir = "Right") ? steps : -steps
    Sleep 150
}

RevertCamera() {
    global RotLeft, RotRight, camRotated
    if camRotated = 0
        return
    key   := (camRotated > 0) ? RotLeft : RotRight
    steps := Abs(camRotated)
    Send "{" key " " steps "}"
    camRotated := 0
    Sleep 150
}

; ================================================================
;  SERVER / JOIN
; ================================================================
JoinServer(linkCode := "", shareCode := "") {
    global BSS_PLACE_ID
    try {
        if shareCode != ""
            Run '"roblox://navigation/share_links?code=' shareCode '&type=Server"'
        else if linkCode != ""
            Run '"roblox://placeID=' BSS_PLACE_ID '&linkcode=' linkCode '"'
        else
            Run '"roblox://placeID=' BSS_PLACE_ID '"'
    }
}

ValidateServerLink(str) {
    str := Trim(str)
    if str = ""
        return {valid: true, code: "", type: "public"}
    if RegExMatch(str, "i)roblox\.com\/([a-z]{2}\/)?games\/1537690962\/?[^?]*\?privateServerLinkCode=(?P<code>[a-z0-9]{32})", &m)
        return {valid: true, code: m.code, type: "private"}
    if RegExMatch(str, "i)roblox\.com\/share\?code=(?P<code>[a-f0-9]{32})&type=Server", &m)
        return {valid: true, code: m.code, type: "share"}
    return {valid: false, code: "", type: ""}
}

JoinPrivate() {
    result := ValidateServerLink(cfg["privServer"])
    if !result.valid {
        MsgBox "Invalid private server link.", "HiveHub", 0x40030
        return
    }
    if cfg["joinMethod"] = 1
        JoinServer(result.code, result.type = "share" ? result.code : "")
    else
        Run "https://www.roblox.com/games/1537690962?privateServerLinkCode=" result.code
}

JoinPublic() {
    global HIVEHUB_URL
    link := Trim(cfg["pubServer"])
    if link = ""
        link := HIVEHUB_URL
    result := ValidateServerLink(link)
    if (result.valid && result.type != "public")
        JoinServer(result.code)
    else
        Run link
}

; ================================================================
;  RECONNECT ENGINE
; ================================================================
StartReconnectTimer() {
    StopReconnectTimer()
    if cfg["reconnectEnable"]
        SetTimer CheckReconnect, 60000
}

StopReconnectTimer() {
    SetTimer CheckReconnect, 0
}

CheckReconnect() {
    global running, lastReconnectTick, cfg
    if !running
        return
    hh := Integer(cfg["reconnectHH"])
    mm := Integer(cfg["reconnectMM"])
    if (hh > 0 || mm > 0) {
        nowH := Integer(FormatTime(A_NowUTC, "HH"))
        nowM := Integer(FormatTime(A_NowUTC, "mm"))
        if (nowH = hh && nowM = mm) {
            if (A_TickCount - lastReconnectTick > 90000)
                DoReconnect()
            return
        }
    }
    hrs := Float(cfg["reconnectHours"])
    if (hrs > 0 && lastReconnectTick > 0) {
        if ((A_TickCount - lastReconnectTick) / 3600000.0 >= hrs)
            DoReconnect()
    }
}

DoReconnect(*) {
    global running, lastReconnectTick, cfg, HIVEHUB_URL
    lastReconnectTick := A_TickCount
    if running
        StopMacro()
    Sleep 500
    result := ValidateServerLink(cfg["privServer"])
    if (result.valid && result.type != "public") {
        if cfg["joinMethod"] = 1
            JoinServer(result.code, result.type = "share" ? result.code : "")
        else
            Run "https://www.roblox.com/games/1537690962?privateServerLinkCode=" result.code
    } else if cfg["fallbackPublic"] {
        link := Trim(cfg["pubServer"])
        Run (link != "" ? link : HIVEHUB_URL)
    }
}

; ================================================================
;  STATS  —  live speed + buff tags every 500ms
; ================================================================
UpdateStats() {
    global running, runStartTime, cycleCount, currentRow, currentPass, cfg
    global lastDetectedSpeed, lastHaste, lastOil, lastSmoothie
    global lastBear, lastHastePlus, lastCoconut

    if !running
        return

    elapsed := A_TickCount - runStartTime
    s := Format("{:02}", Floor(Mod(elapsed / 1000, 60)))
    m := Format("{:02}", Floor(elapsed / 60000))
    p := currentPass = 1 ? "Fwd" : (currentPass = 2 ? "Back" : "-")

    ; live speed — falls back to base config before first Walk()
    liveSpd := (lastDetectedSpeed > 0)
             ? Round(lastDetectedSpeed, 1)
             : cfg["baseSpeed"]

    ; buff label string
    buffStr := ""
    if lastHastePlus
        buffStr .= "H+ "
    if lastHaste > 0
        buffStr .= "H×" lastHaste " "
    if lastCoconut
        buffStr .= "Coco "
    if lastOil
        buffStr .= "Oil "
    if lastSmoothie
        buffStr .= "Smth "
    if lastBear
        buffStr .= "Bear "
    buffStr := Trim(buffStr)

    rc    := FieldGuard_GetRecoveryCount()
    rcStr := rc > 0 ? " G:" rc : ""

    JS('window.HiveHub.setStats("' m ':' s ' | ' p ' R:' currentRow ' C:' cycleCount rcStr '")')
    JS('window.HiveHub.setLiveSpeed(' liveSpd ', "' buffStr '")')
}

ResetStats() {
    global cycleCount, currentRow, currentPass, runStartTime
    global lastDetectedSpeed, lastHaste, lastOil, lastSmoothie
    global lastBear, lastHastePlus, lastCoconut
    cycleCount := 0, currentRow := 0, currentPass := 0, runStartTime := 0
    lastDetectedSpeed := 0, lastHaste := 0
    lastOil := false, lastSmoothie := false
    lastBear := false, lastHastePlus := false, lastCoconut := false
    JS('window.HiveHub.setStats("00:00 | P:- R:0 C:0")')
    JS('window.HiveHub.setLiveSpeed(0, "")')
}

; ================================================================
;  AUTO-KEY (HOTBAR)
; ================================================================
autoKeyTimer := 0

StartAutoKey() {
    global autoKeyTimer
    StopAutoKey()
    if !cfg["hotbarEnable"]
        return
    interval := cfg["hotbarInterval"] * 1000
    if interval <= 0
        return
    SetTimer SendAutoKey, interval
    autoKeyTimer := 1
}

StopAutoKey() {
    global autoKeyTimer
    SetTimer SendAutoKey, 0
    autoKeyTimer := 0
}

SendAutoKey() {
    global running, paused, cfg
    if !running || paused
        return
    for k, v in cfg["hotbarKeys"]
        if v
            SendInput "{" k "}"
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
    root     := LoadProfilesJSON()
    profiles := root["profiles"]
    list     := []
    for name, _ in profiles
        list.Push(name)
    return list.Length > 0 ? list : ["Default"]
}

CfgToMap() {
    global cfg, HIVEHUB_URL
    m := Map()
    m["baseSpeed"]          := cfg["baseSpeed"]
    m["direction"]          := cfg["direction"]
    m["lengthIdx"]          := cfg["lengthIdx"]
    m["width"]              := cfg["width"]
    m["camAlign"]           := cfg["camAlign"]
    m["camSteps"]           := cfg["camSteps"]
    m["shiftLock"]          := cfg["shiftLock"]        ? 1 : 0
    m["autoHarvest"]        := cfg["autoHarvest"]      ? 1 : 0
    m["keyDelay"]           := cfg["keyDelay"]
    m["hotbarEnable"]       := cfg["hotbarEnable"]     ? 1 : 0
    m["hotbarInterval"]     := cfg["hotbarInterval"]
    m["privServer"]         := cfg["privServer"]
    m["joinMethod"]         := cfg["joinMethod"]
    m["reconnectEnable"]    := cfg["reconnectEnable"]  ? 1 : 0
    m["reconnectHours"]     := cfg["reconnectHours"]
    m["reconnectHH"]        := cfg["reconnectHH"]
    m["reconnectMM"]        := cfg["reconnectMM"]
    m["fallbackPublic"]     := cfg["fallbackPublic"]   ? 1 : 0
    pub := Trim(cfg["pubServer"])
    m["pubServer"]          := (pub = "") ? HIVEHUB_URL : pub
    m["fieldGuardEnable"]   := cfg["fieldGuardEnable"] ? 1 : 0
    m["fieldGuardSkyColor"] := cfg["fieldGuardSkyColor"]
    m["fieldGuardFldColor"] := cfg["fieldGuardFldColor"]
    hk := Map()
    for k, v in cfg["hotbarKeys"]
        hk[k] := v ? 1 : 0
    m["hotbarKeys"] := hk
    return m
}

MapToCfg(m) {
    global cfg, HIVEHUB_URL
    G(key, def) {
        try return m[key]
        return def
    }
    cfg["baseSpeed"]          := Integer(G("baseSpeed",         16))
    cfg["direction"]          := Integer(G("direction",         1))
    cfg["lengthIdx"]          := Integer(G("lengthIdx",         3))
    cfg["width"]              := Integer(G("width",             3))
    cfg["camAlign"]           := Integer(G("camAlign",          1))
    cfg["camSteps"]           := Integer(G("camSteps",          1))
    cfg["shiftLock"]          := Integer(G("shiftLock",         0)) = 1
    cfg["autoHarvest"]        := Integer(G("autoHarvest",       1)) = 1
    cfg["keyDelay"]           := Integer(G("keyDelay",          20))
    cfg["hotbarEnable"]       := Integer(G("hotbarEnable",      0)) = 1
    cfg["hotbarInterval"]     := Integer(G("hotbarInterval",    30))
    cfg["privServer"]         := G("privServer",                "")
    cfg["joinMethod"]         := Integer(G("joinMethod",        1))
    cfg["reconnectEnable"]    := Integer(G("reconnectEnable",   0)) = 1
    cfg["reconnectHours"]     := Float(G("reconnectHours",      0))
    cfg["reconnectHH"]        := Integer(G("reconnectHH",       0))
    cfg["reconnectMM"]        := Integer(G("reconnectMM",       0))
    cfg["fallbackPublic"]     := Integer(G("fallbackPublic",    1)) = 1
    pub := G("pubServer", "")
    cfg["pubServer"]          := (pub = "") ? HIVEHUB_URL : pub
    cfg["fieldGuardEnable"]   := Integer(G("fieldGuardEnable",  1)) = 1
    cfg["fieldGuardSkyColor"] := Integer(G("fieldGuardSkyColor", 0x5A9CCC))
    cfg["fieldGuardFldColor"] := Integer(G("fieldGuardFldColor", 0x4A8430))
    keys := Map()
    try {
        hk := m["hotbarKeys"]
        for k, v in hk
            keys[k] := (v = 1)
    }
    cfg["hotbarKeys"] := keys
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
    global G_hwnd
    try WinSetTitle "HiveHub Macro v1.4.0 [" name "]", "ahk_id " G_hwnd
    JS('document.title = "HiveHub Macro v1.4.0 [' name ']"')
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
    JS('window.HiveHub.setProfileFeedback("' (exists ? "Saved" : "Created") ': ' EscJ(name) '", true)')
    PushStateToJS()
}

LoadSelectedProfile(nameRaw := "") {
    global cfg
    name := Trim(StrReplace(nameRaw, '"', ''))
    if name = ""
        name := Trim(cfg["selectedProfile"])
    if name = "" {
        MsgBox "Select a profile first.", "HiveHub", 0x40030
        return
    }
    list  := GetProfileList()
    found := false
    for n in list
        if n = name
            found := true
    if !found {
        MsgBox "Profile not found.", "HiveHub", 0x40030
        return
    }
    LoadProfile(name)
    JS('window.HiveHub.setProfileFeedback("Loaded: ' EscJ(name) '", true)')
}

DeleteProfile(nameRaw := "") {
    global cfg, currentProfile
    name := Trim(StrReplace(nameRaw, '"', ''))
    if name = ""
        name := Trim(cfg["selectedProfile"])
    if name = "" {
        MsgBox "Select a profile to delete.", "HiveHub", 0x40030
        return
    }
    if name = "Default" {
        MsgBox "Cannot delete Default.", "HiveHub", 0x40030
        return
    }
    root     := LoadProfilesJSON()
    profiles := root["profiles"]
    if profiles.Has(name)
        profiles.Delete(name)
    root["profiles"] := profiles
    userKey := "lastUsed_" A_UserName
    if root.Has(userKey) && root[userKey] = name
        root[userKey] := "Default"
    SaveProfilesJSON(root)
    if currentProfile = name
        LoadProfile("Default")
    JS('window.HiveHub.setProfileFeedback("Deleted: ' EscJ(name) '", false)')
    PushStateToJS()
}

; ================================================================
;  HOTKEYS
; ================================================================
F9::  StartMacro()
F10:: StopMacro()
F11:: ToggleHarvest()
F12:: PauseMacro()

OnExit(CleanupOnExit)
CleanupOnExit(*) {
    for k in [FwdKey, BackKey, LeftKey, RightKey]
        Send "{" k " up}"
    Send "{LButton up}"
    RevertCamera()
    DisableShiftLock()
    StopAutoKey()
    StopReconnectTimer()
}

ToggleHarvest() {
    global cfg
    cfg["autoHarvest"] := !cfg["autoHarvest"]
    if !cfg["autoHarvest"]
        Send "{LButton up}"
    ToolTip "Auto harvest: " (cfg["autoHarvest"] ? "ON" : "OFF")
    SetTimer () => ToolTip(), -1200
}

; ================================================================
;  MACRO LIFECYCLE
; ================================================================
StartMacro(*) {
    global running, paused, runStartTime, base_movespeed, cfg
    global FG_Enabled, FG_SkyColorSample, FG_FieldColorSample

    if running
        return
    if !GetRobloxClientPos() {
        MsgBox "Roblox not found.", "HiveHub", 0x40030
        return
    }
    spd := cfg["baseSpeed"]
    if spd <= 0 {
        MsgBox "Walk speed must be > 0.", "HiveHub", 0x40030
        return
    }
    base_movespeed := spd

    FG_Enabled          := cfg["fieldGuardEnable"]
    FG_SkyColorSample   := Integer(cfg["fieldGuardSkyColor"])
    FG_FieldColorSample := Integer(cfg["fieldGuardFldColor"])

    ResetStats()
    RevertCamera()
    SetKeyDelay cfg["keyDelay"]

    running := true, paused := false, runStartTime := A_TickCount
    JS('window.HiveHub.setStatus("RUNNING")')
    JS('window.HiveHub.setPauseBtn("⏸  Pause  (F12)")')

    ActivateRoblox()
    if cfg["shiftLock"]
        EnableShiftLock()

    camDir   := ["None", "Right", "Left"][cfg["camAlign"]]
    camSteps := cfg["camSteps"]
    if (camDir != "None" && camSteps > 0)
        RotateCamera(camDir, camSteps)

    FieldGuard_Init()

    lastReconnectTick := A_TickCount
    SetTimer UpdateStats, 500
    StartAutoKey()
    StartReconnectTimer()
    SetTimer SnakeThread, -1
}

PauseMacro(*) {
    global running, paused
    if !running
        return
    paused := !paused
    if paused {
        for k in [FwdKey, BackKey, LeftKey, RightKey]
            Send "{" k " up}"
        JS('window.HiveHub.setStatus("PAUSED")')
        JS('window.HiveHub.setPauseBtn("▶  Resume  (F12)")')
        StopAutoKey()
    } else {
        JS('window.HiveHub.setStatus("RUNNING")')
        JS('window.HiveHub.setPauseBtn("⏸  Pause  (F12)")')
        ActivateRoblox()
        StartAutoKey()
    }
}

StopMacro(*) {
    global running, paused
    running := false, paused := false
    SetTimer UpdateStats, 0
    for k in [FwdKey, BackKey, LeftKey, RightKey]
        Send "{" k " up}"
    Send "{LButton up}"
    RevertCamera()
    DisableShiftLock()
    StopAutoKey()
    StopReconnectTimer()
    JS('window.HiveHub.setStatus("STOPPED")')
    JS('window.HiveHub.setPauseBtn("⏸  Pause  (F12)")')
    SetKeyDelay -1
    ResetStats()
}

; ================================================================
;  SNAKE TRAVERSAL THREAD
; ================================================================
SnakeThread() {
    global running, paused, cfg, FwdKey, BackKey, LeftKey, RightKey
    global cycleCount, currentRow, currentPass

    lengthT  := GetLengthTiles()
    widthT   := GetWidthTiles()
    standing := (cfg["direction"] = 3)
    keyA     := (cfg["direction"] = 1) ? RightKey : LeftKey
    keyB     := (cfg["direction"] = 1) ? LeftKey  : RightKey

    if cfg["autoHarvest"]
        Send "{LButton down}"

    if standing {
        while running {
            if cfg["autoHarvest"]
                Send "{LButton down}"
            else
                Send "{LButton up}"
            HyperSleep(500)
        }
        Send "{LButton up}"
        return
    }

    while running {
        ; ── Pass 1: forward ───────────────────────────────────
        currentPass := 1
        curKey := keyA
        loop lengthT {
            if !running
                break
            currentRow := A_Index
            Send "{" curKey " down}"
            Walk(widthT)

            revKey := (curKey = keyA) ? keyB : keyA
            if !FieldGuard_AfterStep(curKey, revKey) {
                Send "{" curKey " up}"
                StopMacro()
                return
            }

            if A_Index < lengthT {
                Send "{" curKey " up}{" FwdKey " down}"
                Walk(1)
                FieldGuard_AfterStep(FwdKey, BackKey)
                curKey := (curKey = keyA) ? keyB : keyA
                Send "{" FwdKey " up}{" curKey " down}"
            } else {
                Send "{" curKey " up}"
                curKey := (curKey = keyA) ? keyB : keyA
            }
            if cfg["autoHarvest"]
                Send "{LButton down}"
            else
                Send "{LButton up}"
        }
        if !running
            break

        ; ── Pass 2: backward ──────────────────────────────────
        currentPass := 2
        loop lengthT {
            if !running
                break
            currentRow := A_Index
            Send "{" curKey " down}"
            Walk(widthT)

            revKey := (curKey = keyA) ? keyB : keyA
            if !FieldGuard_AfterStep(curKey, revKey) {
                Send "{" curKey " up}"
                StopMacro()
                return
            }

            if A_Index < lengthT {
                Send "{" curKey " up}{" BackKey " down}"
                Walk(1)
                FieldGuard_AfterStep(BackKey, FwdKey)
                curKey := (curKey = keyA) ? keyB : keyA
                Send "{" BackKey " up}{" curKey " down}"
            } else {
                Send "{" curKey " up}"
                curKey := (curKey = keyA) ? keyB : keyA
            }
            if cfg["autoHarvest"]
                Send "{LButton down}"
            else
                Send "{LButton up}"
        }
        if !running
            break

        cycleCount++
        currentRow  := 0
        currentPass := 0
        HyperSleep(200)
    }
    for k in [FwdKey, BackKey, LeftKey, RightKey]
        Send "{" k " up}"
    Send "{LButton up}"
}

; ================================================================
;  STARTUP
; ================================================================
if !IsSet(pToken) || !pToken
    pToken := Gdip_Startup()

OnExit((*) => Gdip_Shutdown(pToken))

lastProfile := ""
try {
    root0       := LoadProfilesJSON()
    userKey     := "lastUsed_" A_UserName
    lastProfile := root0.Has(userKey) ? root0[userKey] : "Default"
} catch {
    lastProfile := "Default"
}
list0 := GetProfileList()
found := false
for n in list0
    if n = lastProfile
        found := true
LoadProfile(found ? lastProfile : "Default")

BuildGUI()
