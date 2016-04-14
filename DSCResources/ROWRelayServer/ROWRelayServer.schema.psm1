configuration ROWRelayServer {
<#
    .SYNOPSIS
        Installs a RES ONE Workspace Relay Server.
#>
    param (
        ## RES ONE Workspace database server name/instance (equivalient to DBSERVER).
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $DatabaseServer,
        
        ## RES ONE Workspace database name (equivalient to DBNAME).
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $DatabaseName,
        
        ## Microsoft SQL username/password to connect (equivalent to DBUSER/DBPASSWORD).
        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential] $Credential,
        
        ## File path containing the RES ONE Workspace MSIs or the literal path to the legacy console MSI.
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $Path,

        ## RES ONE Workspace Relay Server port
        [Parameter(Mandatory)] [ValidateNotNull()]
        [System.Int32] $Port,

        ## Use Database protocol encryption
        [Parameter()] [ValidateNotNull()]
        [System.Boolean] $UseDatabaseProtocolEncryption,
        
        ## RES ONE Workspace Relay Server cache location
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $CachePath,

        ## RES ONE Workspace component version to be installed, i.e. 9.9.3
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $Version,
        
        ## The specified Path is a literal file reference (bypasses the Version and Architecture checks).
        [Parameter()] [ValidateNotNull()]
        [System.Boolean] $IsLiteralPath,
        
        ## The target node's architecture.
        [Parameter()] [ValidateSet('x64','x86')]
        [System.String] $Architecture = 'x64',

        [Parameter()] [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )

    Import-DscResource -ModuleName xPSDesiredStateConfiguration;

    $resourceName = 'ROWDatabase';
    if (([System.String]::IsNullOrWhitespace($Version)) -and (-not $IsLiteralPath)) {
        throw "$resourceName : Version number is required when not using a literal path.";
    }
    elseif ($IsLiteralPath) {
        if ($Path -notmatch '\.msi$') {
            throw "$resourceName : Specified path '$Path' does not point to an MSI file.";
        }
    }
    elseif ($Version -notmatch '^\d+\.\d+\.\d+\.\d+$') {
        throw "$resourceName : The specified version '$Version' does not match '1.2.3.4' format.";
    }
    
    if (-not $IsLiteralPath) {
        [System.Version] $Version = $Version;
        switch ($Version.Major) {
            9 {
                switch ($Version.Minor) {
                    9 {
                        ## RES Workspace Manager 2014
                        $setup = 'RES-WM-2014-Relay-Server({0})-{1}.msi' -f $Architecture, $Version.ToString();
                        $name = 'RES Workspace Manager 2014 Relay Server';
                        if ($Version.Build -gt 0) {
                            $setup = 'RES-WM-2014-SR{0}-Relay-Server({1})-{2}.msi' -f $Version.Build, $Architecture, $Version.ToString();
                            $name = 'RES Workspace Manager 2014 SR{0} Relay Server' -f $Version.Build;
                        }
                        
                    }
                    10 {
                        ## RES ONE Workspace 2015
                        $setup = 'RES-ONE-Workspace-2015-Relay-Server({0})-{1}.msi' -f $Architecture, $Version.ToString();
                        $name = 'RES ONE Workspace 2015 Relay Server';
                        if ($Version.Build -gt 0) {
                            $setup = 'RES-ONE-Workspace-2015-SR{0}-Relay-Server({1})-{2}.msi' -f $Version.Build, $Architecture, $Version.ToString();
                            $name = 'RES ONE Workspace 2015 SR{0} Relay Server' -f $Version.Build;
                        }
                    }
                    Default {
                        throw "$resourceName : Version '$($Version.Tostring())' is not currently supported :(.";
                    }
                }
            }
            Default {
                throw "$resourceName : Version '$Version' is not  :(.";
            }
        }
        $Path = Join-Path -Path $Path -ChildPath $setup;
    }

    $arguments = @(
        ('DBSERVER="{0}"' -f $DatabaseServer),
        ('DBNAME="{0}"' -f $DatabaseName),
        ('DBUSER="{0}"' -f $Credential.Username),
        ('DBPASSWORD="{0}"' -f $Credential.GetNetworkCredential().Password),
        ('DBTYPE="MSSQL"')
    )

    if ($PSBoundParameters.ContainsKey('PORT')) {
        $arguments += 'PORT="{0}"' -f $Port;    }

    if ($PSBoundParameters.ContainsKey('CACHEPATH')) {
        $arguments += 'CACHEPATH="{0}"' -f $CachePath;    }

    if ($Ensure -eq 'Present') {
        xPackage $resourceName {
            Name = $name;
            ProductId = '';
            Path = $Path;
            Arguments = $arguments -join ' ';
            ReturnCode = 0;
            InstalledCheckRegKey = 'SOFTWARE\RES\Workspace Manager\RelayServer';
            InstalledCheckRegValueName = 'Port';
            Ensure = $Ensure;
        }
    }
    elseif ($Ensure -eq 'Absent') {
        xPackage $resourceName {
            Name = $name;
            ProductId = '';
            Path = $Path;
            ReturnCode = 0;
            InstalledCheckRegKey = 'SOFTWARE\RES\Workspace Manager\RelayServer';
            InstalledCheckRegValueName = 'Port';
            Ensure = $Ensure;
        }
    }

}
