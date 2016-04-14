#requires -Version 5

configuration ROWBuildingBlock {
<#
    .SYNOPSIS
        Adds/removes a RES ONE Workspace custom resource console.
#>
    param (
        ## Source file path of the resource to be added.
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $Path,

        ## Needs to be a valid RES ONE Workspace (domain) user.
        [Parameter(Mandatory)] [ValidateNotNull()]
        [System.Management.Automation.PSCredential] $Credential,

        ## The target node's architecture.
        [Parameter()] [ValidateSet('x64','x86')]
        [System.String] $Architecture = 'x64',

        [Parameter()] [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )

    Import-DscResource -ModuleName xPSDesiredStateConfiguration;

    $pathFileInfo = New-Object -TypeName 'System.IO.FileInfo' -ArgumentList $Path;
    $resourceName = $pathFileInfo.Name.Replace(' ','').Replace('.','');

    if ($Architecture -eq 'x64') {
        $pwrtechPath = 'C:\Program Files (x86)\RES Software\Workspace Manager\pwrtech.exe';
    }
    elseif ($Architecture -eq 'x86') {
        $pwrtechPath = 'C:\Program Files\RES Software\Workspace Manager\pwrtech.exe';
    }

    if ($Ensure -eq 'Present') {
        $arguments = '/add "{0}"' -f $Path;
    }
    elseif ($Ensure -eq 'Absent') {
        $arguments = '/del "{0}"' -f $Path;
    }

    xPackage $resourceName {
        Name = $resourceName;
        ProductId = '';
        Path = $pwrtechPath;
        Arguments = $arguments;
        ReturnCode = 0;
        PsDscRunAsCredential = $Credential;
        InstalledCheckRegKey = 'Software\VirtualEngine';
        InstalledCheckRegValueName = $resourceName;
        InstalledCheckRegValueData = 'ROWBuildingBlock';
        CreateCheckRegValue = $true;
        Ensure = $Ensure;
    }

} #end configuration ROWBuildingBlock
