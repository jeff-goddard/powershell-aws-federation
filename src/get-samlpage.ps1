#   This Source Code Form is subject to the terms of the Mozilla Public
#   License, v. 2.0. If a copy of the MPL was not distributed with this
#   file, You can obtain one at http://mozilla.org/MPL/2.0/.

function GetSamlPage($uri)
{
    $externalCommand = $null

    try
    {
        $externalCommand = Get-Command 'Invoke-CustomFederatedAwsLogin' 2> $null
    }
    catch
    {
        $externalCommand = $null
    }

    if($externalCommand)
    {
            return Invoke-CustomFederatedAwsLogin $uri
    }
    else
    {
        $response = Invoke-WebRequest -Uri $uri -UseDefaultCredentials -TimeoutSec 120
        return $response.ParsedHtml
    }
}
