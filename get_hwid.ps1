$uuid = (Get-WmiObject Win32_ComputerSystemProduct 2>$null).UUID
if (-not $uuid) {
    $uuid = (wmic csproduct get UUID /value 2>$null |
             Select-String 'UUID=' |
             ForEach-Object { $_.ToString().Replace('UUID=','').Trim() })
}
if (-not $uuid) {
    Write-Error "Could not determine machine UUID."
    exit 1
}
$raw   = 'WIN-' + $uuid.Trim()
$bytes = [System.Text.Encoding]::UTF8.GetBytes($raw)
$hash  = [System.Security.Cryptography.SHA256]::Create().ComputeHash($bytes)
$hex   = ($hash | ForEach-Object { $_.ToString('x2') }) -join ''
Write-Host "Your HWID: $hex"
