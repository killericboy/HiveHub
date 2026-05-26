; ================================================================
;  WebView2.ahk  —  AHK v2 WebView2 host wrapper
;  Requires: WebView2Loader.dll in lib\ (ships with Edge or
;            downloadable from Microsoft's WebView2 page)
;  Microsoft Edge WebView2 Runtime must be installed (free,
;  comes with Windows 11, Win10 via Windows Update).
; ================================================================

class WebView2 {

    hwnd       := 0
    _env       := 0
    _ctrl      := 0
    _wv2       := 0
    _readyCB   := 0
    _msgCB     := 0
    _done      := false
    _loaderDll := ""

    NavigationCompleted { set => this._readyCB := value }
    WebMessageReceived  { set => this._msgCB   := value }

    ; ── Factory ───────────────────────────────────────────────
    static create(hwnd, udFolder := "") {
        inst := WebView2()
        inst.hwnd := hwnd
        inst._init(hwnd, udFolder != "" ? udFolder : A_Temp "\HiveHub_WV2")
        return inst
    }

    _init(hwnd, udFolder) {
        ; Locate loader DLL
        candidates := [
            A_ScriptDir "\WebView2Loader.dll",
            A_ScriptDir "\..\lib\WebView2Loader.dll",
            A_ScriptDir "\lib\WebView2Loader.dll"
        ]
        for path in candidates {
            if FileExist(path) {
                this._loaderDll := path
                break
            }
        }
        if !this._loaderDll
            throw Error("WebView2Loader.dll not found.`n`nPlace it next to HiveHub.ahk or in lib\.`nDownload the fixed version from:`nhttps://developer.microsoft.com/en-us/microsoft-edge/webview2/")

        DllCall("LoadLibrary", "Str", this._loaderDll, "Ptr")

        ; Build ICoreWebView2CreateCoreWebView2EnvironmentCompletedHandler
        ; vtable: [0]=QueryInterface [1]=AddRef [2]=Release [3]=Invoke
        inst := this  ; capture for callback
        envHandler := WebView2._makeHandler(
            (pSelf, errCode, pEnv) {
                if errCode != 0 || !pEnv
                    return errCode
                inst._env := pEnv
                ; Create controller
                ctrlHandler := WebView2._makeHandler(
                    (pSelf2, errCode2, pCtrl) {
                        if errCode2 != 0 || !pCtrl
                            return errCode2
                        inst._ctrl := pCtrl
                        ; Get CoreWebView2 from controller (index 25 in vtable)
                        pWV2 := 0
                        ComCall(25, pCtrl, "Ptr*", &pWV2)
                        inst._wv2 := pWV2

                        ; Resize to fill window
                        RECT := Buffer(16, 0)
                        DllCall("GetClientRect", "Ptr", hwnd, "Ptr", RECT)
                        ; put_Bounds = index 6
                        ComCall(6, pCtrl, "Ptr", RECT)

                        ; Register WebMessageReceived event (index 74 in ICoreWebView2)
                        msgHandler := WebView2._makeHandler(
                            (pSelf3, pSender, pArgs) {
                                if inst._msgCB {
                                    msgVal := WebView2._getMsgString(pArgs)
                                    fakeArgs := {TryGetWebMessageAsString: (*) => msgVal}
                                    inst._msgCB(inst, fakeArgs)
                                }
                                return 0
                            }
                        )
                        token := 0
                        ComCall(74, pWV2, "Ptr", msgHandler.ptr, "Int64*", &token)

                        ; Register NavigationCompleted (index 56 in ICoreWebView2)
                        navHandler := WebView2._makeHandler(
                            (pSelf4, pSender4, pArgs4) {
                                if inst._readyCB
                                    inst._readyCB(inst, pArgs4)
                                return 0
                            }
                        )
                        navToken := 0
                        ComCall(56, pWV2, "Ptr", navHandler.ptr, "Int64*", &navToken)

                        inst._done := true
                        return 0
                    }
                )
                ; ICoreWebView2Environment.CreateCoreWebView2Controller = index 3
                ComCall(3, pEnv, "Ptr", hwnd, "Ptr", ctrlHandler.ptr)
                return 0
            }
        )

        r := DllCall(
            this._loaderDll "|CreateCoreWebView2EnvironmentWithOptions",
            "Str", "",          ; browserExecutableFolder (empty = use installed runtime)
            "Str", udFolder,    ; userDataFolder
            "Ptr", 0,           ; options (null = defaults)
            "Ptr", envHandler.ptr,
            "Int"
        )
        if r != 0
            throw Error("CreateCoreWebView2EnvironmentWithOptions failed (0x" Format("{:08X}",r) ")`nEdge WebView2 Runtime may not be installed.")

        ; Pump until ready
        deadline := A_TickCount + 20000
        while !this._done && A_TickCount < deadline {
            WebView2._pump()
            Sleep 5
        }
        if !this._done
            throw Error("WebView2: timed out. Ensure Edge WebView2 Runtime is installed:`nhttps://go.microsoft.com/fwlink/p/?LinkId=2124703")
    }

    ; ── Navigate ──────────────────────────────────────────────
    Navigate(url) {
        if this._wv2
            ComCall(55, this._wv2, "Str", url)   ; Navigate
    }

    ; ── ExecuteScript ─────────────────────────────────────────
    ExecuteScript(script) {
        if this._wv2
            ComCall(72, this._wv2, "Str", script, "Ptr", 0)
    }

    ; ── PostWebMessageAsString ────────────────────────────────
    PostMessage(msg) {
        if this._wv2
            ComCall(49, this._wv2, "Str", msg)
    }

    ; ── Resize (call on WM_SIZE) ──────────────────────────────
    Resize() {
        if this._ctrl {
            RECT := Buffer(16,0)
            DllCall("GetClientRect","Ptr",this.hwnd,"Ptr",RECT)
            ComCall(6, this._ctrl, "Ptr", RECT)
        }
    }

    ; ── Get string from WebMessageReceivedEventArgs ───────────
    static _getMsgString(pArgs) {
        ; get_WebMessageAsString = vtable index 5
        pStr := 0
        try ComCall(5, pArgs, "Ptr*", &pStr)
        if !pStr
            return ""
        s := StrGet(pStr, "UTF-16")
        DllCall("Ole32\CoTaskMemFree", "Ptr", pStr)
        return s
    }

    ; ── Pump Windows messages ─────────────────────────────────
    static _pump() {
        MSG := Buffer(48)
        while DllCall("User32\PeekMessage","Ptr",MSG,"Ptr",0,"UInt",0,"UInt",0,"UInt",1,"Int") {
            DllCall("User32\TranslateMessage","Ptr",MSG)
            DllCall("User32\DispatchMessage", "Ptr",MSG)
        }
    }

    ; ── Build a COM handler object with 4-slot vtable ─────────
    ; Invoke signature: (pSelf, args...) => Int
    static _makeHandler(invokeFn) {
        ; vtable slots: QI, AddRef, Release, Invoke
        qi      := CallbackCreate(WebView2._qi,     "Fast", 3)
        addref  := CallbackCreate(WebView2._addref, "Fast", 1)
        release := CallbackCreate(WebView2._release,"Fast", 1)
        invoke  := CallbackCreate(invokeFn,         "Fast")

        vtbl := Buffer(A_PtrSize * 4)
        NumPut("Ptr", qi,      vtbl, 0)
        NumPut("Ptr", addref,  vtbl, A_PtrSize)
        NumPut("Ptr", release, vtbl, A_PtrSize*2)
        NumPut("Ptr", invoke,  vtbl, A_PtrSize*3)

        obj := Buffer(A_PtrSize)
        NumPut("Ptr", vtbl.Ptr, obj)

        ; Keep references alive
        return {ptr: obj.Ptr, _vtbl: vtbl, _obj: obj,
                _qi: qi, _ar: addref, _rel: release, _inv: invoke}
    }

    static _qi(pSelf, pIID, ppvObj)     => (NumPut("Ptr", pSelf, ppvObj), 0)
    static _addref(pSelf)               => 1
    static _release(pSelf)              => 1
}
