


Stop-Processes -processName "MouseJiggler"


$jiggler = Start-Process $jiggler_path -PassThru


sleep .6
Set-Window -ProcessName $jiggler.Name -X 1950 -Y -100 -Passthru