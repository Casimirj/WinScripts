param (
    [Parameter(Mandatory = $true, Position=0)]
    [string]$inputString
)



# Escape double quotes in the input string

$escapedInputString = $inputString -replace '\\n', "`r`n"

write-output ""
write-output ""
write-output ""
Write-Output $escapedInputString


