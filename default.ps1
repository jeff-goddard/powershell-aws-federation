Properties {
    $version = '0.0.0'
}

Task -Name Default -Depends Test

Task -Name Package -Depends Clean,Test, Version  {
    $buildPath = "./Build/Dist/AwsFederation/"
    New-Item -ItemType Directory  $buildPath
    Copy-Item -Recurse ./src/* $buildPath

    $manifest = Get-Content  $buildPath/AwsFederation.psd1
    $manifest = $manifest -Replace '%%VERSION%%', "$script:version"
    Set-Content $buildPath/AwsFederation.psd1 $manifest
}

Task -Name Install -Depends Package,UnInstall {

    $personalModulePath = $env:PSModulePath.Split(';').Split(':') | ? {$_.StartsWith($(Resolve-Path '~'))} | select-object -First 1
    
    New-Item -ItemType Directory -Force $personalModulePath
    Copy-Item -Recurse -Force ./Build/Dist/* $personalModulePath
}

Task Test  {
    New-Item -ItemType Directory -Force ./Build
    $testResults = Invoke-Pester ./tests/ -OutputFile ./Build/TestResults.xml -OutputFormat NUnitXml  -CodeCoverage @('./src/*.ps1') -PassThru
    If ($testResults.FailedCount -ne 0)
    {
        throw "$($testResults.FailedCount) Unit Tests Failed"
    }
}

Task -Name Clean  {
    Remove-Item -Recurse -Force -ErrorAction Ignore ./Build
}

Task -Name Version  {
    $script:version = Get-Content './version.txt'
    Write-Output "Version $script:version"
}

Task -Name UnInstall {
    $personalModulePath = $env:PSModulePath.Split(';').Split(':') | ? {$_.StartsWith($(Resolve-Path '~'))} | select-object -First 1
    $modulePath = "$personalModulePath/AwsFederation/0.0.1"
    if(Test-Path $modulePath)
    {
        Remove-Item -Recurse -Force $modulePath
    }
}
