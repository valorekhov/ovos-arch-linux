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
    $config = New-Object psobject
    foreach($line in $lines){
        if($line -match '^\s*#'){
            continue
        }
        if($line -match '^\s*(?<key>[^=]+)\s*=\s*(?<value>.*)\s*$'){
            $key = $matches['key'].Trim()
            $value = $matches['value'].Trim()
            if (Get-Member -InputObject $config -Name $key -ErrorAction SilentlyContinue){
                # Check if existing value is an array, if not, convert it to an array
                if ($config.$key -isnot [array]){
                    $config.$key = @($config.$key)
                } 
                $config.$key += $value
            } else {
                Add-Member -InputObject $config -MemberType NoteProperty -Name $key -Value $value
            }
        }
    }
    return $config
}