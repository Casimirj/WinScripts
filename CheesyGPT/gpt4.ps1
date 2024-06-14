$projectPath = "C:\Tools\CheesyGPT"

$current_dir = $(pwd)
$venvPath = "$projectPath\venv\Scripts"
$pythonPath = "$venvPath\Scripts\python.exe"

cd $venvPath
.\Activate.ps1
cd $current_dir

try {
    python $projectPath\CheesyGPT.py  "gpt-4-turbo" "$args[0]"
}
catch {
}
finally {
    cd $venvPath
    deactivate
    cd $current_dir
}


