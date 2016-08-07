# Localized messages
data LocalizedData
{
    # culture="en-US"
    ConvertFrom-StringData @'
        StartingProcess                 = Starting process '{0}' with parameters '{1}'.
        StartingProcessAs               = Starting process as user '{0}'.
        ProcessLaunched                 = Process id '{0}' successfully started.
        WaitingForProcessToExit         = Waiting for process id '{0}' to exit.
        ProcessExited                   = Process id '{0}' exited with code '{1}'.
        OpeningMSIDatabase              = Opening MSI database '{0}'.
        SearchFilePatternMatch          = Searching for files matching pattern '{0}'.
        LocatedPackagePath              = Located package '{0}'.
        UsingPackageName                = Using package name '{0}'.

        VersionNumberRequiredError      = Version number is required when not using a literal path.
        InvalidPathTypeError            = Specified path '{0}' does not point to a '{1}' file.
        InvalidVersionNumberFormatError = The specified version '{0}' does not match '1.2', '1.2.3' or '1.2.3.4' format.
        UnsupportedVersionError         = Version '{0}' is not supported/untested :(
        UnableToLocatePackageError      = Unable to locate '{0}' package.
'@
}


function GetWindowsInstallerPackageProperty {
<#
    .SYNOPSIS
        This cmdlet retrieves product name from a Windows Installer MSI database.
    .DESCRIPTION
        This function uses the WindowInstaller COM object to pull all values from the Property table from a MSI package.
    .NOTES
        Adapted from http://www.scconfigmgr.com/2014/08/22/how-to-get-msi-file-information-with-powershell/
#>
    [CmdletBinding()]
    [OutputType([System.String])]
    param (
        [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'Path')]
        [ValidateNotNullOrEmpty()]
        [Alias('PSPath','FullName')]
        [System.String] $Path,

        [Parameter(Mandatory, Position = 0, ValueFromPipelineByPropertyName, ParameterSetName = 'LiteralPath')]
        [ValidateNotNullOrEmpty()]
        [System.String] $LiteralPath,

        [Parameter(Position = 1, ValueFromPipelineByPropertyName)]
        [ValidateSet('ProductCode', 'ProductVersion', 'ProductName', 'UpgradeCode')]
        [System.String] $Property = 'ProductCode'
    )
    begin {

        if ($PSCmdlet.ParameterSetName -eq 'Path') {
            $LiteralPath += $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path);
        }

    } #end begin
    process {

        $windowsInstaller = New-Object -ComObject WindowsInstaller.Installer;
        Write-Verbose -Message ($localizedData.OpeningMSIDatabase -f $LiteralPath);
        try {
            $msiDatabase = $windowsInstaller.GetType().InvokeMember('OpenDatabase', 'InvokeMethod', $null, $windowsInstaller, @("$LiteralPath", 0));
            $query = "SELECT Value FROM Property WHERE Property = '{0}'" -f $Property;
            $view = $msiDatabase.GetType().InvokeMember('OpenView', 'InvokeMethod', $null, $msiDatabase, $query);
            $view.GetType().InvokeMember('Execute', 'InvokeMethod', $null, $view, $null);
            $record = $view.GetType().InvokeMember('Fetch','InvokeMethod', $null, $view, $null);
            $value = $record.GetType().InvokeMember('StringData', 'GetProperty', $null, $record, 1);
            return $value;
        }
        catch {
            throw;
        }

    } #end process
} #end function Get-WindowsInstallerPackageProperty


function StartWaitProcess {
<#
    .SYNOPSIS
        Starts and waits for a process to exit.
    .NOTES
        This is an internal function and shouldn't be called from outside.
#>
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([System.Int32])]
    param (
        # Path to process to start.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String] $FilePath,

        # Arguments (if any) to apply to the process.
        [Parameter()]
        [AllowNull()]
        [System.String[]] $ArgumentList,

        # Credential to start the process as.
        [Parameter()] [AllowNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $Credential,

        # Working directory
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $WorkingDirectory = (Split-Path -Path $FilePath -Parent)
    )
    process {

        $startProcessParams = @{
            FilePath = $FilePath;
            WorkingDirectory = $WorkingDirectory;
            NoNewWindow = $true;
            PassThru = $true;
        };
        $displayParams = '<None>';

        if ($ArgumentList) {
            $displayParams = [System.String]::Join(' ', $ArgumentList);
            $startProcessParams['ArgumentList'] = $ArgumentList;
        }

        Write-Verbose ($localizedData.StartingProcess -f $FilePath, $displayParams);

        if ($Credential) {
            Write-Verbose ($localizedData.StartingProcessAs -f $Credential.UserName);
            $startProcessParams['Credential'] = $Credential;
        }

        if ($PSCmdlet.ShouldProcess($FilePath, 'Start Process')) {
            $process = Start-Process @startProcessParams -ErrorAction Stop;
        }

        if ($PSCmdlet.ShouldProcess($FilePath, 'Wait Process')) {
            Write-Verbose ($localizedData.ProcessLaunched -f $process.Id);
            Write-Verbose ($localizedData.WaitingForProcessToExit -f $process.Id);
            $process.WaitForExit();
            $exitCode = [System.Convert]::ToInt32($process.ExitCode);
            Write-Verbose ($localizedData.ProcessExited -f $process.Id, $exitCode);
        }
        return $exitCode;

    } #end process
} #end function StartWaitProcess


function GetProductEntry {
<#
    .NOTES
        https://github.com/PowerShell/xPSDesiredStateConfiguration/blob/dev/DSCResources/MSFT_xPackageResource/MSFT_xPackageResource.psm1
#>
    param (
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $Name,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $IdentifyingNumber,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $InstalledCheckRegHive = 'LocalMachine',

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $InstalledCheckRegKey,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $InstalledCheckRegValueName,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $InstalledCheckRegValueData
    )

    $uninstallKey = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall';
    $uninstallKeyWow64 = 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall';

    if ($IdentifyingNumber) {
        $keyLocation = '{0}\{1}' -f $uninstallKey, $identifyingNumber;
        $item = Get-Item $keyLocation -ErrorAction SilentlyContinue;
        if (-not $item) {
            $keyLocation = '{0}\{1}' -f $uninstallKeyWow64, $identifyingNumber;
            $item = Get-Item $keyLocation -ErrorAction SilentlyContinue;
        }
        return $item;
    }

    foreach ($item in (Get-ChildItem -ErrorAction Ignore $uninstallKey, $uninstallKeyWow64)) {
        if ($Name -eq (GetLocalizableRegKeyValue $item 'DisplayName')) {
            return $item;
        }
    }

    if ($InstalledCheckRegKey -and $InstalledCheckRegValueName -and $InstalledCheckRegValueData) {
        $installValue = $null;
        $getRegistryValueIgnoreErrorParams = @{
            RegistryHive = $InstalledCheckRegHive;
            Key = $InstalledCheckRegKey;
            Value = $InstalledCheckRegValueName;
        }

        #if 64bit OS, check 64bit registry view first
        if ([System.Environment]::Is64BitOperatingSystem) {
            $installValue = GetRegistryValueIgnoreError @getRegistryValueIgnoreErrorParams -RegistryView [Microsoft.Win32.RegistryView]::Registry64;
        }

        if ($null -eq $installValue) {
            $installValue = GetRegistryValueIgnoreError @getRegistryValueIgnoreErrorParams -RegistryView [Microsoft.Win32.RegistryView]::Registry32;
        }

        if ($installValue) {
            if ($InstalledCheckRegValueData -and $installValue -eq $InstalledCheckRegValueData) {
                return @{ Installed = $true; }
            }
        }
    }

    return $null;

} #end function GetProductEntry


function GetRegistryValueIgnoreError {
<#
    .NOTES
        https://github.com/PowerShell/xPSDesiredStateConfiguration/blob/dev/DSCResources/MSFT_xPackageResource/MSFT_xPackageResource.psm1
#>

    param (
        [Parameter(Mandatory)]
        [Microsoft.Win32.RegistryHive] $RegistryHive,

        [Parameter(Mandatory)]
        [System.String] $Key,

        [Parameter(Mandatory)]
        [System.String] $Value,

        [Parameter(Mandatory)]
        [Microsoft.Win32.RegistryView] $RegistryView
    )

    try {
        $baseKey = [Microsoft.Win32.RegistryKey]::OpenBaseKey($RegistryHive, $RegistryView);
        $subKey =  $baseKey.OpenSubKey($Key);
        if ($null -ne $subKey) {
            return $subKey.GetValue($Value);
        }
    }
    catch {
        $exceptionText = ($_ | Out-String).Trim();
        Write-Verbose "Exception occured in GetRegistryValueIgnoreError: $exceptionText";
    }
    return $null;

} #end function GetRegistryValueIgnoreError


function GetLocalizableRegKeyValue {
<#
    .NOTES
        https://github.com/PowerShell/xPSDesiredStateConfiguration/blob/dev/DSCResources/MSFT_xPackageResource/MSFT_xPackageResource.psm1
#>

    param (
        [Parameter()]
        [System.Object] $RegKey,

        [Parameter()]
        [System.String] $ValueName
    )

    $res = $RegKey.GetValue("{0}_Localized" -f $ValueName);
    if (-not $res) {
        $res = $RegKey.GetValue($ValueName);
    }
    return $res;
} #end function GetLocalizableRegKeyValue


function ResolveROWPackagePath {
<#
    .SYNOPSIS
        Resolves the latest RES ONE Workspace/Workspace Manager installation package.
#>
    [CmdletBinding()]
    param (
        ## The literal file path or root search path
        [Parameter(Mandatory)]  [ValidateNotNullOrEmpty()]
        [System.String] $Path,

        ## Required RES ONE Workspace/Workspace Manager component
        [Parameter(Mandatory)] [ValidateSet('Console','AgentOnly','FullAgent','RelayServer')]
        [System.String] $Component,

        ## RES ONE Workspace component version to be installed, i.e. 9.9 or 9.10.2
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $Version,

        ## The specified Path is a literal file reference (bypasses the Version and Architecture checks).
        [Parameter()]
        [System.Boolean] $IsLiteralPath
    )

    if (([System.String]::IsNullOrWhitespace($Version)) -and (-not $IsLiteralPath)) {
        throw ($LocalizedData.SpecifedPathTypeError);
    }
    elseif ($IsLiteralPath) {
        if ($Path -notmatch '\.msi$') {
            throw ($LocalizedData.InvalidPathTypeError -f $Path, 'MSI');
        }
    }
    elseif ($Version -notmatch '^\d\.\d\d?(\.\d\d?|\.\d\d?\.\d\d?)?$') {
         throw ($LocalizedData.InvalidVersionNumberFormatError -f $Version);
    }

    if ($IsLiteralPath) {
        $packagePath = $Path;
    }
    else {

        [System.Version] $productVersion = $Version;

        switch ($productVersion.Major) {

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
                    Default {
                        throw ($LocalizedData.UnsupportedVersionError -f $Version);
                    }

                } #end switch version minor

            }

            Default {
                throw ($LocalizedData.UnsupportedVersionError -f $Version);
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

        Write-Verbose -Message ($LocalizedData.SearchFilePatternMatch -f $regex);

        $packagePath = Get-ChildItem -Path $Path -Recurse |
            Where-Object { $_.Name -imatch $regex } |
                Sort-Object -Property Name -Descending |
                    Select-Object -ExpandProperty FullName -First 1;

    } #end if

    if ((-not $IsLiteralPath) -and (-not [System.String]::IsNullOrEmpty($packagePath))) {

        Write-Verbose ($LocalizedData.LocatedPackagePath -f $packagePath);
        $isServiceRelease = $packagePath -match '(?<=SR)\d(?=[-\.])';
        if ($isServiceRelease) {
            $packageName = '{0} SR{1} {2}' -f $productName, $Matches[0], $productDescription;
        }
        else {
            $packageName = '{0} {1}' -f $productName, $productDescription;
        }
        Write-Verbose ($LocalizedData.UsingPackageName -f $packageName);
        return $packagePath;

    }
    elseif ([System.String]::IsNullOrEmpty($packagePath)) {
       throw ($LocalizedData.UnableToLocatePackageError -f $Component);
    }

} #end function ResolveROWPackagePath
