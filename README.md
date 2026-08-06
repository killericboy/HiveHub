# 🐝 HiveHub Macro

**by Killericboy**  
Roblox Bee Swarm Simulator automation macro.

---

## ⚙️ Requirements

| | |
|---|---|
| 🔧 **AutoHotkey v2** | https://www.autohotkey.com/ |
| 🌐 **Edge WebView2 Runtime** | Already on Windows 11. [Download for Win10](https://go.microsoft.com/fwlink/p/?LinkId=2124703) |

---

## 📁 File Structure

```
HiveHub\
├── HiveHub.bat
├── lib\
│   ├── HiveHub.ahk
│   ├── WebView2.ahk
│   ├── JSON.ahk
│   ├── 32bit\
│   │   └── WebView2Loader.dll
│   ├── 64bit\
│   │   └── WebView2Loader.dll
│   ├── Gdip_All.ahk
│   ├── Gdip_ImageSearch.ahk
│   ├── HyperSleep.ahk
│   ├── Roblox.ahk
│   └── Walk.ahk
├── ui\
│   ├── index.html
│   ├── style.css
│   └── app.js
├── settings\
│   └── profiles.json
└── assets\
    └── bee.ico
```

---

## ⌨️ Hotkeys

| Key | Action |
|---|---|
| F9  | Start |
| F10 | Stop |
| F11 | Toggle auto-harvest |
| F12 | Pause / Resume |

---

## ✨ Features

- 🔄 **Traversal** — automatically walks across your field in a snake pattern
- ⚡ **Haste detection** — detects speed buffs and adjusts walk timing automatically
- 🔌 **Auto-reconnect** — rejoins your server on a timer or at a set time every day
- 👤 **Profiles** — save and switch between multiple setups easily
- 📷 **Camera alignment** — rotates camera to the right angle before starting
- 🔒 **ShiftLock** — enables ShiftLock automatically when the macro starts
- 🎮 **Hotbar** — automatically presses your selected hotbar keys on a timer
- ⏱️ **Key delay** — fine-tune input timing per profile
