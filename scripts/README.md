# ControlR Build Scripts

This directory contains scripts for building and deploying ControlR.

## Docker Build Scripts

### build-agents.sh

Script for building agent binaries for all platforms. Run this BEFORE building the Docker image.

**Usage:**

```bash
./scripts/build-agents.sh [OPTIONS]
```

**Options:**

- `-v, --version VERSION` - Application version (default: 1.0.0)
- `-p, --platform PLATFORM` - Build specific platform only (linux-x64, win-x64, win-x86, osx-x64, osx-arm64, all)
- `--clean` - Clean output directories before building
- `-h, --help` - Show help message

**Examples:**

Build all platforms:

```bash
./scripts/build-agents.sh --version 1.0.0
```

Build only Linux agent:

```bash
./scripts/build-agents.sh --version 1.0.0 --platform linux-x64
```

Clean and build all:

```bash
./scripts/build-agents.sh --clean --version 1.0.0
```

**Output:**
Agent binaries are placed in `ControlR.Web.Server/wwwroot/downloads/` and will be included in the Docker image.

### build-and-push-docker.sh

Main script for building and pushing Docker images to the registry.

**Usage:**

```bash
./scripts/build-and-push-docker.sh [OPTIONS]
```

**Options:**

- `-t, --tag TAG` - Image tag (default: latest)
- `-v, --version VERSION` - Application version for build (default: 1.0.0)
- `-r, --registry URL` - Registry URL (default: register.ucstack.io)
- `--no-cache` - Build without using cache
- `--no-push` - Build only, don't push to registry
- `--platform PLATFORMS` - Target platforms (default: linux/amd64)
- `-h, --help` - Show help message

**Examples:**

Build and push with default settings:

```bash
./scripts/build-and-push-docker.sh
```

Build with specific version and tag:

```bash
./scripts/build-and-push-docker.sh --version 1.2.3 --tag v1.2.3
```

Build without cache:

```bash
./scripts/build-and-push-docker.sh --no-cache
```

Build for multiple platforms:

```bash
./scripts/build-and-push-docker.sh --platform linux/amd64,linux/arm64
```

Build only (don't push):

```bash
./scripts/build-and-push-docker.sh --no-push --tag test
```

### quick-build.sh

Simplified wrapper that automatically determines version from git tags and creates a tag with commit hash.

**Usage:**

```bash
./scripts/quick-build.sh [OPTIONS]
```

This script:

1. Gets the version from the latest git tag (or uses 1.0.0 as default)
2. Gets the current git commit hash
3. Creates a tag like `1.2.3-abc1234`
4. Calls `build-and-push-docker.sh` with these values

You can pass any options from `build-and-push-docker.sh` to this script.

**Examples:**

Quick build with auto-versioning:

```bash
./scripts/quick-build.sh
```

Quick build without pushing:

```bash
./scripts/quick-build.sh --no-push
```

Quick build without cache:

```bash
./scripts/quick-build.sh --no-cache
```

## Registry Configuration

The default registry is `register.ucstack.io/controlr/server`.

To use the built image in your Helm deployment, update `helm/values.yaml`:

```yaml
controlr:
  image:
    repository: register.ucstack.io/controlr/server
    tag: "1.2.3-abc1234" # Use your built tag
```

Or override during Helm install:

```bash
helm install controlr ./helm \
  --set controlr.image.repository=register.ucstack.io/controlr/server \
  --set controlr.image.tag=1.2.3-abc1234
```

## Prerequisites

- Docker installed and running
- Access to the target registry (login credentials)
- Run from the repository root directory

## Authentication

The script will prompt for registry authentication when pushing. Make sure you have credentials for `register.ucstack.io`.

You can also login beforehand:

```bash
docker login register.ucstack.io
```

## Troubleshooting

**Error: "Dockerfile not found"**

- Make sure you're running the script from the repository root

**Error: "Docker daemon is not running"**

- Start Docker: `sudo systemctl start docker` (Linux) or start Docker Desktop

**Error: "Failed to login to registry"**

- Check your registry credentials
- Verify the registry URL is correct
- Ensure you have network access to the registry

**Build fails with dependency errors**

- Try building with `--no-cache` flag
- Ensure all project files are present and not corrupted

## CI/CD Integration

These scripts can be integrated into CI/CD pipelines:

**GitHub Actions example:**

```yaml
- name: Build and push Docker image
  run: |
    ./scripts/build-and-push-docker.sh \
      --version ${{ github.ref_name }} \
      --tag ${{ github.sha }}
```

**GitLab CI example:**

```yaml
build:
  script:
    - ./scripts/build-and-push-docker.sh --version $CI_COMMIT_TAG --tag $CI_COMMIT_SHORT_SHA
```
