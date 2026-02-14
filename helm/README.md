# ControlR Helm Chart

This Helm chart deploys ControlR, a cross-platform remote access and control solution, on a Kubernetes cluster.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- PV provisioner support in the underlying infrastructure (for PostgreSQL persistence)

## Installing the Chart

To install the chart with the release name `controlr`:

```bash
helm install controlr ./helm
```

To install with custom values:

```bash
helm install controlr ./helm -f custom-values.yaml
```

## Uninstalling the Chart

To uninstall/delete the `controlr` deployment:

```bash
helm uninstall controlr
```

## Configuration

The following table lists the configurable parameters of the ControlR chart and their default values.

### Global Parameters

| Parameter                 | Description                                     | Default |
| ------------------------- | ----------------------------------------------- | ------- |
| `global.imagePullSecrets` | Global Docker registry secret names as an array | `[]`    |

### ControlR Parameters

| Parameter                    | Description                                                     | Default             |
| ---------------------------- | --------------------------------------------------------------- | ------------------- |
| `controlr.replicaCount`      | Number of ControlR replicas (keep at 1 without Redis backplane) | `1`                 |
| `controlr.image.repository`  | ControlR image repository                                       | `bitbound/controlr` |
| `controlr.image.tag`         | ControlR image tag                                              | `latest`            |
| `controlr.image.pullPolicy`  | Image pull policy                                               | `IfNotPresent`      |
| `controlr.service.type`      | Kubernetes service type                                         | `ClusterIP`         |
| `controlr.service.port`      | Service port                                                    | `8080`              |
| `controlr.ingress.enabled`   | Enable ingress controller resource                              | `false`             |
| `controlr.ingress.className` | Ingress class name                                              | `""`                |
| `controlr.ingress.hosts`     | Ingress hosts configuration                                     | See values.yaml     |
| `controlr.resources`         | CPU/Memory resource requests/limits                             | `{}`                |

### PostgreSQL Parameters

| Parameter                        | Description              | Default    |
| -------------------------------- | ------------------------ | ---------- |
| `postgresql.enabled`             | Deploy PostgreSQL        | `true`     |
| `postgresql.auth.username`       | PostgreSQL username      | `postgres` |
| `postgresql.auth.password`       | PostgreSQL password      | `password` |
| `postgresql.auth.database`       | PostgreSQL database name | `controlr` |
| `postgresql.persistence.enabled` | Enable persistence       | `true`     |
| `postgresql.persistence.size`    | PVC size                 | `10Gi`     |

### Aspire Dashboard Parameters

| Parameter                  | Description                     | Default                  |
| -------------------------- | ------------------------------- | ------------------------ |
| `aspire.enabled`           | Deploy Aspire Dashboard         | `true`                   |
| `aspire.auth.browserToken` | Browser authentication token    | `token`                  |
| `aspire.auth.publicUrl`    | Public URL for Aspire Dashboard | `http://localhost:18888` |
| `aspire.ingress.enabled`   | Enable ingress for Aspire       | `false`                  |

### Application Options

| Parameter                                              | Description                    | Default     |
| ------------------------------------------------------ | ------------------------------ | ----------- |
| `controlr.env.appOptions.enablePublicRegistration`     | Allow public user registration | `false`     |
| `controlr.env.appOptions.allowAgentsToSelfBootstrap`   | Allow agents to self-register  | `false`     |
| `controlr.env.appOptions.requireUserEmailConfirmation` | Require email confirmation     | `true`      |
| `controlr.env.appOptions.maxFileTransferSize`          | Max file transfer size (bytes) | `104857600` |

See `values.yaml` for the complete list of configurable parameters.

## Example Configurations

### Production Deployment with Ingress

**Note:** ControlR uses SignalR for real-time connections and is not horizontally scalable without a Redis backplane. Keep `replicaCount: 1` unless you have configured Redis.

```yaml
controlr:
  replicaCount: 1 # Do not increase without Redis backplane
  image:
    tag: "1.0.0"

  ingress:
    enabled: true
    className: nginx
    annotations:
      cert-manager.io/cluster-issuer: letsencrypt-prod
    hosts:
      - host: controlr.example.com
        paths:
          - path: /
            pathType: Prefix
    tls:
      - secretName: controlr-tls
        hosts:
          - controlr.example.com

  env:
    appOptions:
      enablePublicRegistration: false
      requireUserEmailConfirmation: true
      knownProxies:
        - "10.0.0.1"

postgresql:
  auth:
    password: "your-secure-password"
  persistence:
    size: 50Gi
    storageClass: "fast-ssd"

aspire:
  auth:
    browserToken: "your-secure-token"
    publicUrl: "https://metrics.example.com"
  ingress:
    enabled: true
    className: nginx
    hosts:
      - host: metrics.example.com
        paths:
          - path: /
            pathType: Prefix
```

### Development Deployment

```yaml
controlr:
  image:
    tag: "latest"

  env:
    aspnetcoreEnvironment: Development
    appOptions:
      enablePublicRegistration: true
      allowAgentsToSelfBootstrap: true
      disableEmailSending: true

postgresql:
  persistence:
    enabled: false

aspire:
  auth:
    allowAnonymous: true
```

## Upgrading

To upgrade the ControlR deployment:

```bash
helm upgrade controlr ./helm -f custom-values.yaml
```

## Backup and Restore

### Backup PostgreSQL Data

```bash
kubectl exec -it <postgresql-pod> -- pg_dump -U postgres controlr > backup.sql
```

### Restore PostgreSQL Data

```bash
kubectl exec -i <postgresql-pod> -- psql -U postgres controlr < backup.sql
```

## Troubleshooting

### Check Pod Status

```bash
kubectl get pods -l app.kubernetes.io/name=controlr
```

### View Logs

```bash
# ControlR logs
kubectl logs -l app.kubernetes.io/name=controlr -f

# PostgreSQL logs
kubectl logs -l app.kubernetes.io/component=database -f

# Aspire logs
kubectl logs -l app.kubernetes.io/component=aspire -f
```

### Access Services Locally

```bash
# ControlR
kubectl port-forward svc/controlr 8080:8080

# Aspire Dashboard
kubectl port-forward svc/controlr-aspire 18888:18888

# PostgreSQL
kubectl port-forward svc/controlr-postgresql 5432:5432
```

## Scaling Considerations

ControlR uses SignalR for real-time bidirectional communication between the server, agents, and web clients. SignalR maintains stateful WebSocket connections, which means:

- **Single replica recommended**: By default, run with `replicaCount: 1`
- **Horizontal scaling requires Redis**: To scale horizontally, you must configure a Redis backplane for SignalR to share connection state across instances
- **Vertical scaling**: For better performance, increase CPU and memory resources instead of adding replicas

If you need to scale horizontally:

1. Deploy Redis (or use a managed Redis service)
2. Configure ControlR to use Redis as a SignalR backplane
3. Then increase `replicaCount` or enable autoscaling

## Security Considerations

1. **Change default passwords**: Always change the default PostgreSQL password and Aspire browser token in production
2. **Use secrets**: Consider using Kubernetes secrets or external secret management (e.g., HashiCorp Vault)
3. **Enable TLS**: Configure ingress with TLS certificates for production deployments
4. **Network policies**: Implement Kubernetes network policies to restrict traffic
5. **RBAC**: Configure appropriate RBAC rules for service accounts

## Support

For issues and questions:

- GitHub: https://github.com/bitbound/ControlR
- Documentation: https://github.com/bitbound/ControlR/tree/main/docs
