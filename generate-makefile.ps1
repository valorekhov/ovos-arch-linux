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
        $ret = Get-ConfigFromLines $srcInfo
        $ret['_pkggroup'] = if ($_.Directory.FullName.Contains('-extra')) {"extra"} else {"main"}
        $ret
    }
}

$pkgbuilds = (Get-ChildItem -Path "./PKGBUILDs/*/PKGBUILD" -Recurse) + (Get-ChildItem -Path "./PKGBUILDs-extra/*/PKGBUILD" -Recurse) `
    | Where-Object { -not (Test-Path "$($_.Directory)/.pkgignore" -PathType Leaf) }

$deps = @{}
$srcInfos = @{}
$knownPackages = $pkgbuilds | ForEach-Object { $_.Directory.Name }
foreach($srcInfo in (Get-SrcInfos $pkgbuilds)){
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
        | Where-Object { $knownPackages -contains $_ }
}
$virtualPackages = Get-ConfigFromLines (Get-Content "./virtual-packages.txt") 

function New-Makefile([string]$dir, $deps){
    $sorted = $deps.Keys | Sort-Object

    Copy-Item -Path "$dir/templates/Makefile" -Destination "$dir/Makefile" -Force
    function Get-DepName([Parameter(ValueFromPipeline = $true)] $name){
        process {
            $srcInfo = $srcInfos[$name]
            $pkgBaseDir = if ($srcInfo['_pkggroup'] -eq 'extra') {"PKGBUILDs-extra"} else {"PKGBUILDs"}
            "$pkgBaseDir/$name/*.pkg.tar.zst"
        }
    }

    $sorted | ForEach-Object {
        $key = $_
        $depends = $deps[$key] #| Get-DepName
        $targetName = $key | Get-DepName
        "`n$($key): $($depends -join ' ') $targetName"  `
                # + "`n$($targetName):`n`t@echo 'Building $key'`n`t@cd '$pkgBaseDir/$key' && `$(RUN_MAKEPKG)`n" `
                | Out-File -FilePath "$dir/Makefile" -Append -Encoding "UTF8"
    }
}

New-Makefile "$PSScriptRoot" $deps


