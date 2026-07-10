param(
    [switch]$Build
)

$ErrorActionPreference = "Stop"

$args = @("compose", "up", "-d")
if ($Build) {
    $args += "--build"
}

Write-Host "Starting BrainTrust infra stack..."
docker @args
