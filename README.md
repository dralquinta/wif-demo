# wif-demo
Workload Identity Federation Demo



dalquint@cloudshell:~ (dryruns)$ gcloud iam service-accounts add-iam-policy-binding github-actions-sa@dryruns.iam.gserviceaccount.com \
    --role roles/iam.workloadIdentityUser \
    --member "principalSet://iam.googleapis.com/projects/551624959543/locations/global/workloadIdentityPools/github-int-pool/attribute.repository/dralquinta/wif-demo"
Updated IAM policy for serviceAccount [github-actions-sa@dryruns.iam.gserviceaccount.com].
bindings:
- members:
  - principalSet://iam.googleapis.com/projects/551624959543/locations/global/workloadIdentityPools/github-int-pool/attribute.repository/dralquinta/wif-demo
  role: roles/iam.workloadIdentityUser
etag: BwYbpw1unWI=
version: 1