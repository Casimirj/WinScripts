$uuid = [guid]::NewGuid()
Write-Host "New UUID: $uuid"
Set-Clipboard "$uuid"
