function Import-ROWBuildingBlockFile {
<#
    .SYNOPSIS
        Import a RES ONE Workspace building block.
#>
    [CmdletBinding(DefaultParameterSetName = 'Path')]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param (
        # Specifies a path to one or more locations. Wildcards are permitted.
        [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'Path')]
        [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'PathCredential')]
        [SupportsWildcards()]
        [System.String] $Path,

        # Windows authentication username and password
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'PathCredential')]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()] $Credential,

        ## Overwrite existing objects in the RES ONE Workspace database.
        [Parameter()]
        [System.Boolean] $Overwrite,

        ## Remove objects in the building block from the RES ONE Workspace database.
        [Parameter()]
        [System.Boolean] $Delete
    )
    begin {

        $pwrtechPath = Get-ROWConsolePath;

    }
    process {

        $paths = @();
        if (-not (Test-Path -Path $Path)) {

            $exMessage = $localizedData.CannotFindPathError -f $Path;
            $ex = New-Object System.Management.Automation.ItemNotFoundException $exMessage;
            $category = [System.Management.Automation.ErrorCategory]::ObjectNotFound;
            $errRecord = New-Object System.Management.Automation.ErrorRecord $ex, 'PathNotFound', $category, $Path;
            $psCmdlet.WriteError($errRecord);
        }
        else {

            # Resolve any wildcards that might be in the path
            $provider = $null;
            $paths += $psCmdlet.SessionState.Path.GetResolvedProviderPathFromPSPath($Path, [ref] $provider);
        }

        foreach ($filePath in $paths) {

            $arguments = @();

            if (-not $Delete) {

                $arguments += '/add';
                $arguments += '"{0}"' -f $filePath;
                if (($PSBoundParameters.ContainsKey('Overwrite')) -and ($Overwrite -eq $true)) {

                    $arguments += '/overwrite';
                }
            }
            else {

                $arguments += '/del';
                $arguments += '"{0}"' -f $filePath;
            }

            if ($PSBoundParameters.ContainsKey('Credential')) {

                $exitCode = Start-WaitProcess -FilePath $pwrtechPath -ArgumentList $arguments -Credential $Credential;
            }
            else {

                $exitCode = Start-WaitProcess -FilePath $pwrtechPath -ArgumentList $arguments;
            }

            Write-Output -InputObject ([PSCustomObject] @{
                BuildingBlock = $filePath;
                ExitCode = $exitCode;
            });

        } #end foreach resolved path

    } #end process
} #end function Import-ROWBuildingBlockFile
