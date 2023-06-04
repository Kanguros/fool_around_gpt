## Pull and deploy Go application

#### Pipeline

Write an Azure Pipeline in yaml format. It is placed in repository. It should contains separate stages for ACC and PRD environment, with its own configuration defined in single global parameters as an object type . Each stage should look the same and contains following actions. 

Pull Universal Package which is an Windows executable file type. It name and version is defined in global variables. Upload an exe to a external Windows Server along with its configuration file from repository. Using PowerShell script, copy a repositories' files from directory defined in global variable to a Windows Server's directory defined in global variable. Make it verbose. Upload executable and run it as a Windows Service and verify that service is up and running. Password for the username which is used to login to server is obtained from Azure Key Vault. 

A pipeline itself should be executed on merge to master and whenever a new version of Universal Package is available. Implement caching whenever possible. 

#### Documentation

Based on defined pipeline, Create a workflow documentation in markdown format. Be very verbose and detailed.  Create it graphical workflow representation using mermaid.js as part of documentation. Add example of uses. 

