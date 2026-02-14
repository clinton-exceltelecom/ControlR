# Development Environment Setup

This guide will help you set up your development environment for ControlR on Linux or macOS. By the end of this guide, you'll be able to build, run, debug, and test the full ControlR stack.

## Overview

ControlR is built with:

- **.NET 10** - Cross-platform framework for all components
- **ASP.NET Core** - Web server with SignalR for real-time communication
- **Blazor WebAssembly** - Client-side web UI
- **Avalonia UI** - Cross-platform desktop client
- **PostgreSQL** - Primary database (with InMemory option for development)
- **.NET Aspire** - Orchestration and observability

## Prerequisites

### Required Software

| Software       | Minimum Version | Purpose                             |
| -------------- | --------------- | ----------------------------------- |
| .NET SDK       | 10.0            | Build and run all projects          |
| Docker         | Latest          | Run PostgreSQL and Aspire Dashboard |
| Docker Compose | v2.0+           | Orchestrate development services    |

### Optional Software

| Software          | Purpose                                       |
| ----------------- | --------------------------------------------- |
| PostgreSQL Client | Connect to local PostgreSQL for debugging     |
| Node.js           | Blazor development tooling                    |
| Git               | Version control (should already be installed) |

### Platform-Specific Dependencies

#### Linux (X11)

For desktop client development on X11:

```bash
# Ubuntu/Debian
sudo apt install libx11-dev libxrandr-dev libxi-dev

# Fedora/RHEL
sudo dnf install libX11-devel libXrandr-devel libXi-devel
```

#### Linux (Wayland)

For experimental Wayland support:

```bash
# Ubuntu/Debian
sudo apt install libgstreamer1.0-0 gstreamer1.0-plugins-base gstreamer1.0-plugins-good

# Fedora/RHEL
sudo dnf install gstreamer1 gstreamer1-plugins-base gstreamer1-plugins-good
```

#### macOS

macOS includes all required frameworks (CoreGraphics, Cocoa). No additional dependencies needed.

## Installation Instructions

### Ubuntu / Debian

```bash
# Update package list
sudo apt update

# Install .NET SDK 10
wget https://dot.net/v1/dotnet-install.sh -O dotnet-install.sh
chmod +x dotnet-install.sh
./dotnet-install.sh --channel 10.0
echo 'export PATH="$HOME/.dotnet:$PATH"' >> ~/.bashrc
source ~/.bashrc

# Install Docker
sudo apt install docker.io docker-compose-plugin

# Add your user to docker group (logout/login required after this)
sudo usermod -aG docker $USER

# Start Docker service
sudo systemctl enable docker
sudo systemctl start docker

# Optional: Install PostgreSQL client
sudo apt install postgresql-client

# Optional: Install platform dependencies for desktop client
sudo apt install libx11-dev libxrandr-dev libxi-dev
```

### Fedora / RHEL

```bash
# Install .NET SDK 10
sudo dnf install dotnet-sdk-10.0

# Install Docker
sudo dnf install docker docker-compose-plugin

# Add your user to docker group (logout/login required after this)
sudo usermod -aG docker $USER

# Start Docker service
sudo systemctl enable docker
sudo systemctl start docker

# Optional: Install PostgreSQL client
sudo dnf install postgresql

# Optional: Install platform dependencies for desktop client
sudo dnf install libX11-devel libXrandr-devel libXi-devel
```

### macOS

```bash
# Install Homebrew (if not already installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install .NET SDK 10
brew install dotnet@10

# Install Docker Desktop for Mac
brew install --cask docker

# Start Docker Desktop (GUI application)
open -a Docker

# Optional: Install PostgreSQL client
brew install postgresql@17

# Optional: Install Node.js
brew install node
```

## Verify Your Environment

After installing prerequisites, run the verification script to ensure everything is configured correctly:

```bash
bash scripts/verify-dev-env.sh
```

This script checks for:

- .NET SDK version 10.0 or higher
- Docker installation and daemon status
- Docker Compose availability
- Platform-specific dependencies
- Optional tools (PostgreSQL client, Node.js)

If any required checks fail, follow the remediation instructions provided by the script.

## Database Setup Options

ControlR supports three database configurations for development:

### Option 1: Docker Compose (Recommended)

Uses PostgreSQL in a Docker container with persistent storage.

**Advantages:**

- Closest to production environment
- Data persists between restarts
- Includes Aspire Dashboard for observability

**Setup:**

```bash
# Navigate to docker-compose directory
cd docker-compose

# Create .env file with required variables
cat > .env << 'EOF'
ControlR_POSTGRES_USER=dev
ControlR_POSTGRES_PASSWORD=dev123
ControlR_ASPIRE_BROWSER_TOKEN=dev-token-123
EOF

# Start services
docker compose up -d

# Verify services are running
docker compose ps

# View logs
docker compose logs -f
```

**Access Points:**

- PostgreSQL: `localhost:5432`
- Aspire Dashboard: `http://localhost:18888` (token: `dev-token-123`)

### Option 2: InMemory Database

Uses Entity Framework Core's in-memory provider. No Docker required.

**Advantages:**

- No external dependencies
- Fast startup
- Ideal for quick testing

**Limitations:**

- Data lost on application restart
- Some EF Core features not supported
- Not suitable for testing migrations

**Setup:**

```bash
# Edit appsettings.Development.json in ControlR.Web.Server
# Set DatabaseProvider to "InMemory"
```

Or set via environment variable:

```bash
export ControlR__DatabaseProvider=InMemory
```

### Option 3: Local PostgreSQL

Uses a locally installed PostgreSQL instance.

**Advantages:**

- No Docker required
- Full PostgreSQL feature support
- Can use existing PostgreSQL installation

**Setup:**

```bash
# Install PostgreSQL (if not already installed)
# Ubuntu/Debian: sudo apt install postgresql
# Fedora/RHEL: sudo dnf install postgresql-server
# macOS: brew install postgresql@17

# Create database
createdb controlr

# Set connection string via environment variable
export ControlR__ConnectionStrings__PostgreSQL="Host=localhost;Database=controlr;Username=youruser;Password=yourpass"

# Or add to appsettings.Development.json
```

## First-Time Run

### Using .NET Aspire (Recommended)

.NET Aspire orchestrates all services with proper dependency ordering and provides observability through the Aspire Dashboard.

```bash
# From repository root
dotnet run --project ControlR.Web.AppHost
```

This will:

1. Start PostgreSQL (if using Docker)
2. Apply database migrations
3. Start the web server
4. Start the agent
5. Open the Aspire Dashboard in your browser

**Access Points:**

- Web UI: `http://localhost:5120`
- Aspire Dashboard: `http://localhost:18888`
- API Documentation: `http://localhost:5120/scalar/`

### Using IDE Launch Configurations

#### VS Code

1. Open the repository in VS Code
2. Press `F5` or select "Run > Start Debugging"
3. Choose a launch configuration:
   - **Full Stack (Debug)** - Debug all components
   - **Full Stack (Hot Reload)** - Enable hot reload for rapid iteration
   - **Aspire AppHost** - Run via Aspire orchestration

#### JetBrains Rider

1. Open the solution in Rider
2. Select a run configuration from the dropdown:
   - **Full Stack (Debug)** - Debug all components
   - **Full Stack (Hot Reload)** - Enable hot reload
   - **Aspire AppHost** - Run via Aspire orchestration
3. Click the Run or Debug button

### Manual Component Startup

If you prefer to start components individually:

```bash
# Terminal 1: Start web server
cd ControlR.Web.Server
dotnet run

# Terminal 2: Start agent
cd ControlR.Agent
dotnet run

# Terminal 3: Start desktop client
cd ControlR.DesktopClient
dotnet run
```

## Building the Solution

```bash
# Build entire solution
dotnet build ControlR.slnx

# Build with minimal output (fast feedback)
dotnet build ControlR.slnx --verbosity quiet

# Clean build artifacts
dotnet clean ControlR.slnx

# Restore NuGet packages
dotnet restore ControlR.slnx
```

## Running Tests

```bash
# Run all tests
dotnet test ControlR.slnx

# Run tests with detailed output
dotnet test ControlR.slnx --verbosity normal

# Run tests for a specific project
dotnet test Tests/ControlR.Web.Server.Tests

# Run tests in watch mode (auto-rerun on changes)
dotnet watch test --project Tests/ControlR.Web.Server.Tests
```

## Development Workflows

### Hot Reload Development

Hot reload allows you to see code changes without restarting the application.

**Supported Changes:**

- Blazor component modifications (`.razor` files)
- CSS and JavaScript changes
- Some C# code changes (method bodies, properties)

**Unsupported Changes (require restart):**

- Adding new files
- Changing method signatures
- Modifying constructors
- Adding/removing dependencies

**Enable Hot Reload:**

```bash
# Using dotnet CLI
dotnet watch run --project ControlR.Web.Server

# Or use IDE launch configurations:
# - VS Code: "Full Stack (Hot Reload)"
# - Rider: "Full Stack (Hot Reload)"
```

### Debugging

**Set Breakpoints:**

- In your IDE, click in the gutter next to line numbers to set breakpoints
- Breakpoints work in all project types (web server, agent, desktop client)

**Blazor WebAssembly Debugging:**

1. Start the application with debugging enabled
2. Open browser developer tools (F12)
3. Navigate to Sources tab
4. Find your `.cs` files and set breakpoints
5. Or use VS Code's browser debugging integration

**Multi-Process Debugging:**

- Use compound launch configurations to debug multiple components simultaneously
- Switch between debug sessions using your IDE's debug panel

### Database Migrations

**Apply Migrations:**

```bash
# Using EF Core tools
dotnet ef database update --project ControlR.Web.Server

# Or let the application apply them automatically on startup
```

**Create New Migration:**

```bash
dotnet ef migrations add MigrationName --project ControlR.Web.Server
```

**Reset Database:**

```bash
# Docker Compose
docker compose down -v
docker compose up -d

# Local PostgreSQL
dropdb controlr
createdb controlr
dotnet ef database update --project ControlR.Web.Server

# InMemory
# Just restart the application
```

## IDE Setup

### VS Code

**Recommended Extensions:**

- C# Dev Kit (Microsoft)
- Docker (Microsoft)
- GitLens (optional)

**Configuration Files:**

- `.vscode/tasks.json` - Build and test tasks
- `.vscode/launch.json` - Debug configurations
- `.vscode/settings.json` - Workspace settings

**Useful Tasks:**

- `Ctrl+Shift+B` - Run default build task
- `Ctrl+Shift+P` > "Tasks: Run Task" - See all available tasks

### JetBrains Rider

**Configuration Files:**

- `.run/*.run.xml` - Run configurations

**Useful Features:**

- Built-in test runner with coverage
- Integrated database tools
- Advanced debugging and profiling

## Next Steps

- **IDE Configuration:** See [IDE_SETUP.md](IDE_SETUP.md) for detailed IDE-specific instructions
- **Database Details:** See [DATABASE.md](DATABASE.md) for advanced database configuration
- **Troubleshooting:** See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for common issues and solutions
- **Contributing:** See the root `README.md` for contribution guidelines

## Quick Reference

### Common Commands

```bash
# Verify environment
bash scripts/verify-dev-env.sh

# Build solution
dotnet build ControlR.slnx

# Run tests
dotnet test ControlR.slnx

# Start full stack via Aspire
dotnet run --project ControlR.Web.AppHost

# Start Docker services
cd docker-compose && docker compose up -d

# View Docker logs
docker compose logs -f

# Stop Docker services
docker compose down
```

### Environment Variables

```bash
# Database provider (InMemory or PostgreSQL)
export ControlR__DatabaseProvider=InMemory

# PostgreSQL connection string
export ControlR__ConnectionStrings__PostgreSQL="Host=localhost;Database=controlr;Username=dev;Password=dev"

# Aspire Dashboard token
export ControlR_ASPIRE_BROWSER_TOKEN=your-token-here
```

### Default Ports

| Service          | Port  | URL                    |
| ---------------- | ----- | ---------------------- |
| Web Server       | 5120  | http://localhost:5120  |
| PostgreSQL       | 5432  | localhost:5432         |
| Aspire Dashboard | 18888 | http://localhost:18888 |
| Aspire OTLP      | 18889 | http://localhost:18889 |

## Getting Help

If you encounter issues:

1. Run the verification script: `bash scripts/verify-dev-env.sh`
2. Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for common issues
3. Review logs in the Aspire Dashboard
4. Check Docker logs: `docker compose logs`
5. Open an issue on GitHub with details about your environment and the error
