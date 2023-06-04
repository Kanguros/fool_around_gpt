 Go Application Deployment

This repository contains the Azure Pipelines configuration and templates to deploy a Go application to ACC (Acceptance) and PRD (Production) environments. The deployment process involves pulling a universal package, copying repository files, and deploying the application as a Windows service on the target servers.

## Pipeline

The deployment pipeline is defined in the `azure-pipeline.yml` file.

### Parameters

The pipeline requires the following parameters to be configured:

- `accEnvironment`: Configuration specific to the ACC environment.
    - `host`: Hostname or IP address of the ACC server.
    - `username`: Username for accessing the ACC server.
    - `package`: Name of the application package.
    - `packageVersion`: Version of the application package.
    - `vaultName`: Name of the Azure Key Vault containing the ACC password.
    - `subscription`: Subscription ID for accessing the ACC Key Vault.
- `prdEnvironment`: Configuration specific to the PRD environment.
    - `host`: Hostname or IP address of the PRD server.
    - `username`: Username for accessing the PRD server.
    - `package`: Name of the application package.
    - `packageVersion`: Version of the application package.
    - `vaultName`: Name of the Azure Key Vault containing the PRD password.
    - `subscription`: Subscription ID for accessing the PRD Key Vault.

### Pipeline Structure

The pipeline consists of the following stages:

- **DeployToAcc**: Deployment stage for the ACC environment.
- **DeployToPrd**: Deployment stage for the PRD environment.

Each stage performs the following steps:

1. Retrieves the password for the server from the Azure Key Vault.
2. Invokes the `deploy-template.yml` template, passing the environment-specific parameters.
3. The template copies repository files to the target server using WinRM.
4. The template downloads the application package from the Universal Package feed.
5. The template uploads the package to the target server using WinRM.
6. The template installs and starts the application as a Windows service using WinRM.



This diagram illustrates the flow of the deployment pipeline, starting with the trigger and branching into the ACC and PRD deployment stages. Each stage consists of copying files, using WinRM to transfer files, and deploying the application package.

## Usage

1.  Update the pipeline configuration in the `azure-pipeline.yml` file, specifying the correct parameter values for your ACC and PRD environments.
2.  Commit and push the changes to your repository.
3.  Azure Pipelines will automatically trigger the pipeline on merges to the `master` branch or when a new version of the universal package is available.