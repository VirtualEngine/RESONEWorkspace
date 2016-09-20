configuration ROWLabRelayServerAgent {
<#
    .SYNOPSIS
        Installs a RES ONE Workspace Relay Server agent and configures the local firewall.
#>
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
        [System.Management.Automation.Credential()] $EnvironmentPassword,

        ## File path containing the RES ONE Workspace MSIs or the literal path to the legacy console MSI.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Path,

        ## RES ONE Workspace Relay Server environment password is hashed.
        [Parameter()]
        [ValidateNotNull()]
        [System.Boolean] $EnvironmentPasswordIsHashed,

        ## Inherit RES ONE Workspace connection settings
        [Parameter()]
        [ValidateNotNull()]
        [System.Boolean] $InheritSettings = $true,

        ## Enable the RES ONE Workspace composer
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [System.Boolean] $EnableWorkspaceComposer = $true,

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

        ## RES ONE Workspace component version to be installed, i.e. 9.9.3
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $Version,

        ## The specified Path is a literal file reference (bypasses the $Version and $Architecture checks).
        [Parameter()]
        [ValidateNotNull()]
        [System.Boolean] $IsLiteralPath,

        ## Reboot the machine after RES ONE Workspace agent installation
        [Parameter()]
        [ValidateNotNull()]
        [System.Boolean] $ForceRestart,

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )

    Import-DscResource -ModuleName LegacyNetworking;
    Import-DscResource -Name ROWRelayServerAgent;

    if (($PSBoundParameters.ContainsKey('RelayServerList')) -and
        ($PSBoundParameters.ContainsKey('RelayServerDnsName'))) {

        ROWRelayServerAgent 'ROWLabRelayServerAgent' {
            Agent = $Agent;
            EnvironmentGuid = $EnvironmentGuid;
            EnvironmentPassword = $EnvironmentPassword;
            EnvironmentPasswordIsHashed = $EnvironmentPasswordIsHashed;
            Path = $Path;
            InheritSettings = $InheritSettings;
            EnableWorkspaceComposer = $EnableWorkspaceComposer;
            RelayServerDiscovery = $RelayServerDiscovery;
            RelayServerList = $RelayServerList;
            RelayServerDnsName = $RelayServerDnsName;
            Version = $Version;
            IsLiteralPath = $IsLiteralPath;
            ForceRestart = $ForceRestart;
            Ensure = $Ensure;
        }
    }
    elseif ($PSBoundParameters.ContainsKey('RelayServerList')) {

        ROWRelayServerAgent 'ROWLabRelayServerAgent' {
            Agent = $Agent;
            EnvironmentGuid = $EnvironmentGuid;
            EnvironmentPassword = $EnvironmentPassword;
            EnvironmentPasswordIsHashed = $EnvironmentPasswordIsHashed;
            Path = $Path;
            InheritSettings = $InheritSettings;
            EnableWorkspaceComposer = $EnableWorkspaceComposer;
            RelayServerDiscovery = $RelayServerDiscovery;
            RelayServerList = $RelayServerList;
            Version = $Version;
            IsLiteralPath = $IsLiteralPath;
            ForceRestart = $ForceRestart;
            Ensure = $Ensure;
        }
    }
    elseif ($PSBoundParameters.ContainsKey('RelayServerDnsName')) {

        ROWRelayServerAgent 'ROWLabRelayServerAgent' {
            Agent = $Agent;
            EnvironmentGuid = $EnvironmentGuid;
            EnvironmentPassword = $EnvironmentPassword;
            EnvironmentPasswordIsHashed = $EnvironmentPasswordIsHashed;
            Path = $Path;
            InheritSettings = $InheritSettings;
            EnableWorkspaceComposer = $EnableWorkspaceComposer;
            RelayServerDiscovery = $RelayServerDiscovery;
            RelayServerDnsName = $RelayServerDnsName;
            Version = $Version;
            IsLiteralPath = $IsLiteralPath;
            ForceRestart = $ForceRestart;
            Ensure = $Ensure;
        }
    }
    else {

        ROWRelayServerAgent 'ROWLabRelayServerAgent' {
            Agent = $Agent;
            EnvironmentGuid = $EnvironmentGuid;
            EnvironmentPassword = $EnvironmentPassword;
            EnvironmentPasswordIsHashed = $EnvironmentPasswordIsHashed;
            Path = $Path;
            InheritSettings = $InheritSettings;
            EnableWorkspaceComposer = $EnableWorkspaceComposer;
            RelayServerDiscovery = $RelayServerDiscovery;
            Version = $Version;
            IsLiteralPath = $IsLiteralPath;
            ForceRestart = $ForceRestart;
            Ensure = $Ensure;
        }
    }

    vFirewall 'ROWLabRelayServerAgentFirewall' {
        DisplayName = 'RES ONE Workspace Manger (Agent)';
        Action = 'Allow';
        Direction = 'Inbound';
        Enabled = $true;
        Profile = 'Any';
        Protocol = 'TCP';
        LocalPort = 1942;
        Description = 'RES ONE Workspace Agent Service';
        Ensure = $Ensure;
        DependsOn = '[ROWRelayServerAgent]ROWLabRelayServerAgent';
    }

} #end configuration ROWLabRelayServerAgent
