#   This Source Code Form is subject to the terms of the Mozilla Public
#   License, v. 2.0. If a copy of the MPL was not distributed with this
#   file, You can obtain one at http://mozilla.org/MPL/2.0/.

function GetCredentials($assertion, $profileObject) 
{    
    $credentials = InvokeAwsCommand -arguments ('sts', 
         'assume-role-with-saml',
        '--role-arn',  $profileObject.Role,
        '--principal-arn', $profileObject.Principal, 
        '--saml-assertion', $assertion, 
        '--output', 'json') |
        Out-String |
        ConvertFrom-Json
    
    return $credentials.Credentials;
}
