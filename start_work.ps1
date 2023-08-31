
param (
    [Parameter(Mandatory=$true, Position=0)]
	[string]$branch_name = ""

)
git stash push

git checkout develop
git fetch
git pull
git clean -f

git checkout -b $branch_name
