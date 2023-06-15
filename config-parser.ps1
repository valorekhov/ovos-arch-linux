function Get-ParsedConfig([string]$path){
    $config = @{} 
    $lines = Get-Content $path
    foreach($line in $lines){
        if($line -match '^\s*#'){
            continue
        }
        if($line -match '^\s*(?<key>[^=]+)\s*=\s*(?<value>.*)\s*$'){
            $config[$matches['key']] = $matches['value']
        }
    }
    return $config
}