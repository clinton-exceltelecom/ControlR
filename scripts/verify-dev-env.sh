#!/usr/bin/env bash

# ControlR Development Environment Verification Script
# This script checks for all required prerequisites and provides actionable feedback

# Don't exit on error - we want to run all checks
set +e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Track overall status
ALL_CHECKS_PASSED=true

# Helper functions
print_header() {
    echo -e "\n${BLUE}=== $1 ===${NC}"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
    ALL_CHECKS_PASSED=false
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Compare version numbers (returns 0 if $1 >= $2)
version_ge() {
    printf '%s\n%s\n' "$2" "$1" | sort -V -C
}

# Main verification functions

check_dotnet_sdk() {
    print_header "Checking .NET SDK"
    
    if ! command_exists dotnet; then
        print_error ".NET SDK not found"
        print_info "Install from: https://dotnet.microsoft.com/download"
        print_info "Required version: 10.0 or higher"
        return 1
    fi
    
    local dotnet_version
    dotnet_version=$(dotnet --version 2>/dev/null | cut -d'.' -f1)
    
    if [ -z "$dotnet_version" ]; then
        print_error "Unable to determine .NET SDK version"
        return 1
    fi
    
    if [ "$dotnet_version" -ge 10 ]; then
        print_success ".NET SDK $(dotnet --version) found"
        return 0
    else
        print_error ".NET SDK version $(dotnet --version) is too old"
        print_info "Required version: 10.0 or higher"
        print_info "Install from: https://dotnet.microsoft.com/download"
        return 1
    fi
}

check_docker() {
    print_header "Checking Docker"
    
    if ! command_exists docker; then
        print_warning "Docker not found (optional for InMemory database development)"
        print_info "Install Docker Desktop from: https://www.docker.com/products/docker-desktop"
        print_info "Or use your package manager:"
        print_info "  Ubuntu/Debian: sudo apt install docker.io"
        print_info "  Fedora/RHEL: sudo dnf install docker"
        print_info "  macOS: brew install --cask docker"
        return 0
    fi
    
    print_success "Docker $(docker --version | cut -d' ' -f3 | tr -d ',') found"
    
    # Check if Docker daemon is running
    if docker info >/dev/null 2>&1; then
        print_success "Docker daemon is running"
    else
        print_error "Docker is installed but daemon is not running"
        print_info "Start Docker:"
        print_info "  Linux: sudo systemctl start docker"
        print_info "  macOS: Start Docker Desktop application"
        return 1
    fi
    
    return 0
}

check_docker_compose() {
    print_header "Checking Docker Compose"
    
    # Check for docker compose (v2, integrated with docker)
    if docker compose version >/dev/null 2>&1; then
        local compose_version
        compose_version=$(docker compose version --short 2>/dev/null || echo "unknown")
        print_success "Docker Compose v2 (${compose_version}) found"
        return 0
    fi
    
    # Check for docker-compose (v1, standalone)
    if command_exists docker-compose; then
        local compose_version
        compose_version=$(docker-compose --version | cut -d' ' -f3 | tr -d ',')
        print_success "Docker Compose v1 (${compose_version}) found"
        return 0
    fi
    
    print_warning "Docker Compose not found (optional for InMemory database development)"
    print_info "Install Docker Compose:"
    print_info "  Ubuntu/Debian: sudo apt install docker-compose-plugin"
    print_info "  Fedora/RHEL: sudo dnf install docker-compose-plugin"
    print_info "  macOS: Included with Docker Desktop"
    return 0
}

check_platform_dependencies() {
    print_header "Checking Platform-Specific Dependencies"
    
    local os_type
    os_type=$(uname -s)
    
    case "$os_type" in
        Linux)
            check_linux_dependencies
            ;;
        Darwin)
            check_macos_dependencies
            ;;
        *)
            print_warning "Unknown operating system: $os_type"
            ;;
    esac
}

check_linux_dependencies() {
    print_info "Detected Linux system"
    
    # Check for X11 development libraries (optional, for desktop client development)
    if command_exists pkg-config; then
        if pkg-config --exists x11 2>/dev/null; then
            print_success "X11 development libraries found"
        else
            print_warning "X11 development libraries not found (optional for desktop client development)"
            print_info "Install: sudo apt install libx11-dev libxrandr-dev libxi-dev"
        fi
    else
        print_warning "pkg-config not found, skipping library checks"
        print_info "Install: sudo apt install pkg-config"
    fi
    
    # Check for GStreamer (optional, for Wayland support)
    # Check for runtime libraries via dpkg or ldconfig
    if dpkg -l 2>/dev/null | grep -q "^ii.*libgstreamer1.0-0" || \
       ldconfig -p 2>/dev/null | grep -q "libgstreamer-1.0"; then
        print_success "GStreamer found (Wayland support)"
    else
        print_warning "GStreamer not found (optional for Wayland support)"
        print_info "Install: sudo apt install libgstreamer1.0-0 gstreamer1.0-plugins-base gstreamer1.0-plugins-good"
    fi
    
    # Check display server
    if [ -n "$WAYLAND_DISPLAY" ]; then
        print_info "Running on Wayland (experimental support)"
    elif [ -n "$DISPLAY" ]; then
        print_info "Running on X11"
    else
        print_warning "No display server detected"
    fi
}

check_macos_dependencies() {
    print_info "Detected macOS system"
    
    # Check for Homebrew (recommended package manager)
    if command_exists brew; then
        print_success "Homebrew found"
    else
        print_warning "Homebrew not found (recommended for macOS)"
        print_info "Install from: https://brew.sh"
    fi
    
    # macOS has built-in frameworks for desktop client, no additional deps needed
    print_success "macOS frameworks available (CoreGraphics, Cocoa)"
}

check_optional_tools() {
    print_header "Checking Optional Tools"
    
    # PostgreSQL client (optional, for local PostgreSQL development)
    if command_exists psql; then
        local psql_version
        psql_version=$(psql --version | cut -d' ' -f3)
        print_success "PostgreSQL client (${psql_version}) found"
    else
        print_info "PostgreSQL client not found (optional for local PostgreSQL development)"
        print_info "Install:"
        print_info "  Ubuntu/Debian: sudo apt install postgresql-client"
        print_info "  Fedora/RHEL: sudo dnf install postgresql"
        print_info "  macOS: brew install postgresql"
    fi
    
    # Kiota (optional, for API client generation)
    if command_exists kiota; then
        local kiota_version
        kiota_version=$(kiota --version 2>/dev/null | head -n1 | grep -oP '\d+\.\d+\.\d+' || echo "unknown")
        print_success "Kiota (${kiota_version}) found"
    else
        print_info "Kiota not found (optional for API client generation)"
        print_info "Install: dotnet tool install --global Microsoft.OpenApi.Kiota"
    fi
    
    # Node.js (optional, for Blazor tooling)
    if command_exists node; then
        local node_version
        node_version=$(node --version)
        print_success "Node.js (${node_version}) found"
    else
        print_info "Node.js not found (optional for Blazor development tooling)"
        print_info "Install from: https://nodejs.org"
    fi
    
    # Git (should be present, but check anyway)
    if command_exists git; then
        print_success "Git found"
    else
        print_warning "Git not found (required for version control)"
        print_info "Install:"
        print_info "  Ubuntu/Debian: sudo apt install git"
        print_info "  Fedora/RHEL: sudo dnf install git"
        print_info "  macOS: brew install git"
    fi
}

print_summary() {
    print_header "Verification Summary"
    
    if [ "$ALL_CHECKS_PASSED" = true ]; then
        echo -e "${GREEN}✓ All required checks passed!${NC}"
        echo -e "${GREEN}Your development environment is ready for ControlR development.${NC}"
        echo ""
        echo "Next steps:"
        echo "  1. Build the solution: dotnet build ControlR.slnx"
        echo "  2. Start the full stack: dotnet run --project ControlR.Web.AppHost"
        echo "  3. Or use your IDE's launch configurations"
        echo ""
        echo "For more information, see: docs/development/SETUP.md"
        return 0
    else
        echo -e "${RED}✗ Some required checks failed${NC}"
        echo -e "${YELLOW}Please address the errors above before starting development.${NC}"
        echo ""
        echo "For detailed setup instructions, see: docs/development/SETUP.md"
        echo "For troubleshooting, see: docs/development/TROUBLESHOOTING.md"
        return 1
    fi
}

# Main execution
main() {
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║  ControlR Development Environment Verification            ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
    
    check_dotnet_sdk
    check_docker
    check_docker_compose
    check_platform_dependencies
    check_optional_tools
    
    print_summary
    return $?
}

# Run main function
main
exit $?
