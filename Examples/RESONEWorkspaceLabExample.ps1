$config = @{
    AllNodes = @(
        @{
            NodeName = 'localhost';
            PSDSCAllowPlainTextPassword = $true;
            
            ROWDatabaseServer          = 'controller.lab.local';
            ROWDatabaseName            = 'RESONEWorkspace';
            ROWBinariesFolder          = 'C:\SharedData\Software\RES\ONE Worksapce 2015\SR1';
            ROWBinariesVersion         = '9.10.1.0';
            ROWEnvironmentPasswordHash = '5E68E81153E9F01EBF8476AA8F99050A481DA9EA'; # Tra1ning
            ROWRelayServerPort         = 1943;
        }
    )
}

configuration RESONEWorkspaceLabExample {
    param (
        ## RES ONE Workspace SQL database/user credential
        [Parameter(Mandatory)]
        [PSCredential] $Credential,

        ## Microsoft SQL Server credentials used to create the RES ONE Workspace database/user
        [Parameter(Mandatory)]
        [PSCredential] $SQLCredential
    )

    Import-DscResource -ModuleName RESONEWorkspace;

    node 'localhost' {
    
        ROWLab 'ROWLab' {
            DatabaseServer = $node.ROWDatabaseServer;
            DatabaseName = $node.ROWDatabaseName;
            Path = $node.ROWBinariesFolder;
            Version = $node.ROWBinariesVersion;
            SQLCredential = $SQLCredential;
            Credential = $Credential;
            EnvironmentPasswordHash = $node.ROWEnvironmentPasswordHash;
            RelayServerPort = $node.ROWRelayServerPort;
        }
    }

} #end configuration RESONEWorkspaceLabExample

if (-not $Cred) { $Cred = Get-Credential -UserName 'RESONEWorkspace' -Message 'RES ONE Workspace SQL account credential'; }
if (-not $sqlCred) { $sqlCred = Get-Credential -UserName 'sa' -Message 'Microsoft SQL Server account credential'; }
RESONEWorkspaceLabExample -OutputPath ~\Documents -ConfigurationData $config -Credential $cred -SQLCredential $sqlCred;
