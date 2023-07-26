param(
    [Parameter(Mandatory = $true)]
    [System.IO.FileInfo]$Path, 
    [Parameter(Mandatory = $true)]
    [System.Collections.Hashtable]$PackageMap
)

Import-Module "$PSScriptRoot/dep-update-utils.psm1"

$versionInfo = Get-VersionInformation $Path
Write-Host "Getting release info from '$($versionInfo.url)'" -ForegroundColor Green
$releaseInfo = Get-GithubRelease $versionInfo.url
if ($null -eq $releaseInfo) {
    Write-Information "No release version information found for '$Path'"
    return @{ 'updated' = $false }
}

if (-not $releaseInfo.isDraft -and -not $releaseInfo.isPrerelease `
-and $versionInfo.pkgver -ne $releaseInfo.version) {

    return Update-Pkgbuild -VersionInfo $versionInfo -ReleaseInfo $releaseInfo -PackageMap $PackageMap
}

return @{ 'updated' = $false }