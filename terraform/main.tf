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

# Wait for ArgoCD CRDs to register after Helm chart deploys
# This prevents race conditions where the Application CRD isn't available yet
resource "time_sleep" "wait_for_argocd_crd" {
  create_duration = "15s"

  depends_on = [helm_release.argocd]
}

# Apply the ArgoCD Application manifest (points ArgoCD at this repo)
# Using local-exec because kubernetes_manifest requires the CRD to exist during the plan phase
resource "null_resource" "argocd_app" {
  depends_on = [time_sleep.wait_for_argocd_crd]

  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/../argocd/application.yaml"
  }
}
