# Setting Up Workload Identity Federation for GitHub Actions with Google Cloud


This guide will walk you through the process of setting up Workload Identity Federation to allow GitHub Actions to authenticate with Google Cloud. This setup enables secure, short-lived, and scoped access tokens for your GitHub workflows.

## Prerequisites
- Google Cloud project
- GitHub repository
- Google Cloud SDK installed

## Steps
0. Set your project workspace as the current one you're working on

```shell
dalquint@cloudshell:~$ gcloud config set project YOUR_PROJECT_ID
Updated property [core/project].

```
1. Create a Service Account
    - Open the Google Cloud Console.
    - Navigate to the IAM & Admin section.
    - Select "Service accounts".
    - Click "Create Service Account".
    - Fill in the Service Account details:
        Name: `github-actions-sa`
        ID: `github-actions-sa`
    - Click "Create and Continue".
    - Grant the necessary roles:
        `Service Account Token Creator`
    - Click "Done".


   ### Verification
    ```shell
    dalquint@cloudshell:~ (dryruns)$ gcloud iam service-accounts list --filter="email:github-actions-sa@dryruns.iam.gserviceaccount.com"    
    DISPLAY NAME: github-actions-sa
    EMAIL: github-actions-sa@dryruns.iam.gserviceaccount.com
    DISABLED: False

    ```



2. Create a Workload Identity Pool (WIF)

```shell
PROJECT_ID="your-project-id"
PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format="value(projectNumber)")
WORKLOAD_IDENTITY_POOL_ID="githubpool"

gcloud iam workload-identity-pools create $WORKLOAD_IDENTITY_POOL_ID \
  --project=$PROJECT_ID \
  --location="global" \
  --display-name="GitHub Workload Identity Pool"

```

### Verification

```shell
dalquint@cloudshell:~$ gcloud iam workload-identity-pools describe $WORKLOAD_IDENTITY_POOL_ID --project=$PROJECT_ID --location="global"
description: 'WIF Integration with GitHub '
displayName: githubpool
name: projects/551624959543/locations/global/workloadIdentityPools/githubpool
state: ACTIVE
```

3. Create an OIDC Provider

```shell
PROVIDER_NAME="githubprovider"

gcloud iam workload-identity-pools providers create-oidc $PROVIDER_NAME \
  --project=$PROJECT_ID \
  --location="global" \
  --workload-identity-pool=$WORKLOAD_IDENTITY_POOL_ID \
  --display-name="GitHub Actions OIDC Provider" \
  --attribute-mapping="google.subject=assertion.sub,attribute.repository=assertion.repository,attribute.full=assertion.repository+assertion.environment" \
  --issuer-uri="https://token.actions.githubusercontent.com"

```

### Verification

```shell
dalquint@cloudshell:~$ gcloud iam workload-identity-pools providers describe $PROVIDER_NAME --project=$PROJECT_ID --location="global" --workload-identity-pool=$WORKLOAD_IDENTITY_POOL_ID
attributeMapping:
  attribute.full: assertion.repository+assertion.environment
  attribute.repository: assertion.repository
  google.subject: assertion.sub
displayName: githubprovider
name: projects/551624959543/locations/global/workloadIdentityPools/githubpool/providers/githubprovider
oidc:
  issuerUri: https://token.actions.githubusercontent.com
state: ACTIVE
```

4. Configure IAM Policy Binder of Service Account and corresponding Principal

```shell
SA="github-actions-sa@${PROJECT_ID}.iam.gserviceaccount.com"
REPO="your-github-username/your-repo-name"

gcloud iam service-accounts add-iam-policy-binding $SA \
  --project=$PROJECT_ID \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/${WORKLOAD_IDENTITY_POOL_ID}/attribute.repository/${REPO}"

```

### Verfication

```shell
dalquint@cloudshell:~$ gcloud iam service-accounts get-iam-policy $SA
bindings:
- members:
  - serviceAccount:github-actions-sa@dryruns.iam.gserviceaccount.com
  role: roles/editor
- members:
  - serviceAccount:github-actions-sa@dryruns.iam.gserviceaccount.com
  role: roles/iam.serviceAccountTokenCreator
- members:
  - principalSet://iam.googleapis.com/projects/551624959543/locations/global/workloadIdentityPools/githubpool/attribute.repository/dralquinta/wif-demo
  role: roles/iam.workloadIdentityUser
etag: BwYbuSgkGXk=
version: 1
```


5. Generate Github Actions Configuration file

Create or update your GitHub Actions workflow file (e.g., `.github/workflows/deploy.yml`):

```yaml
name: Deploy to GCP

on:
  push:
    branches:
      - main

jobs:
  deploy:
    runs-on: ubuntu-latest
    permissions:
      id-token: write
      contents: read

    steps:
    - name: Checkout repository
      uses: actions/checkout@v3

    - name: Authenticate to Google Cloud
      id: auth
      uses: google-github-actions/auth@v1
      with:
        workload_identity_provider: projects/${{ secrets.PROJECT_NUMBER }}/locations/global/workloadIdentityPools/${{ secrets.WORKLOAD_IDENTITY_POOL_ID }}/providers/${{ secrets.PROVIDER_NAME }}
        service_account: ${{ secrets.SERVICE_ACCOUNT_EMAIL }}
        id_token_include_email: true

    - name: Run Cloud Build
      run: gcloud builds submit --config cloudbuild.yaml

```


6. Set GitHub Secrets

In your GitHub repository, navigate to `Settings` > `Secrets` > `Actions` and add the following secrets:

`PROJECT_NUMBER`: Your Google Cloud project number.
`WORKLOAD_IDENTITY_POOL_ID`: `githubpool`
`PROVIDER_NAME`: `githubprovider`
`SERVICE_ACCOUNT_EMAIL`: `github-actions-sa@your-project-id.iam.gserviceaccount.com`

7. Verify Setup
Commit and push your changes to GitHub.
Check the Actions tab in your GitHub repository to ensure the workflow runs successfully.



