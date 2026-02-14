# IDE Setup Guide

This guide provides detailed instructions for setting up and using VS Code and JetBrains Rider for ControlR development. Both IDEs are fully supported on Linux and macOS with comprehensive launch configurations, tasks, and debugging support.

## Table of Contents

- [VS Code Setup](#vs-code-setup)
- [JetBrains Rider Setup](#jetbrains-rider-setup)
- [Launch Configurations](#launch-configurations)
- [Tasks and Commands](#tasks-and-commands)
- [Debugging Guide](#debugging-guide)
- [Tips and Best Practices](#tips-and-best-practices)

## VS Code Setup

### Installation

**Linux:**

```bash
# Ubuntu/Debian
sudo snap install code --classic

# Or download .deb from https://code.visualstudio.com/
sudo dpkg -i code_*.deb

# Fedora/RHEL
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
sudo dnf install code
```

**macOS:**

```bash
brew install --cask visual-studio-code
```

### Required Extensions

When you open the ControlR repository in VS Code, you'll be prompted to install recommended extensions. Click "Install All" or install them manually:

**Essential Extensions:**

1. **C# Dev Kit** (`ms-dotnettools.csdevkit`)
   - Provides C# language support, IntelliSense, and debugging
   - Includes the C# extension automatically
   - Required for all .NET development

2. **C#** (`ms-dotnettools.csharp`)
   - Installed automatically with C# Dev Kit
   - Provides core C# language features

3. **.NET Runtime Install Tool** (`ms-dotnettools.vscode-dotnet-runtime`)
   - Manages .NET runtime installations for extensions
   - Installed automatically with C# Dev Kit

4. **Docker** (`ms-azuretools.vscode-docker`)
   - Manage Docker containers and compose files
   - View logs and inspect containers
   - Required for Docker-based workflows

**Recommended Extensions:**

5. **EditorConfig** (`editorconfig.editorconfig`)
   - Enforces consistent coding styles
   - Reads `.editorconfig` file in repository

6. **GitLens** (`eamodio.gitlens`)
   - Enhanced Git integration
   - Blame annotations, commit history, and more

7. **YAML** (`redhat.vscode-yaml`)
   - Syntax highlighting for docker-compose files
   - Schema validation

8. **XML** (`redhat.vscode-xml`)
   - Syntax highlighting for `.csproj` and Rider `.run.xml` files

9. **Markdown All in One** (`yzhang.markdown-all-in-one`)
   - Enhanced markdown editing for documentation

### Configuration Files

VS Code configuration is stored in the `.vscode/` directory:

- **`tasks.json`** - Build, test, and utility tasks
- **`launch.json`** - Debug configurations and compounds
- **`settings.json`** - Workspace-specific settings
- **`extensions.json`** - Recommended extensions list

These files are committed to the repository and shared across all developers.

### Workspace Settings

The repository includes workspace settings that configure:

- File associations for `.razor`, `.axaml`, and `.slnx` files
- Terminal shell preferences per platform
- Test explorer integration
- Editor formatting rules

You can view these settings in `.vscode/settings.json` or through the VS Code settings UI (Cmd/Ctrl+,).

## JetBrains Rider Setup

### Installation

**Linux:**

```bash
# Using JetBrains Toolbox (recommended)
# Download from: https://www.jetbrains.com/toolbox-app/

# Or using snap
sudo snap install rider --classic

# Or download tar.gz from https://www.jetbrains.com/rider/download/
tar -xzf JetBrains.Rider-*.tar.gz
cd JetBrains.Rider-*/bin
./rider.sh
```

**macOS:**

```bash
# Using Homebrew
brew install --cask rider

# Or download from https://www.jetbrains.com/rider/download/
```

### Required Plugins

Rider includes most required plugins by default. Verify these are enabled:

1. **.NET Core** - Built-in, provides .NET SDK support
2. **Docker** - Built-in, manage containers and compose files
3. **Database Tools** - Built-in, connect to PostgreSQL
4. **Terminal** - Built-in, integrated terminal

### Optional Plugins

Consider installing these for enhanced productivity:

- **GitToolBox** - Enhanced Git integration
- **Rainbow Brackets** - Colorize matching brackets
- **.ignore** - Support for `.gitignore` and other ignore files

### Configuration Files

Rider run configurations are stored in the `.run/` directory:

- **`Full Stack (Debug).run.xml`** - Debug all components
- **`Full Stack (Hot Reload).run.xml`** - Hot reload enabled
- **`Aspire AppHost.run.xml`** - Run via Aspire orchestration
- **`Tests (All).run.xml`** - Run all tests
- **`Server (hot reload).run.xml`** - Server-only hot reload
- **`compose (dev).run.xml`** - Docker Compose management

These files are committed to the repository and appear in Rider's run configuration dropdown automatically.

### Rider-Specific Features

**Test Runner:**

- Integrated test explorer with coverage
- Run/debug individual tests or test classes
- View test results inline in code

**Database Tools:**

- Connect to PostgreSQL directly from Rider
- Browse tables, run queries, view data
- Generate entity classes from database schema

**Profiling:**

- Built-in performance profiler
- Memory profiler for leak detection
- Timeline profiler for async operations

## Launch Configurations

### VS Code Launch Configurations

Access launch configurations via:

- Debug panel (Ctrl/Cmd+Shift+D)
- Run menu > Start Debugging (F5)
- Command palette > "Debug: Select and Start Debugging"

#### Individual Component Debugging

**Server (Debug)**

- Starts the web server with debugger attached
- Uses HTTPS profile from `launchSettings.json`
- Opens browser automatically when ready
- Breakpoints work in all server-side code

**Agent (Debug)**

- Starts the agent service with debugger attached
- Connects to web server via SignalR
- Breakpoints work in agent code

**DesktopClient (Debug)**

- Starts the Avalonia desktop client with debugger attached
- Requires agent to be running for IPC communication
- Breakpoints work in UI and service code

**Server (wasm debug)**

- Starts server with Blazor WebAssembly debugging enabled
- Opens browser with debugging support
- Set breakpoints in Blazor components and C# code
- Browser DevTools integration for client-side debugging

#### Hot Reload Configurations

**Server (Hot Reload)**

- Starts server with `dotnet watch` for hot reload
- Automatically applies code changes without restart
- Supported: Razor components, CSS, JS, some C# changes
- Unsupported: New files, signature changes, constructors

**Agent (Hot Reload)**

- Starts agent with hot reload enabled
- Limited hot reload support (method bodies only)

**DesktopClient (Hot Reload)**

- Starts desktop client with hot reload
- Supports AXAML and some C# changes

#### Aspire Configurations

**Aspire AppHost (Debug)**

- Starts the Aspire orchestration host
- Launches all services with proper dependency ordering
- Opens Aspire Dashboard automatically
- Provides centralized logging and telemetry

**Aspire AppHost (Hot Reload)**

- Same as above but with hot reload enabled for all services

#### Compound Configurations

**Full Stack (Debug)**

- Starts Server, Agent, and DesktopClient simultaneously
- All components have debugger attached
- Runs `build + compose` task first (builds solution and starts Docker services)
- Use this for full-stack debugging sessions

**Full Stack (Hot Reload)**

- Starts all components with hot reload enabled
- Faster iteration for UI and API development
- Runs `build + compose` task first

**Full Stack (wasm debug)**

- Starts server with Blazor debugging, plus Agent and DesktopClient
- Use this for debugging Blazor WebAssembly code

**Backend**

- Starts only the web server
- Use this for API-only development

**Load Test**

- Starts server and load testing tool
- Use this for performance testing

**Aspire Full Stack (Debug/Hot Reload)**

- Starts Aspire AppHost which orchestrates all services
- Provides observability through Aspire Dashboard
- Recommended for development that requires full stack

### Rider Run Configurations

Access run configurations via:

- Run configuration dropdown (top-right toolbar)
- Run menu > Run/Debug
- Keyboard shortcuts (Shift+F10 to run, Shift+F9 to debug)

#### Available Configurations

**Full Stack (Debug)**

- Compound configuration that starts all components
- Debugger attached to all processes
- Equivalent to VS Code's "Full Stack (Debug)"

**Full Stack (Hot Reload)**

- Compound configuration with hot reload enabled
- Faster iteration for development
- Equivalent to VS Code's "Full Stack (Hot Reload)"

**Aspire AppHost**

- Runs the Aspire orchestration host
- Starts all services with observability
- Opens Aspire Dashboard automatically

**Tests (All)**

- Runs all xUnit tests in the solution
- Displays results in Rider's test explorer
- Supports coverage collection

**Server (hot reload)**

- Runs only the web server with hot reload
- Use for API-only development

**compose (dev)**

- Manages Docker Compose services
- Starts PostgreSQL and Aspire Dashboard
- Use before running components manually

## Tasks and Commands

### VS Code Tasks

Access tasks via:

- Terminal menu > Run Task
- Command palette (Ctrl/Cmd+Shift+P) > "Tasks: Run Task"
- Keyboard shortcut (Ctrl/Cmd+Shift+B for default build task)

#### Build Tasks

**build-solution** (Default)

- Builds the entire solution
- Shows detailed output with error messages
- Problem matcher highlights errors in Problems panel
- Keyboard shortcut: Ctrl/Cmd+Shift+B

**build solution** (Quiet)

- Builds with minimal output for fast feedback
- Use when you just want to verify compilation
- Used by launch configurations as pre-launch task

**clean**

- Removes all build artifacts
- Run this if you encounter strange build errors

**restore**

- Restores NuGet packages
- Run this after pulling changes that modify dependencies

#### Individual Project Build Tasks

**build server**

- Builds only the web server project

**build agent**

- Builds the agent project
- Depends on server build

**build desktopclient**

- Builds the desktop client project
- Depends on agent build

**build loadtester**

- Builds the load testing tool
- Depends on server build

#### Test Tasks

**test-all** (Default test task)

- Runs all xUnit tests in the solution
- Displays results in terminal with detailed output
- Problem matcher highlights test failures

**test-watch**

- Runs tests in watch mode
- Automatically reruns tests when code changes
- Prompts you to select which test project to watch
- Runs in dedicated terminal panel

#### Utility Tasks

**verify-env**

- Runs the environment verification script
- Checks for required tools and dependencies
- Displays pass/fail status with remediation steps
- Run this after initial setup or when troubleshooting

#### Docker Tasks

**compose**

- Starts Docker Compose services (PostgreSQL, Aspire Dashboard)
- Runs in detached mode
- Used by compound launch configurations

**compose-down**

- Stops Docker Compose services
- Preserves volumes (data persists)
- Use this to clean up after development

**build + compose**

- Compound task that builds solution then starts Docker services
- Used as pre-launch task for Full Stack configurations

### Rider Tasks

Rider doesn't use a separate task system like VS Code. Instead, tasks are integrated into run configurations and the IDE's build system.

**Build Actions:**

- Build Solution: Ctrl/Cmd+Shift+F9
- Build Project: Ctrl/Cmd+F9
- Rebuild Solution: Right-click solution > Rebuild
- Clean Solution: Right-click solution > Clean

**Test Actions:**

- Run All Tests: Right-click solution > Run Unit Tests
- Run Tests in File: Right-click test file > Run All
- Run Single Test: Click gutter icon next to test method
- Debug Test: Right-click test > Debug

**Docker Actions:**

- Managed through Docker tool window (View > Tool Windows > Docker)
- Start/stop containers
- View logs
- Execute commands in containers

## Debugging Guide

### Setting Breakpoints

**VS Code:**

- Click in the gutter (left of line numbers) to set a breakpoint
- Red dot appears when breakpoint is set
- Right-click breakpoint for conditional breakpoints and logpoints
- Breakpoints panel (Ctrl/Cmd+Shift+D) shows all breakpoints

**Rider:**

- Click in the gutter to set a breakpoint
- Red circle appears when breakpoint is set
- Right-click breakpoint for conditions, hit counts, and more
- Breakpoints window (Ctrl/Cmd+Shift+F8) shows all breakpoints

### Debugging Different Project Types

#### Web Server (ASP.NET Core)

**What you can debug:**

- API endpoints and controllers
- SignalR hub methods
- Middleware pipeline
- Background services
- Database queries (EF Core)

**Tips:**

- Set breakpoints in controller actions to inspect request data
- Use conditional breakpoints to catch specific scenarios
- Inspect `HttpContext` to see request headers, cookies, etc.
- Watch window to evaluate expressions

#### Agent (Background Service)

**What you can debug:**

- SignalR client connection logic
- Command handling
- IPC communication with desktop client
- Platform-specific services

**Tips:**

- Agent connects to server on startup - ensure server is running first
- Set breakpoints in command handlers to see incoming commands
- Use logging to trace execution flow
- Inspect SignalR connection state

#### Desktop Client (Avalonia UI)

**What you can debug:**

- View models and UI logic
- User input handlers
- Screen capture and input simulation
- IPC communication with agent

**Tips:**

- Set breakpoints in view model methods to inspect UI state
- Use Avalonia DevTools (F12 in debug builds) to inspect visual tree
- Debug data binding issues by checking view model properties
- Inspect IPC messages between agent and desktop client

#### Blazor WebAssembly

**VS Code:**

1. Start with "Server (wasm debug)" or "Full Stack (wasm debug)" configuration
2. Browser opens automatically with debugging enabled
3. Set breakpoints in `.razor` or `.cs` files in VS Code
4. Or use browser DevTools (F12) > Sources tab to set breakpoints

**Rider:**

1. Start with Blazor debugging enabled
2. Rider opens browser with debugging support
3. Set breakpoints in Blazor components
4. Rider's debugger shows client-side execution

**Tips:**

- Blazor debugging requires browser support (Chrome, Edge)
- Some async operations may not hit breakpoints reliably
- Use `Console.WriteLine` or browser console for quick debugging
- Inspect component state in browser DevTools

### Multi-Process Debugging

When using compound configurations (Full Stack), multiple processes run simultaneously with debuggers attached.

**VS Code:**

- Debug panel shows all active debug sessions
- Use dropdown to switch between processes
- Each process has its own call stack and variables
- Stop button stops all processes (or stop individually)

**Rider:**

- Debug tool window shows all processes
- Switch between processes using tabs
- Each process has independent debug controls
- Stop All button stops all processes

**Tips:**

- Set breakpoints in multiple components before starting
- Use conditional breakpoints to reduce noise
- Name your breakpoints for easier identification
- Use logpoints instead of breakpoints for high-frequency code

### Debugging Tips by Scenario

#### Debugging SignalR Communication

**Server-side:**

- Set breakpoints in hub methods (`AgentHub`, `ViewerHub`)
- Inspect `Context.ConnectionId` to identify clients
- Watch `Clients.All` or `Clients.Client(id)` calls

**Client-side (Agent/Desktop):**

- Set breakpoints in SignalR event handlers
- Inspect connection state (`HubConnection.State`)
- Watch for connection/disconnection events

#### Debugging IPC Between Agent and Desktop Client

**Agent side:**

- Set breakpoints in IPC message sending code
- Inspect message payloads before sending

**Desktop Client side:**

- Set breakpoints in IPC message handlers
- Verify message deserialization

**Tips:**

- Use logging to trace message flow
- Verify named pipe connection is established
- Check for serialization errors

#### Debugging Database Issues

**EF Core Queries:**

- Set breakpoints before and after database calls
- Inspect `DbContext` state
- Use logging to see generated SQL queries

**Migrations:**

- Run migrations manually with verbose output
- Check migration history table
- Verify connection string is correct

**Tips:**

- Enable sensitive data logging in development
- Use Rider's database tools to inspect data directly
- Check PostgreSQL logs for errors

#### Debugging Platform-Specific Code

**Windows:**

- Debug Win32 API calls and DirectX code
- Inspect P/Invoke marshalling
- Check for access denied errors

**Linux:**

- Debug X11 or Wayland integration
- Inspect DBus communication
- Check for missing dependencies

**macOS:**

- Debug CoreGraphics and Cocoa calls
- Inspect Objective-C interop
- Check for permission issues

**Tips:**

- Use conditional compilation to isolate platform code
- Test on actual target platform (not just in VM)
- Check platform-specific logs and error codes

### Hot Reload Debugging

When using hot reload configurations, you can modify code while debugging:

**Supported Changes:**

- Method body modifications
- Property changes
- Razor component markup
- CSS and JavaScript files

**Unsupported Changes (require restart):**

- Adding new files
- Changing method signatures
- Modifying constructors
- Adding/removing dependencies
- Changing generic type parameters

**Tips:**

- Save file to trigger hot reload
- Watch for hot reload status in terminal
- If hot reload fails, restart the debug session
- Use hot reload for rapid UI iteration

### Performance Debugging

**VS Code:**

- Use browser DevTools Performance tab for Blazor
- Profile server-side code with dotnet-trace
- Monitor memory with dotnet-counters

**Rider:**

- Built-in performance profiler (Run > Profile)
- Memory profiler for leak detection
- Timeline profiler for async operations
- CPU profiler for hot path identification

**Tips:**

- Profile in Release mode for accurate results
- Use sampling profiler for low overhead
- Focus on hot paths (frequently executed code)
- Check for memory leaks with heap snapshots

## Tips and Best Practices

### General IDE Tips

**VS Code:**

- Use Command Palette (Ctrl/Cmd+Shift+P) to discover features
- Customize keyboard shortcuts (Preferences > Keyboard Shortcuts)
- Use multi-cursor editing (Alt+Click or Ctrl/Cmd+D)
- Split editor for side-by-side file viewing
- Use breadcrumbs for quick navigation

**Rider:**

- Use Search Everywhere (Double Shift) to find anything
- Navigate to symbol (Ctrl/Cmd+Shift+T for types, Ctrl/Cmd+Shift+Alt+N for symbols)
- Use refactoring shortcuts (Ctrl/Cmd+Shift+R)
- Enable code lens for inline information
- Use TODO explorer to track tasks

### Workflow Recommendations

**For UI Development:**

- Use hot reload configurations for fast iteration
- Keep browser DevTools open for Blazor debugging
- Use Avalonia DevTools (F12) for desktop UI debugging
- Test on actual target platforms regularly

**For API Development:**

- Use Scalar API documentation (`/scalar/` endpoint)
- Test endpoints with Rider's HTTP client or Postman
- Use hot reload for quick API changes
- Monitor Aspire Dashboard for request traces

**For Full-Stack Development:**

- Use Aspire AppHost for complete observability
- Monitor logs in Aspire Dashboard
- Use compound configurations to debug multiple components
- Keep Docker services running in background

**For Testing:**

- Use test watch mode for TDD workflow
- Run tests frequently during development
- Use coverage tools to identify untested code
- Debug failing tests with breakpoints

### Performance Tips

**VS Code:**

- Disable unused extensions
- Exclude `bin/` and `obj/` from file watcher
- Use workspace trust for better security
- Close unused editor tabs

**Rider:**

- Increase heap size for large solutions (Help > Change Memory Settings)
- Disable unused plugins
- Use power save mode when not actively developing
- Clear caches if IDE becomes slow (File > Invalidate Caches)

### Troubleshooting IDE Issues

**VS Code:**

_C# extension not working:_

- Reload window (Ctrl/Cmd+Shift+P > "Reload Window")
- Restart OmniSharp server (Command Palette > "OmniSharp: Restart OmniSharp")
- Check Output panel > OmniSharp Log for errors

_Debugger not attaching:_

- Verify .NET SDK is installed (`dotnet --version`)
- Check launch configuration paths are correct
- Ensure project builds successfully first
- Try deleting `bin/` and `obj/` folders

_Tasks not running:_

- Check task definition in `tasks.json`
- Verify command paths are correct
- Check terminal output for error messages

**Rider:**

_Solution not loading:_

- Invalidate caches (File > Invalidate Caches > Invalidate and Restart)
- Delete `.idea/` folder and reopen solution
- Check for corrupted project files

_Debugger not working:_

- Verify run configuration is correct
- Check that project builds successfully
- Try rebuilding solution
- Check for antivirus interference

_Tests not discovered:_

- Rebuild solution
- Invalidate caches
- Check test framework is installed
- Verify test project references xUnit correctly

### Additional Resources

**VS Code:**

- [VS Code .NET Documentation](https://code.visualstudio.com/docs/languages/dotnet)
- [C# Dev Kit Documentation](https://code.visualstudio.com/docs/csharp/get-started)
- [Debugging in VS Code](https://code.visualstudio.com/docs/editor/debugging)

**Rider:**

- [Rider Documentation](https://www.jetbrains.com/help/rider/)
- [Rider Debugging Guide](https://www.jetbrains.com/help/rider/Debugging_Code.html)
- [Rider Keyboard Shortcuts](https://www.jetbrains.com/help/rider/Reference_Keymap_Rider_OSX.html)

**ControlR Documentation:**

- [Development Setup](SETUP.md) - Initial environment setup
- [Database Configuration](DATABASE.md) - Database setup details
- [Troubleshooting](TROUBLESHOOTING.md) - Common issues and solutions

## Quick Reference

### VS Code Keyboard Shortcuts

| Action               | Windows/Linux       | macOS              |
| -------------------- | ------------------- | ------------------ |
| Command Palette      | Ctrl+Shift+P        | Cmd+Shift+P        |
| Quick Open File      | Ctrl+P              | Cmd+P              |
| Start Debugging      | F5                  | F5                 |
| Toggle Breakpoint    | F9                  | F9                 |
| Step Over            | F10                 | F10                |
| Step Into            | F11                 | F11                |
| Continue             | F5                  | F5                 |
| Build (Default Task) | Ctrl+Shift+B        | Cmd+Shift+B        |
| Run Task             | Ctrl+Shift+P > Task | Cmd+Shift+P > Task |
| Toggle Terminal      | Ctrl+`              | Cmd+`              |
| Go to Definition     | F12                 | F12                |
| Find References      | Shift+F12           | Shift+F12          |
| Rename Symbol        | F2                  | F2                 |

### Rider Keyboard Shortcuts

| Action            | Windows/Linux | macOS        |
| ----------------- | ------------- | ------------ |
| Search Everywhere | Double Shift  | Double Shift |
| Run               | Shift+F10     | Ctrl+R       |
| Debug             | Shift+F9      | Ctrl+D       |
| Toggle Breakpoint | Ctrl+F8       | Cmd+F8       |
| Step Over         | F8            | F8           |
| Step Into         | F7            | F7           |
| Continue          | F9            | Cmd+Alt+R    |
| Build Solution    | Ctrl+Shift+F9 | Cmd+Shift+F9 |
| Run Tests         | Ctrl+U, R     | Cmd+U, R     |
| Go to Declaration | Ctrl+B        | Cmd+B        |
| Find Usages       | Alt+F7        | Alt+F7       |
| Rename            | Ctrl+R, R     | Cmd+R, R     |
| Refactor This     | Ctrl+Shift+R  | Cmd+Shift+R  |

### Common Launch Configurations

| Configuration           | Purpose                             | IDE     |
| ----------------------- | ----------------------------------- | ------- |
| Full Stack (Debug)      | Debug all components simultaneously | Both    |
| Full Stack (Hot Reload) | Develop with hot reload enabled     | Both    |
| Aspire AppHost (Debug)  | Run via Aspire with observability   | Both    |
| Server (Debug)          | Debug web server only               | VS Code |
| Server (wasm debug)     | Debug Blazor WebAssembly            | VS Code |
| Agent (Debug)           | Debug agent only                    | VS Code |
| DesktopClient (Debug)   | Debug desktop client only           | VS Code |
| Tests (All)             | Run all tests                       | Rider   |

### Common Tasks

| Task           | Purpose                                | IDE     |
| -------------- | -------------------------------------- | ------- |
| build-solution | Build entire solution with full output | VS Code |
| build solution | Build with minimal output (fast)       | VS Code |
| test-all       | Run all tests                          | VS Code |
| test-watch     | Run tests in watch mode                | VS Code |
| verify-env     | Verify development environment         | VS Code |
| compose        | Start Docker services                  | VS Code |
| compose-down   | Stop Docker services                   | VS Code |
