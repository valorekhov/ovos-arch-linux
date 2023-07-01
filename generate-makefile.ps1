Import-Module ./config-parser.psm1

function Get-SrcInfos([System.IO.FileInfo[]]$pkgBuilds){
    $pkgBuilds | ForEach-Object {
        $srcInfoPath = "$($_.Directory)/.SRCINFO"
        if (Test-Path $srcInfoPath){
            $srcInfo = Get-Content $srcInfoPath
        } else {
            set-location $_.Directory.FullName
            $srcInfo = makepkg --printsrcinfo
            $srcInfo | Set-Content -Path $srcInfoPath
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
        | Where-Object { $knownPackages -contains $_ }
}

function New-Makefile([string]$dir, $deps){
    $sorted = $deps.Keys | Sort-Object

    Set-Content -Path "$dir/Makefile" `
                -Value (".PHONY: all clean extra`nRUN_MAKEPKG := makepkg --syncdeps --noconfirm --force --install" + `
                    "`n`nOVOS_PACKAGES := `$(notdir `$(wildcard PKGBUILDs/*))`n`nEXTRA_PACKAGES := `$(notdir `$(wildcard PKGBUILDs-extra/*))`n`nALL_PACKAGES := `$(OVOS_PACKAGES) + `$(EXTRA_PACKAGES)`n")

    "# The default target will build all OVOS packages and only those 'extra' dependent packages which are in use`nall: `$(OVOS_PACKAGES)`n" | Out-File -FilePath "$dir/Makefile" -Append -Encoding "UTF8"

    "extra: `$(EXTRA_PACKAGES)`n" | Out-File -FilePath "$dir/Makefile" -Append -Encoding "UTF8"

    "clean:`n`t@rm -rf ./{PKGBUILDs,PKGBUILDs-extra}/*/pkg ./{PKGBUILDs,PKGBUILDs-extra}/*/src ./{PKGBUILDs,PKGBUILDs-extra}/*/*.pkg.tar*" `
        + "`n`nuninstall:`n`t@pacman -Qq | sort | comm -12 - <(echo `"`$(ALL_PACKAGES)`" | tr ' ' '\n' | sort) | xargs sudo pacman -Rcns --noconfirm" `
        | Out-File -FilePath "$dir/Makefile" -Append -Encoding "UTF8"

    "%.pkg.tar.zst:`n`t`$(eval DIR := `$(shell echo '$*' | cut -d* -f1))`n`t@echo 'Building `$(DIR)'`n`t@cd `$(DIR) && `$(RUN_MAKEPKG)`n" | Out-File -FilePath "$dir/Makefile" -Append -Encoding "UTF8"

    function Get-DepName([Parameter(ValueFromPipeline = $true)] $name){
        process {
            $srcInfo = $srcInfos[$name]
            $pkgBaseDir = if ($srcInfo['_pkggroup'] -eq 'extra') {"PKGBUILDs-extra"} else {"PKGBUILDs"}
            "$pkgBaseDir/$name/*.pkg.tar.zst"
        }
    }

    $sorted | ForEach-Object {
        $key = $_
        $depends = $deps[$key] | Get-DepName
        $targetName = $key | Get-DepName
        "`n$($key): $($depends -join ' ') $targetName"  `
                # + "`n$($targetName):`n`t@echo 'Building $key'`n`t@cd '$pkgBaseDir/$key' && `$(RUN_MAKEPKG)`n" `
                | Out-File -FilePath "$dir/Makefile" -Append -Encoding "UTF8"
    }
}

New-Makefile "$PSScriptRoot" $deps


