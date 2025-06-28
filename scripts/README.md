# Kubernetes Deployment Scripts

This folder contains utility scripts to automate deployment, health checking, and rollback for your FastAPI Kubernetes environment.

## 📁 Files

### `deploy.sh`

- Builds and Push docker images to ECR.
- Automates deployment of Kubernetes manifests.
- Applies namespace, config, service, deployment, ingress, RBAC, HPA, and network policies in order.
- Usage:

  ```bash
  ./scripts/deploy.sh
  ```

- See [deploy.sh](./deploy.sh) file.

### `health-check.sh`

- Verifies that the FastAPI app is healthy after deployment.
- Performs HTTP health checks to the live ingress endpoint.
- Usage:

    ```bash
    ./scripts/health-check.sh
    ```

- See [health-check.sh](./health-check.sh) file.

### rollback.sh

- Rolls back the last deployment of your Kubernetes app.
- Relies on kubectl rollout undo and the deployment revision history.
- Usage:

    ```bash
    ./scripts/rollback.sh
    ```

- See [rollback.sh](./rollback.sh) file.

## THOUGHTS

I am not sure if the above files are relevant asides maybe `deploy.sh`, because the entire concept of automation is event driven (Say a push to the main branch on GitHub). And most of what is in the `deploy.sh` file would be handled on the GitHub pipeline, well maybe just declare it as a `step` on the GitHub pipeline, but it's not neccessarily Ideal.

I think using a tool like `FluxCD` or more prefferably `ArgoCD` would have better ease and more concept of automation to it. Because all you need to do is point ArgoCD to a repo holding the Kubernetes manifests and it makes sure what is on the repo is what is deployed on the cluster. And if you need to update, just run script on the pipeline using `grep` command to find the image name and `sed` command to replace the image with the latest image tag. ArgoCD would notice the change in the repo and automatically carry out a rollout deployment. You can also create Helm Chart of the app and point ArgoCD to the Helm Repo and then the same logic applies upon new updates.

What is the event trigger for automatic rollbacks is the question? Because you are more likely to manually run the script, which nolonger serves the purpose of automation. ArgoCD can show you versions of your app and you can choose the rollback version of choice you want on the dashboard, with ease.

Also why have a healtcheck script when we already have a monitoring platform? Tools like `Uptime-Kuma` and other Uptime observability tools can make pings to the health endpoint at specific intervals, and alert you if the endpoint is unresponsive.

I generally believe this is a better usecase scenario.
