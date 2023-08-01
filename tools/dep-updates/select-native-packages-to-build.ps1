param(
    [Parameter(Mandatory=$true)]
    [string[]]$pkgbuilds,
    [string[]]$nativeArchitectures = @("aarch64", "armv7h"),
    [System.IO.DirectoryInfo]$packageRepoDir = $null
)

Import-Module $PSScriptRoot/../config-parser.psm1

$pkgbuildsDict = @{}

foreach ($arch in $nativeArchitectures) {
    $pkgbuildsDict["$arch"] = @()
}

foreach ($pkgbuild in $pkgbuilds) {
    $pkgbuildDir = (Get-Item $pkgbuild).Directory
    [array]$packages = (ConvertFrom-SrcInfo -lines (Get-Content (Join-Path $pkgbuildDir.FullName ".SRCINFO")))

    $packageGrouping = if ($packages.Count -gt 1) { "split" } else { "single" }
    foreach($package in $packages){
        $packageName = $package.pkgname
        [array]$packageArch = $package.arch
        foreach($nativeArch in $nativeArchitectures) {
            foreach ($packageArch in $packageArch) {
                $dir = if  ($null -ne $packageRepoDir -and (Test-Path $packageRepoDir.FullName)) { Join-Path $packageRepoDir.FullName $nativeArch } else { $pkgbuildDir.FullName } 
                # Check if the package declares the specific native architecture or is `any` arch
                if ($packageArch -eq $nativeArch -or $packageArch -eq "any") { 
                    $packageVersion = $packages[0].pkgver + "-" + $packages[0].pkgrel
                    $wildcard = "$packageName-$packageVersion-$packageArch.pkg.tar.*"
                    Write-Host "`n### Checking '$dir' for '$wildcard' ..." 
                    $files = Get-ChildItem -Filter $wildcard -Path $dir -File
                    $count = $files.Count
                    $names = $files | ForEach-Object { $_.Name } | Join-String -Separator " "
                    Write-Host "---- Found $count '$wildcard' package(s) in '$dir': $names"
                    
                    if ($count -ge 1) {
                        Write-Host "---- Skipping $packageGrouping package '$packageName', part of '$pkgbuild', as it has already been built for $nativeArch ..."
                        continue
                    } else {
                        if (-not ($pkgbuildsDict["$nativeArch"] -contains $pkgbuild)){
                            Write-Host "---- Adding '$pkgbuild' $packageGrouping package to the list of packages to build for $nativeArch ..."
                            $pkgbuildsDict["$nativeArch"] += $pkgbuild
                        }
                    }
                }
            }
        }
    }
}

return $pkgbuildsDict