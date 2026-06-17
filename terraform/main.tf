# Create the ArgoCD namespace 
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.argocd_namespace
  }
}

# Install ArgoCD via its official Helm chart
resource "helm_release" "argocd" {
  name       = "argocd"
  namespace  = kubernetes_namespace.argocd.metadata[0].name
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.argocd_chart_version

  # Keep ArgoCD server insecure for local/demo use (removes TLS requirement)
  # Remove this values entry in production and configure proper TLS instead
  values = [
    <<-EOF
    server:
      extraArgs:
        - --insecure
    EOF
  ]

  depends_on = [kubernetes_namespace.argocd]
}

# Apply the ArgoCD Application manifest (points ArgoCD at this repo
resource "kubernetes_manifest" "argocd_app" {
  manifest = yamldecode(file("${path.module}/../argocd/application.yaml"))

  depends_on = [helm_release.argocd]
}
