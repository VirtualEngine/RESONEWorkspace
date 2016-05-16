configuration ROWLab {
<#
    .SYNOPSIS
        Creates the RES ONE Workspace single node lab deployment.
#>
    param (
        ## RES ONE Workspace database server name/instance (equivalient to DBSERVER).
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $DatabaseServer,
        
        ## RES ONE Workspace database name (equivalient to DBNAME).
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $DatabaseName,
        
        ## Microsoft SQL username/password to create (equivalent to DBUSER/DBPASSWORD).
        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential] $Credential,
        
        ## Microsoft SQL database credentials used to create the database (equivalient to DBCREATEUSER/DBCREATEPASSWORD).
        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential] $SQLCredential,
        
        ## File path containing the RES ONE Workspace MSIs or the literal path to the legacy console MSI.
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $Path,

        ## RES ONE Workspace component version to be installed, i.e. 9.9.3
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $Version,

        ## RES ONE Workspace Relay Server port
        [Parameter()] [ValidateNotNull()]
        [System.Int32] $RelayServerPort = 1943,

        ## Use Database protocol encryption
        [Parameter()] [ValidateNotNull()]
        [System.Boolean] $UseDatabaseProtocolEncryption,
        
        ## The target node's architecture.
        [Parameter()] [ValidateSet('x64','x86')]
        [System.String] $Architecture = 'x64',

        [Parameter()] [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )

    Import-DscResource -ModuleName xPSDesiredStateConfiguration;
    Import-DscResource -ModuleName xNetworking;
    Import-DscResource -Name ROWDatabase, ROWRelayServer;

    if ($Ensure -eq 'Present') {
        
        ROWDatabase 'ROWLabDatabase' {
            DatabaseServer = $DatabaseServer;
            DatabaseName = $DatabaseName;
            Credential = $Credential;
            SQLCredential = $SQLCredential;
            Path = $Path;
            IsLiteralPath = $false;
            UseDatabaseProtocolEncryption = $UseDatabaseProtocolEncryption;
            Version = $Version;
            Ensure = $Ensure;
        }

        ROWRelayServer 'ROWLabRelayServer' {
            DatabaseServer = $DatabaseServer;
            DatabaseName = $DatabaseName;
            Credential = $Credential;
            Path = $Path;
            IsLiteralPath = $false;
            Version = $Version;
            UseDatabaseProtocolEncryption = $UseDatabaseProtocolEncryption;
            Architecture = $Architecture;
            Port = $RelayServerPort;
            Ensure = $Ensure;
            DependsOn = '[ROWDatabase]ROWLabDatabase';
        }
        
    }
    elseif ($Ensure -eq 'Absent') {
        
        ROWRelayServer 'ROWLabRelayServer' {
            DatabaseServer = $DatabaseServer;
            DatabaseName = $DatabaseName;
            Credential = $Credential;
            Path = $Path;
            IsLiteralPath = $false;
            Version = $Version;
            UseDatabaseProtocolEncryption = $UseDatabaseProtocolEncryption;
            Architecture = $Architecture;
            Port = $RelayServerPort;
            Ensure = $Ensure;
        }
        
        ROWDatabase 'ROWLabDatabase' {
            DatabaseServer = $DatabaseServer;
            DatabaseName = $DatabaseName;
            Credential = $Credential;
            SQLCredential = $SQLCredential;
            Path = $Path;
            IsLiteralPath = $false;
            Version = $Version;
            UseDatabaseProtocolEncryption = $UseDatabaseProtocolEncryption;
            Ensure = $Ensure;
            DependsOn = '[ROWRelayServer]ROWLabRelayServer';
        }
        
        ## Can't remove the environment password or environment Guid!
    }
    
    xFirewall 'ROWLabRelayServerFirewall' {
        Name = 'RESONEWorkspace-TCP-{0}-In' -f $RelayServerPort;
        Group = 'RES ONE Workspace';
        Action = 'Allow';
        Direction = 'Inbound';
        DisplayName = 'RES ONE Workspace (Relay Server)';
        Enabled = $true;
        Profile = 'Any';
        LocalPort = $RelayServerPort;
        Protocol = 'TCP';
        Description = 'RES ONE Workspace Relay Server Service';
        Ensure = $Ensure;
        DependsOn = '[ROWRelayServer]ROWLabRelayServer'
    }
    
    xFirewall 'ROWLabRelayServerDiscoveryFirewall' {
        Name = 'RESONEWorkspace-UDP-1942-In' -f $RelayServerPort;
        Group = 'RES ONE Workspace';
        Action = 'Allow';
        Direction = 'Inbound';
        DisplayName = 'RES ONE Workspace (Relay Server Discovery)';
        Enabled = $true;
        Profile = 'Any';
        LocalPort = '1942';
        Protocol = 'UDP';
        Description = 'RES ONE Workspace Relay Server Discovery Service';
        Ensure = $Ensure;
        DependsOn = '[ROWRelayServer]ROWLabRelayServer';
    }

} #end configuration ROWLab
