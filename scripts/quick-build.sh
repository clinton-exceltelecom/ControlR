#!/bin/bash
# Quick build script - builds and pushes with sensible defaults

set -e

# Get version from git tag or use default
VERSION=$(git describe --tags --abbrev=0 2>/dev/null || echo "1.0.0")
VERSION=${VERSION#v}  # Remove 'v' prefix if present

# Get current git commit short hash
COMMIT=$(git rev-parse --short HEAD 2>/dev/null || echo "dev")

# Create tag from version and commit
TAG="${VERSION}-${COMMIT}"

echo "Building ControlR Docker image"
echo "Version: ${VERSION}"
echo "Tag: ${TAG}"
echo ""

# Run the main build script
./scripts/build-and-push-docker.sh \
    --version "${VERSION}" \
    --tag "${TAG}" \
    "$@"
