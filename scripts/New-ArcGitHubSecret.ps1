# Run from an interactive PowerShell session with kubectl connected to EKS.
# Creates a new Secret; deliberately fails if github-auth already exists.
$ErrorActionPreference = 'Stop'
$ArcSecureToken = Read-Host 'Paste your GitHub token' -AsSecureString

try {
    $ArcCredential = [System.Net.NetworkCredential]::new('', $ArcSecureToken)
    $ArcPlainToken = $ArcCredential.Password
    if ([string]::IsNullOrWhiteSpace($ArcPlainToken)) {
        throw 'The token cannot be empty.'
    }

    $ArcSecret = @{
        apiVersion = 'v1'
        kind = 'Secret'
        metadata = @{
            name = 'github-auth'
            namespace = 'arc-runners'
        }
        type = 'Opaque'
        stringData = @{ github_token = $ArcPlainToken }
    }
    $ArcSecretJson = $ArcSecret | ConvertTo-Json -Depth 5
    $ArcSecretJson | kubectl create -f -
    if ($LASTEXITCODE -ne 0) {
        throw 'Secret creation failed. Check the kubectl error above.'
    }
}
finally {
    if ($null -ne $ArcSecureToken) { $ArcSecureToken.Dispose() }
    Remove-Variable ArcSecureToken, ArcCredential, ArcPlainToken, ArcSecret, ArcSecretJson -ErrorAction SilentlyContinue
}
