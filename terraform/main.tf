# ── 1. Create the ArgoCD namespace ───────────────────────────────────────────
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.argocd_namespace
  }
}

# ── 2. Install ArgoCD via its official Helm chart ────────────────────────────
resource "helm_release" "argocd" {
  name       = "argocd"
  namespace  = kubernetes_namespace.argocd.metadata[0].name
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.argocd_chart_version

  # Keep ArgoCD server insecure for local/demo use (removes TLS requirement).
  # Remove this set block in production and configure proper TLS instead.
  set {
    name  = "server.extraArgs[0]"
    value = "--insecure"
  }

  depends_on = [kubernetes_namespace.argocd]
}

# ── 3. Apply the ArgoCD Application manifest (points ArgoCD at this repo) ────
resource "kubernetes_manifest" "argocd_app" {
  manifest = yamldecode(file("${path.module}/../argocd/application.yaml"))

  depends_on = [helm_release.argocd]
}
