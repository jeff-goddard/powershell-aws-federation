#   This Source Code Form is subject to the terms of the Mozilla Public
#   License, v. 2.0. If a copy of the MPL was not distributed with this
#   file, You can obtain one at http://mozilla.org/MPL/2.0/.

. "$PSScriptRoot/iniformat.ps1"

function GetAwsConfig($path)
{
    try
    {
        $config = convertFromIniFormat $(Get-Content -Raw $path 2> $null)
        $config.Values | ForEach-Object {            
            if($_.expiration) {
                 $_.expiration = [DateTime]::Parse($_.expiration)
            }
        }
        return $config
    }
    catch
    {
        return @{}
    } 
}

function SetAwsConfig($name, $credentials, $config, $path)
{
    try
    {
        $configObject = convertFromIniFormat $(Get-Content -Raw $path 2> $null)
        
    }
    catch
    {
        $configObject = [ordered] @{}
    } 
    
    $creds = copyCredentialsToConfigObject $credentials $config
    
    if($name -eq $config.Default)
    {
        $configObject['default'] = $creds
    }
    elseif ($configObject['default'] -eq $null)
    {
        $configObject['default'] =[ordered] @{
            output = $config.OutputFormat;
            region = $config.Region;
        }
    }
    
    $configObject["profile $name"] = $creds
    
    writeIniFileWithoutBom $path $configObject
}

function GetAwsCredentials($config, $name)
{
    try
    {
        return copyCredentialsFromConfigObject($config["profile $name"])
    }
    catch
    {
        return $null    
    }
}


function copyCredentialsFromConfigObject($creds, $config)
{
    if($creds -eq $null)
    {
        return $null
    }
    else 
    {
        return  [ordered] @{
            AccessKeyId = $creds.aws_access_key_id;
            SecretAccessKey = $creds.aws_secret_access_key;
            SessionToken = $creds.aws_session_token;
            Expiration =  $creds.expiration;
        }
    }
    
}


function copyCredentialsToConfigObject($creds, $config)
{   
    return  [ordered] @{
        output = $config.OutputFormat;
        region = $config.Region;
        aws_access_key_id = $creds.AccessKeyId;
        aws_secret_access_key = $creds.SecretAccessKey;
        aws_session_token = $creds.SessionToken;
        expiration = $creds.Expiration.tostring('o')
    }
    
}
