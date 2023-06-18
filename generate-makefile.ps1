Import-Module ./config-parser.psm1

function Get-SrcInfos([System.IO.FileInfo[]]$pkgBuilds){
    $pkgBuilds | ForEach-Object {
        set-location $_.Directory.FullName
        $srcInfo = makepkg --printsrcinfo
        Get-ConfigFromLines $srcInfo
    }
}

$pkgbuilds = Get-ChildItem -Path "./PKGBUILDs/*/PKGBUILD" -Recurse

$deps = @{}
if (-not (Test-Path "$PSScriptRoot/.srcinfo.json")){
    Write-Host "Generating .srcinfo cache. This may take a while."
    Push-Location
    try{
        Get-SrcInfos $pkgbuilds | ConvertTo-Json | Set-Content "$PSScriptRoot/.srcinfo.json"
    } finally {
        Pop-Location
    }
}
$srcInfos = Get-Content "$PSScriptRoot/.srcinfo.json" | ConvertFrom-Json 
$knownPackages = $pkgbuilds | ForEach-Object { $_.Directory.Name }
foreach($srcInfo in $srcInfos){
    $pkgname = $srcInfo.pkgname
    $deps[$pkgname] = $srcInfo.depends `
        | ForEach-Object { $_ -replace '>?=.*', '' } `
        | Where-Object { $knownPackages -contains $_ }
}

function New-Makefile([string]$dir, $deps){
    $sorted = $deps.Keys | Sort-Object
    $all = $sorted -join " \`n`t"
    Set-Content -Path "$dir/Makefile" -Value ".PHONY: all clean`nRUN_MAKEPKG := makepkg --syncdeps --noconfirm --force --install`nPACKAGES := $all`n"

    $sorted | ForEach-Object {
        $key = $_
        $depends = $deps[$key]
        $targetName = "$key-%.pkg.tar.zst"
        "# $($key)`n$($key): $($depends -join ' ') $targetName" + `
                 "`n$($targetName):`n`t@echo 'Building $key'`n`t@cd '$key' && `$(RUN_MAKEPKG)`n" `
                | Out-File -FilePath "$dir/Makefile" -Append -Encoding "UTF8"
    }
    "all: `$(PACKAGES)`n" | Out-File -FilePath "$dir/Makefile" -Append -Encoding "UTF8"

    "clean:`n`t@rm -rf ./*/pkg ./*/src ./*/src/*.pkg.tar*" `
        + "`n`nuninstall:`n`t@pacman -Qq | sort | comm -12 - <(echo `"`$(PACKAGES)`" | tr ' ' '\n' | sort) | xargs sudo pacman -Rcns --noconfirm" `
        | Out-File -FilePath "$dir/Makefile" -Append -Encoding "UTF8"
}

New-Makefile "$PSScriptRoot/PKGBUILDs" $deps


