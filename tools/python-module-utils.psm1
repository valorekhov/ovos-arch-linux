## Inline Python, space/indentation sensitive:
$pyDepCode = @"
import json
import importlib.metadata
from packaging.requirements import Requirement

def spec(specifier):
    ret = {}
    ret['__str'] = str(specifier)
    if specifier.operator:
        ret['op'] = specifier.operator
    if specifier.version:
        ret['ver'] = str(specifier.version)
    if specifier.prereleases:
        ret['pre'] = str(specifier.prereleases)
    return ret

def serializable_req(req_string):
    req = Requirement(req_string)
    ret = {}
    ret['__str'] = str(req_string)
    ret['name'] = req.name
    ret['specs'] = [spec(s) for s in req.specifier]
    ret['marker'] = str(req.marker or '')
    return ret

print(json.dumps([serializable_req(req) for req in importlib.metadata.requires('{{pkgname}}')]))
"@

function Get-PythonPackageName([string]$name, [hashtable]$packageMap){
    if ($packageMap.ContainsKey("pip:$name")){
        return $packageMap["pip:$name"]
    }
    $name = $name.Replace("_", "-").ToLowerInvariant()
    if (-not $name.StartsWith("python-")){
        $name = "python-$name"
    }
    if ($packageMap.ContainsKey($name)){
        return $packageMap[$name]
    }
    $name
}

function ConvertFrom-PythonModuleDependencies([string]$path, $packageMap){

    # Need to extract updated dependencies from the python package
    Push-Location $path | Out-Null
    try {
        python -m build --wheel --no-isolation
        $whl = Get-ChildItem -Path ./dist -Filter *.whl
        $moduleName = $whl.Name -replace '-.*$'
        $deps = $pyDepCode.Replace("{{pkgname}}", $moduleName) | python | ConvertFrom-Json
        $depends=New-Object System.Collections.ArrayList
        $conflicts=New-Object System.Collections.ArrayList
        $optdepends=New-Object System.Collections.ArrayList
        $comments=New-Object System.Collections.ArrayList
        foreach($dep in $deps){
            $packageName = Get-PythonPackageName $dep.name $packageMap
            if ($dep.specs.Count -eq 0){
                if ($dep.marker) {
                    $optdepends +=  "'$packageName' # $($dep.__str)"
                } else {
                    $depends += "'$packageName' # $($dep.__str)"
                }
            } else {
                foreach($spec in $dep.specs){
                    if ($spec.op.StartsWith('>') || $spec.op.StartsWith('=')){
                        if ($dep.marker) {
                            $optdepends += "'$packageName>=$($spec.ver)' # $($dep.__str)"
                        } else {
                            $depends += "'$packageName>=$($spec.ver)' # $($dep.__str)"
                        }
                    } elseif ($spec.op.StartsWith('<')) {
                        $conflicts += "'$packageName>=$($spec.ver)' # $($dep.__str)"
                    } elseif ($spec.op.StartsWith('~')) {
                        # This is a tilde requirement, which we skip
                    } else {
                        $comments += "# $($packageName): $($dep.__str)"
                    }
                }
            }
        }

        $depends = $depends | Sort-Object -Unique | Join-String -Separator "`n"
        $conflicts = $conflicts | Sort-Object -Unique | Join-String -Separator "`n"
        $optdepends = $optdepends | Sort-Object -Unique | Join-String -Separator "`n"
        $comments = $comments | Sort-Object -Unique | Join-String -Separator "`n"

        $modules = New-Object System.Collections.ArrayList
        foreach($dep in ($deps | ForEach-Object { Get-PythonPackageName $_.name $packageMap })){
            if (-not $modules.Contains($dep)){
                $modules.Add($dep)
            }
        }

        return @{
            depends = $depends
            conflicts = $conflicts
            optdepends = $optdepends
            comments = $comments
            modules = $modules
        }
    }
    finally {
        Pop-Location
    }
}