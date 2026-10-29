# Prometheus + Grafana on Kubernetes — Beginner Demo

A small, hands-on project for a 60–90 minute class. It installs the community `kube-prometheus-stack` Helm chart into an existing cluster, deploys a simple demo web app, explores Prometheus metrics, and imports a four-panel Grafana dashboard.

> **Scope and safety:** This is a learning demo, not a production configuration. It does not create a cluster. Run it only in a cluster where you are authorized to install monitoring components. Review the resources and cleanup commands before executing them.

## Learning objectives

- Explain monitoring, metrics, scraping, targets, PromQL, data sources, dashboards, and panels.
- Install Prometheus and Grafana with Helm.
- Inspect basic Kubernetes metrics.
- Import a dashboard and troubleshoot a missing panel.

## Prerequisites

- An existing Kubernetes cluster and a working `kubectl` context.
- Helm 3, Bash, and a Linux/macOS terminal.
- Cluster permissions to create namespaces, Helm releases, and the resources installed by the chart.
- Enough cluster capacity for the monitoring stack. The chart can create several Pods and CRDs.

## Project layout

```text
prometheus-grafana-demo/
├── README.md
├── docs/
│   ├── 01-introduction.md
│   ├── 02-architecture.md
│   ├── 03-installation.md
│   ├── 04-prometheus-basics.md
│   ├── 05-grafana-dashboard.md
│   ├── 06-troubleshooting.md
│   └── 07-cleanup.md
├── diagrams/
│   ├── monitoring-architecture.mmd
│   └── metrics-flow.mmd
├── helm/
│   ├── prometheus-values.yaml
│   └── grafana-values.yaml
├── manifests/
│   └── demo-app.yaml
├── dashboards/
│   └── basic-kubernetes-dashboard.json
└── scripts/
    ├── 01-check-cluster.sh
    ├── 02-install-monitoring.sh
    ├── 03-deploy-demo-app.sh
    ├── 04-access-monitoring.sh
    ├── 05-verify-monitoring.sh
    └── 06-cleanup.sh
```

## Quick start

From this project directory:

```bash
chmod +x scripts/*.sh
./scripts/01-check-cluster.sh
./scripts/02-install-monitoring.sh
./scripts/03-deploy-demo-app.sh
./scripts/05-verify-monitoring.sh
```

Use separate terminals for port-forwarding. Run `./scripts/04-access-monitoring.sh` for the service names and commands. It prints the commands; it does not leave background port-forward processes running.

### Open Prometheus

```bash
kubectl get svc -n monitoring
kubectl -n monitoring port-forward svc/prometheus-operated 9090:9090
```

If `prometheus-operated` is not present in your chart release, discover the Prometheus service:

```bash
kubectl get svc -n monitoring
```

Use the actual Prometheus service name and port shown. Open <http://localhost:9090>, then visit **Status → Targets** and try `up` in the query page.

### Open Grafana

Find the service name first:

```bash
kubectl get svc -n monitoring | grep -i grafana
```

For the common service name:

```bash
kubectl -n monitoring port-forward svc/prometheus-grafana 3000:80
```

Open <http://localhost:3000>. The initial username is normally `admin`. Retrieve the password from the Secret without putting it into shell history or logs:

```bash
kubectl get secret -n monitoring
kubectl get secret -n monitoring prometheus-grafana \
  -o jsonpath='{.data.admin-password}' | base64 --decode; echo
```

Secret names and keys can vary; inspect the actual Grafana Secret if the command does not work. Do not share the password. On macOS, `base64 --decode` may be available as `base64 -D` depending on the system.

### Import the dashboard

In Grafana, choose **Dashboards → New → Import**, upload `dashboards/basic-kubernetes-dashboard.json`, and select the Prometheus data source if prompted. The dashboard uses common metrics provided by `kube-prometheus-stack`; metric names and labels can vary by chart version and cluster.

## Installation version

The chart version used as the project baseline is `92.11.0`, which was listed in the official Prometheus Community chart package page during project preparation. Confirm that the version is still available in your environment before installation:

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm search repo prometheus-community/kube-prometheus-stack --versions | head
```

The install script pins the baseline version. If your environment lists a different suitable version or has compatibility constraints, update `CHART_VERSION` in `scripts/02-install-monitoring.sh` after reviewing the chart's release notes and values.

## Expected results

- A `monitoring` namespace containing Prometheus, Grafana, and chart-managed monitoring components.
- A `monitoring-demo` namespace containing the sample web application.
- Prometheus targets with healthy targets showing `UP`.
- The Grafana dashboard displaying target availability, pod count, CPU usage, and memory usage when the expected metrics exist.

## Validation limitations

The files and scripts are checked for local syntax and JSON validity during generation. A live Kubernetes cluster was not available for an end-to-end deployment, so Pod readiness, chart installation, and metric availability must be verified in your own environment.

## Documentation

Follow the guides in `docs/` in numerical order. Start with [introduction](docs/01-introduction.md), then [architecture](docs/02-architecture.md), [installation](docs/03-installation.md), [Prometheus basics](docs/04-prometheus-basics.md), [Grafana dashboard](docs/05-grafana-dashboard.md), [troubleshooting](docs/06-troubleshooting.md), and [cleanup](docs/07-cleanup.md).
