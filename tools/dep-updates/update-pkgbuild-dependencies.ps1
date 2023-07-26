param(
    [Parameter(Mandatory = $true)]
    [System.IO.DirectoryInfo]$Path,

    [switch]$SkipRecentlyModified=$false
)

$ErrorActionPreference = "Stop"

Import-Module "$PSScriptRoot/dep-update-utils.psm1"

# Canonicalized repo root
$RepoRoot = (Get-Item -Path "$PSScriptRoot/../..").FullName
$PackageMap = Get-ParsedConfig -Path "$RepoRoot/package-map.txt"

$pkgbuilds = (Get-ChildItem -Path "$Path/PKGBUILDs/*/PKGBUILD" -Recurse)

foreach ($pkgbuild in $pkgbuilds) {
    if ($SkipRecentlyModified -and (Get-Item $pkgbuild.FullName).LastWriteTime -gt (Get-Date).AddDays(-1)) {
        Write-Host "Skipping $pkgbuild because it was recently modified" -ForegroundColor Yellow
        continue
    }

    Write-Host "Checking $($pkgbuild) for updates" -ForegroundColor Cyan

    $versionInfo = Get-VersionInformation $pkgbuild
    Write-Host "Getting release info from '$($versionInfo.url)'" -ForegroundColor Green
    $releaseInfo = Get-GithubRelease $versionInfo.url
    if ($null -eq $releaseInfo) {
        Write-Information "No release version information found for '$pkgbuild'"
        continue
    }

    if ($versionInfo.pkgver -eq $releaseInfo.version) {
        Write-Host "No update required for '$($versionInfo.pkgbase)'" -ForegroundColor Green
        continue
    }

    if ($versionInfo.pkgver -gt $releaseInfo.version) {
        Write-Host "No update required for '$($versionInfo.pkgbase)' because the package version $($versionInfo.pkgver) is greater than the latest stable release $($releaseInfo.version) " -ForegroundColor Green
        continue
    }

    if ($releaseInfo.isDraft -or $releaseInfo.isPrerelease) {
        Write-Host "No update required for '$($versionInfo.pkgbase)' because $($releaseInfo.version) is a pre-release" -ForegroundColor Green
        continue
    }

    $commitSha = $releaseInfo.commit.Substring(0, 7)
    $pkgbase = $versionInfo.pkgbase
    $latestVersion = $releaseInfo.version

    # check if a PR already exists for this version and commitSha
    $pr = gh pr list --search "$commitSha" --json number | ConvertFrom-Json
    if ($pr) {
        Write-Host "PR already exists for '$pkgbase' version '$latestVersion' and commit '$commitSha'" -ForegroundColor Green
        continue
    }

    $updateInfo = Update-Pkgbuild -VersionInfo $versionInfo -ReleaseInfo $releaseInfo -PackageMap $PackageMap
    
    if (-not $updateInfo.updated) {
        continue
    }

    try{
        $dir = $pkgbuild.Directory.FullName

        # Commit the changes to PKGBUILD
        git checkout -b "BUMP/$pkgbase-$latestVersion-$commitSha"
        git add "$dir/"
        git commit -m "BUMP $pkgbase to version $latestVersion`n`n$($updateInfo.commit)`n$($updateInfo.url)"
        
        git push origin --set-upstream "BUMP/$pkgbase-$latestVersion-$commitSha"

        # Create a pull request for each updated .SRCINFO file
        gh pr create --base main `
        --head "BUMP/$pkgbase-$latestVersion-$commitSha" `
        --title "BUMP: $pkgbase to version $pkgver" [$commitSha]`
        --body "BUMP $pkgbase to version $latestVersion`n`n$($commitSha)`n$($updateInfo.url)"
        
    } finally {
        git checkout main
    }
    
}