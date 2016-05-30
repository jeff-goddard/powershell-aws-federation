. ./src/get-credentials.ps1

Describe 'GetCredentials' {
    It 'Should return values from AWS' {
        Mock Use-STSRoleWithSAML { return @{Credentials = 'hello'} } `
            -ParameterFilter {
                $RoleArn -eq 'role:arn:test' -and
                $PrincipalArn -eq 'principal:arn:test' -and
                $SAMLAssertion -eq 'saml' -and
                $Region -eq 'test'
            }
   
        $profile = @{
            Role =  'role:arn:test';
            Principal =  'principal:arn:test';
        }
        
        $actual = GetCredentials 'saml' $profile 'test'
        
        $actual | Should Be 'hello'   
    }
}
