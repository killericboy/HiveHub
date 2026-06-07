; ================================================================
;  HiveHub.ahk — FieldGuard integration patches
;  Apply these three changes to your existing HiveHub.ahk
; ================================================================

; ── PATCH 1: #Include  (add after the other #Include lines) ───
; Place this line immediately after:
;   #Include Walk.ahk

#Include FieldGuard.ahk


; ── PATCH 2: StartMacro() — call FieldGuard_Init() after camera ─
; Find the block in StartMacro() that reads:
;
;   if (camDir != "None" && camSteps > 0)
;       RotateCamera(camDir, camSteps)
;
; Add these two lines AFTER it:

    FieldGuard_Init()                    ; warm up boundary detection


; ── PATCH 3: SnakeThread() — add boundary checks after Walk() ──
; Replace the existing SnakeThread() body with the version below.
; The only additions are FieldGuard_AfterStep() calls and
; a forward/backward guard pair.  All other logic is unchanged.

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
        ; ── Pass 1: forward sweep ─────────────────────────────
        currentPass := 1
        curKey := keyA
        loop lengthT {
            if !running
                break
            currentRow := A_Index
            Send "{" curKey " down}"
            Walk(widthT)

            ; ── GUARD: lateral boundary check ─────────────────
            reverseKey := (curKey = keyA) ? keyB : keyA
            if !FieldGuard_AfterStep(curKey, reverseKey) {
                ; Recovery failed — abort gracefully
                Send "{" curKey " up}"
                StopMacro()
                return
            }
            ; ──────────────────────────────────────────────────

            if A_Index < lengthT {
                Send "{" curKey " up}{" FwdKey " down}"
                Walk(1)

                ; ── GUARD: forward boundary check (narrow top rows) ──
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

        ; ── Pass 2: backward sweep ────────────────────────────
        currentPass := 2
        loop lengthT {
            if !running
                break
            currentRow := A_Index
            Send "{" curKey " down}"
            Walk(widthT)

            ; ── GUARD: lateral boundary check ─────────────────
            reverseKey := (curKey = keyA) ? keyB : keyA
            if !FieldGuard_AfterStep(curKey, reverseKey) {
                Send "{" curKey " up}"
                StopMacro()
                return
            }
            ; ──────────────────────────────────────────────────

            if A_Index < lengthT {
                Send "{" curKey " up}{" BackKey " down}"
                Walk(1)

                ; ── GUARD: backward boundary check ────────────
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


; ── PATCH 4 (optional): expose settings via cfg so GUI can ──────
; toggle FieldGuard and tune its colours in future profile saves.
; Add these keys to the cfg Map() initialiser block:

;     "fieldGuardEnable", true,
;     "fieldGuardSkyColor",   0x5A9CCC,
;     "fieldGuardFieldColor", 0x4A8430,

; Then in StartMacro(), after FieldGuard_Init():

;     FG_Enabled          := cfg["fieldGuardEnable"]
;     FG_SkyColorSample   := Integer(cfg["fieldGuardSkyColor"])
;     FG_FieldColorSample := Integer(cfg["fieldGuardFieldColor"])
