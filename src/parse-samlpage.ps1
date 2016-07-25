#   This Source Code Form is subject to the terms of the Mozilla Public
#   License, v. 2.0. If a copy of the MPL was not distributed with this
#   file, You can obtain one at http://mozilla.org/MPL/2.0/.

function ParseSamlPage($samlPage)
{
    try
    {
        $assertion = $samlPage.InputFields.Find('SAMLResponse').Value
        $samlXml = GetSamlXml $assertion
        $roles = GetRolesFromSamlXml $samlXml
        return @{
            Assertion = $assertion;
            Roles = $roles;
        }
    }
    catch
    {
        Throw 'Invalid SAML Page'
    }
}


function GetSamlXml($samlString)
{
    return [XML] [System.Text.Encoding]::UTF8.GetString(  [System.Convert]::FromBase64String($samlString))
}

function GetRolesFromSamlXml($samlXml)
{
    $roles =  @()
    $rolesAttribute = $samlXml.Response.Assertion.AttributeStatement.Attribute | `
        Where-Object {$_.Name -eq 'https://aws.amazon.com/SAML/Attributes/Role'}

    $rolesAttribute.AttributeValue | Foreach-Object {
        $roles +=  @{
            Principal = $_.split(',')[0];
            Role = $_.split(',')[1];
        }
    }

    return $roles
}
