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

        ## RES ONE Workspace Relay Server environment GUID.
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [System.Guid] $EnvironmentGuid,

        ## RES ONE Workspace Relay Server environment password.
        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()] $EnvironmentPassword,

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

        ## RES ONE Workspace Relay Server environment password is hashed.
        [Parameter()]
        [ValidateNotNull()]
        [System.Boolean] $EnvironmentPasswordIsHashed,

        ## Enable RES ONE Workspace Relay Server multicast discovery.
        [Parameter()]
        [ValidateNotNull()]
        [System.Boolean] $RelayServerDiscovery,

        ## Use specified RES ONE Workspace Relay Servers (including port number).
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String[]] $RelayServerList,

        ## Resolve RES ONE Workspace Relay Server via DNS.
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $RelayServerDnsName,

        ## Do not create a desktop shortcut
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.Boolean] $NoDesktopShortcut,

        ## Do not create a Start Menu shortcut
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.Boolean] $NoStartMenuShortcut,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String[]] $AddToWorkspace,

        ## RES ONE Workspace component version to be installed, i.e. 9.9.3
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $Version,

        ## The specified Path is a literal file reference (bypasses the Version and Architecture checks).
        [Parameter()]
        [System.Boolean] $IsLiteralPath,

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )

    $agentComponent = $Agent;
    if ($Agent -eq 'Full') {
        $agentComponent = 'FullAgent';
    }
    $setupPath = ResolveROWPackagePath -Path $Path -Component $agentComponent -Version $Version -IsLiteralPath:$IsLiteralPath -Verbose:$Verbose;
    [System.String] $msiProductName = GetWindowsInstallerPackageProperty -Path $setupPath -Property ProductName;
    $productName = $msiProductName.Trim();
    $targetResource = @{
        Path = $setupPath;
        ProductName = $productName;
        Ensure = if (GetProductEntry -Name $productName) { 'Present' } else { 'Absent' };
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

        ## RES ONE Workspace Relay Server environment GUID.
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [System.Guid] $EnvironmentGuid,

        ## RES ONE Workspace Relay Server environment password.
        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()] $EnvironmentPassword,

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

        ## RES ONE Workspace Relay Server environment password is hashed.
        [Parameter()]
        [ValidateNotNull()]
        [System.Boolean] $EnvironmentPasswordIsHashed,

        ## Enable RES ONE Workspace Relay Server multicast discovery.
        [Parameter()]
        [ValidateNotNull()]
        [System.Boolean] $RelayServerDiscovery,

        ## Use specified RES ONE Workspace Relay Servers (including port number).
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String[]] $RelayServerList,

        ## Resolve RES ONE Workspace Relay Server via DNS.
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $RelayServerDnsName,

        ## Do not create a desktop shortcut
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.Boolean] $NoDesktopShortcut,

        ## Do not create a Start Menu shortcut
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.Boolean] $NoStartMenuShortcut,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String[]] $AddToWorkspace,

        ## RES ONE Workspace component version to be installed, i.e. 9.9.3
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $Version,

        ## The specified Path is a literal file reference (bypasses the Version and Architecture checks).
        [Parameter()]
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

        ## RES ONE Workspace Relay Server environment GUID.
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [System.Guid] $EnvironmentGuid,

        ## RES ONE Workspace Relay Server environment password.
        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()] $EnvironmentPassword,

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

        ## RES ONE Workspace Relay Server environment password is hashed.
        [Parameter()]
        [ValidateNotNull()]
        [System.Boolean] $EnvironmentPasswordIsHashed,

        ## Enable RES ONE Workspace Relay Server multicast discovery.
        [Parameter()]
        [ValidateNotNull()]
        [System.Boolean] $RelayServerDiscovery,

        ## Use specified RES ONE Workspace Relay Servers (including port number).
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String[]] $RelayServerList,

        ## Resolve RES ONE Workspace Relay Server via DNS.
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $RelayServerDnsName,

        ## Do not create a desktop shortcut
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.Boolean] $NoDesktopShortcut,

        ## Do not create a Start Menu shortcut
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.Boolean] $NoStartMenuShortcut,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String[]] $AddToWorkspace,

        ## RES ONE Workspace component version to be installed, i.e. 9.9.3
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $Version,

        ## The specified Path is a literal file reference (bypasses the Version and Architecture checks).
        [Parameter()]
        [System.Boolean] $IsLiteralPath,

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )

    $agentComponent = $Agent;
    if ($Agent -eq 'Full') {
        $agentComponent = 'FullAgent';
    }
    $setupPath = ResolveROWPackagePath -Path $Path -Component $agentComponent -Version $Version -IsLiteralPath:$IsLiteralPath -Verbose:$Verbose;
    if ($Ensure -eq 'Present') {

        $arguments = @(
            ('/i "{0}"' -f $setupPath),
            ('RSENVGUID="{{{0}}}"' -f $EnvironmentGuid.ToString().ToUpper()),
            ('RSPASSWORD="{0}"' -f $EnvironmentPassword.GetNetworkCredential().Password)
        )

        if ($PSBoundParameters.ContainsKey('EnvironmentPasswordIsHashed')) {
            if ($EnvironmentPasswordIsHashed -eq $true) {
                $arguments += 'RSPWHASHED="yes"';
            }
        }

        if ($PSBoundParameters.ContainsKey('RelayServerDiscovery')) {
            if ($RelayServerDiscovery -eq $true) {
                $arguments += 'RSDISCOVER="yes"';
            }
        }

        if ($PSBoundParameters.ContainsKey('RelayServerList')) {
            $arguments += 'RSLIST="{0}"' -f ($RelayServerList -join ';');
        }

        if ($PSBoundParameters.ContainsKey('$RelayServerDnsName')) {
            $arguments += 'RSRESOLVE="{0}"' -f $RelayServerDnsName;
        }

        if ($PSBoundParameters.ContainsKey('InheritSettings')) {
            if ($InheritSettings -eq $true) {
                $arguments += 'INHERITSETTINGS="yes"';
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

    }
    elseif ($Ensure -eq 'Absent') {

        [System.String] $msiProductCode = GetWindowsInstallerPackageProperty -Path $setupPath -Property ProductCode;
        $arguments = @(
            ('/X{0}' -f $msiProductCode)
        )

    }

    ## Start install/uninstall
    $arguments += '/norestart';
    $arguments += '/qn';
    StartWaitProcess -FilePath "$env:WINDIR\System32\msiexec.exe" -ArgumentList $arguments -Verbose:$Verbose;

} #end function Set-TargetResource


## Import the ROWCommon library functions
$moduleRoot = Split-Path -Path $MyInvocation.MyCommand.Path -Parent;
$moduleParent = Split-Path -Path $moduleRoot -Parent;
Import-Module (Join-Path -Path $moduleParent -ChildPath 'ROWCommon') -Force;

Export-ModuleMember -Function *-TargetResource;
