. ./src/invoke-awscommand.ps1




Describe 'GetAwsCommand' {
    It 'Should return the command' {
        Mock Get-Command {return (
            @{
                CommandType = [System.Management.Automation.CommandTypes]::Alias
                Path = 'foo'
            },
            @{
                CommandType = [System.Management.Automation.CommandTypes]::Function
                Path = 'bar'
        })}

        $actual = GetAwsCommand

        $actual | Should Be 'bar'
    }
}

Describe 'InvokeAwsCommand' {
    It 'Should invoke the command' {

        $arguments = @('foo','bar')
        function AwsCommand($a)
        {
            $bull = $a | Should Be $arguments
            return 'baz'
        }
        Mock GetAwsCommand  {'AwsCommand'}

        $actual = InvokeAwsCommand $arguments

        $actual | Should Be 'baz'


    }

}
