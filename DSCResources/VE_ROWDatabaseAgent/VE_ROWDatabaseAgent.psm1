# Localized messages
data localizedData
{
    # culture="en-US"
    ConvertFrom-StringData @'
        ResourceIncorrectPropertyState  = Resource property '{0}' is NOT in the desired state. Expected '{1}', actual '{2}'.
        ResourceInDesiredState          = Resource '{0}' is in the desired state.
        ResourceNotInDesiredState       = Resource '{0}' is NOT in the desired state.
'@
}


function Get-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param (
        ## Install full agent including the console or agent only
        [Parameter(Mandatory)]
        [ValidateSet('Full','AgentOnly')]
        [System.String] $Agent,

        ## RES ONE Workspace database server name/instance (equivalient to DBSERVER).
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String] $DatabaseServer,

        ## RES ONE Workspace database name (equivalient to DBNAME).
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String] $DatabaseName,

        ## Microsoft SQL username/password to connect (equivalent to DBUSER/DBPASSWORD).
        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()] $Credential,

        ## File path containing the RES ONE Workspace MSIs or the literal path to the legacy console MSI.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Path,

        ## Inherit RES ONE Workspace connection settings
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [System.Boolean] $InheritSettings,

        ## Enable the RES ONE Workspace composer
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [System.Boolean] $EnableWorkspaceComposer,

        ## Use Database protocol encryption
        [Parameter()]
        [ValidateNotNull()]
        [System.Boolean] $UseDatabaseProtocolEncryption,

        ## Do not create a desktop shortcut
        [Parameter()]
        [ValidateNotNull()]
        [System.Boolean] $NoDesktopShortcut,

        ## Do not create a Start Menu shortcut
        [Parameter()]
        [ValidateNotNull()]
        [System.Boolean] $NoStartMenuShortcut,

        ## RES ONE Workspace Agent Service account (RES ONE Workspace 2015+ only)
        [Parameter()]
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()] $ServiceAccountCredential,

        ## Add RES ONE Workspace Agent to Workspace containers"
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String[]] $AddToWorkspace,

        ## RES ONE Workspace component version to be installed, i.e. 9.9.3
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $Version,

        ## The specified Path is a literal file reference (bypasses the Version and Architecture checks).
        [Parameter()]
        [ValidateNotNull()]
        [System.Boolean] $IsLiteralPath,

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )

    $agentComponent = $Agent;
    if ($Agent -eq 'Full') {
        $agentComponent = 'FullAgent';
    }
    $setupPath = Resolve-ROWPackagePath -Path $Path -Component $agentComponent -Version $Version -IsLiteralPath:$IsLiteralPath -Verbose:$Verbose;
    [System.String] $msiProductName = Get-WindowsInstallerPackageProperty -Path $setupPath -Property ProductName;
    $productName = $msiProductName.Trim();
    $targetResource = @{
        Path = $setupPath;
        ProductName = $productName;
        Ensure = if (Get-InstalledProductEntry -Name $productName) { 'Present' } else { 'Absent' };
    }
    return $targetResource;

} #end function Get-TargetResource


function Test-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        ## Install full agent including the console or agent only
        [Parameter(Mandatory)]
        [ValidateSet('Full','AgentOnly')]
        [System.String] $Agent,

        ## RES ONE Workspace database server name/instance (equivalient to DBSERVER).
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String] $DatabaseServer,

        ## RES ONE Workspace database name (equivalient to DBNAME).
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String] $DatabaseName,

        ## Microsoft SQL username/password to connect (equivalent to DBUSER/DBPASSWORD).
        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()] $Credential,

        ## File path containing the RES ONE Workspace MSIs or the literal path to the legacy console MSI.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Path,

        ## Inherit RES ONE Workspace connection settings
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [System.Boolean] $InheritSettings,

        ## Enable the RES ONE Workspace composer
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [System.Boolean] $EnableWorkspaceComposer,

        ## Use Database protocol encryption
        [Parameter()]
        [ValidateNotNull()]
        [System.Boolean] $UseDatabaseProtocolEncryption,

        ## Do not create a desktop shortcut
        [Parameter()]
        [ValidateNotNull()]
        [System.Boolean] $NoDesktopShortcut,

        ## Do not create a Start Menu shortcut
        [Parameter()]
        [ValidateNotNull()]
        [System.Boolean] $NoStartMenuShortcut,

        ## RES ONE Workspace Agent Service account (RES ONE Workspace 2015+ only)
        [Parameter()]
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()] $ServiceAccountCredential,

        ## Add RES ONE Workspace Agent to Workspace containers"
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String[]] $AddToWorkspace,

        ## RES ONE Workspace component version to be installed, i.e. 9.9.3
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $Version,

        ## The specified Path is a literal file reference (bypasses the Version and Architecture checks).
        [Parameter()]
        [ValidateNotNull()]
        [System.Boolean] $IsLiteralPath,

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )

    $targetResource = Get-TargetResource @PSBoundParameters;
    if ($Ensure -ne $targetResource.Ensure) {
        Write-Verbose -Message ($localizedData.ResourceIncorrectPropertyState -f 'Ensure', $Ensure, $targetResource.Ensure);
        Write-Verbose -Message ($localizedData.ResourceNotInDesiredState -f $targetResource.ProductName);
        return $false;
    }
    else {
        Write-Verbose -Message ($localizedData.ResourceInDesiredState -f $targetResource.ProductName);
        return $true;
    }

} #end function Test-TargetResource


function Set-TargetResource {
    [CmdletBinding()]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    param (
        ## Install full agent including the console or agent only
        [Parameter(Mandatory)]
        [ValidateSet('Full','AgentOnly')]
        [System.String] $Agent,

        ## RES ONE Workspace database server name/instance (equivalient to DBSERVER).
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String] $DatabaseServer,

        ## RES ONE Workspace database name (equivalient to DBNAME).
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String] $DatabaseName,

        ## Microsoft SQL username/password to connect (equivalent to DBUSER/DBPASSWORD).
        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()] $Credential,

        ## File path containing the RES ONE Workspace MSIs or the literal path to the legacy console MSI.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Path,

        ## Inherit RES ONE Workspace connection settings
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [System.Boolean] $InheritSettings,

        ## Enable the RES ONE Workspace composer
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [System.Boolean] $EnableWorkspaceComposer,

        ## Use Database protocol encryption
        [Parameter()]
        [ValidateNotNull()]
        [System.Boolean] $UseDatabaseProtocolEncryption,

        ## Do not create a desktop shortcut
        [Parameter()]
        [ValidateNotNull()]
        [System.Boolean] $NoDesktopShortcut,

        ## Do not create a Start Menu shortcut
        [Parameter()]
        [ValidateNotNull()]
        [System.Boolean] $NoStartMenuShortcut,

        ## RES ONE Workspace Agent Service account (RES ONE Workspace 2015+ only)
        [Parameter()]
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()] $ServiceAccountCredential,

        ## Add RES ONE Workspace Agent to Workspace containers"
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String[]] $AddToWorkspace,

        ## RES ONE Workspace component version to be installed, i.e. 9.9.3
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $Version,

        ## The specified Path is a literal file reference (bypasses the Version and Architecture checks).
        [Parameter()]
        [ValidateNotNull()]
        [System.Boolean] $IsLiteralPath,

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )

    $agentComponent = $Agent;
    if ($Agent -eq 'Full') {
        $agentComponent = 'FullAgent';
    }
    $setupPath = Resolve-ROWPackagePath -Path $Path -Component $agentComponent -Version $Version -IsLiteralPath:$IsLiteralPath -Verbose:$Verbose;
    if ($Ensure -eq 'Present') {

        $arguments = @(
            ('/i "{0}"' -f $setupPath),
            ('DBSERVER="{0}"' -f $DatabaseServer),
            ('DBNAME="{0}"' -f $DatabaseName),
            ('DBUSER="{0}"' -f $Credential.Username),
            ('DBPASSWORD="{0}"' -f $Credential.GetNetworkCredential().Password),
            ('DBTYPE="MSSQL"')
        )

        if ($PSBoundParameters.ContainsKey('InheritSettings')) {
            if ($InheritSettings -eq $true) {
                $arguments += 'INHERITSETTINGS="yes"';
            }
        }

        if ($PSBoundParameters.ContainsKey('UseDatabaseProtocolEncryption')) {
            if ($UseDatabaseProtocolEncryption -eq $true) {
                $arguments += 'DBPROTOCOLENCRYPTION="yes"';
            }
        }

        if ($PSBoundParameters.ContainsKey('EnableWorkspaceComposer')) {
            if ($InheritSettings -eq $true) {
                $arguments += 'AUTORUNCOMPOSER="yes"';
            }
        }

        if ($PSBoundParameters.ContainsKey('NoDesktopShortcut')) {
            if (-not $NoDesktopShortcut) {
                $arguments += 'AI_DESKTOP_SH="0"';
            }
        }

        if ($PSBoundParameters.ContainsKey('NoStartMenuShortcut')) {
            if (-not $NoStartMenuShortcut) {
                $arguments += 'AI_STARTMENU_SH="0"';
            }
        }

        if ($PSBoundParameters.ContainsKey('AddToWorkspace')) {
            $arguments += ('ADDTOWORKSPACE="{0}"' -f ($AddToWorkspace -join '|'));
        }

        if ($PSBoundParameters.ContainsKey('ServiceAccountCredential')) {
            $arguments += ('SERVICEACCOUNTNAME="{0}"' -f $ServiceAccountCredential.UserName);
            $arguments += ('SERVICEACCOUNTPASSWORD="{0}"' -f $ServiceAccountCredential.GetNetworkCredential().Password);
        }

    }
    elseif ($Ensure -eq 'Absent') {

        [System.String] $msiProductCode = Get-WindowsInstallerPackageProperty -Path $setupPath -Property ProductCode;
        $arguments = @(
            ('/X{0}' -f $msiProductCode)
        )

    }

    ## Start install/uninstall
    $arguments += '/norestart';
    $arguments += '/qn';
    Start-WaitProcess -FilePath "$env:WINDIR\System32\msiexec.exe" -ArgumentList $arguments -Verbose:$Verbose;

} #end function Set-TargetResource


## Import the ROWCommon library functions
$moduleRoot = Split-Path -Path $MyInvocation.MyCommand.Path -Parent;
$moduleParent = Split-Path -Path $moduleRoot -Parent;
Import-Module (Join-Path -Path $moduleParent -ChildPath 'ROWCommon') -Force;

Export-ModuleMember -Function *-TargetResource;
