<div align="center">

  <img src="https://i.imgur.com/XyhEFsY.gif" alt="WASOR v4.9 Banner" width="480" style="border-radius: 12px; box-shadow: 0 8px 32px rgba(0,0,0,0.6);" />

  # ⚡ WASOR v4.9
  ### *We Are Skidding On Roblox*

  [![Documentation](https://img.shields.io/badge/Documentation-Live_on_Vercel-34d399?style=for-the-badge&logo=vercel&logoColor=white)](https://wasordocumentation.vercel.app/#intro)
  [![Version](https://img.shields.io/badge/Version-4.9_Production-7c3aed?style=for-the-badge)](https://wasordocumentation.vercel.app/)
  [![Roblox](https://img.shields.io/badge/Platform-Roblox_Lua-00a2ff?style=for-the-badge&logo=roblox&logoColor=white)](https://wasordocumentation.vercel.app/)
  [![Languages](https://img.shields.io/badge/i18n-10_Languages-f59e0b?style=for-the-badge)](https://wasordocumentation.vercel.app/)
  [![Modules](https://img.shields.io/badge/Modules-107_Active-10b981?style=for-the-badge)](https://wasordocumentation.vercel.app/)

  **A Roblox Lua client-side utility featuring more than 100+ distinct modules across Combat, Movement, Render, Player, World, and Utility.**

  [🌐 **Explore Official Live Documentation**](https://wasordocumentation.vercel.app/) • [📖 **API Reference**](https://wasordocumentation.vercel.app/#aimbot) • [⚡ **Quickstart**](#-quickstart--execution) • [🛠️ **Features**](#-features--module-breakdown)

</div>

---

## 📖 Official Documentation

Deployed at:
### 👉 [https://wasordocumentation.vercel.app/](https://wasordocumentation.vercel.app/#intro)

* **Interactive API Reference**: Comprehensive specifications for all modules with parameters and descriptions, reproducible Lua snippets.
* **Status Badges**: Real-time status indicators across all engines (`Working`, `Defunct`, `Patched`, `Broken`).

---

## ⚡ How the hell do i execute it

To execute the github version of W-A-S-O-R(We Are Skidding On Roblox) you must have a roblox executor to start

```lua
if identifyexecutor then
    game:GetService("GuiService"):SetGameplayPausedNotificationEnabled(false)
    loadstring(game:HttpGet("https://raw.githubusercontent.com/MizunoSync/WASOR/refs/heads/main/github_loader.lua", true))()
end
```
---

## 📂 Project Architecture

```
WASOR/
├── Core/
│   ├── Services.lua         # Centralized Roblox service caching
│   ├── State.lua            # Reactive configuration & runtime flags
│   ├── Utils.lua            # Mathematical solvers, raycasting & math
│   ├── Config.lua           # Persistent JSON storage handler
│   ├── Logger.lua           # Chat & system output interceptor
│   ├── Cleanup.lua          # Garbage collection & Drawing disposal
│   ├── UI.lua              
│   └── Runtime.lua          # Heartbeat, Stepped & RenderStepped loops
├── Modules/                 # Current modules
│   ├── Combat/              # Targeting, weapon mechanics & damage
│   ├── Player/              # Character state & identity spoofing
│   ├── Movement/            # Kinematics, flight & physics overrides
│   ├── Render/              # Drawing API ESP & visual enhancements
│   ├── World/               # Environment triggers & world interaction
│   └── Misc/                # Network tools, console & diagnostics
├── dev_loader.lua           # Local Testing Loader
├── github_loader.lua        # Loader
└── init.lua                 # Primary initialization
```

---

## ⚡ Local Development Setup

To test and modify WASOR source code locally:

1. Clone or place the `WASOR` directory directly inside your executor's `workspace` folder:
   ```
   <Executor>/workspace/WASOR/
   ```
2. Execute the local development loader:
   ```lua
   loadstring(readfile("WASOR/dev_loader.lua"))()
   ```
   
---

<div align="center">
  <sub>WASOR v4.9 is developed for software interoperability testing and educational security research.</sub>
</div>
