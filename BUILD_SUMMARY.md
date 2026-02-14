# ControlR Build Summary

## What Was Created

### 1. Helm Chart (`./helm/`)

A production-ready Kubernetes Helm chart for deploying ControlR with:

- ControlR web server deployment
- PostgreSQL database with persistent storage
- Aspire Dashboard for telemetry
- Configurable ingress for both services
- Proper scaling notes (single replica due to SignalR)
- Comprehensive values.yaml with all configuration options

### 2. Docker Build Scripts (`./scripts/`)

Automated scripts for building and pushing Docker images:

- `build-and-push-docker.sh` - Main build script with full control
- `quick-build.sh` - Simplified wrapper with auto-versioning
- `README.md` - Complete documentation

### 3. Fixed Dockerfile

Updated `ControlR.Web.Server/Dockerfile` with:

- All required project dependencies
- Proper version handling (semantic versioning for Version, numeric for FileVersion)
- Support for pre-release versions (e.g., 1.0.0-test, 1.2.3-beta)

## Quick Start

### Build Docker Image

```bash
# Simple build and push
./scripts/build-and-push-docker.sh --version 1.0.0-test --tag test

# Build without pushing (for local testing)
./scripts/build-and-push-docker.sh --no-push --version 1.0.0-dev --tag dev

# Quick build with auto-versioning
./scripts/quick-build.sh
```

### Deploy with Helm

```bash
# Install with default values
helm install controlr ./helm

# Install with custom image
helm install controlr ./helm \
  --set controlr.image.repository=register.ucstack.io/controlr/server \
  --set controlr.image.tag=1.0.0-test

# Install with custom values file
helm install controlr ./helm -f production-values.yaml
```

## Important Notes

### Version Requirements

- Version must follow semantic versioning: `X.Y.Z` or `X.Y.Z-suffix`
- Valid: `1.0.0`, `1.2.3-beta`, `2.0.0-rc1`, `1.0.0-test`
- Invalid: `test`, `v1.0`, `latest`

### Test Builds

Test builds (non-production tags) will NOT overwrite the `latest` tag:

```bash
# Safe - won't affect 'latest'
./scripts/build-and-push-docker.sh --version 1.0.0-test --tag test-feature

# Will also tag as 'latest' (production version detected)
./scripts/build-and-push-docker.sh --version 1.2.3 --tag v1.2.3
```

### Scaling Considerations

ControlR uses SignalR for stateful connections and should run with `replicaCount: 1` unless you configure a Redis backplane for distributed connection state.

## Registry Configuration

Images are pushed to: `register.ucstack.io/controlr/server`

Make sure you're logged in:

```bash
docker login register.ucstack.io
```

## Testing the Build

The Docker image was successfully built and tested:

```bash
# Image created
docker images test-build
# Output: test-build:latest   1dc6abd9e497   374MB

# Test locally
docker run -p 8080:8080 test-build:latest
```

## Next Steps

1. Build and push your first image:

   ```bash
   ./scripts/build-and-push-docker.sh --version 1.0.0 --tag v1.0.0
   ```

2. Deploy to Kubernetes:

   ```bash
   helm install controlr ./helm \
     --set controlr.image.tag=v1.0.0 \
     --set postgresql.auth.password=your-secure-password \
     --set aspire.auth.browserToken=your-secure-token
   ```

3. Configure ingress for external access (update `helm/values.yaml`)

4. Set up monitoring and backups for PostgreSQL

## Files Modified

- `ControlR.Web.Server/Dockerfile` - Fixed dependencies and version handling
- `scripts/build-and-push-docker.sh` - Created build script
- `scripts/quick-build.sh` - Created quick build wrapper
- `scripts/README.md` - Created documentation
- `helm/` - Created complete Helm chart

## Build Verification

✅ Agent builds successfully on Linux  
✅ Docker image builds successfully  
✅ Helm chart created with proper configuration  
✅ Version validation working  
✅ Test builds don't overwrite production tags
