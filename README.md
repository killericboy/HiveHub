# HiveHub Macro  **by Killericboy**  
Roblox Bee Swarm Simulator automation macro.

---

## Requirements

| Requirement | Notes |
|---|---|
| **AutoHotkey v2** | https://www.autohotkey.com/ |
| **Edge WebView2 Runtime** | Ships with Windows 11. Win10: install from link below |
| **WebView2Loader.dll** | See section below |

### Getting WebView2Loader.dll

The UI uses Microsoft Edge WebView2. Most machines already have the runtime installed.  
You need `WebView2Loader.dll` in the `lib\` folder.

**Option A** (easiest): Install the Evergreen Runtime from Microsoft:  
https://go.microsoft.com/fwlink/p/?LinkId=2124703  
Then copy `WebView2Loader.dll` from `C:\Program Files (x86)\Microsoft\EdgeWebView\Application\<version>\`

**Option B**: Download the fixed-version SDK from NuGet:  
https://www.nuget.org/packages/Microsoft.Web.WebView2  
Extract the `.nupkg` (it's a zip), grab `runtimes\win-x64\native\WebView2Loader.dll`

---

## File Structure

```
HiveHub\
├── HiveHub.bat          ← Run this to start
├── lib\
│   ├── HiveHub.ahk      ← Main macro logic
│   ├── WebView2.ahk     ← WebView2 COM wrapper
│   ├── WebView2Loader.dll  ← YOU MUST ADD THIS
│   ├── Gdip_All.ahk
│   ├── Gdip_ImageSearch.ahk
│   ├── HyperSleep.ahk
│   ├── Roblox.ahk
│   └── Walk.ahk
├── ui\
│   └── index.html       ← HTML/CSS UI
├── settings\            ← Auto-created, stores profiles
└── assets\
    └── bee.ico
```

---

## Hotkeys

| Key | Action |
|---|---|
| F9  | Start |
| F10 | Stop |
| F11 | Toggle auto-harvest |
| F12 | Pause / Resume |

---

## Features

- **Snake traversal** — configurable field size and direction
- **Haste/buff detection** — Walk.ahk reads buff icons via image search
- **Reconnect engine** — auto-rejoin on interval or fixed UTC time
- **Profiles** — save/load multiple configurations
- **Camera alignment** — auto-rotate before start
- **ShiftLock support**
- **Hotbar auto-press**
- **HTML/CSS UI** — Edge WebView2 rendered interface
