# Zero-Drift Kubernetes Deployment Pipeline via GitOps

A minimal, production-patterned GitOps pipeline that keeps your Kubernetes cluster **always in sync with Git** — any manual cluster change is automatically reverted.

---

## How it works

```
Developer pushes code
        │
        ▼
GitHub Actions CI
  ├─ Builds Docker image
  ├─ Tags it with short commit SHA
  ├─ Pushes to Docker Hub
  └─ Patches helm/zero-drift-app/values.yaml (image tag)
        │
        ▼ (Git commit by CI bot)
ArgoCD detects change in Git
  └─ Syncs cluster to match Git state
        │
        ▼
Zero-Drift: any manual kubectl change → ArgoCD reverts it
```

---

## Project Structure

```
.
├── app/                            # Demo Node.js application
│   ├── server.js
│   ├── package.json
│   ├── Dockerfile
│   └── .dockerignore
│
├── .github/
│   └── workflows/
│       └── ci.yml                  # GitHub Actions: build → tag → push → update values
│
├── helm/
│   └── zero-drift-app/             # Helm chart for the application
│       ├── Chart.yaml
│       ├── values.yaml             # CI patches image.tag here on every commit
│       └── templates/
│           ├── deployment.yaml
│           └── service.yaml
│
├── argocd/
│   └── application.yaml            # ArgoCD Application (selfHeal + prune = zero drift)
│
└── terraform/
    ├── providers.tf                # Kubernetes + Helm providers
    ├── variables.tf
    ├── main.tf                     # Installs ArgoCD + registers Application
    └── outputs.tf                  # Prints access instructions after apply
```

---

## Prerequisites

| Tool | Purpose |
|------|---------|
| `kubectl` | Interact with Kubernetes cluster |
| `terraform` >= 1.5 | Provision ArgoCD |
| `helm` >= 3.x | Template / validate charts |
| Docker Hub account | Store Docker images |
| A running K8s cluster | e.g. Docker Desktop, kind, GKE, EKS |

---

## Setup (one-time)

### Step 1 — Configure two GitHub Secrets

Go to your GitHub repo → **Settings → Secrets → Actions** and add:

| Secret name | Value |
|-------------|-------|
| `DOCKERHUB_USERNAME` | Your Docker Hub username |
| `DOCKERHUB_TOKEN` | A Docker Hub access token (not your password) |

### Step 2 — Update placeholder values

| File | Field | Change to |
|------|-------|-----------|
| `helm/zero-drift-app/values.yaml` | `image.repository` | `your-dockerhub-username/zero-drift-app` |
| `argocd/application.yaml` | `spec.source.repoURL` | Your GitHub repo URL |
| `terraform/variables.tf` | `kube_context` default | Your kubectl context name |

### Step 3 — Provision ArgoCD with Terraform

```bash
cd terraform
terraform init
terraform apply
```

Terraform will:
1. Create the `argocd` namespace
2. Install ArgoCD via its official Helm chart
3. Apply the ArgoCD `Application` manifest

After apply, follow the printed output instructions to log in to the ArgoCD UI.

### Step 4 — Push a commit and watch the pipeline

```bash
git add .
git commit -m "feat: initial deployment"
git push origin main
```

GitHub Actions will build the image, update `values.yaml`, and ArgoCD will auto-sync the cluster within ~3 minutes.

---

## Zero-Drift Guarantee

ArgoCD is configured with:
- `selfHeal: true` — reverts any direct `kubectl` changes back to Git state
- `prune: true` — removes resources that no longer exist in Git

This means **Git is the only way to change the cluster** — no drift, ever.

---

## Tools Used

- **ArgoCD** — GitOps controller (self-healing sync)
- **GitHub Actions** — CI pipeline (build, tag, push, update)
- **Docker** — Container image build
- **Helm** — Kubernetes manifest management (no raw YAML editing)
- **Terraform** — Infrastructure provisioning (fully reproducible)
