---
inclusion: always
---

# Technology Stack

## Build System

- **.NET 10** - Target framework for all projects
- **Solution file**: `ControlR.slnx` (XML-based solution format)
- **Central Package Management**: `Directory.Packages.props` manages all NuGet package versions centrally
- **Build properties**: `Directory.Build.props` defines common project settings

## Backend Technologies

- **ASP.NET Core 10** - Web framework for REST APIs and hosting
- **SignalR** - Real-time bidirectional communication between server, agents, and web clients
- **Entity Framework Core 10** - ORM with PostgreSQL provider
- **PostgreSQL** - Primary database (InMemory option for testing)
- **MessagePack** - Binary serialization for SignalR messages
- **StreamJsonRpc** - JSON-RPC for IPC communication
- **.NET Aspire** - Orchestration and observability for development

## Frontend Technologies

- **Blazor WebAssembly** - Client-side web UI framework
- **MudBlazor 8.15** - Material Design component library
- **JavaScript Interop** - Browser-specific functionality

## Desktop Technologies

- **Avalonia UI 11.3** - Cross-platform .NET UI framework
- **SkiaSharp** - 2D graphics rendering for screen capture
- **Platform-specific interop**:
  - Windows: DirectX Desktop Duplication, Win32 APIs via CsWin32
  - Linux: X11, Wayland via XDG Desktop Portal, DBus (Tmds.DBus)
  - macOS: CoreGraphics, Cocoa APIs

## Key Libraries

- **CommunityToolkit.Mvvm** - MVVM helpers for desktop client
- **Bitbound.SimpleMessenger** - Cross-component messaging
- **Serilog** - Structured logging
- **Microsoft.PowerShell.SDK** - Embedded PowerShell for terminal
- **QRCoder** - QR code generation
- **MailKit** - Email sending
- **OpenTelemetry** - Metrics, traces, and logs

## Testing

- **xUnit** - Unit testing framework
- **Moq** - Mocking library
- **Microsoft.AspNetCore.Mvc.Testing** - Integration testing for web APIs
- **coverlet.collector** - Code coverage

## Common Commands

### Build
```bash
# Build entire solution
dotnet build ControlR.slnx

# Build with minimal output (verify compilation)
dotnet build ControlR.slnx --verbosity quiet
```

### Run (Development)
Use IDE launch profiles:
- **Visual Studio/Rider**: "Full Stack" profile
- **VS Code**: "Full Stack (Debug)" or "Full Stack (Hot Reload)" configs
- **CLI**: Use .NET Aspire AppHost: `dotnet run --project ControlR.Web.AppHost`

### Test
```bash
# Run all tests
dotnet test ControlR.slnx

# Run specific test project
dotnet test Tests/ControlR.Web.Server.Tests
```

### Package Management
```bash
# Add package (automatically updates Directory.Packages.props)
dotnet add <project-path> package <package-name>

# Never manually add Version attributes to PackageReference elements
```

### Docker
```bash
# Start with docker-compose
docker compose up -d

# Check health
curl http://127.0.0.1:5120/health
```

## Development Tools

- **Scalar** - OpenAPI/Swagger UI (available at `/scalar/` during debug)
- **Aspire Dashboard** - Metrics and telemetry (port 18888)
- **Hot Reload** - Supported for Blazor UI development
