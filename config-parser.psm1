function Get-ParsedConfig([string]$path){
    Get-ConfigFromLines (Get-Content $path)
}

function Get-ParsedConfigFromString([string]$text){
    Write-Host "Parsing config from string: $text"
    $lines = $text -split '`n'
    Get-ConfigFromLines -lines $lines
}

function Get-ConfigFromLines([string[]]$lines) {
    # TODO: Use PSObject instead of hashtable
    $config = @{}
    foreach($line in $lines){
        if($line -match '^\s*#'){
            continue
        }
        if($line -match '^\s*(?<key>[^=]+)\s*=\s*(?<value>.*)\s*$'){
            $key = $matches['key'].Trim()
            $value = $matches['value'].Trim()
            if ($config[$key]){
                # Check if existing value is an array, if not, convert it to an array
                if ($config[$key] -isnot [array]){
                    $config[$key] = @($config[$key])
                } 
                $config[$key] += $value
            } else {
                $config[$key] = $value
            }
        }
    }
    return $config
}


function ConvertFrom-SrcInfo([string[]]$lines) {
    $sections = @()
    $base = $config = @{}
    foreach($line in $lines){
        if($line -match '^\s*#'){
            continue
        }

        if ($line.StartsWith('pkgname')){
            $config = @{}
            $sections += $config
        }
        
        if($line -match '^\s*(?<key>[^=]+)\s*=\s*(?<value>.*)\s*$'){
            $key = $matches['key'].Trim()
            $value = $matches['value'].Trim()
            if ($config[$key]){
                # Check if existing value is an array, if not, convert it to an array
                if ($config[$key] -isnot [array]){
                    $config[$key] = @($config[$key])
                } 
                $config[$key] += $value
            } else {
                $config[$key] = $value
            }
        }
    }

    # at this point $sections contains one or more packages
    # and $base has the pckgbase info applicable to all of them
    # we iterate each package and merge the base info into each

    foreach($section in $sections){
        foreach($key in $base.Keys){
            if (-not $section[$key]){
                $section[$key] = $base[$key]
            } else {
                if ($section[$key] -isnot [array]){
                    $section[$key] = @($section[$key])
                }
                $section[$key] += $base[$key]
            }
        }
    }

    $sections
}