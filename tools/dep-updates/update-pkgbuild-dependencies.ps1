param(
    [Parameter(Mandatory = $true)]
    [System.IO.DirectoryInfo]$Path
)

$ErrorActionPreference = "Stop"

# Canonicalized repo root
$RepoRoot = (Get-Item -Path "$PSScriptRoot/../..").FullName
$PackageMap = Get-ParsedConfig -Path "$RepoRoot/package-map.txt"

$pkgbuilds = (Get-ChildItem -Path "$Path/PKGBUILDs/*/PKGBUILD" -Recurse)

foreach ($pkgbuild in $pkgbuilds) {
    Write-Host "Checking $($pkgbuild.DirectoryName) for updates" -ForegroundColor Cyan

    $updateInfo = &"$PSScriptRoot/check-for-repo-changes.ps1" -Path $pkgbuild.FullName -PackageMap $PackageMap

    if (-not $updateInfo.updated) {
        continue
    }

    try{
        $latestVersion = $updateInfo.latestVersion
        $dir = $pkgbuild.Directory.FullName
        $pkgbase = $updateInfo.pkgbase
        $commitSha = $updateInfo.commit.Substring(0, 7)

        # # Commit the changes to PKGBUILD
        # git checkout -b "BUMP/$pkgbase-$latestVersion-$commitSha"
        # git add "$dir/"
        # git commit -m "BUMP $pkgbase to version $latestVersion`n`n$($updateInfo.commit)`n$($updateInfo.url)"
        
        # git push origin --set-upstream "BUMP/$pkgbase-$latestVersion-$commitSha"

        # # Create a pull request for each updated .SRCINFO file
        # gh pr create --base main `
        # --head "BUMP/$pkgbase-$latestVersion-$commitSha" `
        # --title "BUMP: $pkgbase to version $pkgver" `
        # --body "BUMP $pkgbase to version $latestVersion`n`n$($commitSha)`n$($updateInfo.url)"
        
    } finally {
        # git checkout main
    }
}