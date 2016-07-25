. ./src/parse-samlpage.ps1

Describe 'ParseSamlPage' {

    It 'Should throw an error if null is passed' {
        {
            ParseSamlPage $null
        } | Should Throw 'Invalid SAML Page'
    }

    It 'Should throw an error if invalid saml page is passed' {
        $page = [pscustomobject] @{InputFields = [pscustomobject] @{}}
        {
            ParseSamlPage $page
        } | Should Throw 'Invalid SAML Page'
    }

    It 'Should return the correct saml object' {
        $page = [pscustomobject] @{InputFields = [pscustomobject] @{}}

        $page.InputFields | Add-Member -Name Find -MemberType ScriptMethod -Value {
            param( [string]$name)
            if($name -eq 'SAMLResponse')
            {
                @{ Value ='PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz4NCjxzYW1scDpSZXNwb25zZSB4bWxuczpzYW1scD0idXJuOm9hc2lzOm5hbWVzOnRjOlNBTUw6Mi4wOnByb3RvY29sIj4NCiAgPEFzc2VydGlvbiAgeG1sbnM9InVybjpvYXNpczpuYW1lczp0YzpTQU1MOjIuMDphc3NlcnRpb24iPg0KICAgIDxBdHRyaWJ1dGVTdGF0ZW1lbnQ+DQogICAgICA8QXR0cmlidXRlIE5hbWU9Imh0dHBzOi8vYXdzLmFtYXpvbi5jb20vU0FNTC9BdHRyaWJ1dGVzL1JvbGVTZXNzaW9uTmFtZSI+DQogICAgICAgIDxBdHRyaWJ1dGVWYWx1ZT50ZXN0ZXJAZXhhbXBsZS5jb208L0F0dHJpYnV0ZVZhbHVlPg0KICAgICAgPC9BdHRyaWJ1dGU+DQogICAgICA8QXR0cmlidXRlIE5hbWU9Imh0dHBzOi8vYXdzLmFtYXpvbi5jb20vU0FNTC9BdHRyaWJ1dGVzL1JvbGUiPg0KICAgICAgICA8QXR0cmlidXRlVmFsdWU+YXJuOmF3czppYW06OjEyMzQ6c2FtbC1wcm92aWRlci90ZXN0LGFybjphd3M6aWFtOjoxMjM0OnJvbGUvdGVzdC1yb2xlMTwvQXR0cmlidXRlVmFsdWU+DQogICAgICAgIDxBdHRyaWJ1dGVWYWx1ZT5hcm46YXdzOmlhbTo6NTY3ODpzYW1sLXByb3ZpZGVyL3Rlc3QsYXJuOmF3czppYW06OjU2Nzg6cm9sZS90ZXN0LXJvbGUyPC9BdHRyaWJ1dGVWYWx1ZT4NCiAgICAgIDwvQXR0cmlidXRlPg0KICAgIDwvQXR0cmlidXRlU3RhdGVtZW50Pg0KICA8L0Fzc2VydGlvbj4NCjwvc2FtbHA6UmVzcG9uc2U+'}
            }
            else
            {
                ''
            }
        }


        $expected = @{
            Assertion = $(Get-Content './tests/resources/base-64-saml-response.txt').ToString();
            Roles = @(
                @{
                    Principal = 'arn:aws:iam::1234:saml-provider/test';
                    Role = 'arn:aws:iam::1234:role/test-role1';
                },
                @{
                    Principal = 'arn:aws:iam::5678:saml-provider/test';
                    Role = 'arn:aws:iam::5678:role/test-role2';
                }
            )
        }

        $actual = ParseSamlPage $page

        $(ConvertTo-Json $actual) | Should Be $(ConvertTo-Json $expected)
    }
}
