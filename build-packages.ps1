Import-Module ./config-parser.psm1

function Get-SrcInfos([System.IO.FileInfo[]]$pkgBuilds){
    $pkgBuilds | ForEach-Object {
        set-location $_.Directory.FullName
        $srcInfo = makepkg --printsrcinfo
        Get-ConfigFromLines $srcInfo
    }
}

$pkgbuilds = Get-ChildItem -Path "./PKGBUILDs/*/PKGBUILD" -Recurse

Push-Location
try{
    $deps = @{}
    if (-not (Test-Path "$PSScriptRoot/.srcinfo.json")){
        Write-Hose "Generating .srcinfo cache. This may take a while."
        Get-SrcInfos $pkgbuilds | ConvertTo-Json | Set-Content "$PSScriptRoot/.srcinfo.json"
    }
    $srcInfos = Get-Content "$PSScriptRoot/.srcinfo.json" | ConvertFrom-Json 
    foreach($srcInfo in $srcInfos){
        $pkgname = $srcInfo.pkgname
        $deps[$pkgname] = $srcInfo.depends | ForEach-Object { $_ -replace '>?=.*', '' }
    }
    
    foreach($pkgbuild in $pkgbuilds) {
        $path = $pkgbuild.FullName
        $dir = Split-Path $path -Parent
        $name = Split-Path $dir -Leaf

        if (Get-ChildItem -Path "$dir" -Filter "*.pkg.tar.*"){
            Write-Host "Package $name already built"
            continue
        }

        Set-Location $dir
        if ($name.StartsWith("python-")) {
            makepkg -d --noconfirm
        } else {
            makepkg --noconfirm
        }
    }
} finally {
    Pop-Location
}
