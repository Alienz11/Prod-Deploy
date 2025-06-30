# Prod-Deploy

A production-ready FastAPI web application, deployed on Amazon EKS using Kubernetes and industry-standard DevSecOps practices. This project includes everything from IaC (Terraform) to CI/CD (GitHub Actions), Kubernetes security hardening, and observability tooling.

## 📁 Project Structure

This project follows a well-organized structure to separate application code, infrastructure as code, CI/CD pipelines, and Kubernetes configurations.

| Folder / File           | Purpose                                                                   |
| :---------------------- | :------------------------------------------------------------------------ |
| `main.py`, `test.py`    | Core application logic and unit tests                                   |
| `Dockerfile`            | Multistage Dockerfile for lightweight, secure builds                      |
| `.github/workflows/deploy.yaml` | GitHub Actions pipeline: Linting, testing, scanning & deployment          |
| `security/`             | Kubernetes security configurations (PodSecurity, RBAC, etc.)              |
| `k8s/`                  | Core Kubernetes manifests (Deployment, Service, HPA, Ingress, etc.)       |
| `terraform/`            | Infrastructure as Code (IaC) for provisioning AWS VPC and EKS clusters    |
| `scripts/`              | Helper scripts for CI/CD deployment and rollback automation               |
| `monitoring/`           | Setup for Prometheus, Alertmanager, and Grafana                           |
| `solutions/`            | Screenshots and artifacts proving successful deployment                   |

## 🔒 Security Features

This project integrates multiple Kubernetes security best practices:

* ✅ Pod Security Policies (restricted by default)
* ✅ RBAC: Role-based access control
* ✅ Network Policies: Explicit traffic control
* ✅ OWASP Dependency-Check: Detect vulnerable dependencies
* ✅ Trivy: Image vulnerability scanning
* ✅ GitHub Code Scanning: SARIF-based vulnerability reports

## ⚙️ CI/CD Pipeline

The Continuous Integration/Continuous Delivery pipeline is implemented via GitHub Actions (`deploy.yaml`):

* ✅ Code Checkout
* ✅ Security Scanning: OWASP, Trivy, SonarQube
* ✅ Linting & Formatting: Flake8, Black
* ✅ Testing: Pytest + Coverage
* ✅ Docker Build & Push to ECR
* ✅ K8s Deployment to EKS
* ✅ Rollback Automation on Failure

## ☁️ Infrastructure Setup (Terraform)

The infrastructure as code (IaC) is located in the `terraform/` folder. It provisions:

* An AWS VPC
* A fully configured EKS Cluster

## 📈 Monitoring & Observability

The project includes a basic setup for monitoring and observability:

* **Prometheus**: Metrics collection
* **Grafana**: Dashboards for visualization
* **Alertmanager**: Notifications for critical alerts

Setup details and manifests are in the `monitoring/` directory.

## 📦 Deployment

Deployment is automated via the CI/CD pipeline. However, you can also run it manually:

```bash
./scripts/deploy.sh
```

If something goes wrong, rollback is also automated:

```bash
./scripts/rollback.sh
```

## 🖼️ Solution Verification

The `solutions/` folder contains screenshots and output artifacts confirming:

* 🟢 Successful deployment on Kind
* 🧪 Test results and coverage
* 🔐 Security scan outputs

## ✅ Requirements

To run or deploy this project, you will need:

* An AWS account with IAM credentials
* GitHub Secrets set up for CI/CD
* `kubectl`, `awscli`, and `terraform` installed locally (for manual work)
* Docker

## 💡 Future Improvements

* Add ArgoCD for GitOps workflows
* Integrate Kubernetes admission controllers (e.g., OPA/Gatekeeper)
* Set up cost monitoring for FinOps (e.g., Kubecost or InfraCost)

## 🏁 Conclusion

The project revolves around a Local Kubernetes Deployment `Kind` and `AWS Cloud Services`. Configurations in this project can work for other cloud services, just to make certain naming or syntax changes based on the cloud provider of choice.

Each individual folder has a `README.md` file explaining steps, procedures and concepts in dept.

A full breakdown of the application can be seen in the [`APPLICATION.md`](./APPLICATION.md) file, while the step-by-step Kind Deployment procedure can be found in this [README.md](./k8s/README.md) file, under the `Local Deployment With Kind` section.

⚠️ **`ATTENTION`** ⚠️ : Commented out sections in this project are what is necessary for AWS Cloud based production deployment. They were commented out for local test purposes. Comments with 2 hashtags (i.e. Lines with `# #` in front of them), are real comments.

Have fun deploying 🚀🚀🚀

## 🧑‍💻 Author

Kenechukwu Nnajim

GitHub: @Alienz11
