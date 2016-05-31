Properties {
    $version = '0.0.0'
}


Task -Name Default -Depends Test


Task -Name Package -Depends Clean,Test, Version  {
    $buildPath = "./Build/Dist/AwsFederation/$script:version/"
    New-Item -ItemType Directory -Force $buildPath
    Copy-Item -Recurse ./src/* $buildPath
    
    $manifest = Get-Content  $buildPath/AwsFederation.psd1  
    $manifest = $manifest -Replace '%%VERSION%%', "$script:version"
    Set-Content $buildPath/AwsFederation.psd1 $manifest
}

Task -Name Install -Depends Package {
    $personalModulePath = Join-Path $([Environment]::GetFolderPath("MyDocuments")) 'WindowsPowerShell/Modules/'
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
    Remove-Item -Recurse -Force .\build
}

Task -Name Version  {
    $script:version = Get-Content './version.txt'
    Write-Output "Version $script:version"
}
