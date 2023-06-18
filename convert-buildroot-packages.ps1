param(
    [switch]$Force = $false
)
Import-Module ./config-parser.psm1
Import-Module ./makefile-parser.psm1
Import-Module ./utils.psm1

$rootDir = Get-Location

# TODO: prefixes: python-mycroft, python-neon, skill
$packagePrefix = "python-ovos"
$rootPath = "../ovos-buildroot/buildroot-external/package"

$packageDirectories = Get-ChildItem -Path $rootPath -Directory -Filter "$packagePrefix*"

$buildTypeRegex = [regex]"`\$\(eval `\$\((cmake|python|autotools|generic)-package\)\)"

$packageMap = Get-ParsedConfig -Path "./package-map.txt"
$existingPkgDirs = Get-ChildItem -Path "./PKGBUILDs/" -Directory 
$knownPackages = @{}
$packageMap.Values | ForEach-Object { $knownPackages[$_] = $true }
foreach ($existingPkgDir in $existingPkgDirs) {
    $knownPackages[$existingPkgDir.Name] = $existingPkgDir.FullName
}
Push-Location
try{
    foreach ($packageDir in $packageDirectories) {
        $packageName = $packageDir.Name
        $dstPkgDir = "./PKGBUILDs/$packageName"
        mkdir -p $dstPkgDir

        # Check if $dstPkgDir already has a built package file *.pkg.tar.zst
        # and if so, skip this package
        if ((Test-Path -Path "$dstPkgDir/*.pkg.tar.zst") -or (Test-Path -Path "$dstPkgDir/.pkgignore")) {
            if (-not $Force){
                continue
            }
        }
        $packageDir.FullName
        $dstTemplate = ""
        $_name = ""
        $_version = ""

        if (Test-Path -Path "$dstPkgDir/PKGBUILD") {
            $dstTemplate = Get-Content -Path "$dstPkgDir/PKGBUILD" 
            # Extract _name and pkgver values from existing PKGBUILD using regex
            $_name = $dstTemplate | Where-Object{ $_.Trim().StartsWith("_name=") } | ForEach-Object{ $_.Split("=")[1].Trim() }
            $_version = $dstTemplate | Where-Object{ $_.Trim().StartsWith("pkgver=") } | ForEach-Object{ $_.Split("=")[1].Trim() }
            Write-Host "Found existing PKGBUILD for $_name version $_version"
        }

        $buildRootPkgPath = (Get-ChildItem -Path $packageDir -Filter "*.mk").FullName
        $buildRootHashPath = (Get-ChildItem -Path $packageDir -Filter "*.hash").FullName
        $buildRootConfigPath = (Get-ChildItem -Path $packageDir -Filter "Config.in").FullName
        $parsed = ConvertFrom-MakeFile -FilePath $buildRootPkgPath

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
        $conflicts = @()
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
            $sources = @( Format-QuotedString "https://github.com/`$_gh_org/`$_gh_proj/$file" -char "`"" )
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
            $buildType = $evalMatches[0].Groups[1].Value
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
                "python" {
                    $dependencies = @("python")   
                    #iterate over sources and replace $pkgver with $_base_ver
                    $sources = @($sources | ForEach-Object { $_ -replace "pkgver", "_base_ver" })         
                    $makeDependencies += "python-build", "python-installer", "python-wheel"
                        
                    $dstTemplate = Set-Template -template (Get-Content "./templates/python/PKGBUILD" -Raw) -properties @{
                        "_name" = if ($_name) { $_name } else {
                            if ($gitHubProj) {$gitHubProj} else {$packageName.Substring("python-".Length)}
                        }
                        "_pkgver" = if ($_version){ $_version } else { $version }
                    }
                }
                Default {
                    $dstTemplate = $buildRootPkgSrc 
                    $buildType = ""
                }
            }
        } else {
            $dstTemplate = $buildRootPkgSrc 
        }

        $brConfig = Get-Content -Path $buildRootConfigPath
        $found = $false
        $description = @()
        foreach($line in $brConfig){
            if ($line.TrimStart().Equals("help")){
                $found = $true
                continue
            }
            if (-not $found){
                continue
            }
            $line = $line.Trim()
            if ($line.StartsWith("https://")){
                continue
            }
            $description += $line
        }
        #check if the last line in $description is empty and remove it
        if ($description[$description.Length - 1].Trim().Length -eq 0){
            $description = $description[0..($description.Length - 2)]
        }
            
        function Save-PKGBUILD {
            $PKGBUILD = Set-Template -template $dstTemplate -properties @{
                "gh_org" = $gitHubOrg
                "gh_proj" = $gitHubProj
                "license" = Format-QuotedString -str (Get-Property -properties $parsed -name "LICENSE")
                "pkgname" = $packageName
                "pkgver" = Format-QuotedString $version
                "pkgdesc" = Format-QuotedString -str ($description | Join-String -Separator "`n") 
                "url" =  Format-QuotedString $url
                "sources" = $sources | Join-String  -Separator " \"
                "sha256sums" = $sha256sums | Join-String  -Separator " \"
                "depends" = $dependencies
                "conflicts" = $conflicts
                "makedepends" = $makeDependencies
                "footer" = "`n" + (Split-NewLines -str $buildRootPkgSrc -repl "`n# ") + "`n"
            }
            $PKGBUILD | Set-Content -Path "$rootDir/PKGBUILDs/$packageName/PKGBUILD"
        }
        Save-PKGBUILD

        if ($buildType -eq "python"){
            Push-Location "."
            Set-Location "$rootDir/PKGBUILDs/$packageName"

            # call makepkg to install & unpack sources only
            Write-Host "Building $packageName"
            $makepkgOutput = makepkg -o
            if ($makepkgOutput -match "==> ERROR: A failure occurred in build()."){
                Write-Error "Failed to build $packageName"
                Write-Error $makepkgOutput
                Pop-Location
                continue
            }
            
            # find the first folder under src/ which ends with "-$version"
            Set-Location (Get-ChildItem -Path "src" -Directory -Filter "*-$version" | Select-Object -First 1)

            # Change to the src directory and locate the folder with requirements.txt
            # After that, use python to parse the requirements.txt and
            # return them into a powershell array
            # requires pip install requirements-parser
            
            # check whether requirements/requirements.txt exists

            if (Test-Path "./requirements/requirements.txt"){
                $requirementsPath = "./requirements/requirements.txt"
            } else {
                $requirementsPath = "./requirements.txt"
            }
            $requirements = python -c "import os; import json; import requirements; print(json.dumps([{'name': r.name, 'specs': r.specs} for r in requirements.parse(open('$requirementsPath', 'r'))]))" `
                                | ConvertFrom-Json

            $requirements = @($requirements | Sort-Object -Property "name" | ForEach-Object {
                @{ 
                    "name" = $_.name
                    "specs" = $_.specs | Foreach-Object {
                        @{
                            "op" = $_[0]
                            "ver" = $_[1]
                        }
                    }
                }
            })

            function Get-PythonPackageName([string]$name){
                if ($packageMap.ContainsKey("pip:$name")){
                    return $packageMap["pip:$name"]
                }
                $name = $name.Replace("_", "-").ToLowerInvariant()
                if (-not $name.StartsWith("python-")){
                    $name = "python-$name"
                }
                if ($packageMap.ContainsKey($name)){
                    return $packageMap[$name]
                }
                $name
            }

            $dependencies += $requirements | ForEach-Object {
                $versions = @($_.specs | ForEach-Object { $_.op + $_.ver })
                $ver = $versions
                    | Where-Object { $_.StartsWith(">")}
                    | Sort-Object -Descending
                    | Select-Object -First 1
                $__packageName = Get-PythonPackageName $_.name
                $__mod = ""
                $__packageInRepos = Find-PackageInRepositories $__packageName
                if ($__packageInRepos -and -not $knownPackages.ContainsKey($__packageName)){
                    $knownPackages[$__packageName] = $true
                }
                if (-not $knownPackages.ContainsKey($__packageName)){
                    $__mod = " # TODO:"
                }
                if ($ver -and $versions.Count -gt 1) {"$__mod '$__packageName$ver' #$($versions | Sort-Object | Join-String -Separator ",")" }
                    else {"$__mod '$__packageName$ver'"}
            }
            $dependencies = $dependencies | Join-String -Separator " \`n"
            $dependencies += " \`n"

            $conflicts += $requirements | Where-Object {$_.specs | Where-Object {$_.op.StartsWith("<") } } | ForEach-Object {
                $ver = $_.specs
                    | Where-Object { $_.op.StartsWith("<")}
                    | Sort-Object -Property "ver" -Descending
                    | ForEach-Object { ">=" + $_.ver }
                    | Select-Object -First 1
                " '$(Get-PythonPackageName $_.name)$ver'"
            }
            $conflicts = $conflicts | Join-String -Separator " \`n"

            Pop-Location
            Save-PKGBUILD
        }
        # break
    }
} finally {
    Pop-Location
}
