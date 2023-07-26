
Import-Module $PSScriptRoot/../config-parser.psm1
Import-Module $PSScriptRoot/../python-module-utils.psm1

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
        Write-Host "Unable to fetch latest release information from GitHub API. Possible missing release?" -ForegroundColor Red
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
    $pkgbuildContent = $pkgbuildContent | ForEach-Object {
        if ($_ -match '^\s*pkgver=') {
            "pkgver='$version'"
        } elseif ($_ -match '^\s*pkgrel=') {
            "pkgrel=00"
        } elseif ($_ -match '^\s*_commit=') {
            "_commit='$commit'"
        } else {
            $_
        }
    }
    $pkgbuildContent | Set-Content $pkgbuild
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
    Write-Host "Updating '$pkgbuild' from '$($versionInfo.pkgver)' to '$($releaseInfo.version)'" -ForegroundColor Green

    $updated = $false

    Set-PkgbuildVersion $pkgbuild $releaseInfo.version $releaseInfo.commit

    $tmpPath = "/tmp/ovos-updater/$($versionInfo.pkgbase)";
    New-Item -ItemType Directory -Path $tmpPath -Force | Out-Null
    # Copy-Item -Path $($versionInfo.dir)/* -Destination $tmpPath/ -Recurse -Force
    
    if (-not (Test-Path "$tmpPath/$($versionInfo.pkgbase).tar.gz")) {
        Invoke-WebRequest -Uri $releaseInfo.tarballUrl -OutFile "$tmpPath/$($versionInfo.pkgbase).tar.gz" -MaximumRedirection 10
    }
    tar -xzf "$tmpPath/$($versionInfo.pkgbase).tar.gz" -C $tmpPath --strip-components=1

    # TODO: Calculate sha256sum of the tarball and update the PKGBUILD by sourcing the PKGBUILD with bash
    # and getting the first sha256sum from the source array, then replacing the obtained value with the calculated one
    
    $newSha256 = sha256sum "$tmpPath/$($versionInfo.pkgbase).tar.gz" | ForEach-Object { $_.Split(' ')[0] }
    $oldSha256 = bash -c "source `"$pkgbuild`"; echo `$sha256sums" | Select-Object -First 1
    Write-Host "Replacing sha256sum '$oldSha256' with '$newSha256'" 
    sed -i "s/$oldSha256/$newSha256/" "$pkgbuild"
    
    if ((Test-Path "$tmpPath/setup.py") -or (Test-Path "$tmpPath/pyproject.toml")) {
        $newDeps =  ConvertFrom-PythonModuleDependencies -Path $tmpPath -PackageMap $PackageMap
        write-host "depends:" $newDeps.depends
        write-host "conflicts:" $newDeps.conflicts
        write-host "optdepends:" $newDeps.optdepends 
        write-host "comments:" $newDeps.comments

        if ($newDeps.modules -and $newDeps.modules.Count -gt 0) {
            Set-PkgbuildDependencies $versionInfo.pkgbuild $newDeps
        } else {
            Write-host "No requirements found in '$($versionInfo.pkgbase)'" -ForegroundColor Yellow
        }
        $updated = $true
    }

    # # Commit the changes to .SRCINFO
    # git add $pkgbuild
    # git commit -m "Update $pkgbuild to version $latest_version"

    return @{
        'pkgbase' = $versionInfo.pkgbase
        'pkgver' = $releaseInfo.version
        'url' = $versionInfo.url
        'dir' = $versionInfo.dir
        'priorVersion' = $versionInfo.pkgver
        'latestVersion' = $releaseInfo.version
        'isPreRelease' = $releaseInfo.isDraft -or $releaseInfo.isPrerelease
        'commit' = $releaseInfo.commit
        'updated' = $updated
    }
}
