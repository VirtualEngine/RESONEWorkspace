function Export-ROWBuildingBlock {
<#
    .SYNOPSIS
        Exports a RES ONE Workspace building block.
    .EXAMPLE
        Export-ROWBuildingBlock -Path .\RESWM.xml

        Exports the entire RES ONE Workspace environment into the 'RESWM.xml' building block file.
    .EXAMPLE
        Export-ROWBuildingBlock -Path .\RESWM.xml -Type Application,UserSetting

        Exports the the applications and user settings from the RES ONE Workspace environment into the 'RESWM.xml' building block file.
    .NOTES
        This cmdlet requires the RES ONE Workspace console (PWRTECH.EXE) to be installed.
#>
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'Type', ConfirmImpact = 'Low')]
    [OutputType([System.IO.FileInfo])]
    param (
        # Specifies a path to one or more locations. Wildcards are permitted.
        [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'Type')]
        [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'Guid')]
        [ValidateNotNullOrEmpty()]
        [System.String] $Path,

        # Specifies the specific feature(s) that need to be included in the Building Block. If not types are specified,
        # a Building Block of the entire environment will be created.
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'Type')]
        [ValidateSet(
            'Application',
            'AutomationTask',
            'ConfigMgr',
            'DataSource',
            'DirectoryService',
            'Email',
            'ExecuteCommand',
            'FolderRedirection',
            'FolderSync',
            'HomeDirectory',
            'Location',
            'Mapping',
            'Printer',
            'ProfileDirectory',
            'Registry',
            'Substitutes',
            'UserSetting',
            'Variable'
        )]
        [System.String[]] $Type,

        # Specified creating a Building Block for one specific object.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'Guid')]
        [System.Guid] $Guid,

        # Authentication username and password
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'Type')]
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'Guid')]
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()] $Credential,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'Type')]
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'Guid')]
        [System.Management.Automation.SwitchParameter]
        $PassThru
    )
    process {

        $paths = @();
        foreach ($filePath in $Path) {
            # Resolve any relative paths
            $paths += $psCmdlet.SessionState.Path.GetUnresolvedProviderPathFromPSPath($filePath);
        }

        foreach ($filePath in $paths) {

            if ($pscmdlet.ShouldProcess($filePath, 'Export')) {

                $PSBoundParameters['Path'] = $filePath;
                Export-ROWBuildingBlockFile @PSBoundParameters;

            }
        }

    } #end process
} #end function Export-ROWBuildingBlock

