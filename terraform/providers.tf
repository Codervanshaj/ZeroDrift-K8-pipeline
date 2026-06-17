terraform {
  required_version = ">= 1.5"

  required_providers {
    # Interact with an existing Kubernetes cluster (e.g. kind, GKE, EKS, etc.)
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.27"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.13"
    }
  }
}

# ── Kubernetes provider ───────────────────────────────────────────────────────
# Reads credentials from the local kubeconfig file (~/.kube/config).
# Change context_name to match your cluster context.
provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = var.kube_context
}

# ── Helm provider (shares same credentials) ───────────────────────────────────
provider "helm" {
  kubernetes {
    config_path    = "~/.kube/config"
    config_context = var.kube_context
  }
}
