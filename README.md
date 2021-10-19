# galoy-infra

This repository contains terraform definitions to bring up a robust infrastructure implementation suitable for running the [galoy](https://github.com/GaloyMoney/galoy) stack.
It is production ready by default.

The infrastructure is organized into 4 modules that must be executed in sequence.
They can be executed against a completly blank google cloud project with `owner` access.
The final state is a regional gke cluster running on a private network with a bastion host deployed for connectivity.

## modules

- `bootstrap` - Enables required APIs and provisions the initial "inception" service account as well as the GCS bucket to store all terraform state required in all other phases. This step should be executed 1 time only and not automated.
- `inception` - Provisions all security sensitive resourced like the vpc network, bastion, roles, service accounts etc.
- `platform` - Provisions the gke cluster itself
- `services` - Deploys the [ingress-nginx](https://github.com/kubernetes/ingress-nginx) and [cert-manager](https://cert-manager.io/docs/) charts onto the k8s cluster - basic dependencies for everything else that will be deployed to kubernetes.

The `bootstrap`, `inception` and `platform` modules currently only support GCP while the `services` module is IaaS independent.
In the future additional versions of the first 3 modules will be developped to support other IaaSes.

The structure of the modules is intended to support continous delivery.
After initial deploy moving from 1 version to the next should always be smooth and automatable - albeit the sequence of the rollout should remain unchanged.

The initial deploy - while it is automatable - does have a few caveats.
A complete walkthrough of a rollout is documented in the [examples/gcp](./examples/gcp) folder.
