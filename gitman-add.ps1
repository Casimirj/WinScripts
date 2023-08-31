 # Function to check if a file contains any ignored text
 function IsIgnored($fileContent, $ignoredText) {
     foreach ($text in $ignoredText) {
         if ($fileContent -like "*$text*") {
             return $true
         }
     }
     return $false
 }

 # Function to read the ignored text from .gitmanignore file
 function GetIgnoredText($ignoreFilePath) {
     if (Test-Path -Path $ignoreFilePath) {
         return Get-Content -Path $ignoreFilePath
     }
     return @()
 }

 # Main script
 $ignoreFile = '.gitmanignore'
 $ignoredText = GetIgnoredText $ignoreFile

 # Get the list of changes
 $changes = git diff --name-only

 echo $changes

 foreach ($change in $changes) {
     # Read the content of the file
     $fileContent = Get-Content -Path $change -Raw

     # Check if the file contains ignored text
     if (IsIgnored $fileContent $ignoredText) {
         Write-Host "Skipped: $change (contains ignored text)"
         continue
     }

     # Prompt user to stage the change
     $prompt = Read-Host "Stage change: $change (y/n)"
     if ($prompt -eq 'y') {
         git add $change
         Write-Host "Staged: $change"
     }
     else {
         Write-Host "Skipped: $change"
     }
 }
