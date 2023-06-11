Import-Module ./makefile-parser.ps1

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

function Quote-String([string]$str, [string]$char = "`'", [string]$replace = "`'\`'`'"){
    $char + $str.Replace($char, $replace) + $char
}

function Split-NewLines([string]$str, [string]$repl){
    return $str.Replace("`n", $repl)
}

$packagePrefix = "ovos"
$rootPath = "../ovos-buildroot/buildroot-external/package"

$packageDirectories = Get-ChildItem -Path $rootPath -Directory -Filter "$packagePrefix*"
#$buildScriptTemplate = Get-Content "templates/build.sh" -Raw

$buildTypeRegex = [regex]"`\$\(eval `\$\((cmake|python|automake)-package\)\)"

foreach ($packageDir in $packageDirectories) {
    $packageDir.FullName
    $packageName = $packageDir.Name

    $buildRootPkgPath = (Get-ChildItem -Path $packageDir.FullName -Filter "*.mk").FullName
    $buildRootHashPath = (Get-ChildItem -Path $packageDir.FullName -Filter "*.hash").FullName
    $buildRootConfigPath = (Get-ChildItem -Path $packageDir.FullName -Filter "Config.in").FullName
    $parsed = Parse-MakeFile -FilePath $buildRootPkgPath
    # $parsedConfig = Parse-MakeFile -FilePath $buildRootConfigPath

    $buildRootPkgSrc = Get-Content -Path $buildRootPkgPath -Raw
    $buildRootPkgHash = if ($buildRootHashPath) {Get-Content -Path $buildRootHashPath} 

    Copy-Item -Path $packageDir -Destination "./PKGBUILDs/$packageName" `
        -Exclude "*.patch", "*.mk", "*.hash", "*.in" -Recurse -Force -ErrorAction SilentlyContinue

    Copy-Item -Path "$packageDir/*.patch" -Destination "./PKGBUILDs/$packageName" -Force -ErrorAction SilentlyContinue
    $patches = Get-ChildItem -Path $packageDir.FullName -Filter "*.patch"
    $sha256sums = @()

    if ($buildRootPkgHash){
        $dic = @{}
        foreach($line in ($buildRootPkgHash | Where-Object{-not $_.StartsWith("#")})){
            $arr = $line -split "\s+"
            $dic[$arr[2]] = $arr[1]
            $sha256sums += "`n   #$($arr[2])" 
            $sha256sums += "`n   $($arr[1])" 
        }
        $buildRootPkgHash = $dic
    }

    $version = Get-Property -properties $parsed -name "VERSION"
    $site = Get-Property -properties $parsed -name "SITE"
    $confOptions = Get-Property -properties $parsed -name "CONF_OPTS"
    $dependencies = Get-Property -properties $parsed -name "DEPENDENCIES" -split "\s+"
    $makeDependencies = @()

    # In buildroot, dependencies prefixed with "host-" can be presumed to be build dependencies
    # we therefore move them to the makedepends section
    if($dependencies) { 
        $makeDependencies = @($dependencies | Where-Object{$_.StartsWith("host-")} | ForEach-Object {$_.Substring("host-".Length)} )
        $dependencies = @($dependencies | Where-Object{-not $_.StartsWith("host-")})
    }

    Write-Host $packageName, $version, $site, $dependencies

    if ($site.Contains("`$(call github,")){
        $arr = $site.Split(",")
        $gitHubOrg = $arr[1]
        $gitHubProj = $arr[2]
        $file = $arr[3]
        $url = "https://github.com/$gitHubOrg/$gitHubProj/"
        if ($file.Contains("_VERSION")){
            $file = "archive/`$pkgver.tar.gz"
        }
        $sources = @( Quote-String https://github.com/`$_gh_org/`$_gh_proj/$file -char "`"" )
    }

    foreach($patch in $patches){
        $sha256sums += "`n   #$($patch.Name)" 
        $sha256sums += "`n   $(($patch | Get-FileHash -Algorithm SHA256).Hash)"
        $sources += "`n   $($patch.Name)" 
    }

    $evalMatches = $buildTypeRegex.Matches($buildRootPkgSrc)
    if ($evalMatches.Count -gt 0){
        $buildType = $evalMatches[0].Groups[1]
        switch ($buildType) {
            "cmake" { 
                $dstTemplate = Set-Template -template (Get-Content "./templates/cmake/PKGBUILD" -Raw) -properties @{
                    "build_leader" = if ($confOptions) {"CONF_OPTS=$confOptions"}
                }

                $makeDependencies += "cmake"
             }
            Default {}
        }
    }
        
    $PKGBUILD = Set-Template -template $dstTemplate -properties @{
        "gh_org" = $gitHubOrg
        "gh_proj" = $gitHubProj
        "license" = Quote-String -str (Get-Property -properties $parsed -name "LICENSE")
        "pkgname" = $packageName
        "pkgver" = Quote-String $version
        "pkgdesc" = Quote-String -str (Get-Content -Path $buildRootConfigPath -Raw) 
        "url" =  Quote-String $url
        "sources" = $sources | Join-String  -Separator " \"
        "sha256sums" = $sha256sums | Join-String  -Separator " \"
        "depends" = $dependencies
        "makedepends" = $makeDependencies
        "build" = $buildScript
        "package" = $packageScript
        "footer" = "`n" + (Split-NewLines -str $buildRootPkgSrc -repl "`n# ") + "`n"
    }

    mkdir -p "./PKGBUILDs/$packageName"
    $PKGBUILD | Set-Content -Path "./PKGBUILDs/$packageName/PKGBUILD"
}