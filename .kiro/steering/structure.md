---
inclusion: always
---

# Project Structure

## Solution Organization

The solution uses a flat structure with projects grouped by function:

```
ControlR.slnx                    # Main solution file
├── /Examples/                   # Example implementations
├── /Libraries/                  # Shared libraries
├── /Tests/                      # Test projects
├── ControlR.Agent               # Agent entry point
├── ControlR.Agent.Common        # Shared agent code
├── ControlR.DesktopClient       # Desktop client entry point
├── ControlR.DesktopClient.*     # Platform-specific desktop implementations
├── ControlR.Web.Server          # ASP.NET Core web server
├── ControlR.Web.Client          # Blazor WebAssembly frontend
├── ControlR.Web.AppHost         # .NET Aspire orchestration
└── docker-compose/              # Docker deployment files
```

## Core Projects

### Web Stack
- **ControlR.Web.Server** - ASP.NET Core backend
  - `/Api/` - REST API endpoints
  - `/Hubs/` - SignalR hubs (AgentHub, ViewerHub)
  - `/Services/` - Business logic services
  - `/Data/` - EF Core DbContext and entities
  - `/Authz/` - Authorization policies and handlers
  - `/Middleware/` - Custom middleware
- **ControlR.Web.Client** - Blazor WebAssembly frontend
  - `/Components/` - Razor components
  - `/Services/` - Client-side services
  - `/StateManagement/` - Application state
  - `/ViewModels/` - Component view models
- **ControlR.Web.ServiceDefaults** - Shared service configuration
- **ControlR.Web.WebSocketRelay** - WebSocket relay for remote control streams

### Agent Stack
- **ControlR.Agent** - Entry point and host configuration
- **ControlR.Agent.Common** - Shared agent functionality
  - `/Services/` - Core agent services
  - `/Services/Windows/` - Windows-specific implementations
  - `/Services/Linux/` - Linux-specific implementations
  - `/Services/Mac/` - macOS-specific implementations
  - `/Interfaces/` - Service abstractions

### Desktop Client Stack
- **ControlR.DesktopClient** - Avalonia UI entry point
  - `/Views/` - AXAML view files
  - `/ViewModels/` - MVVM view models
  - `/Services/` - Desktop-specific services
  - `/Controls/` - Custom Avalonia controls
  - `/Resources/` - Styles, icons, themes
- **ControlR.DesktopClient.Common** - Shared desktop functionality
  - `/Services/` - Cross-platform services
  - `/ServiceInterfaces/` - Platform abstraction interfaces
  - `/Resources/Strings/` - Localization JSON files
- **ControlR.DesktopClient.Windows** - Windows-specific implementations
- **ControlR.DesktopClient.Linux** - Linux-specific implementations (X11, Wayland)
- **ControlR.DesktopClient.Mac** - macOS-specific implementations

## Shared Libraries

Located in `/Libraries/` directory:

- **ControlR.Libraries.Shared** - Core shared code
  - `/Dtos/` - Data transfer objects
    - `/HubDtos/` - SignalR hub DTOs
    - `/IpcDtos/` - IPC communication DTOs
    - `/ServerApi/` - REST API DTOs
    - `/StreamerDtos/` - Remote control stream DTOs
  - `/Primitives/` - Common types (Result<T>, etc.)
  - `/Extensions/` - Extension methods
- **ControlR.Libraries.DevicesCommon** - Device-related shared code
- **ControlR.Libraries.Ipc** - IPC abstractions and implementations
- **ControlR.Libraries.Signalr.Client** - SignalR client helpers
- **ControlR.Libraries.WebSocketRelay.Client** - WebSocket relay client
- **ControlR.Libraries.NativeInterop.Windows** - Windows P/Invoke
- **ControlR.Libraries.NativeInterop.Unix** - Unix/Linux P/Invoke
- **ControlR.Libraries.Viewer.Avalonia** - Avalonia viewer components
- **ControlR.Libraries.SecureStorage** - Credential storage
- **ControlR.Libraries.Branding** - Branding and theming

## Service Registration Patterns

Services are registered via extension methods, not directly in Program.cs:

- **Agent**: `AddControlRAgent()` in `ControlR.Agent.Common/Startup/HostBuilderExtensions.cs`
- **Web Server**: `AddControlrServer()` in `ControlR.Web.Server/Startup/WebApplicationBuilderExtensions.cs`
- **Web Client**: `AddControlrWebClient()` in `ControlR.Web.Client/Startup/IServiceCollectionExtensions.cs`
- **Desktop Client**: `AddControlrDesktop()` in `ControlR.DesktopClient/StaticServiceProvider.cs`

## Platform-Specific Code Organization

### Agent
Platform implementations live in `ControlR.Agent.Common/Services/{Platform}/` with interfaces in `/Interfaces/`. Platform selection via conditional compilation or DI registration.

### Desktop Client
Each platform has its own project (`ControlR.DesktopClient.{Platform}`). The main `ControlR.DesktopClient` project conditionally references the appropriate platform project. Shared UI and view models remain in `ControlR.DesktopClient.Common`.

## File Naming Conventions

- **Razor components**: `ComponentName.razor` with optional `ComponentName.razor.cs` code-behind
- **Component-scoped assets**: `ComponentName.razor.js` and `ComponentName.razor.css`
- **Avalonia views**: `ViewName.axaml` and `ViewName.axaml.cs`
- **View models**: `ViewNameViewModel.cs`
- **Tests**: `ClassNameTests.cs` or `ClassName.test.cs`

## Special Directories

- `/.kiro/` - Kiro AI assistant configuration and steering rules
- `/.plans/` - Planning documents and implementation notes (not committed)
- `/.github/` - GitHub workflows and copilot instructions
- `/.build/` - Build scripts
- `/docker-compose/` - Docker deployment configuration
