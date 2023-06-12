# Load Test URL

This set of files enables you to run a load test on a target URL using Azure Pipelines. It includes the following files:

- `azure-pipeline.yaml`: Azure Pipeline configuration file that triggers the load test on the ACC and PRD environments.
- `load-test-pipeline.yaml`: Template file containing the steps for running the load test.
- `test-script.yaml`: Load test configuration file specifying the target URL and endpoints to simulate.

By providing the target URL and endpoints, the pipeline will execute the load test and generate results, which can be
published as a pipeline artifact.

### `azure-pipeline.yaml`

```yaml
trigger:
  branches:
    include:
      - master

variables:
  - name: accTargetUrl
    value: "http://acc-target-url.com"
  - name: prdTargetUrl
    value: "http://prd-target-url.com"
  - name: endpoint1
    value: "/api/endpoint1"
  - name: endpoint2
    value: "/api/endpoint2"

jobs:
  - job: RunLoadTestOnACC
    displayName: "Run Load Test on ACC"
    pool:
      vmImage: "ubuntu-latest"
    steps:
      - template: load-test-pipeline.yaml
        parameters:
          targetUrl: ${{ variables.accTargetUrl }}
          endpoint1: ${{ variables.endpoint1 }}
          endpoint2: ${{ variables.endpoint2 }}

  - job: RunLoadTestOnPRD
    displayName: "Run Load Test on PRD"
    dependsOn: RunLoadTestOnACC
    condition: succeeded('RunLoadTestOnACC')
    pool:
      vmImage: "ubuntu-latest"
    steps:
      - template: load-test-pipeline.yaml
        parameters:
          targetUrl: ${{ variables.prdTargetUrl }}
          endpoint1: ${{ variables.endpoint1 }}
          endpoint2: ${{ variables.endpoint2 }}
```

### `load-test-pipeline.yaml`

```yaml
parameters:
  - name: targetUrl
    type: string
  - name: endpoint1
    type: string
  - name: endpoint2
    type: string

steps:
  - checkout: self

  - task: Cache@2
    displayName: "Cache npm modules"
    inputs:
      key: "npm | $(Agent.OS) | package-lock.json"
      restoreKeys: |
        npm | $(Agent.OS)
        npm

  - script: npm install -g artillery
    displayName: "Install Artillery"

  - task: ReplaceTokens@3
    displayName: "Replace tokens in test-script.yml"
    inputs:
      targetFiles: "**/test-script.yaml"
      inlineVariables:
        targetUrl: ${{ parameters.targetUrl }}
        endpoint1: ${{ parameters.endpoint1 }}
        endpoint2: ${{ parameters.endpoint2 }}

  - script: cat test-script.yml
    displayName: "Show Load Test - test-script.yaml"

  - script: artillery run test-script.yaml
    displayName: "Run Load Test - ${{ parameters.targetUrl }}"

  - task: PublishPipelineArtifact@1
    displayName: "Publish Load Test results"
    inputs:
      targetPath: $(System.DefaultWorkingDirectory)
      artifact: "load-test-results"
      publishLocation: "pipeline"
      artifactName: "LoadTestResults"

```

### test-script.yaml

Description: Load Test against the target URL with two endpoints.
Users: 100 virtual users.
Requests: Each virtual user makes GET requests to both Endpoint 1 and Endpoint 2.
Duration: 600 seconds (10 minutes).
Phases:
Ramp-up: 300 seconds, gradually increasing from 10 to 100 virtual users.
Sustained: 300 seconds, maintaining 100 virtual users.
Ramp-down: 300 seconds, gradually decreasing from 100 to 10 virtual users.

```yaml
config:
  target: "$(targetUrl)"  # Replace with your target URL

  reporters:
    - json
    - html

scenarios:
  - name: "Load Test against $(targetUrl)"
    flow:
      - get:
          url: "/$(endpoint1)"
          name: "Endpoint $(endpoint1)"
      - get:
          url: "/$(endpoint2)"
          name: "Endpoint $(endpoint2)"

    arrivalRate: 100  # Number of virtual users
    maxDuration: 600  # Duration of the load test in seconds
    phases:
      - duration: 300  # Ramp-up period in seconds
        arrivalRate: 10  # Number of virtual users to increase
      - duration: 300  # Sustained period in seconds
        arrivalRate: 100  # Number of virtual users to sustain
      - duration: 300  # Ramp-down period in seconds
        arrivalRate: 10  # Number of virtual users to decrease per second
```


### `endurance-test-script.yaml`

Description: Endurance Test against the target URL with two endpoints.
Users: 50 virtual users.
Requests: Each virtual user makes GET requests to both Endpoint 1 and Endpoint 2.
Think Time: Randomized think time between requests (1-2 seconds).
Duration: 3600 seconds (1 hour).
Phases:
Ramp-up: 1800 seconds, gradually increasing from 10 to 200 virtual users.
Sustained: 1800 seconds, maintaining 200 virtual users.

```yaml
config:
  target: "$(targetUrl)"  # Replace with your target URL

  reporters:
    - json
    - html

scenarios:
  - name: "Endurance Test against $(targetUrl)"
    flow:
      - get:
          url: "/$(endpoint1)"
          name: "Endpoint $(endpoint1)"
          think: "1-2"  # Randomized think time between requests
      - get:
          url: "/$(endpoint2)"
          name: "Endpoint $(endpoint2)"
          think: "1-2"  # Randomized think time between requests

    arrivalRate: 50  # Number of virtual users
    maxDuration: 3600  # Duration of the load test in seconds
    phases:
      - duration: 1800  # Ramp-up period in seconds
        arrivalRate: 10  # Number of virtual users to increase
      - duration: 1800  # Sustained period in seconds
        arrivalRate: 200  # Number of virtual users to sustain
```