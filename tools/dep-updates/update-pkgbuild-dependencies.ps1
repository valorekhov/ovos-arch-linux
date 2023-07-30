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

    if (-not $versionInfo.url) {
        Write-Host "Skipping $pkgbuild because it doesn't specify a repo url" -ForegroundColor Red
        continue
    }

    if ($versionInfo.url.TrimEnd('/') -eq "https://github.com/OpenVoiceOS"){
        # Most of the non-tracking packages (i.e. packages native to this repo) will specify the url of the OVOS project. 
        # We skip those here
        Write-Host "Skipping $pkgbuild because it doesn't specify a repo in its url: $($versionInfo.url)" -ForegroundColor Yellow
        continue
    }

    Write-Host "Getting release info from '$($versionInfo.url)'" -ForegroundColor Green
    $releaseInfo = Get-GithubRelease $versionInfo.url
    if ($null -eq $releaseInfo) {
        Write-Information "No release version information found for '$pkgbuild'"
        continue
    }

    $currentPkgVer = $versionInfo.pkgver
    $latestVersion = $releaseInfo.version

    Write-Host "Current version: $currentPkgVer, Latest version: $latestVersion"

    $comp = Compare-PackageVersions -Version1 $currentPkgVer -Version2 $latestVersion

    if ($comp -eq 0) {
        Write-Host "No update required for '$($versionInfo.pkgbase)'" -ForegroundColor Green
        continue
    } elseif ($comp -gt 0) {
        Write-Host "No update required for '$($versionInfo.pkgbase)' because the package version $($currentPkgVer) is greater than the latest stable release $latestVersion" -ForegroundColor Green
        continue
    } elseif ($releaseInfo.isDraft -or $releaseInfo.isPrerelease) {
        Write-Host "No update required for '$($versionInfo.pkgbase)' because $latestVersion is a pre-release" -ForegroundColor Green
        continue
    }

    $commitSha = $releaseInfo.commit.Substring(0, 7)
    $pkgbase = $versionInfo.pkgbase

    # check if a PR already exists for this version and commitSha
    $pr = gh pr list --search "$commitSha" --json number | ConvertFrom-Json
    if ($pr) {
        Write-Host "PR already exists for '$pkgbase' version '$latestVersion' and commit '$commitSha'" -ForegroundColor Green
        continue
    }

    $updateInfo = Update-Pkgbuild -VersionInfo $versionInfo -ReleaseInfo $releaseInfo -PackageMap $PackageMap
    
    try{
        $dir = $pkgbuild.Directory.FullName

        Write-Host "Proceeding to open PR for '$pkgbase' version '$latestVersion' and commit '$commitSha'" -ForegroundColor Green

        # Commit the changes to PKGBUILD
        git checkout -b "BUMP/$pkgbase-$latestVersion-$commitSha"
        git add "$dir/"
        git commit -m "BUMP $pkgbase to version $latestVersion`n`n$($updateInfo.url)`ntag: $($releaseInfo.tagName)`ncommit: $commitSha"
        
        git push origin --set-upstream "BUMP/$pkgbase-$latestVersion-$commitSha"

        Write-Host "Pushed branch 'BUMP/$pkgbase-$latestVersion-$commitSha' to origin" -ForegroundColor Green

        # Create a pull request for the commit
        gh pr create --base main `
            --head "BUMP/$pkgbase-$latestVersion-$commitSha" `
            --title "BUMP: $pkgbase to version $latestVersion [$commitSha]" `
            --body "BUMP $pkgbase to version $latestVersion`n`n$($updateInfo.url)`ntag: $($releaseInfo.tagName)`ncommit: $commitSha"

        Write-Host "Created PR for '$pkgbase' version '$latestVersion' and commit '$commitSha'" -ForegroundColor Green      
    } finally {
        git checkout main
    }
    
}