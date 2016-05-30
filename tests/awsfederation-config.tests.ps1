. ./src/awsfederation-config.ps1

Describe 'GetAwsFederationConfig' {

    It 'Should return the default configuration if an error if null is passed' {

        $expected = [ordered] @{
            Default = '';
            FederationUri  = 'http://adfs.example.com/adfs/ls/IdpInitiatedSignOn.aspx?loginToRp=urn:amazon:webservices';
            OutputFormat = 'json';
            Region = 'eu-west-1';
            Profiles = @()
        }
        $actual = GetAwsFederationConfig $null

        $(ConvertTo-Json $actual) | Should Be $(ConvertTo-Json $expected)
    }

    It 'Should load the config file correctly' {

        $expected = [ordered] @{
            Default = 'role2';
            FederationUri  = 'http://adfs.example.com/adfs/ls/IdpInitiatedSignOn.aspx?loginToRp=urn:amazon:webservices';
            OutputFormat = 'table';
            Region = 'us-east-1';
            Profiles = @(
                @{
                    Name = 'role1';
                    Principal = 'arn:aws:iam::1234:saml-provider/test';
                    Role = 'arn:aws:iam::1234:role/test-role1';
                },
                @{
                    Name = 'role2';
                    Principal = 'arn:aws:iam::5678:saml-provider/test';
                    Role = 'arn:aws:iam::5678:role/test-role2';
                }
            )
        }
        $actual = GetAwsFederationConfig './tests/resources/aws-federation.config'

        $(ConvertTo-Json $actual ) | Should Be $(ConvertTo-Json $( $expected))
    }
}

Describe 'SetAwsFederationConfig' {
    It 'Should save the config file correctly' {

        $config = [ordered] @{
            Default = 'role2';
            FederationUri  = 'http://adfs.example.com/adfs/ls/IdpInitiatedSignOn.aspx?loginToRp=urn:amazon:webservices'
            OutputFormat = 'table'
            Region = 'us-east-1';
            Profiles = @(
                @{
                    Name = 'role1';
                    Principal = 'arn:aws:iam::1234:saml-provider/test';
                    Role = 'arn:aws:iam::1234:role/test-role1';
                },
                @{
                    Name = 'role2';
                    Principal = 'arn:aws:iam::5678:saml-provider/test';
                    Role = 'arn:aws:iam::5678:role/test-role2';
                }
            )
        }
        $expected = Get-Content './tests/resources/aws-federation.config' -raw

        SetAwsFederationConfig $config 'TestDrive:/.aws/aws-federation.config'

        $actual = Get-Content -raw 'TestDrive:/.aws/aws-federation.config'

        $actual | Should Be $expected
    }    
}


Describe 'GetProfile' {
    It 'Should get the correct profile' {
         $config = [ordered] @{
            Default = 'role2';
            FederationUri  = 'http://adfs.example.com/adfs/ls/IdpInitiatedSignOn.aspx?loginToRp=urn:amazon:webservices'
            OutputFormat = 'table'
            Region = 'us-east-1';
            Profiles = @(
                @{
                    Name = 'role1';
                    Principal = 'arn:aws:iam::1234:saml-provider/test';
                    Role = 'arn:aws:iam::1234:role/test-role1';
                },
                @{
                    Name = 'role2';
                    Principal = 'arn:aws:iam::5678:saml-provider/test';
                    Role = 'arn:aws:iam::5678:role/test-role2';
                }
            )
        }
            
        $expected =  @{
            Name = 'role2';
            Principal = 'arn:aws:iam::5678:saml-provider/test';
            Role = 'arn:aws:iam::5678:role/test-role2';
        }
        
        $actual = GetProfile $config 'role2'
        
         $(ConvertTo-Json $actual ) | Should Be $(ConvertTo-Json $( $expected))
    }
    
}
