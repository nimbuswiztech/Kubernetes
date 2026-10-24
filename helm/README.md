# Helm Basics Training — Nimbuswiztech

A beginner-level, offline HTML training kit for Helm 3-compatible workflows using an **existing Amazon EKS cluster**. It includes teaching pages, a small custom chart, scripts, student exercises, a quiz, and a trainer guide.

## Requirements
- Existing EKS cluster and at least one Ready worker node
- AWS CLI configured for the intended account/region
- kubectl configured for the intended EKS cluster
- Helm 3-compatible CLI
- Bash for the scripts (macOS/Linux; Windows users can use WSL/Git Bash or run equivalent commands in PowerShell)
- Network access to pull the public NGINX image during deployment

This project does **not** create an EKS cluster, install tools, or change Kubernetes context automatically.

## Safe preparation checklist
1. Unzip the project and open `html/index.html` directly in a browser. HTML/CSS are local; no server is required.
2. From the project root, run `./scripts/00-check-environment.sh`. This script is read-only.
3. Confirm the displayed current context is the intended EKS cluster.
4. Confirm `kubectl get nodes` shows a Ready worker node and that you have permission to create resources in `helm-demo`.
5. Inspect existing releases/resources in `helm-demo` before using the lab release name `demo`.
6. Run `./scripts/02-validate-chart.sh` before deployment. `helm lint` and `helm template` do not install resources.
7. Use `./scripts/03-install-and-test.sh` only after confirming the target context. It asks for explicit confirmation.
8. Use `./scripts/04-upgrade-release.sh` for the lab upgrade.
9. Use `./scripts/05-cleanup.sh` to uninstall only release `demo` in namespace `helm-demo`. It does not delete the namespace.

## Project structure
```text
helm-basics-training/
├── README.md
├── TRAINER-GUIDE.md
├── assets/styles.css
├── html/
│   ├── index.html
│   ├── 01-helm-introduction.html
│   ├── 02-helm-components.html
│   ├── 03-installing-helm-charts.html
│   ├── 04-helm-architecture.html
│   ├── 05-helm-repositories.html
│   ├── 06-creating-first-chart.html
│   ├── 07-helm-built-in-objects.html
│   ├── 08-values-and-templates.html
│   ├── 09-template-functions.html
│   └── 10-live-demo-and-revision.html
├── charts/my-first-chart/
│   ├── Chart.yaml
│   ├── values.yaml
│   └── templates/
│       ├── _helpers.tpl
│       ├── deployment.yaml
│       ├── service.yaml
│       └── NOTES.txt
├── scripts/
│   ├── 00-check-environment.sh
│   ├── 01-setup.sh
│   ├── 02-validate-chart.sh
│   ├── 03-install-and-test.sh
│   ├── 04-upgrade-release.sh
│   └── 05-cleanup.sh
└── exercises/
    ├── student-lab.md
    ├── cheat-sheet.md
    ├── quiz.md
    └── interview-questions.md
```

## Helm installation instructions (manual)
Do not run these automatically; use the official guide for current platform-specific steps:
- macOS: `brew install helm` (if Homebrew is installed and approved)
- Linux: follow the official Helm binary/package instructions
- Windows PowerShell: use the official Helm installation guide or an approved package manager
- Official guide: https://helm.sh/docs/intro/install/

## Run the lab
From the project root:
```bash
helm version
./scripts/02-validate-chart.sh
# After confirming the cluster context:
./scripts/03-install-and-test.sh
./scripts/04-upgrade-release.sh
./scripts/05-cleanup.sh
```

### Manual workflow
```bash
helm lint ./charts/my-first-chart
helm template demo ./charts/my-first-chart -n helm-demo
helm install demo ./charts/my-first-chart -n helm-demo --create-namespace
helm list -n helm-demo
helm status demo -n helm-demo
kubectl get deployments,pods,services -n helm-demo
helm upgrade demo ./charts/my-first-chart -n helm-demo --set replicaCount=2
helm get values demo -n helm-demo
helm get manifest demo -n helm-demo
helm uninstall demo -n helm-demo
```

## Optional public repository demo
Verify current chart availability before installing; public repositories and chart requirements can change.
```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo list
helm search repo nginx
helm repo update
helm show chart bitnami/nginx
helm show values bitnami/nginx
```
The repository example is optional. The custom chart lab does not depend on it.

## Official documentation
- Helm docs: https://helm.sh/docs/
- Helm installation: https://helm.sh/docs/intro/install/
- Helm architecture: https://helm.sh/docs/topics/architecture/
- Chart structure: https://helm.sh/docs/topics/charts/
- Template guide: https://helm.sh/docs/chart_template_guide/
- Built-in objects: https://helm.sh/docs/chart_template_guide/builtin_objects/
- Template functions: https://helm.sh/docs/chart_template_guide/function_list/
- Values: https://helm.sh/docs/chart_template_guide/values_files/
- Kubernetes Deployments: https://kubernetes.io/docs/concepts/workloads/controllers/deployment/
- Kubernetes Services: https://kubernetes.io/docs/concepts/services-networking/service/
- Amazon EKS: https://docs.aws.amazon.com/eks/

## Nimbuswiztech Wiki references
Primary lesson references supplied for this course:
1. https://github.com/nimbuswiztech/Helm_charts/wiki/HELM-Introduction,-Package-manager-need-and-purpose
2. https://github.com/nimbuswiztech/Helm_charts/wiki/Helm-component-introduction
3. https://github.com/nimbuswiztech/Helm_charts/wiki/Installation-of-Helm-charts
4. https://github.com/nimbuswiztech/Helm_charts/wiki/Architecture,-difference-between-HELM-2-and-HELM-3
5. https://github.com/nimbuswiztech/Helm_charts/wiki/Repository-quick-introduction
6. https://github.com/nimbuswiztech/Helm_charts/wiki/Creating-first-custom-chart-and-summary-about-files-present-in-charts
7. https://github.com/nimbuswiztech/Helm_charts/wiki/Helm-built-in-objects
8. https://github.com/nimbuswiztech/Helm_charts/wiki/Read-and-set-values-to-template
9. https://github.com/nimbuswiztech/Helm_charts/wiki/Template-functions

## Notes on validation
The environment checker is read-only. This generated package has not been executed against your EKS cluster. Run `helm lint` and `helm template` locally before installing. Live outputs are representative only and depend on your cluster, permissions, image registry access, and CLI versions.
