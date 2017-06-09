configuration ROWLab {
<#
    .SYNOPSIS
        Creates the RES ONE Workspace single node lab deployment.
#>
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
    param (
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

        ## Microsoft SQL database credentials used to create the database (equivalient to DBCREATEUSER/DBCREATEPASSWORD).
        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()] $SQLCredential,

        ## File path containing the RES ONE Workspace MSIs.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Path,

        ## RES ONE Workspace component version to be installed, i.e. 9.9.3
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Version,

        ## RES ONE Workspace Relay Server port
        [Parameter()]
        [ValidateNotNull()]
        [System.UInt16] $RelayServerPort = 1943,

        ## Use Database protocol encryption
        [Parameter()]
        [ValidateNotNull()]
        [System.Boolean] $UseDatabaseProtocolEncryption,

        ## File path to RES ONE Workspace license file.
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $LicensePath,

        ## File path to RES ONE Workspace building blocks to import.
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $BuildingBlockPath,

        ## Delete the building block from disk after import.
        [Parameter()]
        [System.Boolean] $DeleteBuildingBlock,

        ## Credential used to import the RES ONE Workspace building blocks.
        [Parameter()]
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()] $BuildingBlockCredential,

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )

    Write-Host ' Starting "ROWLab".' -ForegroundColor Gray;

    Import-DscResource -ModuleName xPSDesiredStateConfiguration;
    Import-DscResource -ModuleName xNetworking;
    Import-DscResource -Name ROWDatabase, ROWRelayServer, ROWBuildingBlock;

    if ($Ensure -eq 'Present') {

        if ($PSBoundParameters.ContainsKey('LicensePath')) {

            Write-Host ' Processing "ROWLab\ROELabDatabase" with "LicensePath".' -ForegroundColor Gray;
            ROWDatabase 'ROWLabDatabase' {
                DatabaseServer                = $DatabaseServer;
                DatabaseName                  = $DatabaseName;
                Credential                    = $Credential;
                SQLCredential                 = $SQLCredential;
                Path                          = $Path;
                IsLiteralPath                 = $false;
                UseDatabaseProtocolEncryption = $UseDatabaseProtocolEncryption;
                Version                       = $Version;
                LicensePath                   = $LicensePath;
                Ensure                        = $Ensure;
            }
        }
        else {

            Write-Host ' Processing "ROWLab\ROWLabDatabase".' -ForegroundColor Gray;
            ROWDatabase 'ROWLabDatabase' {
                DatabaseServer                = $DatabaseServer;
                DatabaseName                  = $DatabaseName;
                Credential                    = $Credential;
                SQLCredential                 = $SQLCredential;
                Path                          = $Path;
                IsLiteralPath                 = $false;
                UseDatabaseProtocolEncryption = $UseDatabaseProtocolEncryption;
                Version                       = $Version;
                Ensure                        = $Ensure;
            }
        }

        Write-Host ' Processing "ROWLab\ROWLabRelayServer".' -ForegroundColor Gray;
        ROWRelayServer 'ROWLabRelayServer' {
            DatabaseServer                = $DatabaseServer;
            DatabaseName                  = $DatabaseName;
            Credential                    = $Credential;
            Path                          = $Path;
            IsLiteralPath                 = $false;
            Version                       = $Version;
            UseDatabaseProtocolEncryption = $UseDatabaseProtocolEncryption;
            Port                          = $RelayServerPort;
            Ensure                        = $Ensure;
            DependsOn                     = '[ROWDatabase]ROWLabDatabase';
        }

        if ($PSBoundParameters.ContainsKey('BuildingBlockPath')) {

            Write-Host ' Processing "ROWLab\ROWLabBuildingBlock".' -ForegroundColor Gray;
            ROWBuildingBlock 'ROWLabBuildingBlock' {
                Path           = $BuildingBlockPath;
                Credential     = $BuildingBlockCredential;
                DeleteFromDisk = $DeleteBuildingBlock;
                DependsOn      = '[ROWDatabase]ROWLabDatabase';
            }
        }

    }
    elseif ($Ensure -eq 'Absent') {

        Write-Host ' Processing "ROWLab\ROWLabRelayServer".' -ForegroundColor Gray;
        ROWRelayServer 'ROWLabRelayServer' {
            DatabaseServer                = $DatabaseServer;
            DatabaseName                  = $DatabaseName;
            Credential                    = $Credential;
            Path                          = $Path;
            IsLiteralPath                 = $false;
            Version                       = $Version;
            UseDatabaseProtocolEncryption = $UseDatabaseProtocolEncryption;
            Port                          = $RelayServerPort;
            Ensure                        = $Ensure;
        }

        Write-Host ' Processing "ROWLab\ROWLabDatabase".' -ForegroundColor Gray;
        ROWDatabase 'ROWLabDatabase' {
            DatabaseServer                = $DatabaseServer;
            DatabaseName                  = $DatabaseName;
            Credential                    = $Credential;
            SQLCredential                 = $SQLCredential;
            Path                          = $Path;
            IsLiteralPath                 = $false;
            Version                       = $Version;
            UseDatabaseProtocolEncryption = $UseDatabaseProtocolEncryption;
            Ensure                        = $Ensure;
            DependsOn                     = '[ROWRelayServer]ROWLabRelayServer';
        }

    }

    Write-Host ' Processing "ROWLab\ROWLabRelayServerFirewall".' -ForegroundColor Gray;
    xFirewall 'ROWLabRelayServerFirewall' {
        Name        = 'RESONEWorkspace-TCP-{0}-In' -f $RelayServerPort;
        Group       = 'RES ONE Workspace';
        Action      = 'Allow';
        Direction   = 'Inbound';
        DisplayName = 'RES ONE Workspace (Relay Server)';
        Enabled     = $true;
        Profile     = 'Any';
        LocalPort   = $RelayServerPort;
        Protocol    = 'TCP';
        Description = 'RES ONE Workspace Relay Server Service';
        Ensure      = $Ensure;
        DependsOn   = '[ROWRelayServer]ROWLabRelayServer'
    }

    Write-Host ' Processing "ROWLab\ROWLabRelayServerDiscoveryFirewall".' -ForegroundColor Gray;
    xFirewall 'ROWLabRelayServerDiscoveryFirewall' {
        Name        = 'RESONEWorkspace-UDP-1942-In';
        Group       = 'RES ONE Workspace';
        Action      = 'Allow';
        Direction   = 'Inbound';
        DisplayName = 'RES ONE Workspace (Relay Server Discovery)';
        Enabled     = $true;
        Profile     = 'Any';
        LocalPort   = '1942';
        Protocol    = 'UDP';
        Description = 'RES ONE Workspace Relay Server Discovery Service';
        Ensure      = $Ensure;
        DependsOn   = '[ROWRelayServer]ROWLabRelayServer';
    }

    Write-Host ' Ending "ROWLab".' -ForegroundColor Gray;

} #end configuration ROWLab
