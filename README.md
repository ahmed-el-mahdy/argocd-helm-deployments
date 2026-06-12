# ArgoCD Helm Deployments

GitOps-driven microservice deployments using Argo CD Applications and Helm charts. Demonstrates production patterns for managing multiple services across environments with automated sync.

![ArgoCD](https://img.shields.io/badge/Argo_CD-2.9+-EF7B4D?logo=argo)
![Helm](https://img.shields.io/badge/Helm-3.14+-0F1689?logo=helm)
![Kubernetes](https://img.shields.io/badge/Kubernetes-1.28+-326CE5?logo=kubernetes)
![License](https://img.shields.io/badge/License-MIT-green)

## Architecture

```
┌──────────────────────────────────────────────────────────────────┐
│                         Git Repository                            │
│  apps/          charts/           environments/                    │
│  (ArgoCD Apps)  (Helm Charts)     (Values per env)                │
└──────────┬──────────────────────────────────────────┬────────────┘
           │ watches                                   │
           ▼                                           ▼
┌────────────────────┐                    ┌────────────────────────┐
│    Argo CD Server  │ ──── syncs ────►   │   Kubernetes Cluster   │
│    (GitOps)        │                    │   ├── dev namespace    │
│                    │                    │   ├── qa namespace     │
│  ApplicationSets   │                    │   ├── staging ns       │
│  + Auto-Sync      │                    │   └── prod namespace   │
└────────────────────┘                    └────────────────────────┘
```

## Directory Structure

```
.
├── apps/                              # Argo CD Application manifests
│   ├── app-of-apps.yaml              # Root Application (App of Apps pattern)
│   ├── api-service/
│   │   ├── dev.yaml
│   │   ├── qa.yaml
│   │   ├── staging.yaml
│   │   └── prod.yaml
│   ├── auth-service/
│   └── worker-service/
├── charts/                            # Helm charts
│   └── microservice/                  # Generic chart for all services
│       ├── Chart.yaml
│       ├── values.yaml
│       └── templates/
│           ├── deployment.yaml
│           ├── service.yaml
│           ├── hpa.yaml
│           ├── ingress.yaml
│           ├── secret-provider.yaml
│           └── _helpers.tpl
├── environments/                      # Per-service, per-env values
│   ├── api-service/
│   │   ├── values-dev.yaml
│   │   ├── values-qa.yaml
│   │   ├── values-staging.yaml
│   │   └── values-prod.yaml
│   ├── auth-service/
│   └── worker-service/
└── applicationsets/                   # ApplicationSet generators
    └── all-services.yaml
```

## Key Patterns

### 1. App of Apps
A root Application manages all child Applications, enabling single-click cluster bootstrapping.

### 2. Generic Helm Chart
One chart serves all microservices — each service customizes via environment-specific values files.

### 3. ApplicationSet Generator
Automatically creates ArgoCD Applications for new services/environments using a matrix generator.

### 4. Sync Waves
Resources deploy in order: Namespace → Secrets → ConfigMaps → Deployments → Ingress.

## Quick Start

```bash
# 1. Install Argo CD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# 2. Apply the root App of Apps
kubectl apply -f apps/app-of-apps.yaml

# 3. Argo CD syncs everything automatically
argocd app list
```

## Deployment Flow

1. Developer pushes code → CI builds Docker image → pushes to ACR
2. CI updates `environments/{service}/values-{env}.yaml` with new image tag
3. Argo CD detects drift in Git vs cluster
4. Auto-sync applies the change (or manual sync for prod)
5. Post-sync hook runs health checks

## Environment Strategy

| Environment | Sync Policy | Prune | Self-Heal | Approval |
|-------------|-------------|-------|-----------|----------|
| dev | Auto | Yes | Yes | None |
| qa | Auto | Yes | Yes | None |
| staging | Auto | Yes | Yes | None |
| prod | Manual | No | No | Required |

## Prerequisites

- Argo CD >= 2.9
- Helm >= 3.14
- AKS cluster with NGINX Ingress + CSI Secrets Store
- ACR with images available

## License

MIT
