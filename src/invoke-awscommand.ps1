#   This Source Code Form is subject to the terms of the Mozilla Public
#   License, v. 2.0. If a copy of the MPL was not distributed with this
#   file, You can obtain one at http://mozilla.org/MPL/2.0/.

function GetAwsCommand
{
    $commands = Get-Command -All 'aws'

    $command = $commands | `
        Where-Object {$_.Commandtype -ne [System.Management.Automation.CommandTypes]::Alias } | `
        Select-Object -First 1

    return $command.Path
}

function InvokeAwsCommand($arguments)
{
    $command = GetAwsCommand
    return & $command $arguments
}
