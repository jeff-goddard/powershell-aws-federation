#   This Source Code Form is subject to the terms of the Mozilla Public
#   License, v. 2.0. If a copy of the MPL was not distributed with this
#   file, You can obtain one at http://mozilla.org/MPL/2.0/.

. "$PSScriptRoot/iniformat.ps1"

function GetAwsFederationConfig($path)
{
    try
    {
        $configContents = convertFromIniFormat $(Get-Content -Raw $path) 
    }
    catch{
        $configContents = @{
            AwsFederationConfig = @{
                Default = '';
                FederationUri = 'http://adfs.example.com/adfs/ls/IdpInitiatedSignOn.aspx?loginToRp=urn:amazon:webservices';
                OutputFormat = 'json';
                Region = 'eu-west-1';
            };
        }
    }
    getConfigObjectFromConfgFile($configContents);
}

function SetAwsFederationConfig($config, $path)
{
    $config = getConfigFileFromConfigObject $config
    
    writeIniFileWithoutBom $path $config

}


function GetProfile($config, $profileName)
{
    return $config.Profiles | Where-Object {$_.name -eq $profileName}    
}

function getConfigFileFromConfigObject($configObject)
{
    $config = [ordered] @{
        AwsFederationConfig =[ordered] @{
            Default = $configObject.Default;
            FederationUri  = $configObject.FederationUri;
            OutputFormat = $configObject.OutputFormat;
            Region = $configObject.Region;
        };
    }

     $configObject.Profiles | Foreach-Object {
        $config[$_.Name] = [ordered] @{
            Principal = $_.Principal;
            Role = $_.Role;
        }
    }

    return $config
}

function getConfigObjectFromConfgFile($config)
{

    $configObject = [ordered]  @{
        Default = $configContents.AwsFederationConfig.Default;
        FederationUri  = $configContents.AwsFederationConfig.FederationUri;
        OutputFormat = $configContents.AwsFederationConfig.OutputFormat;
        Region  = $configContents.AwsFederationConfig.Region;
        Profiles = @();
    }

    $config.Keys |
        Where-Object {$_ -ne 'AwsFederationConfig' } |
        Foreach-Object {
            $configObject.Profiles += @{
                Name = $_;
                Principal = $config[$_].Principal;
                Role = $config[$_].Role;
            }
        }
    return $configObject
}
