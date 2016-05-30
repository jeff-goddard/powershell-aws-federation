. ./src/aws-config.ps1

Describe 'GetAwsConfig' {

    It 'Should return null if an error if null is passed' {


        $actual = GetAwsConfig $null

        $actual | Should BeNullOrEmpty
    }

    It 'Should load the config file correctly' {
        $date = [DateTime]::Parse('2001-01-01T00:00:00.0000000+00:00')
        $expected = [ordered] @{
            default =  [ordered] @{
                output='json';
                region='eu-west-1';
                aws_access_key_id='access';
                aws_secret_access_key='secret';
                aws_session_token='session';
                expiration=$date;
            };
            'profile role1' = [ordered] @{
                output='json';
                region='eu-west-1';
                aws_access_key_id='access';
                aws_secret_access_key='secret';
                aws_session_token='session';
                expiration=$date;
            };
        }
        
        $actual = GetAwsConfig './tests/resources/federated.config'

        $(ConvertTo-Json $actual ) | Should Be $(ConvertTo-Json $( $expected))
    }
}

Describe 'SetAwsFederationConfig' {
    It 'Should save the config file correctly' {
        $date = [DateTime]::Parse('2001-01-01T00:00:00.0000000+00:00')
        $config = @{
            Default = 'role1';
            FederationUri  = 'http://adfs.example.com/adfs/ls/IdpInitiatedSignOn.aspx?loginToRp=urn:amazon:webservices'
            OutputFormat = 'json';
            Region = 'eu-west-1';
        }
        
        $creds = [PSCustomObject] @{
           AccessKeyId = 'access';
           SecretAccessKey = 'secret';
           SessionToken='Session';
           Expiration=$date;
        }
        
        $expected = Get-Content './tests/resources/federated.config' -raw

        SetAwsConfig 'role1' $creds $config 'TestDrive:/.aws/federated.config'

        $actual = Get-Content -raw 'TestDrive:/.aws/federated.config'

        $actual | Should Be $expected
    }    
    
      It 'Should set adefault in the config file' {
        $date = [DateTime]::Parse('2001-01-01T00:00:00.0000000+00:00')
        $config = @{
            Default = 'role1';
            FederationUri  = 'http://adfs.example.com/adfs/ls/IdpInitiatedSignOn.aspx?loginToRp=urn:amazon:webservices'
            OutputFormat = 'json';
            Region = 'eu-west-1';
        }
        
        $creds = [PSCustomObject] @{
           AccessKeyId = 'access';
           SecretAccessKey = 'secret';
           SessionToken='Session';
           Expiration=$date;
        }
        
        $expected = Get-Content './tests/resources/federated2.config' -raw

        SetAwsConfig 'role2' $creds $config 'TestDrive:/.aws/federated2.config'

        $actual = Get-Content -raw 'TestDrive:/.aws/federated2.config'

        $actual | Should Be $expected
    }    
}


Describe 'GetConfigCredentials' {
    It 'Should get the correct profile' {
        $date = [DateTime]::Parse('2001-01-01T00:00:00.0000000+00:00')
        
        $config = [ordered] @{
            default = @{
                output='json';
                region='eu-west-1';
                aws_access_key_id='access';
                aws_secret_access_key='secret';
                aws_session_token='session';
                expiration=$date;
            };
            'profile role1' = @{
                output='json';
                region='eu-west-1';
                aws_access_key_id='access';
                aws_secret_access_key='secret';
                aws_session_token='session';
                expiration=$date;
            };
        }
            
        $expected = [ordered] @{
                AccessKeyId = 'access';
                SecretAccessKey = 'secret';
                SessionToken = 'session';
                Expiration = $date;
            };
        
        $actual = GetAwsCredentials $config 'role1'
        
         $(ConvertTo-Json $actual ) | Should Be $(ConvertTo-Json $( $expected))
    }
    
    It 'Should get null if not found' {
        $date = [DateTime]::Parse('2001-01-01T00:00:00.0000000+00:00')
        $config = [ordered] @{
            default = @{
                output='json';
                region='eu-west-1';
                aws_access_key_id='access';
                aws_secret_access_key='secret';
                aws_session_token='session';
                expiration=$date;
            };
            'profile role1' = @{
                output='json';
                region='eu-west-1';
                aws_access_key_id='access';
                aws_secret_access_key='secret';
                aws_session_token='session';
                expiration=$date;
            };
        }
            
        
       $actual = GetAwsCredentials $config 'role2'
        
       $actual | Should BeNullOrEmpty
    }
}
