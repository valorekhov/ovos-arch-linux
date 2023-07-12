Import-Module ./config-parser.psm1

function Get-SrcInfos([System.IO.FileInfo[]]$pkgBuilds){
    $pkgBuilds | ForEach-Object {
        $srcInfoPath = "$($_.Directory)/.SRCINFO"
        $scrInfoExists = Test-Path $srcInfoPath -PathType Leaf
        if ($scrInfoExists -and ((Get-ChildItem -Hidden $srcInfoPath).LastWriteTime -lt $_.LastWriteTime)){
            Remove-Item -Force $srcInfoPath
            $scrInfoExists = $false
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
            $pkg['_folder'] = $_.Directory.FullName.Replace("$PSScriptRoot/", "")
        }
        $packages
    }
    | % { $_ } # Flatten array
}

$pkgbuilds = (Get-ChildItem -Path "./PKGBUILDs/*/PKGBUILD" -Recurse) `
        + (Get-ChildItem -Path "./PKGBUILDs-extra/*/PKGBUILD" -Recurse) `
        + (Get-ChildItem -Path "./AUR/*/PKGBUILD" -Recurse) `
    | Where-Object { -not (Test-Path "$($_.Directory)/.pkgignore" -PathType Leaf) }

$virtualPackages = Get-ConfigFromLines (Get-Content "./virtual-packages.txt") 

$deps = @{}
$srcInfos = @{}
$srcInfoList = Get-SrcInfos $pkgbuilds
$knownPackages = @{}
foreach($srcInfo in $srcInfoList){
    $knownPackages[$srcInfo.pkgname] = $true 
    if ($srcInfo.provides){
        foreach($prov in $srcInfo.provides){
            $knownPackages[$prov] = $true
            $virtualPackages[$prov] = $srcInfo.pkgname
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

    Copy-Item -Path "$dir/templates/Makefile" -Destination "$dir/Makefile" -Force
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
                # + "`n$($targetName):`n`t@echo 'Building $key'`n`t@cd '$pkgBaseDir/$key' && `$(RUN_MAKEPKG)`n" `
                | Out-File -FilePath "$dir/Makefile" -Append -Encoding "UTF8"
    }
}

mkdir -p "$PSScriptRoot/AUR"
bash ./aur-repo.sh "$PSScriptRoot/AUR/" "$PSScriptRoot/aur.lock"
New-Makefile "$PSScriptRoot" $deps
Write-Host "Done"
