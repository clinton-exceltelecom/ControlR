# Development Troubleshooting Guide

This guide covers common issues you may encounter while developing ControlR on Linux and macOS, along with their solutions.

## Table of Contents

- [Port Conflicts](#port-conflicts)
- [Docker Issues](#docker-issues)
- [Database Connection Failures](#database-connection-failures)
- [Hot Reload Not Working](#hot-reload-not-working)
- [Aspire Dashboard Issues](#aspire-dashboard-issues)
- [Build and Compilation Errors](#build-and-compilation-errors)
- [Platform-Specific Issues](#platform-specific-issues)
- [IDE-Specific Issues](#ide-specific-issues)
- [SignalR Connection Issues](#signalr-connection-issues)
- [Performance Issues](#performance-issues)

## Port Conflicts

### Symptom

Application fails to start with an error like:

```
Failed to bind to address http://127.0.0.1:5120: address already in use
```

Or:

```
System.IO.IOException: Failed to bind to address http://[::]:5120
```

### Cause

Another process is already using the required port (5120 for web server, 5432 for PostgreSQL, 18888 for Aspire Dashboard).

### Solution

**Find the process using the port:**

```bash
# Linux
sudo lsof -i :5120
# Or
sudo netstat -tulpn | grep :5120

# macOS
sudo lsof -i :5120
# Or
lsof -nP -iTCP:5120 | grep LISTEN
```

**Kill the process:**

```bash
# Replace <PID> with the process ID from above
kill <PID>

# Or force kill if needed
kill -9 <PID>
```

**Change the port:**

If you need to use a different port, modify `launchSettings.json`:

```bash
# Edit ControlR.Web.Server/Properties/launchSettings.json
# Change the applicationUrl to use a different port
```

Or set via environment variable:

```bash
export ASPNETCORE_URLS="http://localhost:5121"
```

### Prevention

- Stop all ControlR processes before starting a new session
- Use IDE stop buttons instead of closing terminal windows
- Check for orphaned processes: `ps aux | grep dotnet`

## Docker Issues

### Docker Daemon Not Running

**Symptom:**

```
Cannot connect to the Docker daemon at unix:///var/run/docker.sock
```

**Solution:**

**Linux:**

```bash
# Check Docker status
sudo systemctl status docker

# Start Docker if not running
sudo systemctl start docker

# Enable Docker to start on boot
sudo systemctl enable docker

# Verify Docker is running
docker ps
```

**macOS:**

```bash
# Start Docker Desktop
open -a Docker

# Wait for Docker to fully start (check menu bar icon)
# Then verify
docker ps
```

### Permission Denied (Linux)

**Symptom:**

```
permission denied while trying to connect to the Docker daemon socket
```

**Solution:**

```bash
# Add your user to the docker group
sudo usermod -aG docker $USER

# Log out and log back in for changes to take effect
# Or use newgrp to activate the group immediately
newgrp docker

# Verify
docker ps
```

### Docker Compose Services Won't Start

**Symptom:**

```
ERROR: The Compose file is invalid
```

Or services start but immediately exit.

**Solution:**

```bash
# Check if .env file exists and has required variables
cd docker-compose
cat .env

# If missing, create it:
cat > .env << 'EOF'
ControlR_POSTGRES_USER=dev
ControlR_POSTGRES_PASSWORD=dev123
ControlR_ASPIRE_BROWSER_TOKEN=dev-token-123
EOF

# Verify docker-compose configuration
docker compose config

# View service logs
docker compose logs

# Restart services
docker compose down
docker compose up -d
```

### Container Port Already Allocated

**Symptom:**

```
Error response from daemon: driver failed programming external connectivity:
Bind for 0.0.0.0:5432 failed: port is already allocated
```

**Solution:**

```bash
# Find what's using the port
sudo lsof -i :5432

# Stop the conflicting service
# For PostgreSQL:
sudo systemctl stop postgresql

# Or modify docker-compose.yml to use different ports
# Change "5432:5432" to "5433:5432" for example
```

### Docker Disk Space Issues

**Symptom:**

```
no space left on device
```

**Solution:**

```bash
# Check Docker disk usage
docker system df

# Remove unused containers, images, and volumes
docker system prune -a --volumes

# Or be more selective:
docker container prune  # Remove stopped containers
docker image prune -a   # Remove unused images
docker volume prune     # Remove unused volumes
```

## Database Connection Failures

### Cannot Connect to PostgreSQL

**Symptom:**

```
Npgsql.NpgsqlException: Failed to connect to [::1]:5432
```

Or:

```
Connection refused
```

**Solution:**

**Check PostgreSQL is running:**

```bash
# Docker Compose
docker compose ps
docker compose logs postgres

# Local PostgreSQL (Linux)
sudo systemctl status postgresql

# Local PostgreSQL (macOS)
brew services list
```

**Verify connection string:**

```bash
# Check environment variables
env | grep ControlR

# Test connection manually
psql -h localhost -U dev -d controlr
# Enter password when prompted
```

**Check firewall:**

```bash
# Linux - allow PostgreSQL port
sudo ufw allow 5432/tcp

# macOS - check System Preferences > Security & Privacy > Firewall
```

### Database Does Not Exist

**Symptom:**

```
Npgsql.PostgresException: 3D000: database "controlr" does not exist
```

**Solution:**

```bash
# Docker Compose - recreate containers
docker compose down -v
docker compose up -d

# Local PostgreSQL
createdb -U dev controlr

# Or using psql
psql -U postgres
CREATE DATABASE controlr;
\q
```

### Migration Failures

**Symptom:**

```
An error occurred using the connection to database 'controlr'
```

Or migrations don't apply automatically.

**Solution:**

```bash
# Apply migrations manually
dotnet ef database update --project ControlR.Web.Server

# If that fails, check for pending migrations
dotnet ef migrations list --project ControlR.Web.Server

# Reset database and reapply
dotnet ef database drop --project ControlR.Web.Server --force
dotnet ef database update --project ControlR.Web.Server

# Or with Docker Compose
docker compose down -v
docker compose up -d
```

### InMemory Database Not Working

**Symptom:**

Application still tries to connect to PostgreSQL even with InMemory configured.

**Solution:**

```bash
# Verify configuration
cat ControlR.Web.Server/appsettings.Development.json | grep DatabaseProvider

# Set via environment variable (takes precedence)
export ControlR__DatabaseProvider=InMemory

# Verify it's set
env | grep ControlR__DatabaseProvider

# Restart the application
```

## Hot Reload Not Working

### Changes Not Applying

**Symptom:**

Code changes don't take effect without restarting the application.

**Solution:**

**Verify hot reload is enabled:**

```bash
# Check if running with dotnet watch
ps aux | grep "dotnet watch"

# Or check IDE launch configuration includes hot reload
```

**Supported vs Unsupported Changes:**

Hot reload supports:

- Method body changes
- Property modifications
- Razor component markup
- CSS and JavaScript files

Hot reload does NOT support:

- Adding new files
- Changing method signatures
- Modifying constructors
- Adding/removing dependencies
- Generic type parameter changes

**Force a restart:**

```bash
# In terminal running dotnet watch, press Ctrl+R
# Or stop and restart the debug session
```

### Hot Reload Errors

**Symptom:**

```
Hot reload failed: Rude edit detected
```

**Solution:**

This means the change requires a restart. Stop the application and start it again.

**Symptom:**

```
Hot reload failed: Unable to apply changes
```

**Solution:**

```bash
# Clean and rebuild
dotnet clean ControlR.slnx
dotnet build ControlR.slnx

# Delete bin and obj folders
find . -name "bin" -o -name "obj" | xargs rm -rf

# Restart the application
```

## Aspire Dashboard Issues

### Dashboard Not Accessible

**Symptom:**

Cannot access `http://localhost:18888` or connection refused.

**Solution:**

**Check if Aspire Dashboard is running:**

```bash
# Docker Compose
docker compose ps aspire
docker compose logs aspire

# AppHost
# Check terminal output for Aspire Dashboard URL
```

**Verify port is not blocked:**

```bash
# Check if port is listening
lsof -i :18888

# Try accessing with curl
curl http://localhost:18888
```

**Check browser token:**

```bash
# Verify token in .env file
cat docker-compose/.env | grep ASPIRE_BROWSER_TOKEN

# Or check AppHost output for token
```

### Authentication Failed

**Symptom:**

Dashboard prompts for token but rejects it.

**Solution:**

```bash
# Check the token in docker-compose/.env
cat docker-compose/.env | grep ControlR_ASPIRE_BROWSER_TOKEN

# Or check AppHost console output for the correct token

# Update .env file if needed
# Then restart services
docker compose down
docker compose up -d
```

### No Telemetry Data

**Symptom:**

Dashboard loads but shows no logs, traces, or metrics.

**Solution:**

**Verify OTLP endpoint configuration:**

```bash
# Check environment variable
env | grep OTLP_ENDPOINT_URL

# Should be: http://aspire:18889 (Docker) or http://localhost:18889 (local)
```

**Check application is sending telemetry:**

```bash
# Look for OpenTelemetry logs in application output
# Should see messages about OTLP exporter initialization
```

**Restart services in correct order:**

```bash
docker compose down
docker compose up -d aspire
# Wait a few seconds
docker compose up -d controlr
```

## Build and Compilation Errors

### NuGet Restore Failures

**Symptom:**

```
error NU1101: Unable to find package
```

**Solution:**

```bash
# Clear NuGet cache
dotnet nuget locals all --clear

# Restore packages
dotnet restore ControlR.slnx

# If behind a proxy, configure NuGet
dotnet nuget add source https://api.nuget.org/v3/index.json -n nuget.org
```

### SDK Version Mismatch

**Symptom:**

```
error NETSDK1045: The current .NET SDK does not support targeting .NET 10.0
```

**Solution:**

```bash
# Check installed SDK versions
dotnet --list-sdks

# Install .NET 10 SDK
# See SETUP.md for platform-specific instructions

# Verify global.json if present
cat global.json
```

### Missing Dependencies

**Symptom:**

```
error CS0246: The type or namespace name 'X' could not be found
```

**Solution:**

```bash
# Restore NuGet packages
dotnet restore ControlR.slnx

# Clean and rebuild
dotnet clean ControlR.slnx
dotnet build ControlR.slnx

# Check for missing project references
# Verify .csproj files have correct PackageReference entries
```

### Build Artifacts Corruption

**Symptom:**

Strange compilation errors that don't make sense, or "file in use" errors.

**Solution:**

```bash
# Stop all running processes
pkill -f dotnet

# Remove all build artifacts
find . -type d -name "bin" -o -name "obj" | xargs rm -rf

# Rebuild
dotnet restore ControlR.slnx
dotnet build ControlR.slnx
```

## Platform-Specific Issues

### Linux: X11 Issues

**Symptom:**

Desktop client fails to start with X11 errors:

```
Unable to open display
```

**Solution:**

```bash
# Verify X11 is running
echo $DISPLAY
# Should output something like :0 or :1

# If empty, set it
export DISPLAY=:0

# Install X11 development libraries
sudo apt install libx11-dev libxrandr-dev libxi-dev  # Ubuntu/Debian
sudo dnf install libX11-devel libXrandr-devel libXi-devel  # Fedora
```

### Linux: Wayland Issues

**Symptom:**

Desktop client doesn't work properly on Wayland, or screen capture fails.

**Solution:**

```bash
# Check if running Wayland
echo $XDG_SESSION_TYPE
# Output: wayland or x11

# Install GStreamer for Wayland support
sudo apt install libgstreamer1.0-0 gstreamer1.0-plugins-base gstreamer1.0-plugins-good

# Or fall back to X11
# Log out and select "Ubuntu on Xorg" at login screen
```

### Linux: DBus Issues

**Symptom:**

```
Failed to connect to DBus session bus
```

**Solution:**

```bash
# Check DBus is running
systemctl --user status dbus

# Start if not running
systemctl --user start dbus

# Verify DBus session address
echo $DBUS_SESSION_BUS_ADDRESS
```

### macOS: Permission Issues

**Symptom:**

Desktop client can't capture screen or control input.

**Solution:**

1. Open System Preferences > Security & Privacy > Privacy
2. Grant permissions for:
   - Screen Recording
   - Accessibility
   - Input Monitoring
3. Add the terminal app or IDE you're using
4. Restart the application

### macOS: Code Signing Issues

**Symptom:**

```
"ControlR.DesktopClient" cannot be opened because the developer cannot be verified
```

**Solution:**

```bash
# For development builds, disable Gatekeeper temporarily
sudo spctl --master-disable

# Or allow the specific app
xattr -d com.apple.quarantine /path/to/ControlR.DesktopClient.app

# Re-enable Gatekeeper after development
sudo spctl --master-enable
```

### macOS: Rosetta Issues (Apple Silicon)

**Symptom:**

Application crashes or won't start on Apple Silicon Macs.

**Solution:**

```bash
# Install Rosetta 2 if needed (for x64 dependencies)
softwareupdate --install-rosetta

# Verify .NET SDK architecture
dotnet --info | grep RID
# Should show osx-arm64 for native or osx-x64 for Rosetta

# Use native ARM64 SDK when possible
brew install dotnet@10
```

## IDE-Specific Issues

### VS Code: C# Extension Not Working

**Symptom:**

No IntelliSense, red squiggles everywhere, or "OmniSharp" errors.

**Solution:**

```bash
# Restart OmniSharp server
# Command Palette (Ctrl+Shift+P) > "OmniSharp: Restart OmniSharp"

# Check OmniSharp logs
# Output panel > Select "OmniSharp Log" from dropdown

# Reinstall C# Dev Kit
# Extensions > C# Dev Kit > Uninstall > Reload > Install

# Clear VS Code cache
rm -rf ~/.vscode/extensions/ms-dotnettools.*
# Then reinstall C# Dev Kit
```

### VS Code: Debugger Not Attaching

**Symptom:**

Breakpoints show as gray circles, or debugger doesn't stop at breakpoints.

**Solution:**

```bash
# Verify launch configuration
cat .vscode/launch.json

# Check program path is correct
# Should point to bin/Debug/net10.0/ProjectName.dll

# Rebuild project
dotnet build ControlR.slnx

# Try deleting bin/obj folders
find . -name "bin" -o -name "obj" | xargs rm -rf
dotnet build ControlR.slnx
```

### Rider: Solution Won't Load

**Symptom:**

Rider shows errors loading the solution or projects are grayed out.

**Solution:**

```bash
# Invalidate caches
# File > Invalidate Caches > Invalidate and Restart

# Delete Rider cache directory
rm -rf .idea/

# Reopen solution
# Rider will regenerate cache
```

### Rider: Tests Not Discovered

**Symptom:**

Test explorer is empty or doesn't show tests.

**Solution:**

```bash
# Rebuild solution
# Build > Rebuild Solution

# Invalidate caches
# File > Invalidate Caches > Invalidate and Restart

# Check test framework is installed
# Verify xUnit packages in Directory.Packages.props
```

## SignalR Connection Issues

### Agent Can't Connect to Server

**Symptom:**

```
Failed to connect to SignalR hub
```

Or agent shows as offline in web UI.

**Solution:**

**Verify server is running:**

```bash
# Check if server is listening
lsof -i :5120

# Check server logs for errors
```

**Check connection URL:**

```bash
# Verify agent configuration
# Should point to http://localhost:5120 or correct server URL
```

**Check firewall:**

```bash
# Linux
sudo ufw status
sudo ufw allow 5120/tcp

# macOS
# System Preferences > Security & Privacy > Firewall
```

### Connection Drops Frequently

**Symptom:**

SignalR connections disconnect and reconnect repeatedly.

**Solution:**

**Check network stability:**

```bash
# Ping server
ping localhost

# Check for packet loss
```

**Increase timeout values:**

Edit server configuration to increase SignalR timeouts.

**Check server resources:**

```bash
# Monitor CPU and memory
top
# Or
htop

# Check for resource exhaustion
```

## Performance Issues

### Slow Build Times

**Symptom:**

Building the solution takes a very long time.

**Solution:**

```bash
# Build only what you need
dotnet build ControlR.Web.Server

# Use parallel builds
dotnet build ControlR.slnx -m

# Exclude test projects if not needed
dotnet build ControlR.slnx --no-dependencies

# Clean old artifacts
dotnet clean ControlR.slnx
```

### High Memory Usage

**Symptom:**

IDE or application consumes excessive memory.

**Solution:**

**VS Code:**

```bash
# Disable unused extensions
# Extensions > Disable

# Exclude bin/obj from file watcher
# Add to .vscode/settings.json:
# "files.watcherExclude": {
#   "**/bin/**": true,
#   "**/obj/**": true
# }
```

**Rider:**

```bash
# Increase heap size
# Help > Change Memory Settings
# Set to 4096 MB or higher

# Enable power save mode when not coding
# File > Power Save Mode
```

**Application:**

```bash
# Monitor memory usage
dotnet-counters monitor --process-id <PID>

# Profile memory
dotnet-trace collect --process-id <PID>

# Check for memory leaks in code
```

### Slow Application Startup

**Symptom:**

Application takes a long time to start.

**Solution:**

```bash
# Use InMemory database for faster startup
export ControlR__DatabaseProvider=InMemory

# Skip migrations if database is already up to date
# Set in appsettings.Development.json

# Disable unnecessary services during development
# Comment out service registrations you don't need
```

## Getting More Help

If you've tried the solutions above and still have issues:

1. **Run the verification script:**

   ```bash
   bash scripts/verify-dev-env.sh
   ```

2. **Check logs:**
   - Application logs in terminal output
   - Aspire Dashboard logs at http://localhost:18888
   - Docker logs: `docker compose logs`

3. **Gather diagnostic information:**

   ```bash
   # System info
   uname -a

   # .NET info
   dotnet --info

   # Docker info
   docker --version
   docker compose version

   # Running processes
   ps aux | grep dotnet
   ```

4. **Search existing issues:**
   - Check GitHub issues for similar problems
   - Search ControlR documentation

5. **Open a new issue:**
   - Include your platform (Linux/macOS) and version
   - Include .NET SDK version
   - Include error messages and stack traces
   - Include steps to reproduce
   - Include output from verification script

## Quick Diagnostic Commands

```bash
# Verify environment
bash scripts/verify-dev-env.sh

# Check .NET SDK
dotnet --version
dotnet --list-sdks

# Check Docker
docker --version
docker ps
docker compose ps

# Check ports
sudo lsof -i :5120  # Web server
sudo lsof -i :5432  # PostgreSQL
sudo lsof -i :18888 # Aspire Dashboard

# Check running processes
ps aux | grep dotnet

# Check disk space
df -h

# Check memory
free -h  # Linux
vm_stat  # macOS

# View recent logs
docker compose logs --tail=50

# Test database connection
psql -h localhost -U dev -d controlr

# Rebuild everything
dotnet clean ControlR.slnx
find . -name "bin" -o -name "obj" | xargs rm -rf
dotnet restore ControlR.slnx
dotnet build ControlR.slnx
```
