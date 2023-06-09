param(
    [Parameter(HelpMessage="Generates json data")]
    [switch]$jsondata = $False,
    [Parameter(HelpMessage="Generates pgsql data")]
    [switch]$sqldata = $False
)




if ($jsondata){

    $prompt="as a software developer with over 20 years experience, with experience in validation and data generation write me some json test data for a rest endpoint. All fields that specify id should be filled in with a valid guid. The data should be in valid json format, without syntax errors. Here is the definition to create the test data out of: "

    write-host "Please enter the json definition"
    $data = while (1) { read-host | set r; if (!$r) {break}; $r}

    write-host "Got it! Thinking..."

    $data = $data.replace('"', "'")
    gpt "$prompt $data"

}



if ($sqldata){

    $prompt="as a software developer with over 20 years experience, with experience in validation and data generation write me a pgsql insert query with sample test data. All fields that specify id should be filled in with a valid guid. The insert query should be in valid pgsql format, without syntax errors. Here is the definition to create the test data out of: "

    write-host "Please enter the table definition"
    $data = while (1) { read-host | set r; if (!$r) {break}; $r}

    write-host "Got it! Thinking..."

    $data = $data.replace('"', "'")
    gpt "$prompt $data"

}
