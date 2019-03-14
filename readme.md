AwsFederation Powershell module
===============================

What is this?
-------------

This is a powershell module to allow you to use federated credentials to work with the AWS CLI from within PowerShell.

For the PowerShell AWS tools you ca set up federation as described (here)[1]

The concept is similar to (this blog post)[2], but a little more automated - if you are using a standard ADFS type setup, 
then you will not need to enter any usernames and passwords.

This tool howerver will not change your regular AWS configuration files, but will create a new one and set the correct environment 
variable for this to be picked up by the CLI. This allows you to continue using IAM credentails if necessary.

If you are not using a standard ADFS set up you will need to set up a custom function to log into your federated account. 
See the examples folder for an example of how to do this.


Requirements
------------

### PowerShell 3.0 or above.

Warning: This has only been tested with Powershell 4.0 and 5.0

### The AWS CLI 

The AWS CLI must be available on the path.
This will work with both the native windows CLI and the python CLI.


Installation
-------

Clone this repo, then run 
```
./build.ps1 install
```
from a Powershell prompt.

How to use
----------

You will need to have a configuration file in place for this.

Once the module is installed, run
```
Set-AwsFederationConfig
```
to create the configuration file This will provide the account numbers and role names that you can see on the federation page.

Run 
```
Get-AwsFederationCredentials
```
to get credentials for an account, and set the AWS\_CONFIG\_FILE environment variable

Run
```
awswrapper
```
or 
```
Invoke-AwsFederationWrapper
``` 
to wrap calls to the AWS CLI.   

You can safely run 
```
Set-Alias aws awswrapper 
```
for transparent use of the module. The best way to do this is to add this line into (your PowerShell profile) [3].

If you are using bash as your default shell, you can also add a bash alias to call powershell core with this wrapper into your bash profile:

```
alaias aws pwsh -c awswrapper
```

 
[1]: http://docs.aws.amazon.com/powershell/latest/userguide/saml-pst.html
[2]: https://blogs.aws.amazon.com/security/post/Tx1LDN0UBGJJ26Q/How-to-Implement-Federated-API-and-CLI-Access-Using-SAML-2-0-and-AD-FS
[3]: https://blogs.aws.amazon.com/security/post/Tx1LDN0UBGJJ26Q/How-to-Implement-Federated-API-and-CLI-Access-Using-SAML-2-0-and-AD-FS
