#!/bin/bash
set -e

# ControlR Docker Build and Push Script
# This script builds the ControlR web server Docker image and pushes it to the registry

# Configuration
REGISTRY="registry.ucstack.io"
IMAGE_NAME="controlr/server"
FULL_IMAGE="${REGISTRY}/${IMAGE_NAME}"
DOCKERFILE="ControlR.Web.Server/Dockerfile"
BUILD_CONTEXT="."

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

Build and push ControlR Docker image to registry

OPTIONS:
    -t, --tag TAG           Image tag (default: latest)
    -v, --version VERSION   Application version for build (default: 1.0.0)
    -r, --registry URL      Registry URL (default: register.ucstack.io)
    --no-cache              Build without using cache
    --no-push               Build only, don't push to registry
    --skip-login            Skip authentication check (assumes already logged in)
    --platform PLATFORMS    Target platforms (default: linux/amd64)
                           Example: linux/amd64,linux/arm64
    -h, --help              Show this help message

EXAMPLES:
    # Build and push with default settings
    $0

    # Build with specific version and tag
    $0 --version 1.2.3 --tag v1.2.3

    # Build without cache
    $0 --no-cache

    # Build for multiple platforms
    $0 --platform linux/amd64,linux/arm64

    # Build only (don't push)
    $0 --no-push --tag test

EOF
    exit 1
}

# Default values
TAG="latest"
VERSION="1.0.0"
NO_CACHE=""
NO_PUSH=false
SKIP_LOGIN=false
PLATFORM="linux/amd64"

# Function to validate semantic version
validate_version() {
    local version=$1
    # Check if version matches semantic versioning pattern (X.Y.Z or X.Y.Z-suffix)
    if [[ ! $version =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.-]+)?$ ]]; then
        print_error "Invalid version format: $version"
        print_error "Version must follow semantic versioning (e.g., 1.0.0, 1.2.3-beta, 2.0.0-rc1)"
        exit 1
    fi
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -t|--tag)
            TAG="$2"
            shift 2
            ;;
        -v|--version)
            VERSION="$2"
            validate_version "$VERSION"
            shift 2
            ;;
        -r|--registry)
            REGISTRY="$2"
            FULL_IMAGE="${REGISTRY}/${IMAGE_NAME}"
            shift 2
            ;;
        --no-cache)
            NO_CACHE="--no-cache"
            shift
            ;;
        --no-push)
            NO_PUSH=true
            shift
            ;;
        --skip-login)
            SKIP_LOGIN=true
            shift
            ;;
        --platform)
            PLATFORM="$2"
            shift 2
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

# Validate we're in the correct directory
if [ ! -f "$DOCKERFILE" ]; then
    print_error "Dockerfile not found at $DOCKERFILE"
    print_error "Please run this script from the repository root"
    exit 1
fi

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed or not in PATH"
    exit 1
fi

# Check if Docker daemon is running
if ! docker info &> /dev/null; then
    print_error "Docker daemon is not running"
    exit 1
fi

print_info "=========================================="
print_info "ControlR Docker Build Configuration"
print_info "=========================================="
print_info "Registry:     ${REGISTRY}"
print_info "Image:        ${IMAGE_NAME}"
print_info "Full Image:   ${FULL_IMAGE}"
print_info "Tag:          ${TAG}"
print_info "Version:      ${VERSION}"
print_info "Platform:     ${PLATFORM}"
print_info "No Cache:     ${NO_CACHE:-false}"
print_info "Push:         $( [ "$NO_PUSH" = true ] && echo "false" || echo "true" )"
print_info "=========================================="
echo

# Confirm before proceeding
read -p "Continue with build? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_warning "Build cancelled"
    exit 0
fi

# Build the Docker image
print_info "Building Docker image..."
print_info "Command: docker build ${NO_CACHE} --platform ${PLATFORM} --build-arg BUILD_CONFIGURATION=Release --build-arg CURRENT_VERSION=${VERSION} -t ${FULL_IMAGE}:${TAG} -f ${DOCKERFILE} ${BUILD_CONTEXT}"
echo

if docker build ${NO_CACHE} \
    --platform "${PLATFORM}" \
    --build-arg BUILD_CONFIGURATION=Release \
    --build-arg CURRENT_VERSION="${VERSION}" \
    -t "${FULL_IMAGE}:${TAG}" \
    -f "${DOCKERFILE}" \
    "${BUILD_CONTEXT}"; then
    print_success "Docker image built successfully"
else
    print_error "Docker build failed"
    exit 1
fi

# Tag as latest only if explicitly building 'latest' or a production version tag
# Skip tagging as latest for test/dev builds
if [ "$TAG" = "latest" ]; then
    print_info "Building as latest tag"
elif [[ "$TAG" =~ ^v?[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    # Tag as latest for production version tags (e.g., v1.2.3 or 1.2.3)
    print_info "Production version detected, tagging as latest..."
    docker tag "${FULL_IMAGE}:${TAG}" "${FULL_IMAGE}:latest"
    print_success "Tagged as latest"
else
    print_info "Non-production tag detected, skipping 'latest' tag"
fi

# Show image info
print_info "Image details:"
docker images "${FULL_IMAGE}" --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}"
echo

# Push to registry if not disabled
if [ "$NO_PUSH" = false ]; then
    # Skip authentication check if --skip-login flag is set
    if [ "$SKIP_LOGIN" = false ]; then
        # Check if already logged in to the specific registry
        print_info "Checking registry authentication for ${REGISTRY}..."
        
        # Try to check authentication by attempting to list repositories (this will fail if not authenticated)
        # Or check the docker config file for credentials
        if grep -q "${REGISTRY}" ~/.docker/config.json 2>/dev/null; then
            print_success "Already authenticated to ${REGISTRY}"
        else
            print_warning "Not authenticated to ${REGISTRY}"
            print_info "Please login to ${REGISTRY} first:"
            echo ""
            echo "  docker login ${REGISTRY}"
            echo ""
            
            # Check if running in interactive terminal
            if [ -t 0 ]; then
                read -p "Do you want to login now? (y/N) " -n 1 -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    if docker login "${REGISTRY}"; then
                        print_success "Logged in to registry"
                    else
                        print_error "Failed to login to registry"
                        print_warning "Image built but not pushed"
                        print_info "To push later, run:"
                        echo "  docker push ${FULL_IMAGE}:${TAG}"
                        exit 1
                    fi
                else
                    print_warning "Skipping push - not authenticated"
                    print_info "Image built successfully but not pushed"
                    print_info "To push later, first login and then run:"
                    echo "  docker login ${REGISTRY}"
                    echo "  docker push ${FULL_IMAGE}:${TAG}"
                    exit 0
                fi
            else
                # Non-interactive mode
                print_error "Cannot login in non-interactive mode"
                print_warning "Image built but not pushed"
                print_info "To push, first login and then run:"
                echo "  docker login ${REGISTRY}"
                echo "  docker push ${FULL_IMAGE}:${TAG}"
                exit 1
            fi
        fi
    else
        print_info "Skipping authentication check (--skip-login flag set)"
    fi

    print_info "Pushing image ${FULL_IMAGE}:${TAG}..."
    if docker push "${FULL_IMAGE}:${TAG}"; then
        print_success "Pushed ${FULL_IMAGE}:${TAG}"
    else
        print_error "Failed to push image"
        exit 1
    fi

    if [[ "$TAG" =~ ^v?[0-9]+\.[0-9]+\.[0-9]+$ ]] && [ "$TAG" != "latest" ]; then
        # Also push latest tag for production versions
        print_info "Pushing image ${FULL_IMAGE}:latest..."
        if docker push "${FULL_IMAGE}:latest"; then
            print_success "Pushed ${FULL_IMAGE}:latest"
        else
            print_error "Failed to push latest tag"
            exit 1
        fi
    fi

    print_success "=========================================="
    print_success "Build and push completed successfully!"
    print_success "=========================================="
    print_info "Image: ${FULL_IMAGE}:${TAG}"
    if [[ "$TAG" =~ ^v?[0-9]+\.[0-9]+\.[0-9]+$ ]] && [ "$TAG" != "latest" ]; then
        print_info "Image: ${FULL_IMAGE}:latest"
    fi
else
    print_success "=========================================="
    print_success "Build completed successfully!"
    print_success "=========================================="
    print_info "Image: ${FULL_IMAGE}:${TAG}"
    print_warning "Image was not pushed to registry (--no-push flag)"
fi

echo
print_info "To run the image locally:"
echo "  docker run -p 8080:8080 ${FULL_IMAGE}:${TAG}"
echo
print_info "To use in Helm chart, update values.yaml:"
echo "  controlr:"
echo "    image:"
echo "      repository: ${REGISTRY}/${IMAGE_NAME}"
echo "      tag: ${TAG}"
