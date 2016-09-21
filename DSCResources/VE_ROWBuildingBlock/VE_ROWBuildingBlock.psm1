data localizedData {
    # Localized messages; culture="en-US"
    ConvertFrom-StringData @'
        CannotFindPathError            = Cannot find path '{0}' because it does not exist.

        ResourceCorrectPropertyState   = Resource property '{0}' is in the desired state.
        ResourceIncorrectPropertyState = Resource property '{0}' is NOT in the desired state. Expected '{1}', actual '{2}'.
        ResourceInDesiredState         = Resource '{0}' is in the desired state.
        ResourceNotInDesiredState      = Resource '{0}' is NOT in the desired state.
        ImportingBuildingBlock         = Importing building block '{0}'.
        DeletingBuildingBlock          = Deleting building block '{0}'.
'@
}

#region Private

function SetBuildingBlockFileHash {
<#
    .SYNOPSIS
        Updates the registry with friendly names and hash values.
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [System.String] $RegistryName,

        [Parameter(Mandatory)]
        [System.String] $FileHash
    )
    process {

        if (-not (Test-Path -Path $script:DefaultRegistryPath -PathType Container)) {
            $registryParentPath = Split-Path -Path $script:DefaultRegistryPath -Parent;
            $registryKeyName = Split-Path -Path $script:DefaultRegistryPath -Leaf;
            [ref] $null = New-Item -Path $registryParentPath -ItemType Directory -Name $registryKeyName;
        }

        [ref] $null = Set-ItemProperty -Path $script:DefaultRegistryPath -Name $RegistryName -Value $FileHash;

    } #end process
} #end function SetBuildingBlockFileHash


function ResolveBuildingBlock {
<#
    .SYNOPSIS
        Returns a list of resolved RES ONE Workspace building block files/hashes.
#>
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param (
        ## File path containing RES ONE Workspace Manager building blocks.
        [Parameter(Mandatory)]
        [System.String] $Path
    )
    process {

        $paths = @()
        foreach ($filePath in $Path) {

            if (-not (Test-Path -Path $filePath)) {

                $exMessage = $localizedData.CannotFindPathError -f $filePath;
                $ex = New-Object System.Management.Automation.ItemNotFoundException $exMessage;
                $category = [System.Management.Automation.ErrorCategory]::ObjectNotFound;
                $errRecord = New-Object System.Management.Automation.ErrorRecord $ex, 'PathNotFound', $category, $filePath;
                $psCmdlet.WriteError($errRecord);
                continue;
            }

            # Resolve any wildcards that might be in the path
            $provider = $null;
            $paths += $psCmdlet.SessionState.Path.GetResolvedProviderPathFromPSPath($filePath, [ref] $provider);

        }

        foreach ($filePath in $paths) {
            Write-Output -InputObject ([PSCustomObject] @{
                Path = $filePath;
                FileHash = (Get-FileHash -Path $filePath -Algorithm MD5).Hash;
                RegistryName = (Split-Path -Path $filePath -Leaf).Replace(' ','').Replace('-','').Replace('.','_');
            });
        }

    } #end process
} #end function ResolveBuildingBlock

#endregion Private

function Get-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param (
        ## RES ONE Workspace database server name/instance (equivalient to DBSERVER).
        [Parameter(Mandatory)]
        [System.String] $Path,

        ## RES ONE Workspace authentication credential.
        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()] $Credential,

        ## Overwrite existing objects in the RES ONE Workspace database.
        [Parameter()]
        [System.Boolean] $Overwrite,

        ## Remove objects in the building block from the RES ONE Workspace database.
        [Parameter()]
        [System.Boolean] $Delete,

        ## Delete the building block from disk after import.
        [Parameter()]
        [System.Boolean] $DeleteFromDisk
    )
    process {

        $buildingBlocks = ResolveBuildingBlock -Path $Path;
        foreach ($bb in $buildingBlocks) {
            Write-Output -InputObject @{ Path = $bb.Path; }
        }

    }
} #end function Get-TargetResource


function Test-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        [Parameter(Mandatory)]
        [System.String] $Path,

        ## RES ONE Workspace authentication credential.
        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()] $Credential,

        ## Overwrite existing objects in the RES ONE Workspace database.
        [Parameter()]
        [System.Boolean] $Overwrite,

        ## Remove objects in the building block from the RES ONE Workspace database.
        [Parameter()]
        [System.Boolean] $Delete,

        ## Delete the building block from disk after import.
        [Parameter()]
        [System.Boolean] $DeleteFromDisk
    )
    process {

        $inCompliance = $true;
        $buildingBlocks = ResolveBuildingBlock -Path $Path;

        foreach ($bb in $buildingBlocks) {

            $registryName = $bb.RegistryName;
            $registryHash = (Get-ItemProperty -Path $script:DefaultRegistryPath -Name $bb.RegistryName -ErrorAction SilentlyContinue).$RegistryName;
            if ($bb.FileHash -ne $registryHash) {

                Write-Verbose -Message ($localizedData.ResourceIncorrectPropertyState -f $bb.RegistryName, $bb.FileHash, $registryHash);
                $inCompliance = $false;
            }
            else {

                Write-Verbose -Message ($localizedData.ResourceCorrectPropertyState -f $bb.RegistryName);
            }

        }

        if ($inCompliance) {

            Write-Verbose -Message ($localizedData.ResourceInDesiredState -f $Path);
            return $true;
        }
        else {

            Write-Verbose -Message ($localizedData.ResourceNotInDesiredState -f $Path);
            return $false;
        }

    }
} #end function Test-TargetResource


function Set-TargetResource {
    [CmdletBinding()]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    param (
        [Parameter(Mandatory)]
        [System.String] $Path,

        ## RES ONE Workspace authentication credential.
        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()] $Credential,

        ## Overwrite existing objects in the RES ONE Workspace database.
        [Parameter()]
        [System.Boolean] $Overwrite,

        ## Remove objects in the building block from the RES ONE Workspace database.
        [Parameter()]
        [System.Boolean] $Delete,

        ## Delete the building block from disk after import.
        [Parameter()]
        [System.Boolean] $DeleteFromDisk
    )
    process {

        $buildingBlocks = ResolveBuildingBlock -Path $Path;

        foreach ($bb in $buildingBlocks) {

            $registryName = $bb.RegistryName;
            $registryHash = (Get-ItemProperty -Path $script:DefaultRegistryPath -Name $bb.RegistryName -ErrorAction SilentlyContinue).$registryName;

            if ($bb.FileHash -ne $registryHash) {

                try {

                    ## Import the building block
                    $PSBoundParameters['Path'] = $bb.Path;
                    [ref] $null = $PSBoundParameters.Remove('DeleteFromDisk');
                    Write-Verbose -Message ($localizedData.ImportingBuildingBlock -f $bb.Path);
                    Import-ROWBuildingBlockFile @PSBoundParameters;

                    ## Update the registry/hash value
                    SetBuildingBlockFileHash -RegistryName $bb.RegistryName -FileHash $bb.FileHash;

                    if ($DeleteFromDisk) {
                        ## TODO: Needs to delete any associated .xbb file too
                        Write-Verbose -Message ($localizedData.DeletingBuildingBlock -f $bb.Path);
                        Remove-Item -Path $bb.Path -Force;
                    }
                }
                catch {

                    throw $_
                }
            }

        } #end foreach building block

    } #end process
} #end function Set-TargetResource


## Import the ROACommon library functions
$moduleRoot = Split-Path -Path $MyInvocation.MyCommand.Path -Parent;
$moduleParent = Split-Path -Path $moduleRoot -Parent;
Import-Module (Join-Path -Path $moduleParent -ChildPath 'ROWCommon') -Force;

$script:DefaultRegistryPath = 'HKLM:\SOFTWARE\Virtual Engine\RESONEWorkspaceDsc';

Export-ModuleMember -Function *-TargetResource;
