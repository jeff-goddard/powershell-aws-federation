
function Invoke-CustomFederatedAwsLogin($uri)
{
    $loginUri = [uri] $uri
    $loginResponse = Invoke-WebRequest -Uri $loginUri

    $credentials = Get-Credential -Message "Credentials for AWS Federated login"

    $loginForm = $loginResponse.Forms[0]

    $loginUri = New-Object -TypeName Uri $loginResponse.BaseResponse.ResponseUri,$loginForm.Action

    $loginForm.Fields['username'] = $credentials.UserName
    $loginForm.Fields['password'] = $credentials.GetNetworkCredential().Password

    $response = Invoke-WebRequest -Uri $loginUri -Method POST -Body $loginForm -UseBasicParsing

    return $response
}
