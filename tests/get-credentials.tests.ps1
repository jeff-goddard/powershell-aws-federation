. ./src/get-credentials.ps1
. ./src/invoke-awscommand.ps1


Describe 'GetCredentials' {
    It 'Should return values from AWS' {

        $json = $(Get-Content './tests/resources/assume-role-response.json') 
        
        Mock InvokeAwsCommand {return $json } `
            -ParameterFilter {
               $($arguments | Out-String) -eq  $(('sts', 
                    'assume-role-with-saml',
                    '--role-arn',
                    'role:arn:test',
                    '--principal-arn', 
                    'principal:arn:test', 
                    '--saml-assertion', 
                    'saml', 
                    '--output', 
                    'json') | Out-String)
                }
            

        $profile = @{
            Role =  'role:arn:test';
            Principal =  'principal:arn:test';
        }
        
        $actual = GetCredentials 'saml' $profile 
        
        $actual | ConvertTo-Json | Should Be $([ordered] @{
            SecretAccessKey = "foo"
            SessionToken =  "bar"
            Expiration =  "2000-01-01T00:00:00Z"
            AccessKeyId =  "baz"
        } | ConvertTo-Json)
    }
}
