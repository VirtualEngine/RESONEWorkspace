function Export-ROWBuildingBlockFile {
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
    [CmdletBinding(DefaultParameterSetName = 'Type')]
    [OutputType([System.IO.FileInfo])]
    param (
        # Specifies a path to a location.
        [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'Type')]
        [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'Guid')]
        [ValidateNotNullOrEmpty()]
        [System.String] $Path,

        # Specifies the specific feature(s) that need to be included in the Building Block. If no types are specified,
        # a Building Block of the entire RES ONE Workspace environment will be created.
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

        # Specifies creating a Building Block for one specific RES ONE Workspace object.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'Guid')]
        [System.Guid] $Guid,

        # Authentication username and password. Only Windows authentication is supported.
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'Type')]
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'Guid')]
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()] $Credential,

        # Returns an object representing the building block files. By default, this cmdlet does not generate any output.
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'Type')]
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'Guid')]
        [System.Management.Automation.SwitchParameter]
        $PassThru
    )
    begin {

        $pwrtechPath = Get-ROWConsolePath;

    }
    process {

        if ($Path.Contains(' ')) {

            $exceptionMessage = $localizedData.PathCannotContainSpaceError -f $Path;
            $exception = New-Object System.ArgumentException $exceptionMessage;
            $category = [System.Management.Automation.ErrorCategory]::InvalidArgument;
            $errorRecord = New-Object System.Management.Automation.ErrorRecord $exception, 'PWRTECH', $category, $Path;
            $psCmdlet.WriteError($errorRecord);
            return;
        }

        $arguments = @(
            '/export',
            $Path
        );

        if ($PSBoundParameters.ContainsKey('Type')) {
            $exportTypes = [System.String]::Join(',', $Type);
            $arguments += '/type={0}' -f $exportTypes;
        }
        elseif ($PSBoundParameters.ContainsKey('Guid')) {
            $arguments += '/guid={{{0}}}' -f $Guid.ToString().ToUpper();
        }

        if ($PSBoundParameters.ContainsKey('Credential')) {

            $exitCode = Start-WaitProcess -FilePath $pwrtechPath -ArgumentList $arguments -Credential $Credential;
        }
        else {

            $exitCode = Start-WaitProcess -FilePath $pwrtechPath -ArgumentList $arguments;
        }

        if ($exitCode -ne 0) {

            $exceptionMessage = Get-ROWErrorCode -ExitCode $exitCode;
            $exception = New-Object System.Management.Automation.ItemNotFoundException $exceptionMessage;
            $category = [System.Management.Automation.ErrorCategory]::InvalidOperation;
            $errorRecord = New-Object System.Management.Automation.ErrorRecord $exception, 'PWRTECH', $category, $Path;
            $psCmdlet.WriteError($errorRecord);
        }
        else {

            if ($PassThru -and (Test-Path -Path $Path)) {

                $buildingBlockXml = Get-Item -Path $Path;
                Write-Output -InputObject $buildingBlockXml;
                $buildingBlockXbbFilename = '{0}.xbb' -f $buildingBlockXml.BaseName;
                $buildingBlockXbbPath = Join-Path -Path $buildingBlockXml.DirectoryName -ChildPath $buildingBlockXbbFilename;

                if (Test-Path -Path $buildingBlockXbbPath) {
                    Write-Output -InputObject (Get-Item -Path $buildingBlockXbbPath);
                }
            }
        }

    } #end process
} #end function Export-ROWBuildingBlockFile
