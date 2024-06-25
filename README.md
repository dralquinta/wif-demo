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





google.subject=assertion.sub
attribute.repository=assertion.repository
attribute.full=assertion.repository+assertion.environment

dalquint@cloudshell:~$ PROJECT_ID="dryruns"
dalquint@cloudshell:~$ PROJECT_NUMBER="551624959543"
dalquint@cloudshell:~$ WORKLOAD_IDENTITY_POOL_ID="projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/githubpool"
SA="github-actions-sa@dryruns.iam.gserviceaccount.com"
REPO="dralquinta/wif-demo"
dalquint@cloudshell:~$ gcloud iam service-accounts add-iam-policy-binding "${SA}" \
  --project="${PROJECT_ID}" \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/${WORKLOAD_IDENTITY_POOL_ID}/attribute.repository/${REPO}"
Updated IAM policy for serviceAccount [github-actions-sa@dryruns.iam.gserviceaccount.com].
bindings:
- members:
  - serviceAccount:github-actions-sa@dryruns.iam.gserviceaccount.com
  role: roles/iam.serviceAccountTokenCreator
- members:
  - principalSet://iam.googleapis.com/projects/551624959543/locations/global/workloadIdentityPools/githubpool/attribute.repository/dralquinta/wif-demo
  role: roles/iam.workloadIdentityUser
etag: BwYbuKo6kdo=
version: 1