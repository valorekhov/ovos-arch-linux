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
    Write-Hose "Generating .srcinfo cache. This may take a while."
    Get-SrcInfos $pkgbuilds | ConvertTo-Json | Set-Content "$PSScriptRoot/.srcinfo.json"
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
    # Iterate deps, generate Makefile
    Set-Content -Path "$dir/Makefile" -Value ".PHONY: all clean`nRUN_MAKEPKG := makepkg --syncdeps --noconfirm`n"
    $sorted = $deps.Keys | Sort-Object
    $sorted | ForEach-Object {
        $key = $_
        $depends = $deps[$key]
        "$($key): $($depends -join ' ')`n`t@echo 'Building $@'`n`t@cd $@ && `$(RUN_MAKEPKG)`n" `
                | Out-File -FilePath "$dir/Makefile" -Append -Encoding "UTF8"
    }
    $all = $sorted -join " \`n`t"
    "all: $all`n" | Out-File -FilePath "$dir/Makefile" -Append -Encoding "UTF8"

    "clean:`n`t@rm -rf ./*/pkg ./*/src`n" `
        | Out-File -FilePath "$dir/Makefile" -Append -Encoding "UTF8"
}

New-Makefile "$PSScriptRoot/PKGBUILDs" $deps


