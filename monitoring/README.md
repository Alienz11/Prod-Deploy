# Monitoring Setup

This folder contains monitoring configurations for observability of the FastAPI application in Kubernetes. It includes Prometheus metrics scraping, alerting rules, and Grafana dashboards.

## 📁 Files

### `prometheus.yml`

- Configuration file for Prometheus.
- Scrapes metrics from pods labeled `app: item-service`.
- Requires FastAPI app to expose `/metrics` endpoint.
- Expects the following pod annotations in the deployment.yaml file:

    ```yaml
    annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "8000"
    ```

- See [prometheus.yaml](./prometheus.yaml) file.

### `alerts.yml`

- Contains Prometheus alert rules.
- Example: Alert for high 5xx error rates.
- Requires AlertManager integration to notify teams. And also an alertmanager.yaml file for configuring alert destinations. Example for email alerts:

    ```yaml
    global:
        resolve_timeout: 1m
        # The smarthost and SMTP sender used for mail notifications.
        smtp_smarthost: '<smtp hostname>:<smtp port>' #smtp.gmail.com:587
        smtp_from: 'alert@prometheus.com' # The preferred sender's email of choice
        smtp_auth_username: 'sample-email@gmail.com'
        smtp_auth_password: '<password>'

    route:
        # The default receiver for alerts that don't match any specific receiver.
        receiver: 'Alerts-Email'

        repeat_interval: 3h
    receivers:
        - name: Alerts-Email
        email_configs:
        - to: developer@company.com # Desired email destination.
            from: 'alert@prometheus.com'
            require_tls: false
            send_resolved: true
    ```

    you also need to add this to the prometheus.yaml file:

    ```yaml
    alerting:
        alertmanagers:
        - scheme: http
            static_configs:
            - targets:
            - "alertmanager:9093"
    ```

    To help Prometheus trigger alerts that would be sent to the alert destination.

### `grafana-dashboard.json`

- Grafana dashboard (in JSON) for visualizing:
  - Request rates
  - Error rates
  - Latencies
  - System resource metrics
- Import it into Grafana manually or via provisioning.

## RECOMMENDATIONS

The above files would be redundant without an installation of Prometheus, Node Exporter and Grafana in the Kubernetes cluster.

I will advise the installation of `kube-prometheus-stack` on the cluster, then you can manually edit configuration files to get result wanted based on what drives the Company's goal.

### General Set-Up Summary

#### 1. Install Kube-Prometheus-Stack

- First, register the chart’s repository in the Helm client:

    ```bash
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    ```

- Next, update the repository lists to discover the chart:

    ```bash
    helm repo update
    ```

- Now run the following command to deploy the chart into a new namespace in the

    ```bash
    helm install kube-prometheus-stack \
    --create-namespace \
    --namespace kube-prometheus-stack \
    prometheus-community/kube-prometheus-stack
    ```

- Confirm deployment, it should look something like this:

    ```txt
    $ kubectl -n kube-prometheus-stack get pods

    NAME                                                       READY   STATUS    RESTARTS      AGE
    alertmanager-kube-prometheus-stack-alertmanager-0          2/2     Running   1 (66s ago)   83s
    kube-prometheus-stack-grafana-5cd658f9b4-cln2c             3/3     Running   0             99s
    kube-prometheus-stack-kube-state-metrics-b64cf5876-52j8l   1/1     Running   0             99s
    kube-prometheus-stack-operator-754ff78899-669k6            1/1     Running   0             99s
    kube-prometheus-stack-prometheus-node-exporter-vdgrg       1/1     Running   0             99s
    prometheus-kube-prometheus-stack-prometheus-0              2/2     Running   0             83s
    ```

#### 2. Port Forward Prometheus

Prometheus is not exposed automatically, so you need to port forward or create a service for it with type `nodePort` or use an ingress controller to do a type a mapping from a URL say `prometheus.company.com` to the running Prometheus pod on the cluster. I will show a sample of port forwarding, it should look something like this:

```txt
$ kubectl port-forward -n kube-prometheus-stack svc/kube-prometheus-stack-prometheus 9090:9090
Forwarding from 127.0.0.1:9090 -> 9090
Forwarding from [::1]:9090 -> 9090
```

Then you can use `http://localhost:9000` or `http://127.0.0.1:9000` to view Prometheus dashboard.

#### 3. Port Forward Grafana

Grafana is not exposed automatically, so you need to port forward or create a service for it with type `nodePort` or use an ingress controller to do a type a mapping from a URL say `grafana.company.com` to the running Prometheus pod on the cluster. I will show a sample of port forwarding, it should look something like this:

```txt
$ kubectl port-forward -n kube-prometheus-stack svc/kube-prometheus-stack-grafana 8080:80
Forwarding from 127.0.0.1:8080 -> 3000
Forwarding from [::1]:8080 -> 3000
```

Then you can use `http://localhost:3000` or `http://127.0.0.1:3000`to view Grafana dashboard.

You can get pre-designed dashboards by going to [grafana labs](https://grafana.com/grafana/dashboards/) to download dashboard of choice and load into Grafana.

No one really creates dashboard on the fly, why do something that has already been done? 😊

## THOUGHTS

Personally, the use case of Prometheus, Grafana, Alert Manager and Node Exporter for monitoring is more of a Site Reliability Engineer's (SRE) domain/requirements to get Service Level Indicators (SLIs), that would determine Service Level Objectives (SLOs), and would be used to create Service Level Agreements (SLAs) between the company and others. Basically they use it to assure others the availability level of their platform.

As a DevOps Engineer you are less likely to use this dashboard, firstly because we are not interested in really putting a number to the availability of the infrastructure, we are interested in making sure the Infrastructure is sturdy and always available, that is why we already have things in place like Horizontal Pod Autoscaler (HPA) which increases/decreases pods based on high traffic, Vertical Pod Autoscaler(VPA) which increase/decreases compute resource of a pod based on high traffic and a Cluster Autoscaler native to Kubernetes (You can also use Karpenter for this, works best for AWS and EKS services) that increases/decreases the amount of nodes depending on resource requirements based on pod allocations that is caused by high/low user traffic. This ensure that there are automatic fail-safes that make sure the Infrastructure always stands.

You can also use Dashboards like `Lens`, `Portainer`, and even if its core purpose is for GitOps one can use `ArgoCD` dashboard to have a general overview of the Kubernetes cluster that would highlight issues or problems on their screens with direct description of the error and where you can find it.

A more suitable monitoring aspect for DevOps Engineers whose core job is to serve as a liaison between the Developers and the Infrastructure would surround the following:

- **`Logging`**
  - You can use the ELK (Elasticsearch, Logstash and Kibana) stack. Kibana Alerts based on Error messages
  - You can use Promtail, Loki and Grafana. Grafana Alerts based on Error messages. This was done in the local deployment. See [README.md](../k8s/README.md).
  - You can use Fluetbit, Prometheus and Grafana.  Grafana Alerts based on Error messages
- **`Tracing`**
  - You can use Open telemetry and Jeager
  - You can use Open telemetry and Zipkin
- **`Uptime`**
  - You can use BlackBox Exporter, Prometheus, Grafana and Alert manager to alert when an application is down.
  - You can also use `Uptime-Kuma`, a simple light weight all in one tools, that helps with the monitoring of uptime of a certain URL and also handles alerting. This is the best, because over engineering things doesn't mean it would be the best option. Over engineering things can also result to High need of compute resource, which means high Infrastructure Cost. So principle of `Keep It Simple (KISS)` stands.

For companies that rather use third party services, I would recommend [**Sentry**](https://sentry.io/welcome/), it would alert you when the application is down, tell you the error and even pinpoint the line in the source code that makes the application fail. It shows logs, tracing and bread crumbs all in one. An alternative is [**highlight.io**](https://www.highlight.io/), check for price differences. Then for both Infrastructure and APM, say DataDog or Newrelic. DataDog is good, but can be pricey.

These are the ones I have off the top of my head, and research can be made to know appropriate tools depending on product goals requirements of the company.
