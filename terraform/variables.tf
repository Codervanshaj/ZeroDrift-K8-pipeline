variable "kube_context" {
  description = "kubectl context name to use (run 'kubectl config get-contexts' to list yours)"
  type        = string
  default     = "docker-desktop"  # Change to your cluster context name
}

variable "argocd_namespace" {
  description = "Kubernetes namespace where ArgoCD will be installed"
  type        = string
  default     = "argocd"
}

variable "argocd_chart_version" {
  description = "ArgoCD Helm chart version to install"
  type        = string
  default     = "6.7.3"  # https://artifacthub.io/packages/helm/argo/argo-cd
}
