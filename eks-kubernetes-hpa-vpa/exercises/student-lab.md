# Student Lab
1. Run the read-only validation script and record AWS identity, region, context, Ready nodes, metrics API and VPA availability.
2. Predict whether CPU HPA works when `kubectl top pods` fails; explain.
3. If approved and metrics work, run `scripts/01-setup.sh`.
4. Record baseline with `kubectl get hpa,deployment,pods -n autoscaling-demo -o wide`.
5. Run `scripts/02-generate-load.sh 120`; watch HPA, Deployment and Pods.
6. Stop load and observe scale-down. Explain delays and distinguish desired, scheduled, Ready and serving Pods.
7. If VPA is installed and healthy, apply `manifests/05-vpa-recommendation.yaml`; otherwise skip.
8. Diagnose one challenge in `troubleshooting-challenges.md`; clean up with `scripts/04-cleanup.sh`.
**Submission:** baseline/loaded observations, CPU utilization calculation, failure diagnosis and safety explanation.
