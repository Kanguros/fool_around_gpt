**Pipeline Name: API Response Time Testing**

**Explanation:**
The API Response Time Testing pipeline is a workflow designed to test the response time of API endpoints. It utilizes a PowerShell script to perform the testing and provides the flexibility to specify the base URL of the API and a list of endpoints to test. The pipeline executes the script and saves the results to a CSV file.

**How it Works:**
1. The pipeline receives the following parameters:
   - `baseUrl`: Represents the base URL of the API being tested. It is a string parameter with a default value of "https://api.example.com".
   - `endpoints`: Represents a list of API endpoints to test. It is an object parameter with a default value containing three example endpoints ("/endpoint1", "/endpoint2", and "/endpoint3").
2. The pipeline contains a single job named "TestAPIResponseTime" responsible for running the API response time tests.
3. The job runs on a Windows agent specified by the `vmImage` property set to "windows-latest".
4. Within the job, there is a PowerShell task named "Run API Response Time Test".
5. The PowerShell task executes an inline PowerShell script that performs the following steps:
   - Extracts the values of `baseUrl` and `endpoints` from the pipeline parameters.
   - Initializes an empty array, `$results`, to store the test results.
   - Iterates over each endpoint in the `endpoints` list.
   - For each endpoint, it performs 100 requests by sending HTTP requests to the API using `Invoke-WebRequest`.
   - Measures the response time for each request using `Measure-Command`.
   - Calculates the average response time by dividing the total response time by the number of successful requests.
   - Stores the endpoint's test results, including the endpoint name, number of requests, success count, and average response time, as a custom object in the `$results` array.
   - Finally, it formats the `$results` array as a table and outputs it to the console.
6. Additionally, you will need to modify the script to save the results to a CSV file.

**Example of Use:**
To execute the API Response Time Testing pipeline and obtain response time results for specific API endpoints, follow these steps:

1. Define the desired values for the parameters:
   - `baseUrl`: The base URL of the API you want to test (e.g., "https://api.example.com").
   - `endpoints`: A list of API endpoints to test.

2. Execute the pipeline using your preferred CI/CD platform or automation tool, providing the parameter values. For example:
   ```yaml
   - pipeline: APIResponseTime
     parameters:
       baseUrl: "https://api.example.com"
       endpoints:
         - "/endpoint1"
         - "/endpoint2"
         - "/endpoint3"
   ```

3. The pipeline will run the API response time tests for each specified endpoint.
4. Upon completion, the pipeline will generate a CSV file named "results.csv" containing the response time results for each endpoint.

**Data Results Structure:**
The resulting CSV file will have the following structure:

| Endpoint   | Requests | SuccessCount | AverageResponseTime |
|------------|----------|--------------|---------------------|
| /endpoint1 | 100      | X            | Y                   |
| /endpoint2 | 100      | X            | Y                   |
| /endpoint3 | 100      | X            | Y                   |

- `Endpoint`: The API endpoint that was tested.
- `Requests`: The total number of requests made to the endpoint (always 100 in this case).
- `SuccessCount`: The number of successful requests out of the total requests.
- `AverageResponseTime`: The average

 response time (in milliseconds) for successful requests to the endpoint.

**Example Data Results:**

| Endpoint   | Requests | SuccessCount | AverageResponseTime |
|------------|----------|--------------|---------------------|
| /endpoint1 | 100      | 95           | 150.25              |
| /endpoint2 | 100      | 98           | 75.20               |
| /endpoint3 | 100      | 100          | 50.00               |

These results indicate that for each tested endpoint, 100 requests were made. The `SuccessCount` column shows the number of requests that returned a successful response (HTTP status code 200). The `AverageResponseTime` column represents the average response time for the successful requests to each endpoint.