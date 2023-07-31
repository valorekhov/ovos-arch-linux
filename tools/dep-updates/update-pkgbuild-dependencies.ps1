param(
    [Parameter(Mandatory = $true)]
    [System.IO.DirectoryInfo]$Path,

    [switch]$SkipRecentlyModified=$false
)

$ErrorActionPreference = "Stop"

Import-Module "$PSScriptRoot/dep-update-utils.psm1"
Import-Module "$PSScriptRoot/../config-parser.psm1"

# Canonicalized repo root
$RepoRoot = (Get-Item -Path "$PSScriptRoot/../..").FullName
$PackageMap = Get-ParsedConfig -Path "$RepoRoot/package-map.txt"

$pkgbuilds = (Get-ChildItem -Path "$Path/PKGBUILDs/*/PKGBUILD" -Recurse)

$archPackages = @{}
mkdir -p "/tmp/ovos-updater"
foreach($arch in @("x86_64", "aarch64", "armv7h") ){
    if (-not (Test-Path "/tmp/ovos-updater/ovos-arch.db.$arch.tar.gz")){
        Invoke-WebRequest -Uri "https://ovosarchlinuxpackages.blob.core.windows.net/ovos-arch/$arch/ovos-arch.db.tar.gz" -OutFile "/tmp/ovos-updater/ovos-arch.db.$arch.tar.gz"
    }
    $archPackages[$arch] = tar -tf "/tmp/ovos-updater/ovos-arch.db.$arch.tar.gz" | Where-Object { -not $_.EndsWith("/desc") }
}

function Find-MissingPackageInRepo([System.IO.DirectoryInfo]$pkgDir){
    $srcInfo = Join-Path $pkgDir ".SRCINFO"
    $sections = (ConvertFrom-SrcInfo -lines (Get-Content $srcInfo))
    $sections | ForEach-Object {
        $pkgname = $_.pkgname
        $pkgver = $_.pkgver
        $pkgrel = $_.pkgrel
        $version = "$pkgname-$pkgver-$pkgrel/"
        # Write-Host "Checking for $version"
        [array]$archs = $_.arch
        $missingArchs = @()
        foreach($arch in $archs){
            if ($arch -ne 'any' -and -not $archPackages.ContainsKey($arch)){
                Write-Host "$($pkgname): Arch $arch not found in online repo(s)" -ForegroundColor Red
                continue
            }
            if ($arch -eq "any"){
                $archPackages.Keys | ForEach-Object {
                    if (-not ($archPackages[$_] -contains $version)){
                        $missingArchs += $_
                    }
                }
            } else {
                if (-not ($archPackages[$arch] -contains $version)){
                    $missingArchs += $arch
                }
            } 
        }
        $missingArchs = $missingArchs | Sort-Object -Unique
        if ($missingArchs.Count -gt 0){
            Write-Host "Package $version not found in online repo(s): $missingArchs`nClosest matches:" -ForegroundColor Red
            foreach($arch in $missingArchs){
                $title = "[${arch}] $version not found in OVOS-Arch repo"
                $body = "The package $version was not found in the OVOS-Arch repo for the $arch architecture. Current versions:" `
                + ($archPackages[$arch] | Where-Object { $_.StartsWith($pkgname) } | Sort-Object)

                # check if an issue already exists for this version and architecure,
                # if not create one
                $issue = gh issue list --search "$title" --json number | ConvertFrom-Json
                if ($issue.Count -eq 0){
                    Write-Host "Creating issue for $version on $arch" -ForegroundColor Yellow
                    gh issue create --title "$title" --body "$body"
                } else {
                    Write-Host "Issue already exists for $version on $arch" -ForegroundColor Yellow
                }
            }
        }
    }
}

foreach ($pkgbuild in $pkgbuilds) {
    if ($SkipRecentlyModified -and (Get-Item $pkgbuild.FullName).LastWriteTime -gt (Get-Date).AddDays(-1)) {
        Write-Host "Skipping $pkgbuild because it was recently modified" -ForegroundColor Yellow
        continue
    }

    Find-MissingPackageInRepo -PkgDir $pkgbuild.Directory.FullName

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