

Stop-Processes -processName "Slack"



$slack = Start-Process $slack_path -PassThru


sleep 10
Set-Window -ProcessName $slack.Name -X 1950 -Y -100 -Passthru