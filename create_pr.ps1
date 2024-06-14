# Create the pull request using the gh CLI
gh pr create --base uat --head "$(git rev-parse --abbrev-ref HEAD)"
