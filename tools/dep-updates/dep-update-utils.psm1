
Import-Module $PSScriptRoot/../config-parser.psm1
Import-Module $PSScriptRoot/../python-module-utils.psm1

function Get-VersionParts {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Version
    )

    $versionParts = $Version.Split('.')
    $partCount = $versionParts.Count

    if ($partCount -eq 3) {
        # Semver in the 1.2.3 format, possibly with python-style pre-release suffix a la 1.2.3a4
        $patchVersionRegex = '(\d+)([A-Za-z]*\d*)'
        if ($versionParts[2] -match $patchVersionRegex){
            return $versionParts[0], $versionParts[1], $Matches[1], $Matches[2]
        }
        return $versionParts[0], $versionParts[1], $versionParts[2], '0'
    } elseif ($partCount -eq 2) {
        return $versionParts[0], $versionParts[1], '0', '0'
    } elseif ($partCount -eq 1) {
        return $versionParts[0], '0', '0', '0'
    }

    return $versionParts
}

function Compare-PackageVersions {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Version1,

        [Parameter(Mandatory = $true)]
        [string]$Version2
    )

    $version1Parts = Get-VersionParts -Version $Version1
    $version2Parts = Get-VersionParts -Version $Version2

    #Write-Host  ($version1Parts)
    #Write-Host  ($version2Parts)
    
    # Compare major version
    if ([int]$version1Parts[0] -gt [int]$version2Parts[0]) {
        return 1
    }
    elseif ([int]$version1Parts[0] -lt [int]$version2Parts[0]) {
        return -1
    }

    # Compare minor version
    if ([int]$version1Parts[1] -gt [int]$version2Parts[1]) {
        return 1
    }
    elseif ([int]$version1Parts[1] -lt [int]$version2Parts[1]) {
        return -1
    }

    $version1Patch = [int]$version1Parts[2]
    $version1PreRelease = $version1Parts[3]

    $version2Patch = [int]$version2Parts[2]
    $version2PreRelease = $version2Parts[3]
 
    # Compare patch version
    if ($version1Patch -gt $version2Patch) {
        return 1
    }
    elseif ($version1Patch -lt $version2Patch) {
        return -1
    }

    # Compare pre-release version
    if ($version1PreRelease -eq $version2PreRelease) {
        return 0
    }
    elseif ($version1PreRelease -eq '') {
        return 1
    }
    elseif ($version2PreRelease -eq '') {
        return -1
    }
    else {
        return $version1PreRelease -gt $version2PreRelease ? 1 : -1
    }
}

function Get-VersionInformation([System.IO.FileInfo]$path){
    $dir = if ( (Get-Item $path) -is  [System.IO.DirectoryInfo] ) { $path.FullName } else { $path.Directory.FullName }
    $pkgbuild = if ( (Get-Item $path) -is  [System.IO.DirectoryInfo] ) { Join-Path $path.FullName "PKGBUILD" } else { $path.FullName }
    $srcInfo = "$dir/.SRCINFO"
    $pkgver = Select-String -Path $srcInfo -Pattern 'pkgver = (\S+)' | ForEach-Object { $_.Matches.Groups[1].Value }
    $url = Select-String -Path $srcInfo -Pattern 'url = (\S+)' | ForEach-Object { $_.Matches.Groups[1].Value }
    $name = Select-String -Path $pkgbuild -Pattern '_name=(\S+)' | ForEach-Object { $_.Matches.Groups[1].Value }
    @{
        'pkgbase' = (Get-Item $pkgbuild).Directory.Name 
        '_name' = $name
        'pkgver' = $pkgver
        'url' = $url
        'srcInfo' = $srcInfo
        'pkgbuild' = $pkgbuild
        'dir' = $dir
    }
}

function Get-GithubRelease([string]$url){
    # Extract GitHub organization and repository name from the URL
    $res = $url -match 'https://github.com/([^/]+)/([^/]+)'
    if (-not $res)
    {
        Write-Host "Unable to parse GitHub organization and repository name from URL '$url'" -ForegroundColor Red
        return
    }

    $org = $Matches[1]
    $repo = $Matches[2] 

    Write-Host "Checking '$org' for current version information on '$repo'" -ForegroundColor Green

    # Fetch the latest release version from the URL
    $headers = @{
        "Accept" = "application/vnd.github+json"
        "X-GitHub-Api-Version" = "2022-11-28"
        "User-Agent" = "ovos-updater-bot"
    }
    if ($env:GITHUB_TOKEN){
        $headers.Add("Authorization", "Bearer $env:GITHUB_TOKEN")
    }

    # Write-Host "Url: https://api.github.com/repos/$org/$repo/releases/latest"
    try{
        $release = Invoke-RestMethod -Uri "https://api.github.com/repos/$org/$repo/releases/latest" -Headers $headers
    } catch {
        Write-Host "Unable to fetch latest release information from GitHub API. Possibly due to a not having any releases?" -ForegroundColor Red
        return $null
    }
    $tagName = $release.tag_name
    $tag = Invoke-RestMethod -Uri "https://api.github.com/repos/$org/$repo/git/ref/tags/$tagName" -Headers $headers 

    $isPrerelease = $release.prerelease
    $isDraft = $release.draft
    $releaseVersion = $tagName.Replace('release/', '').TrimStart('v').TrimStart('V')

    return @{
        'tagName' = $tagName
        'version' = $releaseVersion
        'isPrerelease' = $isPrerelease
        'isDraft' = $isDraft
        'commit' = $tag.object.sha
        'tarballUrl' = $release.tarball_url
    }
}

function Set-PkgbuildVersion([System.IO.FileInfo]$path, [string]$version, [string]$commit) {
    $pkgbuildContent = Get-Content $pkgbuild
    $baseVerLegacyDetected = $false
    $pkgbuildContent = $pkgbuildContent | ForEach-Object {
        if ($_ -match '^\s*pkgver=') {
            "pkgver='$version'"
        } elseif ($_ -match '^\s*pkgrel=') {
            "pkgrel=00"
        } elseif ($_ -match '^\s*_commit=') {
            "_commit='$commit'"
        } elseif ($_ -match '^\s*_base_ver=') {
            $baseVerLegacyDetected = $true
            "_commit='$commit'"
        } else {
            $_
        }
    }
    $pkgbuildContent | Set-Content $pkgbuild
    if ($baseVerLegacyDetected) {
        Write-Host "WARNING: Legacy _base_ver variable detected. Changed refs to _commit" -ForegroundColor Yellow
        (Get-Content $pkgbuild -Raw) -replace '_base_ver', '_commit' | Set-Content $pkgbuild 
    }
}

function Set-PkgbuildDependencies([System.IO.FileInfo]$pkgbuild, $newDeps) {
    $modules = $newDeps.modules
    $modules = $modules | ForEach-Object { $_.Trim() }
    $skipping = $false
    $pkgbuildContent = Get-Content $pkgbuild | ForEach-Object {
        $line = $_ 
        if ( $modules | Where-Object { $line.TrimStart().TrimStart("'").StartsWith($_) }){
            # Skip this line as it will be replaced by one of the auto-generated lines
        } elseif ($line.Trim().Equals('#### End of automatically generated dependencies.')) {
            Write-Host "Stopping skipping"
            $skipping=$false
        } elseif ($skipping){
            
        } elseif ($line.Trim().Equals('#### Automatically generated dependencies. Do not edit.')) {
            $skipping=$true
        }  elseif ($_ -match '^\s*source=\(') {
            $skipping=$false
            @"
#### Automatically generated dependencies. Do not edit.
depends+=(
$($newDeps.depends)
)
conflicts+=(
$($newDeps.conflicts)
)
optdepends+=(
$($newDeps.optdepends)
)
$($newDeps.comments)
#### End of automatically generated dependencies.

"@ +  $line
        }  else {
            $line
        }
    }
    $pkgbuildContent | Set-Content $pkgbuild
}

# $releaseInfo = @{
#     'tagName' = 'v0.0.1'
#     'version' = '0.0.1'
#     'isPrerelease' = $false
#     'isDraft' = $false
#     'commit' = '1234567890'
#     'tarballUrl' = ''
# }

function Update-Pkgbuild($versionInfo, $releaseInfo, $PackageMap) {
    $pkgbuild = $versionInfo.pkgbuild
    $pkgDir = (Get-Item $pkgbuild).Directory.FullName
    $srcInfo = Join-Path $pkgDir ".SRCINFO"

    Write-Host "Updating '$pkgbuild' from '$($versionInfo.pkgver)' to '$($releaseInfo.version)'" -ForegroundColor Green

    Set-PkgbuildVersion $pkgbuild $releaseInfo.version $releaseInfo.commit

    $tmpPath = "/tmp/ovos-updater/$($versionInfo.pkgbase)";
    New-Item -ItemType Directory -Path $tmpPath -Force | Out-Null
    # Copy-Item -Path $($versionInfo.dir)/* -Destination $tmpPath/ -Recurse -Force

    $sourceUrl = bash -c "source `"$pkgbuild`"; echo `$source" | Select-Object -First 1
    Write-Host "Source URL: $sourceUrl"
    if ($sourceUrl -and $sourceUrl.StartsWith('http') -and -not (Test-Path "$tmpPath/$($versionInfo.pkgbase).tar.gz")) {
        Invoke-WebRequest -Uri $sourceUrl -OutFile "$tmpPath/$($versionInfo.pkgbase).tar.gz" -MaximumRedirection 10
    }

    # Limited .SRCINFO updates. To perform a full update, `makepkg --printsrcinfo > .SRCINFO` is needed
    Get-Content $srcInfo | ForEach-Object {
        $line = $_
        if ($line -match '^\s*pkgver\s*=') {
            "pkgver = $($releaseInfo.version)"
        } elseif ($line -match '^\s*pkgrel\s*=') {
            "pkgrel = 00"
        } else {
            $line
        }
    } | Set-Content $srcInfo
   

    if (Test-Path "$tmpPath/$($versionInfo.pkgbase).tar.gz" -PathType Leaf){
        tar -xzf "$tmpPath/$($versionInfo.pkgbase).tar.gz" -C $tmpPath --strip-components=1
        
        $newSha256 = sha256sum "$tmpPath/$($versionInfo.pkgbase).tar.gz" | ForEach-Object { $_.Split(' ')[0] }
        $oldSha256 = bash -c "source `"$pkgbuild`"; echo `$sha256sums" | Select-Object -First 1
        Write-Host "Replacing sha256sum '$oldSha256' with '$newSha256'" 
        sed -i "s/$oldSha256/$newSha256/" "$pkgbuild"
        sed -i "s/$oldSha256/$newSha256/" "$srcInfo"
    }
    
    if ((Test-Path "$tmpPath/setup.py") -or (Test-Path "$tmpPath/pyproject.toml")) {
        $newDeps =  ConvertFrom-PythonModuleDependencies -Path $tmpPath -PackageMap $PackageMap -DebugOutput $DebugOutput
        write-host "depends:" $newDeps.depends
        write-host "conflicts:" $newDeps.conflicts
        write-host "optdepends:" $newDeps.optdepends 
        write-host "comments:" $newDeps.comments

        if ($newDeps.modules -and $newDeps.modules.Count -gt 0) {
            Set-PkgbuildDependencies $versionInfo.pkgbuild $newDeps
        } else {
            Write-host "No requirements found in '$($versionInfo.pkgbase)'" -ForegroundColor Yellow
        }
    } else {
        Write-host "No Python requirements found in '$($versionInfo.pkgbase)'" -ForegroundColor Yellow
    }

    return @{
        'pkgbase' = $versionInfo.pkgbase
        'pkgver' = $releaseInfo.version
        'url' = $versionInfo.url
        'dir' = $versionInfo.dir
        'priorVersion' = $versionInfo.pkgver
        'latestVersion' = $releaseInfo.version
        'isPreRelease' = $releaseInfo.isDraft -or $releaseInfo.isPrerelease
        'commit' = $releaseInfo.commit
    }
}
