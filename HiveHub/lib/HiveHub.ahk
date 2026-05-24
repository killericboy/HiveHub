; ================================================================
;  HiveHub Macro  V1.3.6  —  by Killericboy
; ================================================================

#Requires AutoHotkey v2.0
#SingleInstance Force
#MaxThreads 4

#Include Gdip_All.ahk
#Include Gdip_ImageSearch.ahk
#Include HyperSleep.ahk
#Include Roblox.ahk
#Include Walk.ahk

SendMode "Event"
CoordMode "Mouse", "Screen"
CoordMode "Pixel", "Screen"

FwdKey   := "sc011"
LeftKey  := "sc01e"
BackKey  := "sc01f"
RightKey := "sc020"
RotLeft   := "sc033"   ; , key — rotate camera left
RotRight  := "sc034"   ; . key — rotate camera right
SC_LShift := "sc02a"   ; Left Shift — toggles ShiftLock in BSS

; ── Walk.ahk globals (hasty_guard and gifted_hasty must be declared globally) ──
; Walk.ahk uses Gdip to detect haste/oil/bear/smoothie from screen automatically.
; hasty_guard and gifted_hasty are from bee stats — cannot be auto-detected,
; so we expose them as user settings later. For now default to false.
base_movespeed := 16   ; updated from UI on Start
hasty_guard    := false   ; set to true if you have Hasty Guard bee equipped
gifted_hasty   := false   ; set to true if Hasty Guard bee is gifted
running      := false
paused       := false
cycleCount   := 0
currentRow   := 0
currentPass  := 0
runStartTime := 0
camRotated      := 0
isLoading       := false
shiftLockActive := false

windowX := 0, windowY := 0, windowWidth := 0, windowHeight := 0

SizeNames := ["XS","S","M","L","XL"]
SizeTiles  := [2, 3, 5, 7, 10]
GetLengthTiles() => SizeTiles[lengthUD.Value]
GetLengthLabel() => SizeNames[lengthUD.Value]
GetWidthTiles()  => widthUD.Value

HIVEHUB_URL    := "https://www.roblox.com/games/15579077077/Hive-Hub"
INI_PATH       := A_ScriptDir "\..\settings\hivehub_config.ini"
BSS_PLACE_ID   := "1537690962"
currentProfile := "Default"

; ── ShiftLock — from NatroMacro nm_setShiftLock ───────────────────
; Natro uses image search to detect current state.
; We use a simpler tracked-state approach: we record whether WE toggled it
; and only revert if we were the ones who enabled it.
; User must ensure ShiftLock is OFF before starting if they want us to enable it.

EnableShiftLock() {
    global shiftLockActive, SC_LShift
    if shiftLockActive    ; already on (we enabled it)
        return
    ActivateRoblox()
    Send "{" SC_LShift "}"   ; toggle on
    Sleep 300
    shiftLockActive := true
}

DisableShiftLock() {
    global shiftLockActive, SC_LShift
    if !shiftLockActive   ; we didn't enable it — don't touch it
        return
    ActivateRoblox()
    Send "{" SC_LShift "}"   ; toggle back off
    Sleep 200
    shiftLockActive := false
}

; ── Camera rotation — copied from NatroMacro nm_CameraRotation ──────────────
; Natro uses RotLeft=sc033 and RotRight=sc034 (keyboard , and . keys)
; Tracks cumulative LR offset in a static variable.
; OnExit hook automatically sends the exact reverse to restore camera angle.
; Called as: RotateCamera("Right", 4)  or  RotateCamera("Left", 2)

RotateCamera(dir, steps) {
    global RotLeft, RotRight, camRotated
    if steps = 0
        return
    ; Use Natro's exact method: send scan code N times in one call
    key := (dir = "Right") ? RotRight : RotLeft
    Send "{" key " " steps "}"
    ; Track offset so RevertCamera can send exact opposite
    camRotated += (dir = "Right") ? steps : -steps
    Sleep 150
}

RevertCamera() {
    global RotLeft, RotRight, camRotated
    if camRotated = 0
        return
    ; Send exact reverse — same logic as Natro's OnExit handler
    key   := (camRotated > 0) ? RotLeft : RotRight
    steps := Abs(camRotated)
    Send "{" key " " steps "}"
    camRotated := 0
    Sleep 150
}

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

CalcSpeed() {
    v := Trim(baseSpeedEdit.Value)
    return (v="" || !IsNumber(v)) ? 16 : Integer(v)
}

UpdateSpeedLabel(*) {
    speedLabel.Value := CalcSpeed()
}

UpdateDetectedSpeed(detectedSpd) {
    ; Called when Walk.ahk detects a speed change
    base := CalcSpeed()
    diff := Round(detectedSpd - base, 1)
    if diff > 0
        detectedLabel.Value := "(+" diff " haste)"
    else if diff < 0
        detectedLabel.Value := "(" diff ")"
    else
        detectedLabel.Value := ""
    speedLabel.Value := Round(detectedSpd, 1)
}

UpdateStats() {
    global running, runStartTime, cycleCount, currentRow, currentPass
    if !running
        return
    elapsed := A_TickCount - runStartTime
    s := Format("{:02}", Floor(Mod(elapsed/1000,60)))
    m := Format("{:02}", Floor(elapsed/60000))
    p := currentPass=1 ? "Fwd" : (currentPass=2 ? "Bck" : "-")
    statsLabel.Value := m ":" s " | P:" p " R:" currentRow " C:" cycleCount
}

ResetStats() {
    global cycleCount, currentRow, currentPass, runStartTime
    cycleCount := 0 , currentRow := 0 , currentPass := 0 , runStartTime := 0
    statsLabel.Value := "00:00 | P:- R:0 C:0"
}

; ── Auto-key press (tool/equip) ────────────────────────────────
; Sends a number key (1-7) every X seconds while macro is running
autoKeyTimer := 0

StartAutoKey() {
    global autoKeyTimer
    StopAutoKey()
    if !autoKeyEnableBox.Value
        return
    interval := Float(autoKeyIntervalEdit.Value) * 1000
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
    global running, paused, hotbarKey
    if !running || paused
        return
    loop 7 {
        if hotbarKey[A_Index].Value
            SendInput "{" A_Index "}"
    }
}

; ── Profile system ─────────────────────────────────────────────
GetProfileList() {
    global INI_PATH
    try {
        raw := IniRead(INI_PATH, "ProfileList", "Names", "Default")
        list := StrSplit(raw, "|")
        return (list.Length=0 || list[1]="") ? ["Default"] : list
    }
    return ["Default"]
}

SaveProfileList(list) {
    global INI_PATH
    joined := ""
    for i, name in list
        joined .= (i>1 ? "|" : "") name
    IniWrite joined, INI_PATH, "ProfileList", "Names"
}

LoadProfile(name) {
    global INI_PATH, currentProfile, isLoading, HIVEHUB_URL
    isLoading      := true
    currentProfile := name
    sec            := "Profile_" name

    baseSpeedEdit.Value     := IniRead(INI_PATH, sec, "BaseSpeed",    "16")
    lengthUD.Value          := Integer(IniRead(INI_PATH, sec, "LengthIdx",   "3"))
    widthUD.Value           := Integer(IniRead(INI_PATH, sec, "Width",       "3"))
    dirDDL.Value            := Integer(IniRead(INI_PATH, sec, "Direction",   "1"))
    autoClickBox.Value      := Integer(IniRead(INI_PATH, sec, "AutoHarvest", "1"))
    camAlignDDL.Value       := Integer(IniRead(INI_PATH, sec, "CamDir",      "1"))
    camStepsUD.Value        := Integer(IniRead(INI_PATH, sec, "CamSteps",    "0"))
    autoKeyEnableBox.Value  := Integer(IniRead(INI_PATH, sec, "AutoKeyOn",   "0"))
    autoKeyIntervalEdit.Value := IniRead(INI_PATH, sec, "AutoKeyInt",  "30")
    privServerEdit.Value    := IniRead(INI_PATH, sec, "PrivServer",   "")
    keyDelayUD.Value        := Integer(IniRead(INI_PATH, sec, "KeyDelay",    "20"))
    savedPub                := IniRead(INI_PATH, sec, "PubServer",    "")
    pubServerEdit.Value     := (savedPub="") ? HIVEHUB_URL : savedPub

    isLoading := false
    lengthLabel.Value := GetLengthLabel()
    UpdateSpeedLabel()
    RefreshSrvLabel()
    G.Title := "HiveHub Macro  v1.4.0  [" name "]"
    try IniWrite name, INI_PATH, "LastUsed", A_UserName
}

SaveProfile() {
    global INI_PATH, currentProfile, isLoading, HIVEHUB_URL
    if isLoading
        return
    sec := "Profile_" currentProfile
    pub := Trim(pubServerEdit.Value)
    IniWrite baseSpeedEdit.Value,                  INI_PATH, sec, "BaseSpeed"
    IniWrite lengthUD.Value,                       INI_PATH, sec, "LengthIdx"
    IniWrite widthUD.Value,                        INI_PATH, sec, "Width"
    IniWrite dirDDL.Value,                         INI_PATH, sec, "Direction"
    IniWrite autoClickBox.Value,                   INI_PATH, sec, "AutoHarvest"
    IniWrite camAlignDDL.Value,  INI_PATH, sec, "CamDir"
    IniWrite camStepsUD.Value,   INI_PATH, sec, "CamSteps"
    IniWrite autoKeyEnableBox.Value,               INI_PATH, sec, "AutoKeyOn"
    IniWrite autoKeyIntervalEdit.Value,            INI_PATH, sec, "AutoKeyInt"
    IniWrite privServerEdit.Value,                 INI_PATH, sec, "PrivServer"
    IniWrite (pub="" ? HIVEHUB_URL : pub),         INI_PATH, sec, "PubServer"
    IniWrite keyDelayUD.Value,                     INI_PATH, sec, "KeyDelay"
}

SaveNamedProfile(name) {
    global INI_PATH, HIVEHUB_URL
    sec := "Profile_" name
    pub := Trim(pubServerEdit.Value)
    IniWrite baseSpeedEdit.Value,                  INI_PATH, sec, "BaseSpeed"
    IniWrite lengthUD.Value,                       INI_PATH, sec, "LengthIdx"
    IniWrite widthUD.Value,                        INI_PATH, sec, "Width"
    IniWrite dirDDL.Value,                         INI_PATH, sec, "Direction"
    IniWrite autoClickBox.Value,                   INI_PATH, sec, "AutoHarvest"
    IniWrite camAlignDDL.Value,  INI_PATH, sec, "CamDir"
    IniWrite camStepsUD.Value,   INI_PATH, sec, "CamSteps"
    IniWrite autoKeyEnableBox.Value,               INI_PATH, sec, "AutoKeyOn"
    IniWrite autoKeyIntervalEdit.Value,            INI_PATH, sec, "AutoKeyInt"
    IniWrite privServerEdit.Value,                 INI_PATH, sec, "PrivServer"
    IniWrite (pub="" ? HIVEHUB_URL : pub),         INI_PATH, sec, "PubServer"
    IniWrite keyDelayUD.Value,                     INI_PATH, sec, "KeyDelay"
}

RefreshSrvLabel() {
    result := ValidateServerLink(privServerEdit.Value)
    if !result.valid {
        srvLabel.Value := "Invalid"
        srvLabel.Opt("cRed")
    } else if result.type = "public" {
        srvLabel.Value := "No private link"
        srvLabel.Opt("c607080")
    } else {
        srvLabel.Value := (result.type="share" ? "Share ✓" : "Private ✓")
        srvLabel.Opt("cLime")
    }
}

; ================================================================
;  LAYOUT CONSTANTS
; ================================================================
; Window
winW  := 480
winBX := 8     ; border x (left & right)

; Inner control area
ctrlX  := 16              ; controls start x
ctrlW  := 448             ; controls width  (16..464)
ctrlRX := ctrlX + ctrlW   ; right edge = 464

; Two-column split for main tab
leftCX  := 16             ; left col x
leftCW  := 210            ; left col width  (16..226)
rightCX := 248            ; right col x     (deliberately 248 not 242)
rightCW := ctrlRX - rightCX  ; right col width = 216  (248..464)

; Right col halves (for Length/Width and Camera/Steps side-by-side)
rightHalfW  := rightCW // 2   ; 108
rightMidX   := rightCX + rightHalfW   ; 356

; Tab content box
boxTop  := 64
boxBot  := 268   ; tall enough for Settings tab
boxH    := boxBot - boxTop

; Status row inside main tab
statusY := boxBot - 20   ; 248

; Bottom buttons (below box)
btnY  := boxBot + 16     ; 284
btnW  := 144             ; each button width
btn1X := 8               ; Start x
btn2X := 160             ; Pause x  (8+144+8)
btn3X := 312             ; Stop  x  (160+144+8)

; Total window height
winH := btnY + 34        ; 318

ctrlBG := "Background172433"

; ================================================================
G := Gui("+AlwaysOnTop","HiveHub Macro  v1.4.0  [Default]")
G.BackColor := "0D1825"

SF(sz, bold:=0) {
    global G
    G.SetFont("s" sz (bold?" Bold":""), "Courier New")
}

; ── Title ──────────────────────────────────────────────────────
G.SetFont("s12 Bold","Verdana")
G.AddText("x8 y6 w464 Center c00E5FF","HiveHub Macro")
SF(8)
G.AddText("x8 y26 w464 Center cE8A020","by Killericboy")

; ── Tab buttons ────────────────────────────────────────────────
SF(9,1)
tabMainBtn     := G.AddText("x8   y42 w90 h22 +0x100 +Border +Center Background1E3050 cWhite",  "Main")
tabSettingsBtn := G.AddText("x102 y42 w90 h22 +0x100 +Border +Center Background0D1825 c8090A0", "Settings")
tabProfileBtn  := G.AddText("x196 y42 w90 h22 +0x100 +Border +Center Background0D1825 c8090A0", "Profiles")
tabMainBtn.OnEvent(    "Click", (*) => ShowTab(1))
tabSettingsBtn.OnEvent("Click", (*) => ShowTab(2))
tabProfileBtn.OnEvent( "Click", (*) => ShowTab(3))

; ── Content border ─────────────────────────────────────────────
G.AddText("x8 y64 w464 h218 +Border BackgroundTrans")

; ================================================================
;  MAIN TAB
;
;  Left  (x=16..230):  Walk Speed  |  Field Size
;  Right (x=248..464): Direction   |  Camera Align
;  Full  (y=188+):     Tool  →  Hotbar  →  Status
; ================================================================
mainCtrls := []

; ── Left: Walk Speed ───────────────────────────────────────────
SF(9,1)
mainCtrls.Push(G.AddText("x16 y72 w90 cE8A020","WALK SPEED"))
; Live speed display — shows base + dynamically detected speed
speedLabel    := G.AddText("x110 y72 w60 cLime","29")
detectedLabel := G.AddText("x174 y72 w100 c607080","")   ; shows "(+haste)" etc
mainCtrls.Push(speedLabel), mainCtrls.Push(detectedLabel)

SF(9)
baseSpeedEdit := G.AddEdit("x16 y88 w70 h20 Background172433 cWhite Limit4","16")
baseSpeedEdit.OnEvent("Change",(*) => (UpdateSpeedLabel(),SaveProfile()))
mainCtrls.Push(baseSpeedEdit)

; ── Left: Field Size ───────────────────────────────────────────
SF(9,1)
mainCtrls.Push(G.AddText("x16 y116 w210 cE8A020","FIELD SIZE"))
SF(8)
mainCtrls.Push(G.AddText("x16  y132 w80 +Center c607080","Length"))
mainCtrls.Push(G.AddText("x104 y132 w80 +Center c607080","Width"))
SF(9)
lengthLabel := G.AddText("x24  y148 w52 h20 0x201 +Center Background172433 cWhite","M")
lengthUD    := G.AddUpDown("Range1-5",3)
lengthUD.OnEvent("Change",(*) => (lengthLabel.Value:=GetLengthLabel(),SaveProfile()))
mainCtrls.Push(lengthLabel), mainCtrls.Push(lengthUD)
widthEdit   := G.AddEdit("x112 y148 w52 h20 0x201 +Center +ReadOnly Background172433 cWhite","3")
widthUD     := G.AddUpDown("Range1-9",3)
widthUD.OnEvent("Change",(*) => SaveProfile())
mainCtrls.Push(widthEdit), mainCtrls.Push(widthUD)

; ── Right: Direction ───────────────────────────────────────────
SF(9,1)
mainCtrls.Push(G.AddText("x248 y72 w216 cE8A020","DIRECTION"))
SF(9)
dirDDL := G.AddDropDownList("x248 y88 w208 Background172433 cWhite Choose1",["Right/Left","Left/Right","Standing"])
dirDDL.OnEvent("Change",(*) => SaveProfile())
mainCtrls.Push(dirDDL)

; ── Right: Camera Align ────────────────────────────────────────
SF(9,1)
mainCtrls.Push(G.AddText("x248 y116 w216 cE8A020","CAMERA ALIGN"))
SF(9)
camAlignDDL  := G.AddDropDownList("x248 y132 w120 Background172433 cWhite Choose1",["None","Right","Left"])
camStepsEdit := G.AddEdit("x406 y132 w50 h20 0x201 +Center +ReadOnly Background172433 cWhite","1")
camStepsUD   := G.AddUpDown("Range1-8",1)
camAlignDDL.OnEvent("Change",(*) => SaveProfile())
camStepsUD.OnEvent("Change",(*) => SaveProfile())
mainCtrls.Push(camAlignDDL), mainCtrls.Push(camStepsEdit), mainCtrls.Push(camStepsUD)
; ShiftLock checkbox inline with camera
shiftLockBox := G.AddCheckbox("x248 y160 w208 cSilver Checked0","Enable ShiftLock")
shiftLockBox.OnEvent("Click",(*) => SaveProfile())
mainCtrls.Push(shiftLockBox)

; ── Full width divider ─────────────────────────────────────────
mainCtrls.Push(G.AddText("x16 y180 w448 h1 0x10"))

; ── TOOL row: Auto harvest | ShiftLock (already in camera section) ────────────
SF(9,1)
mainCtrls.Push(G.AddText("x16 y186 w40 cE8A020","TOOL"))
SF(9)
autoClickBox := G.AddCheckbox("x60 y186 w180 cSilver Checked1","Auto harvest (F11)")
autoClickBox.OnEvent("Click",(*) => SaveProfile())
mainCtrls.Push(autoClickBox)

; ── HOTBAR row ─────────────────────────────────────────────────
mainCtrls.Push(G.AddText("x16 y206 w448 h1 0x10"))
SF(9,1)
mainCtrls.Push(G.AddText("x16 y218 w60 cE8A020","HOTBAR"))
SF(9)
autoKeyEnableBox := G.AddCheckbox("x80 y218 w64 cSilver Checked0","Enable")
autoKeyEnableBox.OnEvent("Click",(*) => SaveProfile())
mainCtrls.Push(autoKeyEnableBox)
mainCtrls.Push(G.AddText("x158 y220 w34 c607080","Every"))
autoKeyIntervalEdit := G.AddEdit("x198 y218 w36 h18 Background172433 cWhite Limit4","30")
autoKeyIntervalEdit.OnEvent("Change",(*) => SaveProfile())
mainCtrls.Push(autoKeyIntervalEdit)
mainCtrls.Push(G.AddText("x238 y220 w14 c607080","s"))
SF(8)
hotbarKey := []
loop 7 {
    cb := G.AddCheckbox("x" (256 + (A_Index-1)*28) " y218 w26 h16 cSilver Checked0", A_Index)
    cb.OnEvent("Click",(*) => SaveProfile())
    mainCtrls.Push(cb)
    hotbarKey.Push(cb)
}

; ── STATUS + TIMER pinned to bottom ────────────────────────────
mainCtrls.Push(G.AddText("x16 y248 w448 h1 0x10"))
SF(9)
statsLabel  := G.AddText("x16 y256 w200 c607080","00:00 | P:- R:0 C:0")
mainCtrls.Push(statsLabel)
SF(9,1)
mainCtrls.Push(G.AddText("x358 y256 w46 cE8A020","STATUS"))
statusLabel := G.AddText("x408 y256 w56 cRed","STOPPED")
mainCtrls.Push(statusLabel)

; ================================================================
;  SETTINGS TAB
; ================================================================
settingsCtrls := []

SF(9,1)
settingsCtrls.Push(G.AddText("x16 y72 w448 cE8A020","SERVER"))
SF(9)
settingsCtrls.Push(G.AddText("x16 y90 w110 c607080","Private server:"))
srvLabel := G.AddText("x130 y90 w334 c607080","No private link")
settingsCtrls.Push(srvLabel)
privServerEdit := G.AddEdit("x16 y106 w448 h20 Background172433 cWhite","")
privServerEdit.OnEvent("Change",(*) => (RefreshSrvLabel(),SaveProfile()))
settingsCtrls.Push(privServerEdit)

settingsCtrls.Push(G.AddText("x16 y132 w448 c607080","Public / fallback link:"))
pubServerEdit := G.AddEdit("x16 y148 w448 h20 Background172433 cWhite","https://www.roblox.com/games/15579077077/Hive-Hub")
pubServerEdit.OnEvent("Change",(*) => SaveProfile())
settingsCtrls.Push(pubServerEdit)

joinPrivBtn := G.AddButton("x16  y174 w220 h24","Join Private")
joinPubBtn  := G.AddButton("x244 y174 w220 h24","Join Public")
joinPrivBtn.OnEvent("Click",JoinPrivate)
joinPubBtn.OnEvent("Click", JoinPublic)
settingsCtrls.Push(joinPrivBtn), settingsCtrls.Push(joinPubBtn)

settingsCtrls.Push(G.AddText("x16 y206 w448 h1 0x10"))
SF(9,1)
settingsCtrls.Push(G.AddText("x16 y212 w220 cE8A020","INPUT"))
SF(9)
settingsCtrls.Push(G.AddText("x16 y230 w72 c607080","Key Delay:"))
keyDelayEdit := G.AddEdit("x92 y228 w44 h18 0x201 +Center +ReadOnly Background172433 cWhite","20")
keyDelayUD   := G.AddUpDown("Range0-500",20)
keyDelayUD.OnEvent("Change",(*) => SaveProfile())
settingsCtrls.Push(keyDelayEdit), settingsCtrls.Push(keyDelayUD)

; ================================================================
;  PROFILES TAB
; ================================================================
profileCtrls := []
LBW  := 240
RPX  := 268
RPW  := 196

SF(9,1)
profileCtrls.Push(G.AddText("x16 y72 w448 cE8A020","PROFILES"))
SF(9)
profileListBox := G.AddListBox("x16 y90 w240 h162 Background172433 cWhite",[])
profileListBox.OnEvent("Change",OnProfileSelect)
profileCtrls.Push(profileListBox)

SF(8)
profileCtrls.Push(G.AddText("x268 y90 w196 c607080","Profile name:"))
SF(9)
newProfileEdit := G.AddEdit("x268 y106 w196 h18 Background172433 cWhite","")
profileCtrls.Push(newProfileEdit)
addBtn    := G.AddButton("x268 y130 w196 h20","Add / Save")
loadBtn   := G.AddButton("x268 y154 w196 h20","Load")
deleteBtn := G.AddButton("x268 y178 w196 h20","Delete")
addBtn.OnEvent("Click",    AddProfile)
loadBtn.OnEvent("Click",   LoadSelectedProfile)
deleteBtn.OnEvent("Click", DeleteProfile)
profileCtrls.Push(addBtn), profileCtrls.Push(loadBtn), profileCtrls.Push(deleteBtn)
SF(8)
profileFeedback := G.AddText("x268 y204 w196 c607080","")
profileCtrls.Push(profileFeedback)

; Hide non-active tabs
for ctrl in settingsCtrls
    try ctrl.Visible := false
for ctrl in profileCtrls
    try ctrl.Visible := false

; ── Bottom buttons ─────────────────────────────────────────────
G.AddText("x8 y282 w464 h2 0x11")
SF(9)
startBtn := G.AddButton("x8   y288 w148 h26","▶  Start  (F9)")
pauseBtn := G.AddButton("x166 y288 w148 h26","⏸  Pause  (F12)")
stopBtn  := G.AddButton("x324 y288 w148 h26","■  Stop  (F10)")
startBtn.SetFont("s9 Bold cLime",   "Courier New")
pauseBtn.SetFont("s9 Bold cE8A020", "Courier New")
stopBtn.SetFont( "s9 Bold cFF4444", "Courier New")

G.OnEvent("Close",(*) => ExitApp())
G.Show("w480 h322")
pToken := Gdip_Startup()
OnExit((*) => Gdip_Shutdown(pToken))

; ── Startup ────────────────────────────────────────────────────
RefreshProfileList()
lastProfile := IniRead(INI_PATH, "LastUsed", A_UserName, "Default")
list0 := GetProfileList()
found := false
for n in list0
    if n = lastProfile
        found := true
LoadProfile(found ? lastProfile : "Default")
RefreshProfileList()

iconFile := A_ScriptDir "\..\assets\bee.ico"
if FileExist(iconFile) {
    TraySetIcon iconFile
    SendMessage 0x80,0,DllCall("LoadImage","Ptr",0,"Str",iconFile,"UInt",1,"Int",16,"Int",16,"UInt",0x50),,"ahk_id " G.Hwnd
    SendMessage 0x80,1,DllCall("LoadImage","Ptr",0,"Str",iconFile,"UInt",1,"Int",32,"Int",32,"UInt",0x50),,"ahk_id " G.Hwnd
}

; ── Tab switcher ───────────────────────────────────────────────
currentTab := 1
ShowTab(n) {
    global currentTab
    if n = currentTab
        return
    currentTab := n
    for ctrl in mainCtrls
        try ctrl.Visible := (n=1)
    for ctrl in settingsCtrls
        try ctrl.Visible := (n=2)
    for ctrl in profileCtrls
        try ctrl.Visible := (n=3)
    tabMainBtn.Opt(    n=1 ? "Background1E3050 cWhite" : "Background0D1825 c8090A0")
    tabSettingsBtn.Opt(n=2 ? "Background1E3050 cWhite" : "Background0D1825 c8090A0")
    tabProfileBtn.Opt( n=3 ? "Background1E3050 cWhite" : "Background0D1825 c8090A0")
}

; ── Profile helpers ────────────────────────────────────────────
RefreshProfileList() {
    global currentProfile
    list := GetProfileList()
    profileListBox.Delete()
    for i, name in list {
        profileListBox.Add([name])
        if name = currentProfile
            profileListBox.Value := i
    }
}

SetProfileFeedback(msg, col := "cLime") {
    profileFeedback.Value := msg
    profileFeedback.Opt(col)
    SetTimer () => (profileFeedback.Value := ""), -3000
}

OnProfileSelect(*) {
    list := GetProfileList()
    idx  := profileListBox.Value
    if idx >= 1 && idx <= list.Length
        newProfileEdit.Value := list[idx]
}

LoadSelectedProfile(*) {
    list := GetProfileList()
    idx  := profileListBox.Value
    if idx < 1 || idx > list.Length {
        MsgBox "Select a profile first.","HiveHub",0x40030
        return
    }
    LoadProfile(list[idx])
    RefreshProfileList()
    SetProfileFeedback("✓ Loaded: " list[idx])
}

AddProfile(*) {
    name := Trim(newProfileEdit.Value)
    if name = ""
        return
    list := GetProfileList()
    exists := false
    for n in list
        if n = name
            exists := true
    if !exists {
        list.Push(name)
        SaveProfileList(list)
    }
    SaveNamedProfile(name)
    RefreshProfileList()
    newProfileEdit.Value := ""
    SetProfileFeedback(exists ? "✓ Saved: " name : "✓ Created: " name)
}

DeleteProfile(*) {
    list := GetProfileList()
    idx  := profileListBox.Value
    if idx < 1 || idx > list.Length {
        MsgBox "Select a profile to delete.","HiveHub",0x40030
        return
    }
    name := list[idx]
    if name = "Default" {
        MsgBox "Cannot delete Default.","HiveHub",0x40030
        return
    }
    newList := []
    for n in list
        if n != name
            newList.Push(n)
    SaveProfileList(newList)
    try IniDelete(INI_PATH, "Profile_" name)
    LoadProfile("Default")
    RefreshProfileList()
    SetProfileFeedback("✓ Deleted: " name, "cFF4444")
}

; ── Hotkeys ────────────────────────────────────────────────────
F9::  StartMacro()
F10:: StopMacro()
F11:: ToggleClick()
F12:: PauseMacro()

startBtn.OnEvent("Click",StartMacro)
pauseBtn.OnEvent("Click",PauseMacro)
stopBtn.OnEvent("Click", StopMacro)

OnExit(CleanupKeys)
CleanupKeys(*) {
    for k in [FwdKey,BackKey,LeftKey,RightKey]
        Send "{" k " up}"
    Send "{LButton up}"
    RevertCamera()
    DisableShiftLock()
    StopAutoKey()
}

ToggleClick(*) {
    global autoClickBox
    autoClickBox.Value := !autoClickBox.Value
    if !autoClickBox.Value
        Send "{LButton up}"
    ToolTip "Auto harvest: " (autoClickBox.Value ? "ON" : "OFF")
    SetTimer () => ToolTip(),-1200
}

JoinPrivate(*) {
    result := ValidateServerLink(privServerEdit.Value)
    if !result.valid {
        MsgBox "Invalid private server link.","HiveHub",0x40030
        return
    }
    JoinServer(result.code, result.type="share" ? result.code : "")
}

JoinPublic(*) {
    global HIVEHUB_URL
    link := Trim(pubServerEdit.Value)
    if link = ""
        link := HIVEHUB_URL
    result := ValidateServerLink(link)
    if result.valid && result.type != "public"
        JoinServer(result.code)
    else
        Run link
}

; ── Start ──────────────────────────────────────────────────────
StartMacro(*) {
    global running, paused, runStartTime
    if running
        return
    if !GetRobloxClientPos() {
        MsgBox "Roblox not found.","HiveHub",0x40030
        return
    }
    if CalcSpeed() <= 0 {
        MsgBox "Walk speed must be > 0.","HiveHub",0x40030
        return
    }
    global base_movespeed
    v := Trim(baseSpeedEdit.Value)
    base_movespeed := (v="" || !IsNumber(v)) ? 16 : Integer(v)
    ResetStats()
    RevertCamera()
    SetKeyDelay keyDelayUD.Value
    running := true , paused := false , runStartTime := A_TickCount
    statusLabel.Value := "RUNNING"
    statusLabel.Opt("cLime")
    pauseBtn.Text := "⏸  Pause  (F12)"
    ActivateRoblox()
    if shiftLockBox.Value
        EnableShiftLock()
    camDir   := ["None","Right","Left"][camAlignDDL.Value]
    camSteps := camStepsUD.Value
    if camDir != "None" && camSteps > 0
        RotateCamera(camDir, camSteps)
    SetTimer UpdateStats, 500
    StartAutoKey()
    SetTimer SnakeThread, -1
}

; ── Pause ──────────────────────────────────────────────────────
PauseMacro(*) {
    global running, paused
    if !running
        return
    paused := !paused
    if paused {
        for k in [FwdKey,BackKey,LeftKey,RightKey]
            Send "{" k " up}"
        statusLabel.Value := "PAUSED"
        statusLabel.Opt("cE8A020")
        pauseBtn.Text := "▶  Resume  (F12)"
        StopAutoKey()
    } else {
        statusLabel.Value := "RUNNING"
        statusLabel.Opt("cLime")
        pauseBtn.Text := "⏸  Pause  (F12)"
        ActivateRoblox()
        StartAutoKey()
    }
}

StopMacro(*) {
    global running, paused
    running := false , paused := false
    SetTimer UpdateStats, 0
    for k in [FwdKey,BackKey,LeftKey,RightKey]
        Send "{" k " up}"
    Send "{LButton up}"
    RevertCamera()
    DisableShiftLock()
    StopAutoKey()
    statusLabel.Value := "STOPPED"
    statusLabel.Opt("cRed")
    pauseBtn.Text := "⏸  Pause  (F12)"
    SetKeyDelay -1
    ResetStats()
}

; ── Snake thread ───────────────────────────────────────────────
SnakeThread() {
    global running, paused, autoClickBox, FwdKey, BackKey, LeftKey, RightKey
    global cycleCount, currentRow, currentPass
    lengthT := GetLengthTiles()
    widthT  := GetWidthTiles()
    standing := (dirDDL.Value = 3)   ; Standing mode — no movement
    keyA    := (dirDDL.Value=1) ? RightKey : LeftKey
    keyB    := (dirDDL.Value=1) ? LeftKey  : RightKey
    if autoClickBox.Value
        Send "{LButton down}"

    ; Standing mode: just hold click and let hotbar/harvest run, no walking
    if standing {
        while running {
            if autoClickBox.Value
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
                curKey := (curKey=keyA) ? keyB : keyA
                Send "{" FwdKey " up}{" curKey " down}"
            } else {
                Send "{" curKey " up}"
                curKey := (curKey=keyA) ? keyB : keyA
            }
            if autoClickBox.Value
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
                curKey := (curKey=keyA) ? keyB : keyA
                Send "{" BackKey " up}{" curKey " down}"
            } else {
                Send "{" curKey " up}"
                curKey := (curKey=keyA) ? keyB : keyA
            }
            if autoClickBox.Value
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
    for k in [FwdKey,BackKey,LeftKey,RightKey]
        Send "{" k " up}"
    Send "{LButton up}"
}
