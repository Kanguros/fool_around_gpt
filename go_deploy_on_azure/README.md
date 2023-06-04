## Test, build and publish Go package

Develop an Azure Pipeline in yaml format. It should apply to repository with Golang code. 

The pipeline should be triggered on merge to master.

On the global level, define variables and use them later on in pipeline definition

Split it into two jobs. First job named "Test and build" contains 

-   name - A name for the source code.
-   artifact_name - Pipeline artifact name. Same as variable name.
-   artifact_docs - Pipeline artifact with generated documentation.
-   package - Name of the Universal Package.

Implement caching whenever possible. 

**Job 1 - Test and build**:

A job should run on vmImage windows-latest. Add caching if possible. Do linting, validating, security checks,  and and any other checks applicable for Go. you could think of, as a separete tasks. All results publish as pipeline results. Run package tests, publish tests results including coverage as pipeline artifact, compiling source code, publishing compiled code as pipeline artifact, 

**Job 2 - Pull and publish:**

-   Depends on successful execution of previous job. 
-   Only run when on master branch. 

-   Pull artifact published in previous job,
-   Publish artifact as a Universal Package, get package name and feed from global variables

-   build a documentation from source code as markdown, 

-   publish generated documentation as pipelina artifact



Based on defined pipeline, create it graphical workflow representation using mermaid.js.

Create a workflow documentation in markdown format. Be very verbose and detailed. 
