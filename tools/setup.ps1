$ErrorActionPreference = "Stop"

Write-Host "Checking for prerequisites..."
if (-not (Get-Command "kind" -ErrorAction SilentlyContinue)) {
    Write-Error "Kind is not installed. Please install Kind using 'choco install kind' or via docker."
    exit 1
}
if (-not (Get-Command "kubectl" -ErrorAction SilentlyContinue)) {
    Write-Error "Kubectl is not installed."
    exit 1
}

$ClusterName = "argocd-local"

# Check if cluster exists
if (kind get clusters | Select-String -Pattern "^$ClusterName$") {
    Write-Host "Cluster '$ClusterName' already exists. Skipping creation."
} else {
    Write-Host "Creating Kind cluster '$ClusterName'..."
    kind create cluster --name $ClusterName
}

# Ensure context
kubectl cluster-info --context kind-$ClusterName

# Install Argo CD
Write-Host "Installing Argo CD..."
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

Write-Host "Waiting for Argo CD components to be ready..."
kubectl wait --for=condition=available deployment/argocd-server -n argocd --timeout=300s

# Get Initial Password
$password = kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | ForEach-Object { [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($_)) }

Write-Host "`nSetup Complete!"
Write-Host "----------------"
Write-Host "Argo CD is running."
Write-Host "To access the UI, run: kubectl port-forward svc/argocd-server -n argocd 8080:443"
Write-Host "URL: https://localhost:8080"
Write-Host "Username: admin"
Write-Host "Password: $password"
