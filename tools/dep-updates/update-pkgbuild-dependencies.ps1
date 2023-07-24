$pkgver = Select-String -Path $srcinfo_file -Pattern 'pkgver = (\S+)' | ForEach-Object { $_.Matches.Groups[1].Value }
$pkgbuild_file = Join-Path (Split-Path $srcinfo_file) "PKGBUILD"

# Update the PKGBUILD file with the latest version
(Get-Content $pkgbuild_file) -replace "pkgver='$pkgver'", "pkgver='$latest_version'" | Set-Content $pkgbuild_file
