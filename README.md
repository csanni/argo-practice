# GitOps Setup Walkthrough

## 1. Local Infrastructure Setup
Open a PowerShell terminal in `d:/Data_HDD/Learning/Argo-CD-Practice` and run:

```powershell
.\tools\setup.ps1
```

This will:
- Create a Kind cluster named `argocd-local`.
- Install Argo CD.
- Output the Argo CD admin password.

**Verify:**
- Check pods: `kubectl get pods -n argocd`
- forward Port: `kubectl port-forward svc/argocd-server -n argocd 8080:443`
- Login to `https://localhost:8080` (admin / <password from script>)

## 2. GitHub Configuration
1.  **Create a Repository**: Create a new public (or private) repository on GitHub (e.g., `argocd-practice`).
2.  **Push Code**:
    ```bash
    git init
    git add .
    git commit -m "Initial commit"
    git branch -M main
    git remote add origin https://github.com/<YOUR_USER>/argocd-practice.git
    git push -u origin main
    ```
    *(Note: Ensure you update `k8s/deployment.yaml` and `argocd/application.yaml` with your actual repo URL/Image path first!)*

3.  **Permissions**:
    - Go to Repo Settings -> Actions -> General -> Workflow permissions.
    - Select **Read and write permissions**.
    - Click **Save**.

## 3. Argo CD Application Setup
1.  **Update Manifest**:
    - Edit `argocd/application.yaml`.
    - Change `repoURL` to your new GitHub repository URL.
2.  **Apply to Cluster**:
    ```bash
    kubectl apply -f argocd/application.yaml
    ```
3.  **Observe**:
    - Go to Argo CD UI.
    - You should see the `fast-api-app` syncing.

## 4. Test the Pipeline
1.  **Make a Change**:
    - Edit `app/main.py` and change the message or version.
2.  **Push**:
    - `git add . && git commit -m "Update app" && git push`
3.  **Watch CI**:
    - Go to GitHub Actions tab.
    - Wait for "Build and Deploy" to finish.
    - It should push a new image and commit the new tag to `k8s/deployment.yaml`.
4.  **Watch CD**:
    - Argo CD will eventually poll (default 3 mins) or you can click "Refresh" in the UI.
    - The new image will be applied to the cluster.

## 5. Access the Application
Since we are using `Service` locally:
```bash
kubectl port-forward svc/fast-api-service 8000:80
```
Visit `http://localhost:8000`.
