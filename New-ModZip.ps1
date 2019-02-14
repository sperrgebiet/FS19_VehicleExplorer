$srcPath = $PSScriptRoot
$dstPath = $PSScriptRoot
$dstFilename = "FS19_VehicleExplorer.zip"

$tmpPath = Join-Path $env:TMP "TmpZip"

$ignorelist = get-content (Join-Path $srcPath ".gitignore")
$ignorelist += "/New-ModZip.ps1"

if($srcPath.Length -gt 0 -and $dstPath.Length -gt 0)
{
    Remove-Item (Join-Path $dstPath $dstFilename) -Force

    [array]$allFiles = Get-ChildItem -Path $srcPath -Exclude {.gitignore} -Recurse -Attributes !Directory
    [array]$allFolders = Get-ChildItem -Path $srcPath -Exclude {.gitignore} -Recurse -Attributes Directory


    New-Item -ItemType Directory -Path $tmpPath -Force

    foreach($f in $allFolders)
    {
        New-Item -ItemType Directory -Path $f.FullName.ToString().Replace($srcPath, $tmpPath)
    }


    foreach($f in $allFiles)
    {   
        if( -not $ignorelist.contains($f.FullName.ToString().Replace("$srcPath", "").Replace("\","/")) )
        {
            #$F.FullName
            #$F.FullName.ToString().Replace($srcPath, $tmpPath)
            Copy-Item $f.FullName -Destination $f.FullName.ToString().Replace($srcPath, $tmpPath) -Force
        }
    }

    Compress-Archive -Path (Join-Path $tmpPath "\*") -DestinationPath (Join-Path $dstPath $dstFilename)

    Remove-Item -Path $tmpPath -Recurse -Force
}