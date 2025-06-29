# Kubernetes Deployment for FastAPI Application

This README covers the setup and deployment of a FastAPI application on Kubernetes, focusing on security, networking, and automation with best practices. Key components include deployment manifests, RBAC, service accounts, ingress with TLS via cert-manager & Let’s Encrypt, network policies, HPA, and secrets management.

## Manifest Files Overview

### Deployment

- Defines your application pods and container specs.
- Includes resource requests and limits for efficient scheduling.
- Uses `restartPolicy: Always` (default in Deployments) for automatic recovery.
- Includes liveness and readiness probes for health monitoring.
- Example snippet: see [deployment.yaml](./deployment.yaml) file.

### Service

- Exposes your application internally within the cluster.
- Typically, ClusterIP type for backend apps.
- Routes traffic to pod replicas.
- Example Snippet: see [service.yaml](./service.yaml) file.

### RBAC & Service Accounts

- Use Service Accounts to assign permissions to pods.
- RBAC Roles and RoleBindings define what resources the service accounts can access.
- Important for limiting pod permissions and adhering to the principle of least privilege.
- Although in this context, the service account and rbac configurations are redundant, because the application does not need to communicate with the Kubernetes API. A proper use case for RBAC is this scenario would be to restrict access to users. Sample snippets can be found in the [recommendations](../recommendations/) folder. But I just did as told in this exercise to show I have knowledge on the topic.
- Example ServiceAccount and RoleBinding: See [serviceaccount.yaml](./serviceaccount.yaml) and [rbac.yaml](../security/rbac.yaml) files

### Horizontal Pod Autoscaler (HPA)

- Automatically scales pod replicas based on CPU or custom metrics.
- Ensures app performance under variable load.
- Example Snippet: see [hpa.yaml](./hpa.yaml) file.

### Pod Security

- Defines a namespace with Pod Security Admission labels.
- Enforces Kubernetes Pod Security Standards (PSS) to restrict pod permissions.
- Typically, sets pod-security.kubernetes.io/enforce to "restricted" or "baseline" for security best practices.
- Controls which pods can run by blocking risky behaviors (e.g., privileged containers, hostPath mounts, running as root).
- Supports additional labels for warn and audit modes to ease migration and monitoring.
- Helps ensure workloads follow the principle of least privilege and sandboxing.
- Example snippet can be found in the [pod-security.yaml](../security/pod-security.yaml) file.

### Secrets

- Store sensitive data (e.g., database credentials, API keys) securely.
- Reference secrets in your deployment as environment variables or mounted volumes.
- Example snippet can be found in the [secret.yaml](./secret.yaml) secret.yaml

### Network Policy

- Controls traffic flow at the IP address or port level.
- Restricts which pods or namespaces can communicate with your app.
- Example restricting ingress to NGINX ingress controller pods, allowing DNS egress: [networkpolicy.yaml](./networkpolicy.yaml)

### Ingress & TLS with cert-manager & Let’s Encrypt

- Use an Ingress controller (e.g., NGINX or Traefik) to expose HTTP/S routes.
- cert-manager automates TLS cert provisioning via Let’s Encrypt.
- For the project Nginx was used, but I would recommend Traefik, because it accommodates more security implementation and visualizes active connection on a dashboard, which can help debug issues with deployments. I didn't use it because Traefik has a lot of Operational Overhead, but once configured, it is very easy to integrate other services to it.

#### Steps

- Install Nginx Using Helm

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

- Create a cluster issuer. See [clusterissuer.yaml](../recomendations/clusterissuer.yaml) for snippet. Then run:

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

- Add response security headers. See [ingress.yaml](./ingress.yaml) for full implementation snippet.

    ⚠️ **`NOTE`** ⚠️ : The current [ingress.yaml](./ingress.yaml) is for deployment without an SSL certificate. This is because I tested the Kubernetes manifest files locally. In production please uncomment the commented section of the file. Lines starting with "`# #`" are original comments and should remain comments.

### Deploy Kubernetes In A Cluster

- Copy folders `k8s` and `security` to the cluster.
- Create a namespace for deployment. (Since namespace value is mentioned in each of the manifest files especially the `deployment.yaml` file, the namespace would be created). But this would create a namespace manually:

    ```bash
    kubectl create namespace item-service-ns
    ```

- Deploy manifest

    ```bash
    kubectl apply -f security/

    kubectl apply -f k8s/
    ```

## Local Deployment With Kind

Kind is a tool that helps you simulate a Kubernetes cluster, using docker containers as Kubernetes nodes. It is lightweight and one of the best and easy ways to simulate a Kubernetes deployment before pushing to prod.

### Prerequisite For Kind

- [Kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installation)
- [Kubectl](https://kubernetes.io/docs/tasks/tools/)
- [Helm](https://helm.sh/docs/intro/install/)
- [Docker](https://docs.docker.com/get-started/get-docker/) or in my case [Podman](https://podman.io/docs/installation)

### Deployment Steps

#### Create Kind Cluster

A cluster can be created by using the command `kind create cluster`, this would create a single node Kubernetes cluster, but if you have a specific setup in mind consider using a configuration file. e.g

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
- role: worker
- role: worker
```

The above file would create a master node and 3 worker nodes (remember each of the nodes are just docker containers).

Then run the below command to create and give your cluster a name.

```bash
kind create cluster --config=./kind-cluster.yaml --name fastapi-item-server 
```

Install Local Path Provisioner, to give a default StorageClass and dynamic volume provisioning inside the Kind Cluster.

```bash
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/master/deploy/local-path-storage.yaml
```

#### Build FastAPI Item Server Docker Image

- Build the docker image:

    ```bash
    podman build -t item-service:latest -t item-service:1.0.0 .
    ```

- Convert image to tarball (Skip this step if you are using Docker and not Podman)

    ```bash
    podman save --format docker-archive -o item-service.tar item-service:1.0.0
    ```

- Load tarball into Kind

    ```bash
    kind load image-archive item-service.tar --name fastapi-item-server
    # If using Docker run this instead:
    kind load docker-image item-service:1.0.0 --name <kind cluster name>
    ```

- Confirm Image is in Kind

    ```bash
    podman exec -it fastapi-item-server-worker2 crictl images | grep item-service
    ```

#### Deploy Monitoring And Service Discovery Dependencies

- Download Helm Repos of dependencies

    ```bash
    helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

    helm repo add grafana https://grafana.github.io/helm-charts
    ```

- Update helm Repo

    ```bash
    helm repo update
    ```

- Install Promstack and port forward Prometheus and Grafana

    ```bash
    helm install kube-prometheus-stack \
    --create-namespace \
    --namespace kube-prometheus-stack \
    prometheus-community/kube-prometheus-stack
    ```

    port forwarding

    ```bash
    kubectl port-forward -n kube-prometheus-stack svc/kube-prometheus-stack-prometheus 9090:9090

    kubectl port-forward -n kube-prometheus-stack svc/kube-prometheus-stack-grafana 8080:80
    ```

    Check if you can access it from the browser

    ```bash
    http://localhost:9090/  # For prometheus
    http://localhost:8080/  # For grafana
    ```

    Login to Grafana `username: admin` and `password: prom-operator`

- Install Promtail and Loki (For Logging) and port forward Loki

    ```bash
    helm install loki grafana/loki-stack \
    --namespace loki \
    --create-namespace \
    --set prometheus.enabled=false \
    --set grafana.enabled=false \
    --set loki.auth_enabled=false \
    --set loki.image.tag="2.9.7" 
    ```

    port forwarding

    ```bash
    kubectl port-forward svc/loki -n loki 3100:3100
    ```

    Check if you can access it from the browser

    ```bash
    http://localhost:3100/loki/api/v1/status/buildinfo

    OR

    http://localhost:3100/ready
    ```

- Connect Loki to Grafana

    After logging into Grafana, take the following actions:
  - Navigate to `Connections` and click on `Data Sources`.
  - On the top right hand of the screen, click on the blue button `Add New Data Source`
  - Search for Loki and click on it.
  - Input `http://loki.loki.svc.cluster.local:3100` to the Connection Section, with key `URL*`
  - Scroll to the bottom of the page and click on the blue button `Save & Test`

- Survey Grafana
  - Go to `Dashboards` to see installed dashboards.
  - Go to `Explore`, change Outline to `Loki` Data Source
  - Select label, either `app` or `pod` (Both works fine)
  - Select value of choice
  - Click the `blue recycle button` on top right-hand corner of screen.

- Install Nginx

    ```bash
    helm install ingress-nginx ingress-nginx/ingress-nginx \
    --namespace ingress-nginx --create-namespace
    ```

#### Deploy Kubernetes Manifest Files

- Deploy files in this order, so that dependency issues doesn't occur:

    ```bash
        kubectl apply -f ../security/pod-security.yaml
        kubectl apply -f ../security/rbac.yaml

        # Apply core application manifests in order
        kubectl apply -f serviceaccount.yaml 
        kubectl apply -f configmap.yaml 
        kubectl apply -f secret.yaml 
        kubectl apply -f deployment.yaml 
        kubectl apply -f service.yaml 
        kubectl apply -f ingress.yaml 
        kubectl apply -f hpa.yaml 
        kubectl apply -f networkpolicy.yaml 

    ```

    You can add it into a bash script and call it (i.e ./create.sh).

#### DNS Routing To Test the Ingress Controller

- Domain Name Mapping

    Now that the application is running on the cluster. You can confirm this by running:

    ```bash
    kubectl get pods -n item-service-ns

    kubectl logs <Pod Name> -n item-service-ns
    ```

    Update your hosts file (`sudo vim /etc/hosts`) by adding the following at the last line of the file.

    ```txt
    127.0.0.1       item-api.example.com
    ```

    For example:

    ```txt
    ##
    # Host Database
    #
    # localhost is used to configure the loopback interface
    # when the system is booting.  Do not change this entry.
    ##
    127.0.0.1       localhost
    255.255.255.255 broadcasthost
    ::1             localhost
    127.0.0.1       item-api.example.com <- Line to be added
    ```

    ⚠️ **`WARNING`** ⚠️ : Do not tamper with any other line in that file.  Unless you are sure of what you are doing, this can mess up the default setting of the localhost on your system.

    This basically maps our localhost to the Domain Name.

- Port Forward The Nginx Controller

    Since we are running on Kind and the default service type for Helm Nginx deployment is `type: Loadbalance`, which you will have to do a CNAME or TypeA mapping with (Depending on your Cloud Provider), after your cloud provider assigns a LoadBalancer to you, we have to port forward the Nginx controller so that it maps traffic to the app.

    I port forwarded to port `8081`, you can port forward to any other port of choice.

    ```bash
    kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 8081:80
    ```

#### Test Connectivity In Browser

- Go to your browser and input the following:

    ```txt
    http://item-api.example.com:8081/health
    ```

    You should see:

    ```txt
    {"status":"healthy","timestamp":"2025-06-29T13:31:51.171834+00:00"}
    ```

    The logic is since, this `http://item-api.example.com:8081/` is basically the domain name, with the opened nginx controller port. Since the ingress works correctly, we have access to the app.

    If it doesn't, you will see a `400` or `404` error code, and if the network policy is not configured properly, you will see a `504` Network Time Out
