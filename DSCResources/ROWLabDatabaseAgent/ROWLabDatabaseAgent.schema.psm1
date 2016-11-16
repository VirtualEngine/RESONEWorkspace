configuration ROWLabDatabaseAgent {
<#
    .SYNOPSIS
        Installs a RES ONE Workspace database agent and configures the local firewall.
#>
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

        ## Microsoft SQL username/password to create (equivalent to DBUSER/DBPASSWORD).
        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()] $Credential,

        ## File path containing the RES ONE Workspace MSIs or the literal path to the legacy console MSI.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Path,

        ## Inherit RES ONE Workspace connection settings
        [Parameter()]
        [ValidateNotNull()]
        [System.Boolean] $InheritSettings = $true,

        ## Enable the RES ONE Workspace composer
        [Parameter()]
        [ValidateNotNull()]
        [System.Boolean] $EnableWorkspaceComposer = $true,

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
        [System.Management.Automation.PSCredential] $ServiceAccountCredential,

        ## Add RES ONE Workspace Agent to Workspace containers"
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String[]] $AddToWorkspace,

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

        ## Disables the RES ONE Workspace composer PWRGATE integration
        [Parameter()]
        [ValidateNotNull()]
        [System.Boolean] $InterceptManagedApplications,

        ## The target node's architecture.
        [Parameter()] [ValidateSet('x64','x86')]
        [System.String] $Architecture = 'x64',

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )

    Import-DscResource -ModuleName LegacyNetworking, PSDesiredStateConfiguration;
    Import-DscResource -Name ROWDatabaseAgent;

    if (($PSBoundParameters.ContainsKey('ServiceAccountCredential')) -and
        ($PSBoundParameters.ContainsKey('AddToWorkspace'))) {

        ROWDatabaseAgent 'ROWLabDatabaseAgent' {
            Agent                         = $Agent;
            DatabaseServer                = $DatabaseServer;
            DatabaseName                  = $DatabaseName;
            Credential                    = $Credential;
            Path                          = $Path;
            InheritSettings               = $InheritSettings;
            EnableWorkspaceComposer       = $EnableWorkspaceComposer;
            UseDatabaseProtocolEncryption = $UseDatabaseProtocolEncryption;
            NoDesktopShortcut             = $NoDesktopShortcut;
            NoStartMenuShortcut           = $NoStartMenuShortcut;
            ServiceAccountCredential      = $ServiceAccountCredential;
            AddToWorkspace                = $AddToWorkspace;
            Version                       = $Version;
            IsLiteralPath                 = $IsLiteralPath;
            ForceRestart                  = $ForceRestart;
            Ensure                        = $Ensure;
        }
    }
    elseif ($PSBoundParameters.ContainsKey('ServiceAccountCredential')) {

        ROWDatabaseAgent 'ROWLabDatabaseAgent' {
            Agent                         = $Agent;
            DatabaseServer                = $DatabaseServer;
            DatabaseName                  = $DatabaseName;
            Credential                    = $Credential;
            Path                          = $Path;
            InheritSettings               = $InheritSettings;
            EnableWorkspaceComposer       = $EnableWorkspaceComposer;
            UseDatabaseProtocolEncryption = $UseDatabaseProtocolEncryption;
            NoDesktopShortcut             = $NoDesktopShortcut;
            NoStartMenuShortcut           = $NoStartMenuShortcut;
            ServiceAccountCredential      = $ServiceAccountCredential;
            Version                       = $Version;
            IsLiteralPath                 = $IsLiteralPath;
            ForceRestart                  = $ForceRestart;
            Ensure                        = $Ensure;
        }
    }
    elseif ($PSBoundParameters.ContainsKey('AddToWorkspace')) {

        ROWDatabaseAgent 'ROWLabDatabaseAgent' {
            Agent                         = $Agent;
            DatabaseServer                = $DatabaseServer;
            DatabaseName                  = $DatabaseName;
            Credential                    = $Credential;
            Path                          = $Path;
            InheritSettings               = $InheritSettings;
            EnableWorkspaceComposer       = $EnableWorkspaceComposer;
            UseDatabaseProtocolEncryption = $UseDatabaseProtocolEncryption;
            NoDesktopShortcut             = $NoDesktopShortcut;
            NoStartMenuShortcut           = $NoStartMenuShortcut;
            AddToWorkspace                = $AddToWorkspace;
            Version                       = $Version;
            IsLiteralPath                 = $IsLiteralPath;
            ForceRestart                  = $ForceRestart;
            Ensure                        = $Ensure;
        }
    }
    else {

        ROWDatabaseAgent 'ROWLabDatabaseAgent' {
            Agent                         = $Agent;
            DatabaseServer                = $DatabaseServer;
            DatabaseName                  = $DatabaseName;
            Credential                    = $Credential;
            Path                          = $Path;
            InheritSettings               = $InheritSettings;
            EnableWorkspaceComposer       = $EnableWorkspaceComposer;
            UseDatabaseProtocolEncryption = $UseDatabaseProtocolEncryption;
            NoDesktopShortcut             = $NoDesktopShortcut;
            NoStartMenuShortcut           = $NoStartMenuShortcut;
            Version                       = $Version;
            IsLiteralPath                 = $IsLiteralPath;
            ForceRestart                  = $ForceRestart;
            Ensure                        = $Ensure;
        }
    }

    vFirewall 'ROWLabDatabaseAgentFirewall' {
        DisplayName = 'RES ONE Workspace Manger (Agent)';
        Action      = 'Allow';
        Direction   = 'Inbound';
        Enabled     = $true;
        Profile     = 'Any';
        Protocol    = 'TCP';
        LocalPort   = 1942;
        Description = 'RES ONE Workspace Agent Service';
        Ensure      = $Ensure;
        DependsOn   = '[ROWDatabaseAgent]ROWLabDatabaseAgent';
    }

    if ($PSBoundParametes.ContainsKey('InterceptManagedApplications')) {

        if ($Architecture -eq 'x64') {
            $key = 'HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\RES\Workspace Manager';
        }
        elseif ($Architecture -eq 'x86') {
            $key = 'HKEY_LOCAL_MACHINE\SOFTWARE\RES\Workspace Manager';
        }

        Registry 'InterceptManagedApps' {
            Key       = $key;
            ValueName = 'InterceptManagedApps';
            ValueData = if ($InterceptManagedApplications) { 'Yes' } else { 'No' };
            ValueType = 'String';
            Ensure    = $Ensure;
            DependsOn = '[ROWDatabaseAgent]ROWLabDatabaseAgent';
        }
    }

} #end configuration ROWLabDatabaseAgent
