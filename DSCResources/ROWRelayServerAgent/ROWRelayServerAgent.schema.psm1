configuration ROWRelayServerAgent {
<#
    .SYNOPSIS
        Installs a RES ONE Workspace agent connected via a Relay Server.
#>
    param (
        ## Install full agent including the console or agent only
        [Parameter(Mandatory)] [ValidateSet('Full','AgentOnly')]
        [System.String] $Agent,
        
        ## RES ONE Workspace Relay Server environment GUID.
        [Parameter(Mandatory)] [ValidateNotNull()]
        [System.Guid] $EnvironmentGuid,
        
        ## RES ONE Workspace Relay Server environment password.
        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential] $EnvironmentPassword,

        ## File path containing the RES ONE Workspace MSIs or the literal path to the legacy console MSI.
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $Path,

        ## Inherit RES ONE Workspace connection settings
        [Parameter(Mandatory)] [ValidateNotNull()]
        [System.Boolean] $InheritSettings,

        ## Enable the RES ONE Workspace composer
        [Parameter(Mandatory)] [ValidateNotNull()]
        [System.Boolean] $EnableWorkspaceComposer,

        ## RES ONE Workspace Relay Server environment password is hashed.
        [Parameter()] [ValidateNotNull()]
        [System.Boolean] $EnvironmentPasswordIsHashed,

        ## Enable RES ONE Workspace Relay Server multicast discovery.
        [Parameter()] [ValidateNotNull()]
        [System.Boolean] $RelayServerDiscovery,

        ## Use specified RES ONE Workspace Relay Servers.
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String[]] $RelayServerList,

        ## Resolve RES ONE Workspace Relay Server via DNS.
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $RelayServerDnsName,

        ## Do not create a desktop shortcut
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.Boolean] $NoDesktopShortcut,

        ## Do not create a Start Menu shortcut
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.Boolean] $NoStartMenuShortcut,

        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String[]] $AddToWorkspace,

        ## RES ONE Workspace component version to be installed, i.e. 9.9.3
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $Version,
        
        ## The specified Path is a literal file reference (bypasses the Version and Architecture checks).
        [Parameter()]
        [System.Boolean] $IsLiteralPath,
        
        ## The target node's architecture.
        [Parameter()] [ValidateSet('x64','x86')]
        [System.String] $Architecture = 'x64',

        [Parameter()] [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )

    Import-DscResource -ModuleName xPSDesiredStateConfiguration;

    $resourceName = 'ROWRelayServerAgent';
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
                        if ($Agent -eq 'Full') {
                            if ($Version.Build -eq 0) {
                                $setup = 'RES-WM-2014.msi' -f $Version.Build;
                                $name = 'RES Workspace Manager 2014' -f $Version.Build;
                            }
                            else {
                                $setup = 'RES-WM-2014-SR{0}.msi' -f $Version.Build;
                                $name = 'RES Workspace Manager 2014 SR{0}' -f $Version.Build;
                            }
                        }
                        elseif ($Agent -eq 'AgentOnly') {
                            if ($Version.Build -eq 0) {
                                $setup = 'RES-WM-2014-Agent.msi';
                                $name = 'RES Workspace Manager 2014 Agent';
                            }
                            else {
                                $setup = 'RES-WM-2014-Agent-SR{0}.msi' -f $Version.Build;
                                $name = 'RES Workspace Manager 2014 SR{0} Agent' -f $Version.Build;
                            }
                        }
                    }
                    10 {
                        ## RES ONE Workspace 2015
                        if ($Agent -eq 'Full') {
                            if ($Version.Build -eq 0) {
                                $setup = 'RES-ONE-Workspace-2015.msi' -f $Version.Build;
                                $name = 'RES ONE Workspace 2015' -f $Version.Build;
                            }
                            else {
                                $setup = 'RES-ONE-Workspace-2015-SR{0}.msi' -f $Version.Build;
                                $name = 'RES ONE Workspace 2015 SR{0}' -f $Version.Build;
                            }
                        }
                        elseif ($Agent -eq 'AgentOnly') {
                            if ($Version.Build -eq 0) {
                                $setup = 'RES-ONE-Workspace-2015-Agent.msi' -f $Version.Build;
                                $name = 'RES ONE Workspace 2015 Agent' -f $Version.Build;
                            }
                            else {
                                $setup = 'RES-ONE-Workspace-2015-Agent-SR{0}.msi' -f $Version.Build;
                                $name = 'RES ONE Workspace 2015 SR{0} Agent' -f $Version.Build;
                            }
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
        ('RSENVGUID="{{{0}}}"' -f $EnvironmentGuid.ToString().ToUpper()),
        ('RSPASSWORD="{0}"' -f $EnvironmentPassword.GetNetworkCredential().Password)
    )

    if ($PSBoundParameters.ContainsKey('EnvironmentPasswordIsHashed')) {
        if ($EnvironmentPasswordIsHashed -eq $true) {
            $arguments += 'RSPWHASHED="yes"';
        }
    }

    if ($PSBoundParameters.ContainsKey('RelayServerDiscovery')) {
        if ($RelayServerDiscovery -eq $true) {            $arguments += 'RSDISCOVER="yes"';        }    }

    if ($PSBoundParameters.ContainsKey('RelayServerList')) {
        $arguments += 'RSLIST="{0}"' -f ($RelayServerList -join ';');    }

    if ($PSBoundParameters.ContainsKey('$RelayServerDnsName')) {
        $arguments += 'RSRESOLVE="{0}"' -f $RelayServerDnsName;    }

    if ($PSBoundParameters.ContainsKey('InheritSettings')) {
        if ($InheritSettings -eq $true) {            $arguments += 'INHERITSETTINGS="yes"';        }    }

    if ($PSBoundParameters.ContainsKey('EnableWorkspaceComposer')) {
        if ($InheritSettings -eq $true) {            $arguments += 'AUTORUNCOMPOSER="yes"';        }    }

    if ($PSBoundParameters.ContainsKey('NoDesktopShortcut')) {
        if (-not $NoDesktopShortcut) {            $arguments += 'AI_DESKTOP_SH="0"';        }
    }

    if ($PSBoundParameters.ContainsKey('NoStartMenuShortcut')) {
        if (-not $NoStartMenuShortcut) {            $arguments += 'AI_STARTMENU_SH="0"';        }
    }

    if ($PSBoundParameters.ContainsKey('AddToWorkspace')) {
        $arguments += ('ADDTOWORKSPACE="{0}"' -f ($AddToWorkspace -join '|'));
    }

    if ($Ensure -eq 'Present') {
        xPackage $resourceName {
            Name = $name;
            ProductId = '';
            Path = $Path;
            Arguments = $arguments -join ' ';
            ReturnCode = 0;
            InstalledCheckRegKey = 'SOFTWARE\RES\Workspace Manager\UpdateGUIDs';
            Ensure = $Ensure;
        }
    }
    elseif ($Ensure -eq 'Absent') {
        xPackage $resourceName {
            Name = $name;
            ProductId = '';
            Path = $Path;
            ReturnCode = 0;
            InstalledCheckRegKey = 'SOFTWARE\RES\Workspace Manager\UpdateGUIDs';
            Ensure = $Ensure;
        }
    }

}
