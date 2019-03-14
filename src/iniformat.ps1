#   This Source Code Form is subject to the terms of the Mozilla Public
#   License, v. 2.0. If a copy of the MPL was not distributed with this
#   file, You can obtain one at http://mozilla.org/MPL/2.0/.


$script:encodingWithoutBom = $([System.Text.UTF8Encoding]::new())

function convertFromIniFormat($inputString)
{
    $output = [ordered] @{}
    $value = [ordered] @{}
    $name = ''
    foreach($line in $inputString.Split("`n"))
    {
        if($line.StartsWith('['))
        {
            if($name -ne '')
            {
                $output[$name] = $value
                $value = [ordered] @{}
            }
            $name =  $line.Trim().Trim('[]')
            
        }
        elseif ($line.Contains('=')) {
            $key = $line.split('=')[0].Trim()
            $val = $line.split('=', 2)[1].Trim()
            $value[$key] = $val 
        }
        
    }
    if($name -ne '')
    {
        $output[$name] = $value
        $value = [ordered] @{}
    }
    
    return $output
}

function convertToIniFormat($inputHash)
{
    $output = ''
    
    foreach($key in $inputHash.Keys)    
    {
        $output += "[$key]`r`n"
        if($inputHash[$key] -ne $null)
        {
            foreach($subKey in $inputHash[$key].Keys)
            {
                $output += "$subKey=$($inputHash[$key][$subKey])`r`n"
            }
            $output += "`r`n"
        }
    }
    
    return $output
}


function writeIniFileWithoutBom($path, $inputhash)
{
    $filename = Split-Path $path -Leaf 
    $dir = Split-Path $path 

    $dir = New-Item -Itemtype Directory -Force $dir
    $path = Join-Path $dir $filename

    $output = convertToIniFormat($inputHash)
    [IO.File]::WriteAllText($path, $output)
}
