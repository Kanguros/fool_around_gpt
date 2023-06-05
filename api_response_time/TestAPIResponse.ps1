$baseUrl = "$(baseUrl)"
$endpoints = "$(endpoints)"

$results = @()

foreach ($endpoint in $endpoints) {
  $totalTime = 0
  $successCount = 0

  for ($i = 1; $i -le 100; $i++) {
    $url = $baseUrl + $endpoint
    $responseTime = Measure-Command { Invoke-WebRequest -Uri $url } | Select-Object -ExpandProperty TotalMilliseconds
    $totalTime += $responseTime

    if ($LASTEXITCODE -eq 0) {
      $successCount++
    }
  }

  $averageTime = $totalTime / $successCount

  $result = [PSCustomObject]@{
    Endpoint = $endpoint
    Requests = 100
    SuccessCount = $successCount
    AverageResponseTime = $averageTime
  }

  $results += $result
}

$results | Export-Csv -Path "results.csv" -NoTypeInformation
