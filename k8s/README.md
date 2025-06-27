# Kubernetes Deployment for FastAPI Application

This README covers the setup and deployment of a FastAPI application on Kubernetes, focusing on security, networking, and automation with best practices. Key components include deployment manifests, RBAC, service accounts, ingress with TLS via cert-manager & Let’s Encrypt, network policies, HPA, and secrets management.

## Deployment

- Defines your application pods and container specs.
- Includes resource requests and limits for efficient scheduling.
- Uses `restartPolicy: Always` (default in Deployments) for automatic recovery.
- Includes liveness and readiness probes for health monitoring.
- Example snippet: see [deployment.yaml](./deployment.yaml) file.

## Service

- Exposes your application internally within the cluster.
- Typically ClusterIP type for backend apps.
- Routes traffic to pod replicas.
- Example Snippet: see [service.yaml](./service.yaml) file.

## RBAC & Service Accounts

- Use Service Accounts to assign permissions to pods.
- RBAC Roles and RoleBindings define what resources the service accounts can access.
- Important for limiting pod permissions and adhering to the principle of least privilege.
- Although in this context, the service account and rbac configurations are redundant, because the application does not need to communicate with the Kubernetes API. A proper usecase for RBAC is this scenario would be to restrict access to users. Sample snippets can be found in the [recomendations](../recomendations/) folder. But I just did as told in this exercise to show I have knowledge on the topic.
- Example ServiceAccount and RoleBinding: See [serviceaccount.yaml](./serviceaccount.yaml) and [rbac.yaml](../security/rbac.yaml) files

## Horizontal Pod Autoscaler (HPA)

- Automatically scales pod replicas based on CPU or custom metrics.
- Ensures app performance under variable load.
- Example Snippet: see [hpa.yaml](./hpa.yaml) file.

## Pod Security

- Defines a namespace with Pod Security Admission labels.
- Enforces Kubernetes Pod Security Standards (PSS) to restrict pod permissions.
- Typically sets pod-security.kubernetes.io/enforce to "restricted" or "baseline" for security best practices.
- Controls which pods can run by blocking risky behaviors (e.g., privileged containers, hostPath mounts, running as root).
- Supports additional labels for warn and audit modes to ease migration and monitoring.
- Helps ensure workloads follow the principle of least privilege and sandboxing.
- Example snippet can be found in the [pod-security.yaml](../security/pod-security.yaml) file.

## Secrets

- Store sensitive data (e.g., database credentials, API keys) securely.
- Reference secrets in your deployment as environment variables or mounted volumes.
- Example snippet can be found in the [secret.yaml](./secret.yaml) secret.yaml

## Network Policy

- Controls traffic flow at the IP address or port level.
- Restricts which pods or namespaces can communicate with your app.
- Example restricting ingress to NGINX ingress controller pods, allowing DNS egress: [networkpolicy.yaml](./networkpolicy.yaml)

## Ingress & TLS with cert-manager & Let’s Encrypt

- Use an Ingress controller (e.g., NGINX or Traefik) to expose HTTP/S routes.
- cert-manager automates TLS cert provisioning via Let’s Encrypt.
- For the project Nginx was used, but I would recommend Traefik, because it accomodates more security implementation and visualizes actice connection on a dashboard, which can help debug issues with deployments. I didn't use it because Traefik has a lot of Operational Overhead, but once configured, it is very easy to integrate other services to it.

### Steps

- Install inginx using helm

    ```bash
    helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

    helm repo update

    helm install ingress-nginx ingress-nginx/ingress-nginx \
    --namespace ingress-nginx --create-namespace
    ```

- Install Cert manager

    ```bash
    kubectl create namespace cert-manager

    kubectl apply --validate=false -f https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.crds.yaml

    helm repo add jetstack https://charts.jetstack.io
    helm repo update

    helm install cert-manager jetstack/cert-manager \
    --namespace cert-manager \
    --version v1.14.0
    ```

- Create a cluster issuer. see [clusterissuer.yaml](../recomendations/clusterissuer.yaml) for snippet. Then run:

    ```bash
    kubectl apply -f clusterissuer.yaml
    ```

- 🔐 Enforce TLS ≥ 1.2. To control TLS protocols and cipher suites, you use a ConfigMap tied to the NGINX Ingress controller. Basically update the ConfigMap by adding this line `ssl-protocols: "TLSv1.2 TLSv1.3"`. The configuration should look like this:

    ```bash
    apiVersion: v1
    kind: ConfigMap
    metadata:
        name: nginx-configuration
        namespace: ingress-nginx
    data:
        ssl-protocols: "TLSv1.2 TLSv1.3"
    ```

- Add respose security headers. See [ingress.yaml](./ingress.yaml) for full implementation snippet.

## Deploy Kubernetes In A Cluster

- Copy folders `k8s` and `security` to the cluster.
- create a namespace for deployment. (Since namespace value is mentioned in each of the manifest files especially the `deployment.yaml` file, the namespace would be created). But this would create a namespace manually:

    ```bash
    kubectl create namespace item-service-ns
    ```

- Deploy manifest

    ```bash
    kubectl apply -f security/

    kubectl apply -f k8s/
    ```
