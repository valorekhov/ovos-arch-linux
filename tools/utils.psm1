# This function checks whether a given package exists in pacman repositories
# To avoid unnecessary network requests, it first checks if the package is
# already known by consulting a `.known-packages` file.
# The format of the file is one package name per line. If package was not found,
# the name is prefixed with a `#` character. 
function Find-PackageInRepositories([string]$name){
    # Get directory from which this script is running
    $dbPath = "$PSScriptRoot/../.known-repo-packages" 
    $knownPackages = Get-Content -Path $dbPath -ErrorAction SilentlyContinue
    $res = $knownPackages | Where-Object { $_.StartsWith("#$name") -or $_.StartsWith("$name") }
                | Select-Object -First 1
    if ($res){
        return -not $res.StartsWith("#")
    }

    # TODO: call pacman -Ss $name and check if return value is 0 or 1
    # 0 means package was found, 1 means package was not found
    pacman -Ss "^$name$"    
    if ($LASTEXITCODE -gt 0){
        Add-Content -Path $dbPath -Value "#$name"
        return $false
    }
    Add-Content -Path $dbPath -Value "$name"
    return $true
}

function Get-BuildrootProject([hashtable]$properties) {
    $key = $properties.Keys | Where-Object{ $_.EndsWith("_SITE")}    
    if ($key) {$key.Substring(0,  $key.Length - "_SITE".Length)} else {$null}
}


function Get-Property([hashtable]$properties, [string]$name) {
    $key = $properties.Keys | Where-Object{ $_.EndsWith("_" + $name)}    
    if ($key) {$properties[$key]} else {$null}
}

function Set-Template([string]$template, [hashtable]$properties){
    $ret = $template
    foreach($key in $properties.Keys){
        $ret = $ret.Replace("{{$key}}", $properties[$key])
    }
    $ret
}

function Format-QuotedString([string]$str, [string]$char = "`'", [string]$replace = "`'\`'`'"){
    $char + $str.Replace($char, $replace) + $char
}

function Split-NewLines([string]$str, [string]$repl){
    return $str.Replace("`n", $repl)
}