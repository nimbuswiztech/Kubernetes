# Beginner Helm Interview Questions

1. **What is Helm?** A Kubernetes package manager that packages resource templates and values and manages deployments as releases.
2. **What is a Helm chart?** A directory/package containing chart metadata, values, and templates used to generate Kubernetes manifests.
3. **What is a Helm release?** A named installation of a chart in a namespace.
4. **What is the role of values.yaml?** It defines default configuration consumed by templates.
5. **What does `helm upgrade` do?** Updates an existing release using a chart and optional new values.
6. **What does `helm uninstall` do?** Removes resources tracked by the named release; it does not automatically delete the namespace.
7. **What did Tiller do in Helm 2?** It was the in-cluster server component; Helm 3 removed it.
8. **What is `helm lint`?** A chart validation command that catches common issues.
9. **What is `helm template`?** It renders manifests locally without installing them.
10. **How do you inspect a release?** Use `helm status`, `helm get values`, and `helm get manifest`.
