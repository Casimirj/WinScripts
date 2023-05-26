$untrackedFiles = git ls-files --others --exclude-standard

if ($untrackedFiles) {
    foreach ($file in $untrackedFiles) {
        Write-Host "$file" -ForegroundColor "Green"
        $response = Read-Host "Do you want to add the file to the commit? (Y/N)"

        if ($response -eq 'Y' -or $response -eq 'y') {
            git add $file
        }
    }
} else {
    Write-Host "No untracked files found."
}
