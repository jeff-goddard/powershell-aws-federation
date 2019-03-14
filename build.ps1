#!/usr/bin.env pwsh
Push-Location $(Split-Path -Path $MyInvocation.MyCommand.Path)

if ($IsLinux -or $IsMacOS) {
    mono ./tools/nuget.exe restore ./packages.config -PackagesDirectory ./packages
}
else {
    ./tools/nuget.exe restore ./packages.config -PackagesDirectory ./packages
}

Import-Module ./packages/psake.4.7.4/tools/psake/psake.psm1
Import-Module ./packages/pester.4.4.1/tools/pester.psm1

$args

Invoke-Expression "Invoke-Psake $args"
Pop-Location
