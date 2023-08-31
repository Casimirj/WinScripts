param (
	[string]$action = "", #you dont have to specify -a or -action, it will automatically fill in this
	[string]$a="", #also action

	[string]$base_branch = "", # branch with the bug/whatever.
	[string]$bb = "",

	[string]$jira_issue= "", #ticket number or jira link (determines changes branch name)
	[string]$ji= "",

	[string]$message="",
	[string]$m="", #also message

	[string]$dev_branch = "", # branch off in last step
	[string]$db = "",

	[string]$bypass_prefix = "", # this is for use by other tools
	[string]$bp = ""              # if you use this make sure to set $base_branch


)

$default_dev_branch = "develop"
$accent_color="Blue"
# You can pick from a list of available colors here:
# 		https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/write-host?view=powershell-7.3#parameters




function get_jira_id {
	param (
		[string]$ticket_link
	)
	if(!$ticket_link){

		$ticket_link= Read-Host -Prompt "Enter the link to the Jira Story, or its story ID"
	}
   $jira_id =  ("$ticket_link" | Select-String '\w{2,4}-\d*' | Select-Object -ExpandProperty Matches -First 1)

	return $jira_id
}

function get_nonnull_val {
	param (
		[string]$val_1,
		[string]$val_2
	)
	if("$val_1"){
		return "$val_1"
	}
	elseif("$val_2"){
		return "$val_2"
	}
	else{
		return ""
	}
}

function is_affirmative_response {
	param (
		[string] $input_resp
	)
	$processed_input = $input_resp.ToLower().Trim()
	return (($processed_input -eq 'y') `
		-or ($processed_input -eq 'yes') `
		-or ($processed_input -eq 'yee') `
		-or ($processed_input -eq 'yeah') `
		-or ($processed_input -eq 'yea') `
		-or ($processed_input -eq 'si') `
		-or ($processed_input -eq 'roger') `
		-or ($processed_input -eq 'da') `
		-or ($processed_input -eq 'haan') `
		-or ($processed_input -eq 'sure') `
		-or ($processed_input -eq 'usre') `
		-or ($processed_input -eq 'absofruitly'))
}



$action = get_nonnull_val -val_1 "$action" -val_2 "$a"
$message = get_nonnull_val -val_1 "$message" -val_2 "$m"
$jira_issue = get_nonnull_val -val_1 "$jira_issue" -val_2 "$ji"
$base_branch = get_nonnull_val -val_1 "$base_branch" -val_2 "$bb"
$dev_branch = get_nonnull_val -val_1 "$dev_branch" -val_2 "$db"
$dev_branch = get_nonnull_val -val_1 "$dev_branch" -val_2 "$default_dev_branch"
$bypass_prefix = get_nonnull_val -val_1 "$bypass_prefix" -val_2 "$bp"





Switch ($action){
	get-dev-env {
		$branch_prefix = ""

		if (!$bypass_prefix){
			$is_hotfix = Read-Host "Is this a Hotfix?"
			if (is_affirmative_response -input "$is_hotfix") {
			    $branch_prefix="hotfix"
			}
			else{
				$after_code_freeze = Read-Host "Is this a bug found after code freeze?"
				if (is_affirmative_response -input "$after_code_freeze") {
				    $branch_prefix="hotfix"
				}
				else{
					$is_subtask = Read-Host "Is this a subtask?"
					if (is_affirmative_response -input $is_subtask) {
						$branch_prefix = "subtask"
					}
					else{
						$branch_prefix="feature"
						$base_branch="$default_dev_branch"
					}
				}
			}
		}
		else{
			$branch_prefix=$bypass_prefix
		}



		if(!$base_branch ){
			$base_branch= Read-Host -Prompt "Enter name of the RC/Base Branch"
		}

		$jira_id = get_jira_id -ticket_link "$jira_issue"



		$new_branch_name = "$branch_prefix/$jira_id"

		if($branch_prefix -eq "hotfix"){
			$new_branch_name = "$new_branch_name"
		}

		Write-host "Creating Branch: $new_branch_name From Branch: $base_branch" -ForegroundColor "$accent_color"

		git checkout "$base_branch"
		git fetch
		git pull
		git checkout -b "$new_branch_name"
		git push
		git checkout "$new_branch_name"

		Write-host "Now do your magic and run 'apply-fix'" -ForegroundColor "$accent_color"
	}


	apply-changes {
		$current_branch = git rev-parse --abbrev-ref HEAD

		if(!$current_branch){
			$jira_id = get_jira_id -ticket_link "$jira_issue"
		}
		else{ 
			#this extracts the jira id from the branch name
			#just so it doesnt annoy the user with questions
			$jira_id = get_jira_id -ticket_link "$current_branch"
		}
		if(!$jira_id){
			$jira_id = get_jira_id -ticket_link "" #forces prompt

		}
		

		if(!$message){
			$message= Read-Host -Prompt "Enter a message for the commit"
		}

		$message = "$jira_id $message".Replace("`"","").Replace("`'","")


		Write-host "Stashing, reapplying, committing, and pushing!" -ForegroundColor "$accent_color"
		Write-host "Message: $message" -ForegroundColor "$accent_color"

		git stash --keep-index -m "$message"
		# git stash save "$message"
		git stash apply
		git commit -m "$message"
		git push
	}


	apply-fix-to-develop { 
		$branch_prefix = ""


		if (!$bypass_prefix){
			$is_hotfix = Read-Host "Is this a Hotfix? "
			if (is_affirmative_response -input "$is_hotfix") {
			    $branch_prefix="hotfix"
			}
			else{
				$after_code_freeze = Read-Host "Is this a bug found after code freeze?"
				if (is_affirmative_response -input $after_code_freeze) {
				    $branch_prefix="hotfix"
				}
				else{
					$is_subtask = Read-Host "Is this a subtask?"
					if (is_affirmative_response -input $is_subtask) {
						$branch_prefix = "subtask"
					}
					else{
						$branch_prefix="feature"
						$base_branch="$default_dev_branch"
					}

					Write-Host "You should skip apply-fix-to-develop for features/subtasks" -ForegroundColor "Red"
					exit(0)
				}
			}

		}
		else{
			$branch_prefix=$bypass_prefix
		}


		if(!$base_branch ){
			$base_branch= Read-Host -Prompt "Enter name of the RC/Base Branch"
		}

		$jira_id = get_jira_id -ticket_link "$jira_issue"
		$new_branch_name = "$branch_prefix/$jira_id-Dev"

		if(!$message){
			$message= Read-Host -Prompt "Enter a message for the commit"
		}
		$message = "$jira_id $message".Replace("`"","").Replace("`'","")

		Write-host "Checking out $dev_branch and Creating $new_branch_name" -ForegroundColor "$accent_color"
 
		git checkout "$dev_branch"

		git fetch
		git pull

		git checkout -b "$new_branch_name"

		git commit -m "$message"
		git push
	}

	status {
		git status -sb
	}

	update {
		git fetch
		git pull
	}


	stash-staged {
		git stash --keep-index
		# git stash save
	}
	stash-list {
		git stash list | grep "$(git rev-parse --abbrev-ref HEAD)"
	}
	add {
		git add -p
	}

	clean {
		git clean -di
	}

	add-untracked {
		$untrackedFiles = git ls-files --others --exclude-standard

		if ($untrackedFiles) {
			foreach ($file in $untrackedFiles) {
			 if (!$file.Contains(".json")) {
				Write-Host "$file" -ForegroundColor "Green"
				$response = Read-Host "Do you want to add the file to the commit? (Y/N)"
				if ($response -eq 'Q' -or $response -eq 'q') {
					exit 0
				}

				if ($response -eq 'Y' -or $response -eq 'y') {
					git add $file
				}
			}
			}
		} else {
			Write-Host "No untracked files found."
		}
	}


	default {
		Write-host "GitMan: Defender of Repositories, Keeper of the Sacred Code Flow" -ForegroundColor "$accent_color"
		echo ""
		Write-host ACTIONS: -ForegroundColor "$accent_color"
		echo "    get-dev-env                - (Step 1) Creates a branch from the base branch"
		echo "    apply-changes              - (Step 2) Creates commit for branch that we developed on"
		echo "    apply-fix-to-develop       - (Step 3) Applies fix to Develop, NOT needed if base_branch is develop"
		echo ""
		echo "    status                     - Less noisy status command"
		echo "    stash-staged               - Stashes only staged files"
		echo "    update                     - Git fetch and pull"
		echo "    add                        - Interactively stage files"
		echo ""
		Write-host "OPTIONS -- Passing these avoids a prompt for it later" -ForegroundColor "$accent_color"
		echo "    -a, -action                - Specifies the Action (Required)"
		echo "    -m, -message               - Specifies a commit message (Optional)"
		echo "    -bb, -base_branch          - Base branch (Optional, if /feature base_branch defaults to develop)"
		echo "    -ji, -jira_issue           - Either the branch name or the jira ticket (Optional)"
		echo "    -db, -dev_branch           - Final branch to merge into (Optional, Default develop)"
		echo ""
	}





}
