$pkgbuilds = Get-ChildItem -Path "./PKGBUILDs/*/PKGBUILD" -Recurse
Push-Location
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
Pop-Location