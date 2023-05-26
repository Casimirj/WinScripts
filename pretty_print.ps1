param (
    [Parameter(Mandatory = $true, Position=0)]
    [string]$inputString
)



# Formats JSON in a nicer format than the built-in ConvertTo-Json does.
function Format-Json([Parameter(Mandatory, ValueFromPipeline)][String] $json) {
    $indent = 0;
    ($json -Split "`n" | % {
        if ($_ -match '[\}\]]\s*,?\s*$') {
            # This line ends with ] or }, decrement the indentation level
            $indent--
        }
        $line = ('  ' * $indent) + $($_.TrimStart() -replace '":  (["{[])', '": $1' -replace ':  ', ': ')
        if ($_ -match '[\{\[]\s*$') {
            # This line ends with [ or {, increment the indentation level
            $indent++
        }
        $line
    }) -Join "`n"
}


# Escape double quotes in the input string
$escapedInputString = $inputString -replace '"', '\"'


# Execute the Python script and capture the output
$pythonOutput = python C:\Tools\pretty_print_helper.py $escapedInputString

Write-Output $pythonOutput

# Copy the formatted output to the clipboard
ConvertFrom-Json $inputString | ConvertTo-Json -Depth 100 | Format-Json | Set-Clipboard

