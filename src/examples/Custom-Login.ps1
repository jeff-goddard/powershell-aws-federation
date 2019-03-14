
function Invoke-CustomFederatedAwsLogin($uri)
{
    $loginUri = [uri] $uri

    $credentials = Get-Credential -Message "Credentials for AWS Federated login"
    $postParams = @{
        UserName=$credentials.UserName;
        Password=$credentials.GetNetworkCredential().Password;
        AuthMethod="FormsAuthentication"
    }
    
    $response = Invoke-WebRequest -Uri $loginUri -Method POST -body $postParams -UseBasicParsing
    return $response
}
