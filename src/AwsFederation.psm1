#   This Source Code Form is subject to the terms of the Mozilla Public
#   License, v. 2.0. If a copy of the MPL was not distributed with this
#   file, You can obtain one at http://mozilla.org/MPL/2.0/.

. "$PsScriptRoot/aws-config.ps1"
. "$PsScriptRoot/awsfederation-config.ps1"
. "$PsScriptRoot/get-credentials.ps1"
. "$PsScriptRoot/get-samlpage.ps1"
. "$PsScriptRoot/invoke-awscommand.ps1"
. "$PsScriptRoot/parse-samlpage.ps1"


function Set-AwsFederationConfig 
{
    <#
    .Synopsis
        Creates a configuration file for the AwsFederation module

    .Description
        Validates using the AWS Federation uri provided, and saves a configruation file at ~\.aws\aws-federation.config

    .Parameter Uri
        Specifies the AWS Federation uri for your organisation.
    #>
    
    [CmdLetBinding()]
    
    Param(
        [Parameter(Mandatory=$True)]
        [string] $Uri
    )
 
    $config = getConfig 
    $config.FederationUri = $uri;
    
    $samlPage = GetSamlPage $uri
    $samlObject = ParseSamlPage $samlPage
    
    $region = Read-Host "Default Region [$($config.Region)]" 
    if( $region -ne '')
    {
        $config.Region = $region
    }
    
    $format = Read-Host "Default Output Format [$($config.OutputFormat)]" 
    if( $format -ne '')
    {
        $config.OutputFormat = $format
    }
    
    $samlObject.Roles | Foreach-Object {
        $name = Read-Host "Friendly name for " + $_.Role
        $config.Profiles += @{
            Name = $name;
            Principal = $_.Principal;
            Role = $_.Role
        }
    }
    
    $default = Read-Host "Default Profile [$($config.Profiles[0].Name)]" 
    if( $default -ne '')
    {
        $config.Default = $default
    }
    else {
        $config.Default = $($config.Profiles[0].Name)
    }
    
    SetAwsFederationConfig $config $(configFilePath)
}


function Get-AwsFederationCredentials
{
    <#
    .Synopsis
        Returns an Aws Credentials object for the given profile

    .Description
        Returns an Aws Credentials object for the given profile

    .Parameter Prifile
        Specifies the name of the AWS profile to use
    #>
    
    [CmdletBinding()]
    
    Param(
        [String] $ProfileName 
    )

    $config = getConfig 
    $profileName = getProfileName $config $ProfileName
    $profileObject = GetProfile $config $profileName
    
    if($profileObject -eq $null)
    {
        throw "Unknown profile"
    }

    $awsConfig = getAwsConfigFromFile
    $credentials = GetAwsCredentials $awsConfig  $profileName

    if($credentials -eq $null  -or $credentials.Expiration -lt [DateTime]::Now.AddMinutes(2))
    {
        $samlPage = GetSamlPage $config.FederationUri
        $samlObject = ParseSamlPage $samlPage    
        $credentials = getCredentials $samlObject.Assertion $profileObject
        SetAwsConfig $profileName  $credentials $config $(awsConfigFilePath)
    }

    $env:AWS_CONFIG_FILE = $(awsConfigFilePath)
}

function Invoke-AwsFederationWrapper
{
    <#
    .Synopsis
        Calls aws.exe after calling Get-AwsFederationCredentials
    #>
    
    $profileName = ''
    foreach($i in 0..$args.length)
    {
        if($args[$i] -eq '--profile')
        {
            $profileName = $args[$i+1]
            break;
        }
    }
    
    Get-AwsFederationCredentials -Profile $profileName
    InvokeAwsCommand $args
} 

Set-Alias awswrapper Invoke-AwsFederationWrapper

Export-ModuleMember -Function "*"
Export-ModuleMember -Variable "*"
Export-ModuleMember -Alias "*"

function configFilePath 
{    
    return Join-Path $([Environment]::GetFolderPath("userprofile")) '.aws/aws-federation.config'
}

function getConfig()
{
    return  GetAwsFederationConfig $(configFilePath)
}


function awsConfigFilePath 
{
    return Join-Path $([Environment]::GetFolderPath("userprofile")) '.aws/federated.config'
}

function getAwsConfigFromFile()
{
    return  GetAwsConfig $(awsConfigFilePath)
}


function getProfileName($config, $profileName)
{
    if( -not $profileName) 
    {
        $profileName = $config.Default
    }
    
    return $profileName
}
