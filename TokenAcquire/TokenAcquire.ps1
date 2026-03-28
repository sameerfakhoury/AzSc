Write-Host "[x] Azure Token Acquisition" -ForegroundColor Cyan

# creds
$UPN = Read-Host "`nEnter UPN (email)"
$SecurePassword = Read-Host "Enter Password" -AsSecureString
$Password = [System.Net.NetworkCredential]::new("", $SecurePassword).Password

# Extract domain & tenant ID
$Domain = $UPN.Split('@')[1]
Write-Host "`n[*] Resolving Tenant ID for domain: $Domain" -ForegroundColor Yellow
try {
    $TenantId = (Invoke-RestMethod "https://login.microsoftonline.com/$Domain/.well-known/openid-configuration").token_endpoint.Split('/')[3]
    Write-Host "[+] Tenant ID: $TenantId" -ForegroundColor Green
} catch {
    Write-Host "[-] Failed to resolve Tenant ID" -ForegroundColor Red
    exit
}

# Get-ARM
Write-Host "`n[*] Requesting ARM token..." -ForegroundColor Yellow
try {
    $global:token = (Invoke-RestMethod -Method POST `
        -Uri "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token" `
        -Body @{
            client_id  = "04f0c124-f2bc-4f59-8241-bf6df9866bbd"
            scope      = "https://management.azure.com/.default"
            username   = $UPN
            password   = $Password
            grant_type = "password"
        }).access_token
    Write-Host "[+] ARM Token acquired successfully" -ForegroundColor Green
} catch {
    Write-Host "[-] Failed to acquire ARM token: $_" -ForegroundColor Red
    exit
}

# Get-Graph
Write-Host "`n[*] Requesting Graph token..." -ForegroundColor Yellow
try {
    $global:graphToken = (Invoke-RestMethod -Method POST `
        -Uri "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token" `
        -Body @{
            client_id  = "04f0c124-f2bc-4f59-8241-bf6df9866bbd"
            scope      = "https://graph.microsoft.com/.default"
            username   = $UPN
            password   = $Password
            grant_type = "password"
        }).access_token
    Write-Host "[+] Graph Token acquired successfully" -ForegroundColor Green
} catch {
    Write-Host "[-] Failed to acquire Graph token: $_" -ForegroundColor Red
    exit
}

# UPN Store globally
$global:UPN = $UPN
$global:TenantId = $TenantId

# Display tokens
Write-Host "`n"
Write-Host "[x] Token Output" -ForegroundColor Cyan

Write-Host "`n[ARM Token `$token]" -ForegroundColor Magenta
Write-Host $global:token -ForegroundColor White
Write-Host "`n[Graph Token `$graphToken]" -ForegroundColor Magenta
Write-Host $global:graphToken -ForegroundColor White

Write-Host "`n"