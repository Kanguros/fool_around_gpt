Here is a Azure Pipeline definition along with the template pipeline it uses. 
Create a documentation for it which contains:
- Description what it is
- Description with example value for input parameters.
- Description of defined variables including an example.
- Explanation how to us it
- Example of use.


### azure-pipelines.yaml
```yaml
trigger:
  branches:
    include:
      - master

variables:
  # Name of the Azure Agent Pool, Windows type.
  - name: agent_pool_name
    value: CUSTOM_WINDOWS
  # Name of the package to be pulled and deployed.
  - name: package_name
    value: MyApplication
  - name: package_feed
    value: UniversalPackageFeed
  - name: service_dir
    value: "O:\AppService\"
    
    

parameters:
  - name: acc_env
    displayName: 'ACC Environment Config'
    type: object
    default:
      name: acc
      host: <ACC_HOST>
      username: <ACC_USERNAME>
      package_version: 1.0.0
      vaultName: <ACC_VAULT_NAME>
      subscription: <ACC_SUBSCRIPTION_ID>

  - name: prd_env
    displayName: 'PRD Environment Config'
    type: object
    default:
      name: prd
      host: <PRD_HOST>
      username: <PRD_USERNAME>
      package_version: 1.0.0
      vaultName: <PRD_VAULT_NAME>
      subscription: <PRD_SUBSCRIPTION_ID>

jobs:
  - job: DeployToAcc
    displayName: 'Deploy to ${{ parameters.acc_env.name }}'
    pool:
      name: ${{ variables.agent_pool_name }}
    steps:
      - task: AzureKeyVault@2
        displayName: 'Retrieve secrets from ACC Key Vault'
        inputs:
          azureSubscription: ${{ parameters.acc_env.subscription }}
          KeyVaultName: ${{ parameters.acc_env.vaultName }}
          SecretsFilter: '*'
          RunAsPreJob: true

      - template: deploy-template.yaml
        parameters:
          environment: ${{ parameters.acc_env.name }}
          package_feed: ${{ variables.package_feed }}
          package_name: ${{ variables.package_name }}
          package_version: ${{ parameters.acc_env.package_version }}
          service_dir: ${{ variables.service_dir }}
          host: ${{ parameters.acc_env.host }}
          username: ${{ parameters.acc_env.username }}
          password: '$(deploy_user_password)'

  - job: DeployToPrd
    displayName: 'Deploy to ${{ parameters.prd_env.name }}'
    pool:
      name: ${{ variables.agent_pool_name }}
    steps:
      - task: AzureKeyVault@2
        displayName: 'Retrieve secrets from PRD Key Vault'
        inputs:
          azureSubscription: ${{ parameters.prd_env.subscription }}
          KeyVaultName: ${{ parameters.prd_env.vaultName }}
          SecretsFilter: '*'
          RunAsPreJob: true

      - template: deploy-template.yaml
        parameters:
          environment: ${{ parameters.prd_env.name }}
          package_feed: ${{ variables.package_feed }}
          package_name: ${{ variables.package_name }}
          package_version: ${{ parameters.prd_env.package_version }}
          service_dir: ${{ variables.service_dir }}
          host: ${{ parameters.prd_env.host }}
          username: ${{ parameters.prd_env.username }}
          password: '$(deploy_user_password)'

```


### deploy-template.yaml
```yaml
parameters:
  - name: environment
    type: string
  - name: package_name  # ${{ parameters.package_name }}
    type: string
  - name: package_version  # ${{ parameters.package_version }}
    type: string
  - name: host
    type: string
  - name: username
    type: string
  - name: password
    type: string
  - name: service_dir
    type: string
  - name: package_feed
    type: string


steps:
  - checkout: self
    clean: true

  - task: WinRM@2
    displayName: 'Copy Files to Remote Server'
    inputs:
      ConnectionType: 'WinRM'
      TargetMachines: '${{ parameters.host }}'
      RunAsPreJob: true
      PreCommand: 'New-Item -Path "${{ parameters.service_dir }}" -ItemType "directory" -Force'
      Files: '$(Build.SourcesDirectory)/RepositoryFiles/*'
      WinRMProtocol: 'Http'
      UserName: '${{ parameters.username }}'
      Password: '${{ parameters.password }}'

  - task: UniversalPackages@0
    displayName: 'Download Package'
    inputs:
      feedsToUse: 'select'
      packageDownloadOptions: 'single'
      downloadDirectory: '$(Build.ArtifactStagingDirectory)/Package'
      packageFeed: '${{ parameters.package_feed }}'
      packageName: '${{ parameters.package_name }}'
      packageVersion: '${{ parameters.package_version }}'

  - task: WinRM@2
    displayName: 'Upload Package to Remote Server'
    inputs:
      ConnectionType: 'WinRM'
      TargetMachines: '${{ parameters.host }}'
      RunAsPreJob: true
      PreCommand: 'New-Item -Path "${{ parameters.service_dir }}" -ItemType "directory" -Force'
      Files: '$(Build.ArtifactStagingDirectory)/Package/*'
      WinRMProtocol: 'Http'
      UserName: '${{ parameters.username }}'
      Password: '${{ parameters.password }}'

  - task: WinRM@2
    displayName: 'Install and Start Service'
    inputs:
      ConnectionType: 'WinRM'
      TargetMachines: '${{ parameters.host }}'
      RunAsPreJob: true
      PreCommand: |
        $serviceName = 'MyService'
        $servicePath = '${{ parameters.service_dir }}/${{ parameters.package_name }}.exe'
        $configPath = '${{ parameters.service_dir }}/${{ parameters.package_name }}.config'

        # Stop and remove existing service
        sc.exe stop $serviceName
        sc.exe delete $serviceName

        # Install new service
        sc.exe create $serviceName binPath= "$servicePath --config $configPath" start= auto

        # Start the service
        sc.exe start $serviceName

        # Verify service status
        $serviceStatus = Get-Service $serviceName
        if ($serviceStatus.Status -eq 'Running') {
          Write-Host "Service '$serviceName' is running."
        } else {
          throw "Service '$serviceName' failed to start."
        }
      WinRMProtocol: 'Http'
      UserName: '${{ parameters.username }}'
      Password: '${{ parameters.password }}'

```