param(
    # RebuildSrcInfos and SkipSrcInfoCheck are mutually exclusive
    [Parameter(Mandatory = $false, ParameterSetName = 'SrcInfos')]
    [switch]$SkipSrcInfoCheck = $false,
    [Parameter(Mandatory = $false, ParameterSetName = 'SrcInfos')]
    [switch]$RebuildSrcInfos = $false  
)

Import-Module $PSScriptRoot/config-parser.psm1

# Canonicalized repo root
$RepoRoot = (Get-Item -Path "$PSScriptRoot/..").FullName

function Get-SrcInfos([System.IO.FileInfo[]]$pkgBuilds){
    $pkgBuilds | ForEach-Object {
        $srcInfoPath = "$($_.Directory)/.SRCINFO"
        $scrInfoExists = Test-Path $srcInfoPath -PathType Leaf
        if (-not $SkipSrcInfoCheck){
            if ($RebuildSrcInfos -or ($scrInfoExists -and ((Get-ChildItem -Hidden $srcInfoPath).LastWriteTime -lt $_.LastWriteTime))){
                Remove-Item -Force $srcInfoPath
                $scrInfoExists = $false
            }
        }
        if ($scrInfoExists){
            $srcInfo = Get-Content $srcInfoPath
        } else {
            Push-Location
            try {
                Set-Location $_.Directory.FullName
                Write-Host "Generating SRCINFO for $($_.Directory.FullName)"
                $srcInfo = makepkg --printsrcinfo
                $srcInfo | Set-Content -Path $srcInfoPath
            } finally {
                Pop-Location
            }
        }
        $packages = ConvertFrom-SrcInfo $srcInfo
        foreach($pkg in $packages){
            # $pkg['_pkggroup'] = if ($_.Directory.FullName.Contains('-extra')) {"extra"} 
            #         else { if ($_.Directory.FullName.Contains('AUR/')) {"aur"} else {"main"} }

            $pkg['_folder'] = $_.Directory.FullName.Replace("$RepoRoot/", "")
        }
        $packages
    }
    | % { $_ } # Flatten array
}

mkdir -p "$RepoRoot/AUR"
bash "$PSScriptRoot/aur-repo.sh" "$RepoRoot/AUR/" "$RepoRoot/aur.lock"

$ignorePackages = Get-Content "$RepoRoot/package-ignore.txt"

$pkgbuilds = (Get-ChildItem -Path "$RepoRoot/PKGBUILDs/*/PKGBUILD" -Recurse) `
        + (Get-ChildItem -Path "$RepoRoot/PKGBUILDs-extra/*/PKGBUILD" -Recurse) `
        + (Get-ChildItem -Path "$RepoRoot/AUR/*/PKGBUILD" -Recurse) `
    | Where-Object { -not (Test-Path "$($_.Directory)/.pkgignore" -PathType Leaf) }
    | Where-Object { -not $ignorePackages.Contains($_.Directory.Name) }

$virtualPackages = Get-ConfigFromLines (Get-Content "$RepoRoot/virtual-packages.txt") 

$deps = @{}
$srcInfos = @{}
$srcInfoList = Get-SrcInfos $pkgbuilds
$knownPackages = @{}
foreach($srcInfo in $srcInfoList){
    $knownPackages[$srcInfo.pkgname] = $true 
    if ($srcInfo.provides){
        foreach($prov in $srcInfo.provides){
            $knownPackages[$prov] = $true
            if (-not $virtualPackages[$prov]){
                # We want the preference for resolutions to be given to 
                # to the entries in virtual-packages.txt. Therefore we don't
                # overwrite them here.
                $virtualPackages[$prov] = $srcInfo.pkgname
            }
        }
    }
}
Write-Host "Got " $knownPackages.Count " known packages"

foreach($srcInfo in $srcInfoList){
    $pkgname = $srcInfo.pkgname
    $srcInfos[$pkgname] = $srcInfo
    $deps[$pkgname] = $srcInfo.depends `
        | ForEach-Object { $_ -replace '>?=.*', '' } `
        | ForEach-Object { 
            if ($virtualPackages.ContainsKey($_)){
                $virtualPackages[$_]
            } else {
                $_
            }
        }
        | Where-Object { $knownPackages.ContainsKey($_) }
}

function New-Makefile([string]$dir, $deps){
    $sorted = $deps.Keys | Sort-Object

    Copy-Item -Path "$PSScriptRoot/templates/Makefile" -Destination "$dir/Makefile" -Force
    function Get-DepName([Parameter(ValueFromPipeline = $true)] $name){
        process {
            $srcInfo = $srcInfos[$name]
            if (-not $srcInfo){
                Write-Host "No SRCINFO for $name"
            }
            $pkgBaseDir = $srcInfo['_folder']
            "$pkgBaseDir/*.pkg.tar.zst"
        }
    }

    $sorted | ForEach-Object {
        $key = $_
        $depends = $deps[$key] #| Get-DepName
        $targetName = $key | Get-DepName
        if ($targetName.StartsWith("AUR/")){
            $depends = @("aur-repo") + $depends
        }
        "`n$($key): $($depends -join ' ') $targetName"  `
                | Out-File -FilePath "$dir/Makefile" -Append -Encoding "UTF8"
    }

    $ignorePackages | ForEach-Object {
        "`n$($_): # Ignored" | Out-File -FilePath "$dir/Makefile" -Append -Encoding "UTF8"
    }
}

New-Makefile "$RepoRoot/" $deps
Write-Host "Done"
