; ================================================================
;  HiveHub Macro  V1.4.0  —  by Killericboy
;  UI: WebView2 (Edge) + HTML/CSS
; ================================================================

#Requires AutoHotkey v2.0
#SingleInstance Force
#MaxThreads 4

#Include Gdip_All.ahk
#Include Gdip_ImageSearch.ahk
#Include HyperSleep.ahk
#Include Roblox.ahk
#Include Walk.ahk
#Include WebView2.ahk

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
isLoading         := false
shiftLockActive   := false
lastReconnectTick := 0

windowX := 0, windowY := 0, windowWidth := 0, windowHeight := 0

; ── Config from loaded state ──────────────────────────────────
; These mirror the JS state object and are updated on every Save message
cfg := Map(
    "baseSpeed",       16,
    "direction",       1,
    "lengthIdx",       3,
    "width",           3,
    "camAlign",        1,
    "camSteps",        1,
    "shiftLock",       false,
    "autoHarvest",     true,
    "keyDelay",        20,
    "hotbarEnable",    false,
    "hotbarInterval",  30,
    "hotbarKeys",      Map(),
    "privServer",      "",
    "joinMethod",      1,
    "reconnectEnable", false,
    "reconnectHours",  0,
    "reconnectHH",     0,
    "reconnectMM",     0,
    "fallbackPublic",  true,
    "pubServer",       "https://www.roblox.com/games/15579077077/Hive-Hub",
    "profileName",     "",
    "selectedProfile", ""
)

; ── Constants ─────────────────────────────────────────────────
HIVEHUB_URL    := "https://www.roblox.com/games/15579077077/Hive-Hub"
INI_PATH       := A_ScriptDir "\..\settings\hivehub_config.ini"
BSS_PLACE_ID   := "1537690962"
currentProfile := "Default"
UI_PATH        := A_ScriptDir "\..\ui\index.html"

SizeNames := ["XS","S","M","L","XL"]
SizeTiles  := [2,   3,  5,  7,  10]

GetLengthTiles() => SizeTiles[cfg["lengthIdx"]]
GetWidthTiles()  => cfg["width"]

; ================================================================
;  WebView2 HOST
; ================================================================
global wv2, wv2ready := false

BuildGUI() {
    global wv2, wv2ready

    G := Gui("+AlwaysOnTop", "HiveHub Macro v1.4.0 [" currentProfile "]")
    G.BackColor := "0d1825"
    G.OnEvent("Close", (*) => ExitApp())
    G.Show("w480 h560")

    ; Store hwnd for icon
    global G_hwnd := G.Hwnd

    ; WebView2 fills the window
    wv2 := WebView2.create(G.Hwnd)
    wv2.Navigate("file:///" StrReplace(UI_PATH, "\", "/"))

    ; Wait for page ready, then inject state
    wv2.NavigationCompleted := WV2_Ready
    wv2.WebMessageReceived  := WV2_Message

    ; Tray icon
    iconFile := A_ScriptDir "\..\assets\bee.ico"
    if FileExist(iconFile) {
        TraySetIcon iconFile
        SendMessage 0x80, 0, DllCall("LoadImage","Ptr",0,"Str",iconFile,"UInt",1,"Int",16,"Int",16,"UInt",0x50),, "ahk_id " G.Hwnd
        SendMessage 0x80, 1, DllCall("LoadImage","Ptr",0,"Str",iconFile,"UInt",1,"Int",32,"Int",32,"UInt",0x50),, "ahk_id " G.Hwnd
    }
}

; Called when navigation finishes — push saved state to JS
WV2_Ready(wv, args) {
    global wv2ready
    wv2ready := true
    PushStateToJS()
}

; Called when JS sends a message via ahk(fn, data)
WV2_Message(wv, args) {
    msg := args.TryGetWebMessageAsString()
    if !msg
        return

    colonPos := InStr(msg, ":")
    if colonPos {
        fn   := SubStr(msg, 1, colonPos-1)
        data := SubStr(msg, colonPos+1)
    } else {
        fn   := msg
        data := ""
    }

    switch fn {
        case "Save":              JS_Save(data)
        case "StartMacro":        StartMacro()
        case "PauseMacro":        PauseMacro()
        case "StopMacro":         StopMacro()
        case "JoinPrivate":       JoinPrivate()
        case "JoinPublic":        JoinPublic()
        case "TestReconnect":     DoReconnect()
        case "RefreshRobloxDetected": JS_RefreshDetected()
        case "OpenWebVersion":    Run HIVEHUB_URL
        case "AddProfile":        AddProfile()
        case "LoadSelectedProfile": LoadSelectedProfile()
        case "DeleteProfile":     DeleteProfile()
    }
}

; Push AHK state to JS as loadState()
PushStateToJS(*) {
    global cfg, currentProfile, wv2ready
    if !wv2ready
        return

    profiles := GetProfileList()
    profileJSON := "["
    for i, n in profiles
        profileJSON .= (i>1 ? "," : "") '"' EscJ(n) '"'
    profileJSON .= "]"

    keys := "{"
    for k, v in cfg["hotbarKeys"]
        keys .= '"' k '":' (v ? "true" : "false") ','
    keys := RTrim(keys, ",") "}"

    json := '{'
    . '"baseSpeed":'       cfg["baseSpeed"]       ','
    . '"direction":'       cfg["direction"]        ','
    . '"lengthIdx":'       cfg["lengthIdx"]        ','
    . '"width":'           cfg["width"]            ','
    . '"camAlign":'        cfg["camAlign"]         ','
    . '"camSteps":'        cfg["camSteps"]         ','
    . '"shiftLock":'       (cfg["shiftLock"]       ? "true" : "false") ','
    . '"autoHarvest":'     (cfg["autoHarvest"]     ? "true" : "false") ','
    . '"keyDelay":'        cfg["keyDelay"]         ','
    . '"hotbarEnable":'    (cfg["hotbarEnable"]    ? "true" : "false") ','
    . '"hotbarInterval":'  cfg["hotbarInterval"]   ','
    . '"hotbarKeys":'      keys                    ','
    . '"privServer":"'   EscJ(cfg["privServer"])  '",'
    . '"joinMethod":'      cfg["joinMethod"]       ','
    . '"reconnectEnable":' (cfg["reconnectEnable"] ? "true" : "false") ','
    . '"reconnectHours":'  cfg["reconnectHours"]   ','
    . '"reconnectHH":'     cfg["reconnectHH"]      ','
    . '"reconnectMM":'     cfg["reconnectMM"]      ','
    . '"fallbackPublic":'  (cfg["fallbackPublic"]  ? "true" : "false") ','
    . '"pubServer":"'    EscJ(cfg["pubServer"])   '",'
    . '"profiles":'        profileJSON             ','
    . '"currentProfile":"' EscJ(currentProfile)   '"'
    . '}'

    wv2.ExecuteScript('window.HiveHub.loadState(' json ')')
}

; JSON string escape helper
EscJ(s) => StrReplace(StrReplace(StrReplace(s, "\", "\\"), '"', '\"'), "`n", "\n")

; JS → AHK: Save called on every UI change
JS_Save(data) {
    global cfg, currentProfile
    ; Parse JSON manually — light, no deps
    ParseJSONIntoCfg(data)
    SaveProfile()
}

; Light JSON parser for our known flat+one-level-nested shape
ParseJSONIntoCfg(json) {
    global cfg

    ; numbers / booleans
    for key in ["baseSpeed","direction","lengthIdx","width","camAlign","camSteps",
                "keyDelay","hotbarInterval","joinMethod","reconnectHours",
                "reconnectHH","reconnectMM"] {
        if RegExMatch(json, '"' key '"\s*:\s*([\d.]+)', &m)
            cfg[key] := Float(m[1])
    }
    for key in ["shiftLock","autoHarvest","hotbarEnable","reconnectEnable","fallbackPublic"] {
        if RegExMatch(json, '"' key '"\s*:\s*(true|false)', &m)
            cfg[key] := (m[1] = "true")
    }
    for key in ["privServer","pubServer","profileName","selectedProfile"] {
        if RegExMatch(json, '"' key '"\s*:\s*"((?:[^"\\]|\\.)*)"', &m)
            cfg[key] := StrReplace(StrReplace(m[1], '\"', '"'), "\\", "\")
    }

    ; hotbarKeys: {"1":true,"2":false,...}
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

; JS call: refresh detected Roblox label
JS_RefreshDetected() {
    hwnd := GetRobloxHWND()
    if hwnd {
        try title := WinGetTitle("ahk_id " hwnd)
        catch
            title := "Roblox"
        name := (title != "") ? SubStr(title,1,30) : "Roblox"
        JS('window.HiveHub.setDetected("' EscJ(name) '", true)')
    } else {
        JS('window.HiveHub.setDetected("Not detected", false)')
    }
}

; Shortcut: execute JS
JS(script) {
    global wv2, wv2ready
    if wv2ready
        wv2.ExecuteScript(script)
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
        return {valid:true, code:"", type:"public"}
    if RegExMatch(str,"i)roblox\.com\/([a-z]{2}\/)?games\/1537690962\/?[^?]*\?privateServerLinkCode=(?P<code>[a-z0-9]{32})",&m)
        return {valid:true, code:m.code, type:"private"}
    if RegExMatch(str,"i)roblox\.com\/share\?code=(?P<code>[a-f0-9]{32})&type=Server",&m)
        return {valid:true, code:m.code, type:"share"}
    return {valid:false, code:"", type:""}
}

JoinPrivate() {
    result := ValidateServerLink(cfg["privServer"])
    if !result.valid {
        MsgBox "Invalid private server link.","HiveHub",0x40030
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

    ; Fixed UTC time
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

    ; Hourly interval
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
;  STATS  (pushed to JS every 500ms while running)
; ================================================================
UpdateStats() {
    global running, runStartTime, cycleCount, currentRow, currentPass
    if !running
        return
    elapsed := A_TickCount - runStartTime
    s := Format("{:02}", Floor(Mod(elapsed / 1000, 60)))
    m := Format("{:02}", Floor(elapsed / 60000))
    p := currentPass = 1 ? "Fwd" : (currentPass = 2 ? "Bck" : "-")
    JS('window.HiveHub.setStats("' m ':' s ' | P:' p ' R:' currentRow ' C:' cycleCount '")')
}

ResetStats() {
    global cycleCount, currentRow, currentPass, runStartTime
    cycleCount := 0, currentRow := 0, currentPass := 0, runStartTime := 0
    JS('window.HiveHub.setStats("00:00 | P:- R:0 C:0")')
}

; ================================================================
;  AUTO-KEY (hotbar)
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
    autoKeyTimer := SetTimer(SendAutoKey, interval)
}

StopAutoKey() {
    global autoKeyTimer
    if autoKeyTimer
        SetTimer(SendAutoKey, 0)
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
GetProfileList() {
    global INI_PATH
    try {
        raw  := IniRead(INI_PATH, "ProfileList", "Names", "Default")
        list := StrSplit(raw, "|")
        return (list.Length = 0 || list[1] = "") ? ["Default"] : list
    }
    return ["Default"]
}

SaveProfileList(list) {
    global INI_PATH
    joined := ""
    for i, name in list
        joined .= (i > 1 ? "|" : "") name
    IniWrite joined, INI_PATH, "ProfileList", "Names"
}

LoadProfile(name) {
    global INI_PATH, currentProfile, cfg, HIVEHUB_URL
    currentProfile := name
    sec            := "Profile_" name

    cfg["baseSpeed"]       := Integer(IniRead(INI_PATH, sec, "BaseSpeed",      "16"))
    cfg["direction"]       := Integer(IniRead(INI_PATH, sec, "Direction",      "1"))
    cfg["lengthIdx"]       := Integer(IniRead(INI_PATH, sec, "LengthIdx",      "3"))
    cfg["width"]           := Integer(IniRead(INI_PATH, sec, "Width",          "3"))
    cfg["camAlign"]        := Integer(IniRead(INI_PATH, sec, "CamAlign",       "1"))
    cfg["camSteps"]        := Integer(IniRead(INI_PATH, sec, "CamSteps",       "1"))
    cfg["shiftLock"]       := Integer(IniRead(INI_PATH, sec, "ShiftLock",      "0")) = 1
    cfg["autoHarvest"]     := Integer(IniRead(INI_PATH, sec, "AutoHarvest",    "1")) = 1
    cfg["keyDelay"]        := Integer(IniRead(INI_PATH, sec, "KeyDelay",       "20"))
    cfg["hotbarEnable"]    := Integer(IniRead(INI_PATH, sec, "HotbarEnable",   "0")) = 1
    cfg["hotbarInterval"]  := Integer(IniRead(INI_PATH, sec, "HotbarInterval", "30"))
    cfg["privServer"]      := IniRead(INI_PATH, sec, "PrivServer",     "")
    cfg["joinMethod"]      := Integer(IniRead(INI_PATH, sec, "JoinMethod",     "1"))
    cfg["reconnectEnable"] := Integer(IniRead(INI_PATH, sec, "ReconnectEnable","0")) = 1
    cfg["reconnectHours"]  := Float(IniRead(INI_PATH, sec, "ReconnectHours",  "0"))
    cfg["reconnectHH"]     := Integer(IniRead(INI_PATH, sec, "ReconnectHH",    "0"))
    cfg["reconnectMM"]     := Integer(IniRead(INI_PATH, sec, "ReconnectMM",    "0"))
    cfg["fallbackPublic"]  := Integer(IniRead(INI_PATH, sec, "FallbackPublic", "1")) = 1
    pub                    := IniRead(INI_PATH, sec, "PubServer", "")
    cfg["pubServer"]       := (pub = "") ? HIVEHUB_URL : pub

    ; hotbar keys
    keys := Map()
    keysRaw := IniRead(INI_PATH, sec, "HotbarKeys", "")
    if keysRaw != ""
        for pair in StrSplit(keysRaw, ",")
            if RegExMatch(pair, "^(\d+):(0|1)$", &m)
                keys[m[1]] := (m[2] = "1")
    cfg["hotbarKeys"] := keys

    try IniWrite name, INI_PATH, "LastUsed", A_UserName
    PushStateToJS()
}

SaveProfile() {
    global INI_PATH, currentProfile, cfg
    _WriteINI("Profile_" currentProfile)
}

SaveNamedProfile(name) {
    _WriteINI("Profile_" name)
}

_WriteINI(sec) {
    global INI_PATH, cfg, HIVEHUB_URL
    IniWrite cfg["baseSpeed"],       INI_PATH, sec, "BaseSpeed"
    IniWrite cfg["direction"],       INI_PATH, sec, "Direction"
    IniWrite cfg["lengthIdx"],       INI_PATH, sec, "LengthIdx"
    IniWrite cfg["width"],           INI_PATH, sec, "Width"
    IniWrite cfg["camAlign"],        INI_PATH, sec, "CamAlign"
    IniWrite cfg["camSteps"],        INI_PATH, sec, "CamSteps"
    IniWrite (cfg["shiftLock"]    ? 1 : 0), INI_PATH, sec, "ShiftLock"
    IniWrite (cfg["autoHarvest"]  ? 1 : 0), INI_PATH, sec, "AutoHarvest"
    IniWrite cfg["keyDelay"],        INI_PATH, sec, "KeyDelay"
    IniWrite (cfg["hotbarEnable"] ? 1 : 0), INI_PATH, sec, "HotbarEnable"
    IniWrite cfg["hotbarInterval"],  INI_PATH, sec, "HotbarInterval"
    IniWrite cfg["privServer"],      INI_PATH, sec, "PrivServer"
    IniWrite cfg["joinMethod"],      INI_PATH, sec, "JoinMethod"
    IniWrite (cfg["reconnectEnable"] ? 1 : 0), INI_PATH, sec, "ReconnectEnable"
    IniWrite cfg["reconnectHours"],  INI_PATH, sec, "ReconnectHours"
    IniWrite cfg["reconnectHH"],     INI_PATH, sec, "ReconnectHH"
    IniWrite cfg["reconnectMM"],     INI_PATH, sec, "ReconnectMM"
    IniWrite (cfg["fallbackPublic"] ? 1 : 0), INI_PATH, sec, "FallbackPublic"
    pub := Trim(cfg["pubServer"])
    IniWrite (pub = "" ? HIVEHUB_URL : pub), INI_PATH, sec, "PubServer"
    ; hotbar keys
    keysStr := ""
    for k, v in cfg["hotbarKeys"]
        keysStr .= k ":" (v ? "1" : "0") ","
    IniWrite RTrim(keysStr, ","), INI_PATH, sec, "HotbarKeys"
}

AddProfile() {
    global cfg
    name := Trim(cfg["profileName"])
    if name = ""
        return
    list   := GetProfileList()
    exists := false
    for n in list
        if n = name
            exists := true
    if !exists {
        list.Push(name)
        SaveProfileList(list)
    }
    SaveNamedProfile(name)
    JS('window.HiveHub.setProfileFeedback("' (exists ? "Saved" : "Created") ': ' EscJ(name) '", true)')
    PushStateToJS()
}

LoadSelectedProfile() {
    global cfg
    name := Trim(cfg["selectedProfile"])
    if name = "" {
        MsgBox "Select a profile first.","HiveHub",0x40030
        return
    }
    list := GetProfileList()
    found := false
    for n in list
        if n = name
            found := true
    if !found {
        MsgBox "Profile not found.","HiveHub",0x40030
        return
    }
    LoadProfile(name)
    JS('window.HiveHub.setProfileFeedback("Loaded: ' EscJ(name) '", true)')
}

DeleteProfile() {
    global cfg, currentProfile
    name := Trim(cfg["selectedProfile"])
    if name = "" {
        MsgBox "Select a profile to delete.","HiveHub",0x40030
        return
    }
    if name = "Default" {
        MsgBox "Cannot delete Default.","HiveHub",0x40030
        return
    }
    list    := GetProfileList()
    newList := []
    for n in list
        if n != name
            newList.Push(n)
    SaveProfileList(newList)
    try IniDelete(INI_PATH, "Profile_" name)
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

OnExit(CleanupKeys)
CleanupKeys(*) {
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
    if running
        return
    if !GetRobloxClientPos() {
        MsgBox "Roblox not found.","HiveHub",0x40030
        return
    }
    spd := cfg["baseSpeed"]
    if spd <= 0 {
        MsgBox "Walk speed must be > 0.","HiveHub",0x40030
        return
    }
    base_movespeed := spd

    ResetStats()
    RevertCamera()
    SetKeyDelay cfg["keyDelay"]

    running := true, paused := false, runStartTime := A_TickCount
    JS('window.HiveHub.setStatus("RUNNING")')
    JS('window.HiveHub.setPauseBtn("⏸  Pause  (F12)")')

    ActivateRoblox()
    if cfg["shiftLock"]
        EnableShiftLock()

    camDir   := ["None","Right","Left"][cfg["camAlign"]]
    camSteps := cfg["camSteps"]
    if (camDir != "None" && camSteps > 0)
        RotateCamera(camDir, camSteps)

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
        currentPass := 1
        curKey := keyA
        loop lengthT {
            if !running
                break
            currentRow := A_Index
            Send "{" curKey " down}"
            Walk(widthT)
            if A_Index < lengthT {
                Send "{" curKey " up}{" FwdKey " down}"
                Walk(1)
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

        currentPass := 2
        loop lengthT {
            if !running
                break
            currentRow := A_Index
            Send "{" curKey " down}"
            Walk(widthT)
            if A_Index < lengthT {
                Send "{" curKey " up}{" BackKey " down}"
                Walk(1)
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
;  START
; ================================================================
pToken := Gdip_Startup()
OnExit((*) => Gdip_Shutdown(pToken))

; Load last-used profile into cfg before GUI opens
lastProfile := ""
try lastProfile := IniRead(INI_PATH, "LastUsed", A_UserName, "Default")
list0 := GetProfileList()
found := false
for n in list0
    if n = lastProfile
        found := true
LoadProfile(found ? lastProfile : "Default")

; Build the WebView2 window (opens UI)
BuildGUI()
