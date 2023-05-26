

. Set-Window.ps1
. Stop-Processes.ps1
. ./Startup/GlobalData.ps1





$test = Start-Job -ScriptBlock {. C:/Tools/Startup/StartJiggler.ps1}
sleep 3
$test | Select-Object -Property *

# . ./Startup/StartSlack.ps1


# taskmgr