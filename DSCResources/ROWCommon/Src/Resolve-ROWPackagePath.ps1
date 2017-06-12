function Resolve-ROWPackagePath {
<#
    .SYNOPSIS
        Resolves the latest RES ONE Workspace/Workspace Manager installation package.
#>
    [CmdletBinding()]
    param (
        ## The literal file path or root search path
        [Parameter(Mandatory)]
        [System.String] $Path,

        ## Required RES ONE Workspace/Workspace Manager component
        [Parameter(Mandatory)]
        [ValidateSet('Console','AgentOnly','FullAgent','RelayServer','ReportingServices','ManagementPortal')]
        [System.String] $Component,

        ## RES ONE Workspace component version to be installed, i.e. 9.9 or 9.10.2
        [Parameter(Mandatory)]
        [System.String] $Version,

        ## The specified Path is a literal file reference (bypasses the Version and Architecture checks).
        [Parameter()]
        [System.Boolean] $IsLiteralPath
    )

    if (([System.String]::IsNullOrWhitespace($Version)) -and (-not $IsLiteralPath)) {

        throw ($localizedData.SpecifedPathTypeError);
    }
    elseif ($IsLiteralPath) {

        if ($Path -notmatch '\.msi$') {

            throw ($localizedData.InvalidPathTypeError -f $Path, 'MSI');
        }
    }
    elseif ($Version -notmatch '^\d\d?\.\d\d?(\.\d\d?|\.\d\d?\.\d\d?)?$') {

         throw ($localizedData.InvalidVersionNumberFormatError -f $Version);
    }
    else {

        $versionMajor = $Version.Split('.')[0] -as [System.Int32];
        if (($Component -eq 'ManagementPortal') -and ($versionMajor -lt 10)) {
            
            throw ($localizedData.InvalidComponentVersionError -f 'ManagementPortal', 10);
        }
    }

    if ($IsLiteralPath) {

        $packagePath = $Path;
    }
    else {

        [System.Version] $productVersion = $Version;
        
        switch ($productVersion.Major) {

            10 {

                switch ($productVersion.Minor) {

                    0 {
                        $packageName = 'RES ONE Workspace';
                        $productName = 'RES ONE Workspace';
                    }
                    Default {

                        throw ($localizedData.UnsupportedVersionError -f $Version);
                    }
                }

            }
            9 {

                switch ($productVersion.Minor) {

                    9 {
                        $packageName = 'RES-WM-2014';
                        $productName = 'RES Workspace Manager 2014'
                    }
                    10 {
                        $packageName = 'RES-ONE-Workspace-2015';
                        $productName = 'RES ONE Workspace 2015';
                    }
                    12 {
                        $packageName = 'RES-ONE-Workspace-2016';
                        $productName = 'RES ONE Workspace 2016';
                    }
                    Default {

                        throw ($localizedData.UnsupportedVersionError -f $Version);
                    }

                } #end switch version minor

            }

            Default {

                throw ($localizedData.UnsupportedVersionError -f $Version);
            }

        } #end switch version major

        switch ($Component) {

            'AgentOnly' {

                ## RES-ONE-Workspace-2015-Agent-SR1 or RES-WM-2014-Agent-SR1

                $productDescription = 'Agent';

                if ($productVersion.Build -eq 0) {

                    ## We're after the RTM release, e.g. specified 9.9.0 or 9.10.0
                    $regex = '{0}-Agent.msi' -f $packageName;
                }
                elseif ($productVersion.Build -ge 1) {

                    ## We're after a specific SR, e.g. specified 9.9.3 or 9.10.2
                    $regex = '{0}-SR{1}-Agent.msi' -f $packageName, $productVersion.Build;
                }
                else {

                    ## Find all
                    $regex = '{0}-Agent(-SR\d)?.msi' -f $packageName;
                }

            } #end switch AgentOnly

            'FullAgent' {

                ## RES-ONE-Workspace-2015-SR1 or RES-WM-2014-SR3

                $productDescription = '';

                if ($productVersion.Build -eq 0) {

                    ## We're after the RTM release, e.g. specified 9.9.0 or 9.10.0
                    $regex = '{0}.msi' -f $packageName;
                }
                elseif ($productVersion.Build -ge 1) {

                    ## We're after a specific SR, e.g. specified 9.9.3 or 9.10.2
                    $regex = '{0}-SR{1}.msi' -f $packageName, $productVersion.Build;
                }
                else {

                    ## Find all
                    $regex = '{0}(-SR\d)?.msi' -f $packageName;
                }

            } #end switch FullAgent

            'RelayServer' {

                ## RES-ONE-Workspace-2015-SR1-Relay-Server(x64)-9.10.1.5 or RES-WM-2014-SR3-Relay-Server(x64)-9.9.3.0

                $productDescription = 'Relay Server';

                $architecture = 'x86';
                if ([System.Environment]::Is64BitOperatingSystem) {

                    $architecture = 'x64';
                }

                if ($productVersion.Build -eq 0) {

                    ## We're after the RTM release, e.g. specified 9.9.0 or 9.10.0
                    $regex = '{0}-Relay-Server\({1}\)\S+.msi' -f $packageName, $architecture;
                }
                elseif ($productVersion.Build -ge 1) {

                    ## We're after a specific SR, e.g. specified 9.9.3 or 9.10.2
                    $regex = '{0}-SR{1}-Relay-Server\({2}\)\S+.msi' -f $packageName, $productVersion.Build, $architecture;
                }
                else {

                    ## Find all
                    $regex = '{0}(-SR\d)?-Relay-Server\({1}\)\S+.msi' -f $packageName, $architecture;
                }

            } #end switch Relay Server

            'ReportingServices' {

                $productDescription = 'Reporting Services';

                if ($productVersion.Build -eq 0) {

                    ## We're after the RTM release, e.g. specified 9.9.0 or 9.10.0
                    $regex = '{0}-Reporting-Services.msi' -f $packageName;
                }
                elseif ($productVersion.Build -ge 1) {

                    ## We're after a specific SR, e.g. specified 9.9.3 or 9.10.2
                    $regex = '{0}-Reporting-Services-SR{1}.msi' -f $packageName, $productVersion.Build;
                }
                else {

                    ## Find all
                    $regex = '{0}-Reporting-Services(-SR\d)?.msi' -f $packageName;
                }

            } #end switch Reporting Services

            'ManagementPortal' {

                ## RES ONE Workspace Management Portal 10.0.0.0.msi
                $productDescription = 'Management Portal';
                ## Find all matching the supplied version
                $regex = '{0} Management Portal {1}\S+.msi' -f $packageName, $Version;
            }

            Default {

                ## RES-ONE-Workspace-2015-Console-SR1 or RES-WM-2014-Console-SR3

                $productDescription = 'Console';

                if ($productVersion.Build -eq 0) {

                    ## We're after the RTM release, e.g. specified 9.9.0 or 9.10.0
                    $regex = '{0}-Console.msi' -f $packageName;
                }
                elseif ($productVersion.Build -ge 1) {

                    ## We're after a specific SR, e.g. specified 9.9.3 or 9.10.2
                    $regex = '{0}-Console-SR{1}.msi' -f $packageName, $productVersion.Build;
                }
                else {

                    ## Find all
                    $regex = '{0}-Console(-SR\d)?.msi' -f $packageName;
                }

            } #end switch Console/Database

        } #end switch component

        Write-Verbose -Message ($localizedData.SearchFilePatternMatch -f $regex);

        $packagePath = Get-ChildItem -Path $Path -Recurse |
            Where-Object { $_.Name -imatch $regex } |
                Sort-Object -Property Name -Descending |
                    Select-Object -ExpandProperty FullName -First 1;

    } #end if

    if ((-not $IsLiteralPath) -and (-not [System.String]::IsNullOrEmpty($packagePath))) {

        Write-Verbose ($localizedData.LocatedPackagePath -f $packagePath);
        $isServiceRelease = $packagePath -match '(?<=SR)\d(?=[-\.])';
        if ($isServiceRelease) {

            $packageName = '{0} SR{1} {2}' -f $productName, $Matches[0], $productDescription;
        }
        else {

            $packageName = '{0} {1}' -f $productName, $productDescription;
        }
        Write-Verbose ($localizedData.UsingPackageName -f $packageName);
        return $packagePath;

    }
    elseif ([System.String]::IsNullOrEmpty($packagePath)) {

       throw ($localizedData.UnableToLocatePackageError -f $Component);
    }

} #end function Resolve-ROWPackagePath
