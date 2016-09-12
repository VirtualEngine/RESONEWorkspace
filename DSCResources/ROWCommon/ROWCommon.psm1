# Localized messages
data LocalizedData
{
    # culture="en-US"
    ConvertFrom-StringData @'
        StartingProcess                 = Starting process '{0}' '{1}'.
        StartingProcessAs               = Starting process '{0}' '{1}' as user '{2}'.
        ProcessExited                   = Process exited with code '{0}'.
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
        #[AllowNull()]
        [System.String[]] $ArgumentList,

        # Credential to start the process as.
        [Parameter()] [AllowNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()] $Credential,

        # Working directory
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $WorkingDirectory = (Split-Path -Path $FilePath -Parent)
    )
    process {

        $startInfo = New-Object System.Diagnostics.ProcessStartInfo;
        $startInfo.UseShellExecute = $false; #Necessary for I/O redirection and just generally a good idea
        $process = New-Object System.Diagnostics.Process;
        $process.StartInfo = $startInfo;
        $startInfo.FileName = $FilePath;

        $startInfo.RedirectStandardError = $true
        $startInfo.RedirectStandardOutput = $true
        $exitCode = 0;

        $displayParams = '<None>';
        if ($ArgumentList) {
            $arguments = [System.String]::Join(' ', $ArgumentList);
            $displayParams = $arguments;
            $startInfo.Arguments = $arguments;
        }


        try {
            if($PSBoundParameters.ContainsKey('Credential')) {

                $commandLine = '"{0}" {1}' -f $startInfo.FileName, $startInfo.Arguments;
                Write-Verbose ($localizedData.StartingProcessAs -f $FilePath, $displayParams, $Credential.UserName);
                CallPInvoke;
                [Source.NativeMethods]::CreateProcessAsUser(
                    $commandLine,
                    $Credential.GetNetworkCredential().Domain,
                    $Credential.GetNetworkCredential().UserName,
                    $Credential.GetNetworkCredential().Password,
                    [ref] $exitCode
                );
            }
            else {

                Write-Verbose ($localizedData.StartingProcess -f $FilePath, $displayParams);
                [ref] $null = $process.Start();
                $process.WaitForExit();

                if ($process) {
                    $exitCode = $process.ExitCode;
                }
            }

            Write-Verbose ($localizedData.ProcessExited -f $exitCode);
            return $exitCode;
        }
        catch {

            throw $_;
        }

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
                    12 {
                        $packageName = 'RES-ONE-Workspace-2016';
                        $productName = 'RES ONE Workspace 2016';
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


function CallPInvoke {
<#
    .NOTES
        Kindly donated by Micorsoft from:
        https://github.com/PowerShell/xPSDesiredStateConfiguration/blob/564bfba5bb0114623a334e1c7a8842b4996e05a6/DSCResources/MSFT_xPackageResource/MSFT_xPackageResource.psm1
#>
    [CmdletBinding()]
    param ( )
    process {

        $script:ProgramSource = @'
using System;
using System.Collections.Generic;
using System.Text;
using System.Security;
using System.Runtime.InteropServices;
using System.Diagnostics;
using System.Security.Principal;
using System.ComponentModel;
using System.IO;
namespace Source
{
    [SuppressUnmanagedCodeSecurity]
    public static class NativeMethods
    {
        //The following structs and enums are used by the various Win32 API's that are used in the code below
        [StructLayout(LayoutKind.Sequential)]
        public struct STARTUPINFO
        {
            public Int32 cb;
            public string lpReserved;
            public string lpDesktop;
            public string lpTitle;
            public Int32 dwX;
            public Int32 dwY;
            public Int32 dwXSize;
            public Int32 dwXCountChars;
            public Int32 dwYCountChars;
            public Int32 dwFillAttribute;
            public Int32 dwFlags;
            public Int16 wShowWindow;
            public Int16 cbReserved2;
            public IntPtr lpReserved2;
            public IntPtr hStdInput;
            public IntPtr hStdOutput;
            public IntPtr hStdError;
        }
        [StructLayout(LayoutKind.Sequential)]
        public struct PROCESS_INFORMATION
        {
            public IntPtr hProcess;
            public IntPtr hThread;
            public Int32 dwProcessID;
            public Int32 dwThreadID;
        }

        [Flags]
        public enum LogonType
        {
            LOGON32_LOGON_INTERACTIVE = 2,
            LOGON32_LOGON_NETWORK = 3,
            LOGON32_LOGON_BATCH = 4,
            LOGON32_LOGON_SERVICE = 5,
            LOGON32_LOGON_UNLOCK = 7,
            LOGON32_LOGON_NETWORK_CLEARTEXT = 8,
            LOGON32_LOGON_NEW_CREDENTIALS = 9
        }
        [Flags]
        public enum LogonProvider
        {
            LOGON32_PROVIDER_DEFAULT = 0,
            LOGON32_PROVIDER_WINNT35,
            LOGON32_PROVIDER_WINNT40,
            LOGON32_PROVIDER_WINNT50
        }
        [StructLayout(LayoutKind.Sequential)]
        public struct SECURITY_ATTRIBUTES
        {
            public Int32 Length;
            public IntPtr lpSecurityDescriptor;
            public bool bInheritHandle;
        }
        public enum SECURITY_IMPERSONATION_LEVEL
        {
            SecurityAnonymous,
            SecurityIdentification,
            SecurityImpersonation,
            SecurityDelegation
        }
        public enum TOKEN_TYPE
        {
            TokenPrimary = 1,
            TokenImpersonation
        }

        [StructLayout(LayoutKind.Sequential, Pack = 1)]
        internal struct TokPriv1Luid
        {
            public int Count;
            public long Luid;
            public int Attr;
        }
        public const int GENERIC_ALL_ACCESS = 0x10000000;
        public const int CREATE_NO_WINDOW = 0x08000000;
        internal const int SE_PRIVILEGE_ENABLED = 0x00000002;
        internal const int TOKEN_QUERY = 0x00000008;
        internal const int TOKEN_ADJUST_PRIVILEGES = 0x00000020;
        internal const string SE_INCRASE_QUOTA = "SeIncreaseQuotaPrivilege";
        [DllImport("kernel32.dll",
              EntryPoint = "CloseHandle", SetLastError = true,
              CharSet = CharSet.Auto, CallingConvention = CallingConvention.StdCall)]
        public static extern bool CloseHandle(IntPtr handle);
        [DllImport("advapi32.dll",
              EntryPoint = "CreateProcessAsUser", SetLastError = true,
              CharSet = CharSet.Ansi, CallingConvention = CallingConvention.StdCall)]
        public static extern bool CreateProcessAsUser(
            IntPtr hToken,
            string lpApplicationName,
            string lpCommandLine,
            ref SECURITY_ATTRIBUTES lpProcessAttributes,
            ref SECURITY_ATTRIBUTES lpThreadAttributes,
            bool bInheritHandle,
            Int32 dwCreationFlags,
            IntPtr lpEnvrionment,
            string lpCurrentDirectory,
            ref STARTUPINFO lpStartupInfo,
            ref PROCESS_INFORMATION lpProcessInformation
            );

        [DllImport("advapi32.dll", EntryPoint = "DuplicateTokenEx")]
        public static extern bool DuplicateTokenEx(
            IntPtr hExistingToken,
            Int32 dwDesiredAccess,
            ref SECURITY_ATTRIBUTES lpThreadAttributes,
            Int32 ImpersonationLevel,
            Int32 dwTokenType,
            ref IntPtr phNewToken
            );
        [DllImport("advapi32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
        public static extern Boolean LogonUser(
            String lpszUserName,
            String lpszDomain,
            String lpszPassword,
            LogonType dwLogonType,
            LogonProvider dwLogonProvider,
            out IntPtr phToken
            );
        [DllImport("advapi32.dll", ExactSpelling = true, SetLastError = true)]
        internal static extern bool AdjustTokenPrivileges(
            IntPtr htok,
            bool disall,
            ref TokPriv1Luid newst,
            int len,
            IntPtr prev,
            IntPtr relen
            );
        [DllImport("kernel32.dll", ExactSpelling = true)]
        internal static extern IntPtr GetCurrentProcess();
        [DllImport("advapi32.dll", ExactSpelling = true, SetLastError = true)]
        internal static extern bool OpenProcessToken(
            IntPtr h,
            int acc,
            ref IntPtr phtok
            );
        [DllImport("kernel32.dll", ExactSpelling = true)]
        internal static extern int WaitForSingleObject(
            IntPtr h,
            int milliseconds
            );
        [DllImport("kernel32.dll", ExactSpelling = true)]
        internal static extern bool GetExitCodeProcess(
            IntPtr h,
            out int exitcode
            );
        [DllImport("advapi32.dll", SetLastError = true)]
        internal static extern bool LookupPrivilegeValue(
            string host,
            string name,
            ref long pluid
            );

        public static void CreateProcessAsUser(string strCommand, string strDomain, string strName, string strPassword, ref int ExitCode )
        {
            var hToken = IntPtr.Zero;
            var hDupedToken = IntPtr.Zero;
            TokPriv1Luid tp;
            var pi = new PROCESS_INFORMATION();
            var sa = new SECURITY_ATTRIBUTES();
            sa.Length = Marshal.SizeOf(sa);
            Boolean bResult = false;
            try
            {
                bResult = LogonUser(
                    strName,
                    strDomain,
                    strPassword,
                    LogonType.LOGON32_LOGON_BATCH,
                    LogonProvider.LOGON32_PROVIDER_DEFAULT,
                    out hToken
                    );
                if (!bResult)
                {
                    throw new Win32Exception("Logon error #" + Marshal.GetLastWin32Error().ToString());
                }
                IntPtr hproc = GetCurrentProcess();
                IntPtr htok = IntPtr.Zero;
                bResult = OpenProcessToken(
                        hproc,
                        TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY,
                        ref htok
                    );
                if(!bResult)
                {
                    throw new Win32Exception("Open process token error #" + Marshal.GetLastWin32Error().ToString());
                }

                tp.Count = 1;
                tp.Luid = 0;
                tp.Attr = SE_PRIVILEGE_ENABLED;
                bResult = LookupPrivilegeValue(
                    null,
                    SE_INCRASE_QUOTA,
                    ref tp.Luid
                    );
                if(!bResult)
                {
                    throw new Win32Exception("Lookup privilege error #" + Marshal.GetLastWin32Error().ToString());
                }
                bResult = AdjustTokenPrivileges(
                    htok,
                    false,
                    ref tp,
                    0,
                    IntPtr.Zero,
                    IntPtr.Zero
                    );
                if(!bResult)
                {
                    throw new Win32Exception("Token elevation error #" + Marshal.GetLastWin32Error().ToString());
                }
                bResult = DuplicateTokenEx(
                    hToken,
                    GENERIC_ALL_ACCESS,
                    ref sa,
                    (int)SECURITY_IMPERSONATION_LEVEL.SecurityIdentification,
                    (int)TOKEN_TYPE.TokenPrimary,
                    ref hDupedToken
                    );
                if(!bResult)
                {
                    throw new Win32Exception("Duplicate Token error #" + Marshal.GetLastWin32Error().ToString());
                }
                var si = new STARTUPINFO();
                si.cb = Marshal.SizeOf(si);
                si.lpDesktop = "";
                bResult = CreateProcessAsUser(
                    hDupedToken,
                    null,
                    strCommand,
                    ref sa,
                    ref sa,
                    false,
                    0,
                    IntPtr.Zero,
                    null,
                    ref si,
                    ref pi
                    );
                if(!bResult)
                {
                    throw new Win32Exception("Create process as user error #" + Marshal.GetLastWin32Error().ToString());
                }
                int status = WaitForSingleObject(pi.hProcess, -1);
                if(status == -1)
                {
                    throw new Win32Exception("Wait during create process failed user error #" + Marshal.GetLastWin32Error().ToString());
                }
                bResult = GetExitCodeProcess(pi.hProcess, out ExitCode);
                if(!bResult)
                {
                    throw new Win32Exception("Retrieving status error #" + Marshal.GetLastWin32Error().ToString());
                }
            }
            finally
            {
                if (pi.hThread != IntPtr.Zero)
                {
                    CloseHandle(pi.hThread);
                }
                if (pi.hProcess != IntPtr.Zero)
                {
                    CloseHandle(pi.hProcess);
                }
                if (hDupedToken != IntPtr.Zero)
                {
                    CloseHandle(hDupedToken);
                }
            }
        }
    }
}
'@
        Add-Type -TypeDefinition $ProgramSource -ReferencedAssemblies 'System.ServiceProcess';

    } #end process
} #end function CallPInvoke
