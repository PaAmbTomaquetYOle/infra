$ErrorActionPreference = "Stop"

function Assert-JsonHealth {
    param(
        [string]$Name,
        [string]$Url,
        [string]$ExpectedStatus = "ok",
        [int]$Retries = 30,
        [int]$DelaySeconds = 2
    )

    for ($attempt = 1; $attempt -le $Retries; $attempt++) {
        try {
            $response = Invoke-RestMethod -Uri $Url -TimeoutSec 10
            if ($response.status -eq $ExpectedStatus) {
                Write-Host "$Name ok -> $Url"
                return
            }

            throw "$Name health check failed. Expected status '$ExpectedStatus' but got '$($response.status)'."
        }
        catch {
            if ($attempt -eq $Retries) {
                throw
            }

            Write-Host "Waiting for $Name ($attempt/$Retries) -> $Url"
            Start-Sleep -Seconds $DelaySeconds
        }
    }
}

function Assert-TcpPort {
    param(
        [string]$Name,
        [string]$HostName,
        [int]$Port,
        [int]$Retries = 30,
        [int]$DelaySeconds = 2
    )

    for ($attempt = 1; $attempt -le $Retries; $attempt++) {
        $client = [System.Net.Sockets.TcpClient]::new()
        try {
            $connect = $client.BeginConnect($HostName, $Port, $null, $null)
            if ($connect.AsyncWaitHandle.WaitOne([TimeSpan]::FromSeconds(2))) {
                $client.EndConnect($connect)
                Write-Host "$Name ok -> ${HostName}:$Port"
                return
            }

            throw "$Name tcp check timed out."
        }
        catch {
            if ($attempt -eq $Retries) {
                throw
            }

            Write-Host "Waiting for $Name ($attempt/$Retries) -> ${HostName}:$Port"
            Start-Sleep -Seconds $DelaySeconds
        }
        finally {
            $client.Dispose()
        }
    }
}

Assert-JsonHealth -Name "backend" -Url "http://localhost:8001/api/v1/health"
Assert-TcpPort -Name "mcp-server" -HostName "localhost" -Port 8000
Assert-JsonHealth -Name "slack-agent" -Url "http://localhost:3000/health"

Write-Host "BrainTrust infra smoke checks passed."
