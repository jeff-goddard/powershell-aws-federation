. ./src/get-samlpage.ps1



function Invoke-CustomFederatedAwsLogin() {}


Describe 'GetSamlPage' {

    It 'Should return the page from the uri' {
      Mock Get-Command {throw 'oops'} `
          -ParameterFilter {$Name -eq 'Invoke-CustomFederatedAwsLogin'}

      Mock Invoke-WebRequest { return  'baz' } `
          -ParameterFilter {$Uri -eq 'foo://bar/'}

      $actual = GetSamlPage 'foo://bar'

      $actual | Should Be 'baz'
    }

    It 'Should return the page from the custom command' {
        Mock Get-Command {return $true} `
            -ParameterFilter {$Name -eq 'Invoke-CustomFederatedAwsLogin'}

      Mock Invoke-CustomFederatedAwsLogin { return 'bat'}  `

      $actual = GetSamlPage 'foo://bar'

      $actual | Should Be 'bat'
    }
}
