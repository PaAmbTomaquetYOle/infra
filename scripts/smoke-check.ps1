$ErrorActionPreference = "Stop"

function Assert-JsonHealth {
    param(
        [string]$Name,
        [string]$Url,
        [string]$ExpectedStatus = "ok"
    )

    $response = Invoke-RestMethod -Uri $Url -TimeoutSec 10
    if ($response.status -ne $ExpectedStatus) {
        throw "$Name health check failed. Expected status '$ExpectedStatus' but got '$($response.status)'."
    }

    Write-Host "$Name ok -> $Url"
}

Assert-JsonHealth -Name "backend" -Url "http://localhost:8001/api/v1/health"
Assert-JsonHealth -Name "mcp-server" -Url "http://localhost:8000/health"
Assert-JsonHealth -Name "slack-agent" -Url "http://localhost:3000/health"

Write-Host "BrainTrust infra smoke checks passed."
