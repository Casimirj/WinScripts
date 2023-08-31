param(
    [Parameter(HelpMessage="Generates json data")]
    [switch]$jsondata = $False,
    [Parameter(HelpMessage="Generates pgsql data")]
    [switch]$sqldata = $False,
    [Parameter(HelpMessage="Generates moar pgsql data")]
    [switch]$moresql = $False
)




if ($jsondata){

    $prompt="as a software developer with over 20 years experience, with experience in validation and data generation write me some json test data for a rest endpoint. All fields that specify id should be filled in with a valid guid. All dates should be filled in with a random date between now and 3 years ago. The data should be in valid json format, without syntax errors. Here is the definition to create the test data out of: "

    write-host "Please enter the json definition"
    $data = while (1) { read-host | set r; if (!$r) {break}; $r}

    write-host "Got it! Thinking..."

    $data = $data.replace('"', "'")
    gpt "$prompt $data"

}



if ($sqldata){

    $prompt="as a software developer with over 20 years experience, with experience in validation and data generation write me a pgsql insert query with 1 test entries. All fields that specify id should be filled in with the custom pgsql function gen_random_uuid(), All dates should be filled in with a random day between now and 3 years ago, with a unique month/day. The insert query should be in valid pgsql format, without syntax errors. Here is the definition to create the test data out of: "

    write-host "Please enter the table definition"
    $data = while (1) { read-host | set r; if (!$r) {break}; $r}

    write-host "Got it! Thinking..."

    $data = $data.replace('"', "'")
    gpt "$prompt $data"

}


if ($moresql){

    $prompt="as a software developer with over 20 years experience, with experience in validation and data generation take this pgsql insert query and expand it to 4 test entries. All fields that specify id should be filled in with the custom pgsql function gen_random_uuid(), Please use random names from popular pieces of childrens fiction.  All dates should be filled in with a random day between now and 3 years ago, with a unique month/day. The insert query should be in valid pgsql format, without syntax errors. Here is the definition to create the test data out of: "

    write-host "Please enter the sql insert query"
    $data = while (1) { read-host | set r; if (!$r) {break}; $r}

    write-host "Got it! Thinking..."

    $data = $data.replace('"', "'")
    gpt "$prompt $data"

}
