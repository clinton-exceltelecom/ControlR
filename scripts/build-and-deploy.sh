#!/bin/bash
set -e

# ControlR Complete Build and Deploy Script
# Builds agents and Docker image in one command

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to show usage
usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Complete build and deploy workflow for ControlR

OPTIONS:
    -v, --version VERSION   Application version (default: 1.0.0)
    -t, --tag TAG           Docker image tag (default: same as version)
    -p, --platform PLATFORM Agent platform to build (default: linux-x64)
    --no-push               Build only, don't push to registry
    --clean                 Clean before building
    -h, --help              Show this help message

EXAMPLES:
    # Build Linux agent and Docker image
    $0 --version 1.0.0

    # Build all agents and Docker image
    $0 --version 1.0.0 --platform all

    # Build and push with custom tag
    $0 --version 1.0.0 --tag v1.0.0

EOF
    exit 1
}

# Default values
VERSION="1.0.0"
TAG=""
PLATFORM="linux-x64"
NO_PUSH=""
CLEAN=""

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -v|--version)
            VERSION="$2"
            shift 2
            ;;
        -t|--tag)
            TAG="$2"
            shift 2
            ;;
        -p|--platform)
            PLATFORM="$2"
            shift 2
            ;;
        --no-push)
            NO_PUSH="--no-push"
            shift
            ;;
        --clean)
            CLEAN="--clean"
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

# Use version as tag if not specified
if [ -z "$TAG" ]; then
    TAG="v${VERSION}"
fi

print_info "=========================================="
print_info "ControlR Complete Build and Deploy"
print_info "=========================================="
print_info "Version:  ${VERSION}"
print_info "Tag:      ${TAG}"
print_info "Platform: ${PLATFORM}"
print_info "=========================================="
echo

# Step 1: Build agents
print_info "Step 1/2: Building agent binaries..."
./scripts/build-agents.sh --version "${VERSION}" --platform "${PLATFORM}" ${CLEAN}

if [ $? -ne 0 ]; then
    print_error "Agent build failed"
    exit 1
fi

echo
print_success "Agent binaries built successfully"
echo

# Step 2: Build and push Docker image
print_info "Step 2/2: Building Docker image..."
./scripts/build-and-push-docker.sh \
    --version "${VERSION}" \
    --tag "${TAG}" \
    --skip-login \
    ${NO_PUSH}

if [ $? -ne 0 ]; then
    print_error "Docker build failed"
    exit 1
fi

print_success "=========================================="
print_success "Complete build and deploy finished!"
print_success "=========================================="
print_info "Docker image: registry.ucstack.io/controlr/server:${TAG}"
