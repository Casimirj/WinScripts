param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$FileName
)

$KatePath = "C:\Program Files\Kate\bin\kate.exe"

if (Test-Path $FileName) {
    Start-Process -FilePath $KatePath -ArgumentList $FileName
}
else {
    Write-Host "File not found: $FileName"
    $response = Read-Host "Do you want to create it? (Y/N)"

    if ($response -eq 'Y' -or $response -eq 'y') {
        ni $FileName
        Start-Process -FilePath $KatePath -ArgumentList $FileName
    }
}
