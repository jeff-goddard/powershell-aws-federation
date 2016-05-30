Push-Location $(Split-Path -Path $MyInvocation.MyCommand.Path)


Write-Output "PowerShell version:  $($PSVersionTable.PSVersion)"

./tools/nuget.exe restore ./packages.config -PackagesDirectory ./packages

Import-Module ./packages/psake.4.6.0/tools/psake.psm1
Import-Module ./packages/pester.3.4.0/tools/pester.psm1

$args

Invoke-Expression "Invoke-Psake $args"
Pop-Location
