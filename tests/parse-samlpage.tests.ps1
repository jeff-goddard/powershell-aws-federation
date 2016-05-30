. ./src/parse-samlpage.ps1

Describe 'ParseSamlPage' {

    It 'Should throw an error if null is passed' {
        {
            ParseSamlPage $null
        } | Should Throw 'Invalid SAML Page'
    }

    It 'Should throw an error if invalid saml page is passed' {
        $page = New-Object -ComObject 'HTMLFile'
        $content = Get-Content -Path './tests/resources/invalid-saml-page.html' -Raw
        $content = [System.Text.Encoding]::Unicode.GetBytes($content)
        try
        {
            $page.IHTMLDocument2_write($content)
        }
        catch
        {
            $content =  $page.write($content)
        }

        {
            ParseSamlPage $page
        } | Should Throw 'Invalid SAML Page'
    }

    It 'Should return the correct saml object' {
        $page = New-Object -ComObject 'HTMLFile'
        $content = Get-Content -Path './tests/resources/valid-saml-page.html' -Raw


        $content =   [System.Text.Encoding]::Unicode.GetBytes($content)

        try
        {
            $page.IHTMLDocument2_write($content)
        }
        catch
        {
            $page.write($content)
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
