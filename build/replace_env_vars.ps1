echo "Running windows replace vars"
foreach ($configFile in Get-Content $args[0])
{
    echo "replacing environment variables"
    $configAndDir = -join($args[2], "/", $configFile);
    echo $configAndDir
    foreach ($line in Get-Content $args[1])
    {
        $split = $line -split '=', 2
        $key = -join("\$\{", $split[0], "\}");
        $value = $split[1]

        (Get-Content $configAndDir) -replace $key, $value | Set-Content $configAndDir
    }
}