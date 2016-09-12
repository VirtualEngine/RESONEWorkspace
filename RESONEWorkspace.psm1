$moduleRoot = Split-Path -Path $MyInvocation.MyCommand.Path -Parent;
$moduleSrcPath = Join-Path -Path $moduleRoot -ChildPath 'Src';
Get-ChildItem -Path $moduleSrcPath -Include *.ps1 -Exclude '*.Tests.ps1' -Recurse |
    ForEach-Object {
        Write-Verbose -Message ('Importing library\source file ''{0}''.' -f $_.FullName);
        . $_.FullName;
    }


## Import the \DSCResources\ROACommon common library functions
Import-Module (Join-Path -Path $moduleRoot -ChildPath '\DSCResources\ROWCommon') -Force;
