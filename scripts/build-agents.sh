#!/bin/bash
set -e

# ControlR Agent Build Script
# Builds agent binaries for all platforms and places them in wwwroot/downloads

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to show usage
usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Build ControlR agent binaries for deployment

OPTIONS:
    -v, --version VERSION   Application version (default: 1.0.0)
    -p, --platform PLATFORM Build specific platform only (linux-x64, win-x64, win-x86, osx-x64, osx-arm64, all)
    --clean                 Clean output directories before building
    -h, --help              Show this help message

EXAMPLES:
    # Build all platforms
    $0 --version 1.0.0

    # Build only Linux agent
    $0 --version 1.0.0 --platform linux-x64

    # Clean and build all
    $0 --clean --version 1.0.0

EOF
    exit 1
}

# Default values
VERSION="1.0.0"
PLATFORM="all"
CLEAN=false
OUTPUT_DIR="ControlR.Web.Server/wwwroot/downloads"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -v|--version)
            VERSION="$2"
            shift 2
            ;;
        -p|--platform)
            PLATFORM="$2"
            shift 2
            ;;
        --clean)
            CLEAN=true
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            print_error "Unknown option: $1"
            usage
            ;;
    esac
done

# Validate version format
if [[ ! $VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.-]+)?$ ]]; then
    print_error "Invalid version format: $VERSION"
    print_error "Version must follow semantic versioning (e.g., 1.0.0, 1.2.3-beta)"
    exit 1
fi

# Extract numeric version for FileVersion
FILE_VERSION=$(echo "$VERSION" | sed -E 's/^([0-9]+\.[0-9]+\.[0-9]+).*/\1.0/')

print_info "=========================================="
print_info "ControlR Agent Build"
print_info "=========================================="
print_info "Version:      ${VERSION}"
print_info "FileVersion:  ${FILE_VERSION}"
print_info "Platform:     ${PLATFORM}"
print_info "Output:       ${OUTPUT_DIR}"
print_info "=========================================="
echo

# Clean if requested
if [ "$CLEAN" = true ]; then
    print_info "Cleaning output directories..."
    rm -rf "${OUTPUT_DIR}"
    rm -rf "ControlR.Agent.Common/Resources/*.zip"
    rm -rf "ControlR.DesktopClient/bin/publish"
    rm -rf "ControlR.Agent/bin/publish"
    print_success "Cleaned output directories"
fi

# Create output directory
mkdir -p "${OUTPUT_DIR}"

# Function to build desktop client
build_desktop_client() {
    local runtime=$1
    local platform_name=$2
    
    print_info "Building DesktopClient for ${platform_name}..."
    
    # Clean resources
    rm -f "ControlR.Agent.Common/Resources/*.zip"
    
    # Build desktop client
    dotnet publish ./ControlR.DesktopClient/ \
        -c Release \
        -r "${runtime}" \
        --self-contained \
        -o "./ControlR.DesktopClient/bin/publish/${runtime}/" \
        -p:Version="${VERSION}" \
        -p:FileVersion="${FILE_VERSION}" \
        > /dev/null
    
    if [ $? -ne 0 ]; then
        print_error "Failed to build DesktopClient for ${platform_name}"
        return 1
    fi
    
    # Create ZIP
    cd "./ControlR.DesktopClient/bin/publish/${runtime}/"
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS - create app bundle and zip
        ditto -c -k --sequesterRsrc . "../../../../ControlR.Agent.Common/Resources/ControlR.app.zip"
    else
        # Linux/Windows - create regular zip
        zip -r -q "../../../../ControlR.Agent.Common/Resources/ControlR.DesktopClient.zip" .
    fi
    
    cd - > /dev/null
    
    print_success "Built DesktopClient for ${platform_name}"
}

# Function to build agent
build_agent() {
    local runtime=$1
    local platform_name=$2
    local extension=$3
    
    print_info "Building Agent for ${platform_name}..."
    
    # Create output directory
    mkdir -p "${OUTPUT_DIR}/${runtime}"
    
    # Build agent
    dotnet publish ./ControlR.Agent/ \
        -c Release \
        -r "${runtime}" \
        -o "${OUTPUT_DIR}/${runtime}/" \
        -p:PublishSingleFile=true \
        -p:UseAppHost=true \
        -p:Version="${VERSION}" \
        -p:FileVersion="${FILE_VERSION}" \
        -p:IncludeAllContentForSelfExtract=true \
        -p:EnableCompressionInSingleFile=true \
        -p:IncludeAppSettingsInSingleFile=true \
        > /dev/null
    
    if [ $? -ne 0 ]; then
        print_error "Failed to build Agent for ${platform_name}"
        return 1
    fi
    
    # Verify the agent binary exists
    if [ ! -f "${OUTPUT_DIR}/${runtime}/ControlR.Agent${extension}" ]; then
        print_error "Agent binary not found: ${OUTPUT_DIR}/${runtime}/ControlR.Agent${extension}"
        return 1
    fi
    
    print_success "Built Agent for ${platform_name}: ${OUTPUT_DIR}/${runtime}/ControlR.Agent${extension}"
}

# Function to build for a specific platform
build_platform() {
    local runtime=$1
    local platform_name=$2
    local extension=$3
    
    print_info "=========================================="
    print_info "Building ${platform_name}"
    print_info "=========================================="
    
    build_desktop_client "${runtime}" "${platform_name}"
    if [ $? -ne 0 ]; then
        return 1
    fi
    
    build_agent "${runtime}" "${platform_name}" "${extension}"
    if [ $? -ne 0 ]; then
        return 1
    fi
    
    echo
}

# Build based on platform selection
case $PLATFORM in
    linux-x64)
        build_platform "linux-x64" "Linux x64" ""
        ;;
    win-x64)
        build_platform "win-x64" "Windows x64" ".exe"
        ;;
    win-x86)
        build_platform "win-x86" "Windows x86" ".exe"
        ;;
    osx-x64)
        build_platform "osx-x64" "macOS x64" ""
        ;;
    osx-arm64)
        build_platform "osx-arm64" "macOS ARM64" ""
        ;;
    all)
        print_info "Building all platforms..."
        echo
        
        build_platform "linux-x64" "Linux x64" ""
        build_platform "win-x64" "Windows x64" ".exe"
        build_platform "win-x86" "Windows x86" ".exe"
        
        # Only build macOS on macOS
        if [[ "$OSTYPE" == "darwin"* ]]; then
            build_platform "osx-x64" "macOS x64" ""
            build_platform "osx-arm64" "macOS ARM64" ""
        else
            print_warning "Skipping macOS builds (not running on macOS)"
        fi
        ;;
    *)
        print_error "Unknown platform: $PLATFORM"
        print_error "Valid platforms: linux-x64, win-x64, win-x86, osx-x64, osx-arm64, all"
        exit 1
        ;;
esac

# Create version file
echo "${VERSION}" > "${OUTPUT_DIR}/Version.txt"
print_success "Created version file: ${OUTPUT_DIR}/Version.txt"

print_success "=========================================="
print_success "Build completed successfully!"
print_success "=========================================="
print_info "Agent binaries are in: ${OUTPUT_DIR}"
echo
print_info "To build Docker image with these agents:"
echo "  ./scripts/build-and-push-docker.sh --skip-login --version ${VERSION} --tag v${VERSION}"
