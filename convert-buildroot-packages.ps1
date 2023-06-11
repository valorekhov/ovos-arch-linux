Import-Module ./makefile-parser.ps1

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

function Quote-String([string]$str, [string]$char = "`'", [string]$replace = "`'\`'`'"){
    $char + $str.Replace($char, $replace) + $char
}

function Split-NewLines([string]$str, [string]$repl){
    return $str.Replace("`n", $repl)
}

$packagePrefix = "ovos"
$rootPath = "../ovos-buildroot/buildroot-external/package"

$packageDirectories = Get-ChildItem -Path $rootPath -Directory -Filter "$packagePrefix*"

$buildTypeRegex = [regex]"`\$\(eval `\$\((cmake|python|autotools|generic)-package\)\)"

foreach ($packageDir in $packageDirectories) {
    $packageName = $packageDir.Name
    $dstPkgDir = "./PKGBUILDs/$packageName"
    mkdir -p $dstPkgDir

    # Check if $dstPkgDir already has a built package file *.pkg.tar.zst
    # and if so, skip this package
    if (Test-Path -Path "$dstPkgDir/*.pkg.tar.zst") {
        continue
    }
    $packageDir.FullName
    $dstTemplate = ""

    $buildRootPkgPath = (Get-ChildItem -Path $packageDir -Filter "*.mk").FullName
    $buildRootHashPath = (Get-ChildItem -Path $packageDir -Filter "*.hash").FullName
    $buildRootConfigPath = (Get-ChildItem -Path $packageDir -Filter "Config.in").FullName
    $parsed = Parse-MakeFile -FilePath $buildRootPkgPath
    # $parsedConfig = Parse-MakeFile -FilePath $buildRootConfigPath

    $buildRootPkgSrc = Get-Content -Path $buildRootPkgPath -Raw
    $buildRootPkgLines = Get-Content -Path $buildRootPkgPath
    $buildRootPkgHash = if ($buildRootHashPath) {Get-Content -Path $buildRootHashPath} 

    $buildRootProject = Get-BuildrootProject -properties $parsed

    $exclude = @("VERSION", "SITE", "LICENSE", "SOURCE", "DEPENDENCIES", "INSTALL_STAGING") `
                    | ForEach-Object { $buildRootProject + "_" + $_ } `
                    | Join-String -Separator "|"
    $buildSteps = $buildRootPkgLines `
                    | Where-Object { -not ($_.StartsWith("#") -or $_.Contains("`$(eval")) }
                    | Where-Object { $_ -notmatch "^\s*($exclude)" }

    Copy-Item -Path "$packageDir/*" -Destination "./PKGBUILDs/$packageName/" `
        -Exclude "*.patch", "*.mk", "*.hash", "*.in" -Recurse -Force
    $extraSources = Get-ChildItem -Path $packageDir -Exclude "*.patch", "*.mk", "*.hash", "*.in" -Force

    Copy-Item -Path "$packageDir/*.patch" -Destination "./PKGBUILDs/$packageName/" 
    $patches = Get-ChildItem -Path $packageDir -Filter "*.patch" -Force

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
        $sources = @( Quote-String "https://github.com/`$_gh_org/`$_gh_proj/$file" -char "`"" )
    } elseif ($site.StartsWith("http")) {
        $gitHubOrg = ""
        $gitHubProj = ""
        $url = $site
        if ($site.StartsWith("https://github.com")){
            $arr = $site.Split("/")
            $gitHubOrg = $arr[3]
            $gitHubProj = $arr[4]
            $src = "https://github.com/`$_gh_org/`$_gh_proj/archive/`$pkgver.tar.gz"
        } else {
            $src = $site
        }
        $sources = @( $src )
    }

    foreach($patch in $patches){
        $sha256sums += "`n   #$($patch.Name)" 
        $sha256sums += "`n   '$(($patch | Get-FileHash -Algorithm SHA256).Hash)'"
        $sources += "`n   $($patch.Name)" 
    }

    foreach($extraSource in $extraSources){
        $sha256sums += "`n   #$($extraSource.Name)" 
        $sha256sums += "`n   '$(($extraSource | Get-FileHash -Algorithm SHA256).Hash)'"
        $sources += "`n   $($extraSource.Name)" 
    }

    $evalMatches = $buildTypeRegex.Matches($buildRootPkgSrc)
    if ($evalMatches.Count -gt 0){
        $buildType = $evalMatches[0].Groups[1]
        switch ($buildType) {
            "cmake" { 
                $dstTemplate = Set-Template -template (Get-Content "./templates/cmake/PKGBUILD" -Raw) -properties @{
                    "build_opts" = if ($confOptions) {"CONF_OPTS=$confOptions"}
                    "build_leader" =  $buildSteps | ForEach-Object { "    # " + $_ } | Join-String -Separator "`n" 
                }
                $makeDependencies += "cmake"
             }
            "autotools" {
                $dstTemplate = Set-Template -template (Get-Content "./templates/autotools/PKGBUILD" -Raw) -properties @{
                    "build_opts" = if ($confOptions) {"CONF_OPTS=$confOptions"}
                    "build_leader" =  $buildSteps | ForEach-Object { "    # " + $_ } | Join-String -Separator "`n" 
                }
                $makeDependencies += "autoconf", "automake", "libtool"
            }
            "generic" {
                $dstTemplate = Set-Template -template (Get-Content "./templates/generic/PKGBUILD" -Raw) -properties @{
                    "build_leader" =  $buildSteps | ForEach-Object { "    # " + $_ } | Join-String -Separator "`n" 
                }
            }
            Default {
                $dstTemplate = $buildRootPkgSrc 
            }
        }
    } else {
        $dstTemplate = $buildRootPkgSrc 
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
        "footer" = "`n" + (Split-NewLines -str $buildRootPkgSrc -repl "`n# ") + "`n"
    }

    $PKGBUILD | Set-Content -Path "./PKGBUILDs/$packageName/PKGBUILD"
}