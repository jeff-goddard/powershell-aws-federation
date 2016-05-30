#   This Source Code Form is subject to the terms of the Mozilla Public
#   License, v. 2.0. If a copy of the MPL was not distributed with this
#   file, You can obtain one at http://mozilla.org/MPL/2.0/.

function GetCredentials($assertion, $profileObject, $region) 
{    
    $credentials = Use-STSRoleWithSAML -SAMLAssertion $assertion `
        -RoleArn $profileObject.Role `
        -PrincipalArn $profileObject.Principal `
        -DurationInSeconds 3600 `
        -Region $region `
        -AccessKey 'n/a' `
        -SecretKey 'n/a' `
        -Force
    
    return $credentials.Credentials;
}
