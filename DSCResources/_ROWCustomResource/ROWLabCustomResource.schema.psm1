#requires -Version 5

configuration ROWLabCustomResource {
<#
    .SYNOPSIS
        Adds/removes a RES ONE Workspace custom resource console.
    .NOTES
        Requires a relative path to the resource file. Will need to do some testing
        using Push/Pop-Location inside the LCM to see whether it works or not.
        
        pwrtech /addresource "resourcefile" /path="path" [/guid="guid"]
        pwrtech /delresource /path="fullpath" [/guid="guid"] (either path OR guid)
#>
    param (
        ## Source file path of the resource to be added.
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $Path,

        [Parameter(Mandatory)] [ValidateNotNull()]
        [System.Management.Automation.PSCredential] $Credential,

        ## RES ONE Workspace custom resource path, i.e. '\MyCustomResources\SubFolder'.
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $ResourcePath = '\',

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
        ## Make sure we only have the target path, excluding the filename
        $ResourcePath = $ResourcePath.TrimEnd($pathFileInfo.Name);
        if ($ResourcePath = '\') {
            $arguments = '/addresource "{0}"' -f $Path;
        }
        else {
            $arguments = '/addresource "{0}" /path="{1}"' -f $Path, $ResourcePath;
        }
    }
    elseif ($Ensure -eq 'Absent') {
        ## Remove custom resource
        if (-not $Resourcepath.EndsWith($pathFileInfo.name)) {
            $ResourcePath = $ResourcePath.TrimEnd('\');
            $ResourcePath = '{0}\{1}' -f $ResourcePath, $pathFileInfo.Name;
        }
        $arguments = '/delresource /path="{0}"' -f $ResourcePath;
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
        InstalledCheckRegValueData = 'ROWLabCustomResource';
        CreateCheckRegValue = $true;
        Ensure = $Ensure;
    }

} #end configuration ROWCustomResource
