# HiveHub Macro

**Version:** v1.4.0  
**Author:** Killericboy  
**Game:** Bee Swarm Simulator (Roblox)

---

## What is HiveHub Macro?

HiveHub Macro is an AutoHotkey v2 automation tool built specifically for the **Hive Hub** server in Bee Swarm Simulator. It automates field gathering using a precision snake/lawnmower pattern, handles buff detection, camera alignment, and tool hotbar management — all from a clean tabbed GUI.

---

## Features

- **Snake Pattern Gathering** — two-pass lawnmower that returns to origin with zero drift
- **Dynamic Speed Detection** — reads your actual in-game walk speed in real-time using screen capture, accounting for haste stacks, oil, bear buff, smoothie, and other multipliers automatically
- **Camera Alignment** — rotates camera before gathering for straight field passes, with optional ShiftLock for consistent rotation
- **Hotbar Auto-Press** — press any combination of keys 1–7 on a timed interval while gathering (useful for tools, sprouts, etc.)
- **Auto Harvest** — automatic left-click collection while walking
- **Standing Mode** — stay stationary while still harvesting and firing hotbar keys
- **Profiles** — save multiple configurations per user, with per-Windows-account last-used profile memory (supports RDP multi-user setups)
- **Server Links** — paste private server links or use the default HiveHub public URL, join directly from the macro
- **Pause / Resume** — F12 instantly pauses mid-row and resumes from where you left off
- **Live Stats** — real-time timer, pass direction, current row, and cycle count

---

## Requirements

- [AutoHotkey v2](https://www.autohotkey.com/) (64-bit recommended)
- Roblox running with Bee Swarm Simulator open
- Windows 10 or 11

---

## Installation

1. Download and extract the zip
2. Make sure the folder structure is intact:

```
HiveHub/
├── HiveHub.bat
├── assets/
│   └── bee.ico
├── lib/
│   ├── HiveHub.ahk
│   ├── Gdip_All.ahk
│   ├── Gdip_ImageSearch.ahk
│   ├── HyperSleep.ahk
│   ├── Roblox.ahk
│   └── Walk.ahk
└── settings/
```

3. Double-click **HiveHub.bat** to launch

> The `settings/` folder is created automatically. Your config is saved as `hivehub_config.ini` inside it.

---

## How to Use

### Main Tab

| Setting | Description |
|---|---|
| **Walk Speed** | Your base walk speed in studs/sec (default 16). Dynamic detection shows actual speed. |
| **Field Size** | Length (XS/S/M/L/XL) and Width (1–9 tiles). 1 tile = 4 studs. |
| **Direction** | Which way to sweep: Right/Left, Left/Right, or Standing (no movement). |
| **Camera Align** | Rotate camera N steps before starting. Enable ShiftLock for consistent rotation. |
| **Tool** | Enable Auto harvest (left-click) while walking. |
| **Hotbar** | Enable timed key presses (1–7) every X seconds while the macro runs. |

### Settings Tab

| Setting | Description |
|---|---|
| **Private Server Link** | Paste your BSS private server URL here. Click Join Private to connect. |
| **Public Fallback Link** | Defaults to the HiveHub public game. Click Join Public to connect. |
| **Key Delay** | Delay between key sends in ms. Increase if keys drop on slow machines. |

### Profiles Tab

- Create named profiles to save different field configurations
- Click a profile name to load it into the name box
- **Add/Save** — saves current settings to that profile name
- **Load** — switches to the selected profile
- **Delete** — removes a profile (Default cannot be deleted)
- Last-used profile is remembered **per Windows user account**

---

## Hotkeys

| Key | Action |
|---|---|
| **F9** | Start |
| **F10** | Stop |
| **F11** | Toggle Auto Harvest on/off |
| **F12** | Pause / Resume |

---

## Camera Alignment Guide

1. Stand at the corner of your field
2. Enable **ShiftLock** in Roblox settings first
3. Check **Enable ShiftLock** in the macro
4. Set Camera Align direction and steps (start with Right 2)
5. Press Start — the macro rotates camera, then begins gathering

> If rows drift sideways, increase or decrease steps by 1 until they're straight.

---

## Tips

- **Stand at a corner** of the field before pressing Start
- Use **Standing mode** at sprout locations or honey dispensers
- **Hotbar key 1** is typically your tool slot — set interval to 30s for regular use
- If Walk Speed shows a number higher than your base, it's detecting active haste buffs

---

## License

Personal use only. Not for redistribution.

---

*HiveHub Macro — by Killericboy*
