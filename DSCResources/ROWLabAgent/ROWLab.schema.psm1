configuration ROWLabAgent {
<#
    .SYNOPSIS
        Installs a RES ONE Workspace lab agent.
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
        
        ## File path containing the RES ONE Workspace MSIs or the literal path to the legacy console MSI.
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $Path,

        ## Use Database protocol encryption
        [Parameter()] [ValidateNotNull()]
        [System.Management.Automation.SwitchParameter] $UseDatabaseProtocolEncryption,

        ## RES ONE Workspace component version to be installed, i.e. 9.9.3
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $Version,
        
        ## The specified Path is a literal file reference (bypasses the $Version and $Architecture checks).
        [Parameter()] [ValidateNotNull()]
        [System.Management.Automation.SwitchParameter] $IsLiteralPath,
        
        ## The target node's architecture.
        [Parameter()] [ValidateSet('x64','x86')]
        [System.String] $Architecture = 'x64',

        [Parameter()] [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )

    Import-DscResource -ModuleName xPSDesiredStateConfiguration;

    $resourceName = 'ROWConsole';
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
                        $setup = 'RES-WM-2014-Console.msi';
                        if ($Version.Build -gt 0) {
                            $setup = 'RES-WM-2014-Console-SR{0}.msi' -f $Version.Build;
                        }
                        $name = 'RES Workspace Manager Console 2014';
                    }
                    10 {
                        ## RES ONE Workspace 2015
                        $setup = 'RES-ONE-Workspace-2015-Console.msi';
                        $name = 'RES ONE Workspace 2015 Console';
                        if ($Version.Build -gt 0) {
                            $setup = 'RES-ONE-Workspace-2015-Console-SR{0}.msi' -f $Version.Build;
                            $name = 'RES ONE Workspace 2015 SR{0} Console' -f $Version.Build;
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

    if ($PSBoundParameters.ContainsKey('UseDatabaseProtocolEncryption')) {
        if ($UseDatabaseProtocolEncryption -eq $true) {
            $arguments += 'DBPROTOCOLENCRYPTION="yes"';
        }
    }

    if ($Ensure -eq 'Present') {
        xPackage $resourceName {
            Name = $name;
            ProductId = '';
            Path = $Path;
            Arguments = $arguments -join ' ';
            ReturnCode = 0;
            InstalledCheckRegKey = 'Software\RES\Workspace Manager';
            InstalledCheckRegValueName = 'DBName';
            InstalledCheckRegValueData = $DatabaseName;
            Ensure = $Ensure;
        }
    }
    elseif ($Ensure -eq 'Absent') {
        xPackage $resourceName {
            Name = $name;
            ProductId = '';
            Path = $Path;
            ReturnCode = 0;
            InstalledCheckRegKey = 'Software\RES\Workspace Manager';
            InstalledCheckRegValueName = 'DBName';
            InstalledCheckRegValueData = $DatabaseName;
            Ensure = $Ensure;
        }
    }

}
