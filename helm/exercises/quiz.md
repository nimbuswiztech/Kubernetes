# Quiz with Answers

## Multiple choice
1. Helm is best described as: A) Container runtime B) Kubernetes package manager C) Cloud provider. **Answer: B**
2. A chart is: A) A reusable package B) A node C) A pod. **Answer: A**
3. An installed chart instance is called a: A) Template B) Release C) Repository. **Answer: B**
4. Which file commonly defines default configuration? A) values.yaml B) README.md C) NOTES.txt. **Answer: A**
5. Helm 3 removed which Helm 2 component? A) kubectl B) Tiller C) Deployment. **Answer: B**

## Short answer
1. Why use Helm? **To package related Kubernetes resources, configure them through values, and manage releases.**
2. What does `helm template` do? **Renders chart templates locally into Kubernetes manifests without installing a release.**
3. What is a repository? **A configured source for discovering/downloading charts.**
4. What is `.Values`? **Template access to chart values after defaults and supplied overrides are combined.**
5. Why run `helm lint`? **To catch common chart issues before deployment.**

## Beginner interview questions
1. Chart vs release? **A chart is the package; a release is an installed instance of it.**
2. What is `values.yaml` for? **It defines default configuration that templates read.**
3. What changed from Helm 2 to Helm 3? **Helm 3 removed Tiller and uses the user's Kubernetes access context.**

## Troubleshooting exercises
1. `helm: command not found`. **Install Helm for your OS using the official guide, then open a new terminal and run `helm version`.**
2. `Kubernetes cluster unreachable`. **Check `kubectl config current-context`, AWS credentials/region, EKS access, and kubeconfig; do not switch context blindly.**
3. `release name already exists`. **Run `helm list -n helm-demo` and `helm status demo -n helm-demo`; inspect the existing release and use upgrade if it is the intended lab release. Do not uninstall unknown releases.**

## Final hands-on assignment
Create or inspect a simple chart, change the replica count, render the output, deploy to the approved `helm-demo` namespace, verify the release and Kubernetes resources, then safely uninstall only your lab release.
