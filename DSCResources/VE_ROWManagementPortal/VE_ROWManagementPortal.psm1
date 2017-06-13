data localizedData {
    # Localized messages; culture="en-US"
    ConvertFrom-StringData @'
        ResourceIncorrectPropertyState  = Resource property '{0}' is NOT in the desired state. Expected '{1}', actual '{2}'.
        ResourceInDesiredState          = Resource '{0}' is in the desired state.
        ResourceNotInDesiredState       = Resource '{0}' is NOT in the desired state.
'@
}


function Get-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param (
        ## IIS website host header/name, i.e. res.lab.local.
        [Parameter(Mandatory)]
        [System.String] $Hostname,

        ## File path containing the RES ONE Workspace MSIs or the literal path to the management portal MSI.
        [Parameter(Mandatory)]
        [System.String] $Path,

        ## Installed certificate thumbprint to bind to the IIS site.
        [Parameter(Mandatory)]
        [System.String] $CertificateThumbprint,

        ## RES ONE Workspace component version to be installed, i.e. 8.0.3.0
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $Version,

        ## The specified Path is a literal file reference (bypasses the $Version and $Architecture checks).
        [Parameter()]
        [System.Boolean] $IsLiteralPath,

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )

    $resolveROWPackagePathParams = @{
        Path = $Path;
        Component = 'ManagementPortal';
        Version = $Version;
        IsLiteralPath = $IsLiteralPath;
        Verbose = $Verbose;
    }
    $setupPath = Resolve-ROWPackagePath @resolveROWPackagePathParams;

    [System.String] $msiProductName = Get-WindowsInstallerPackageProperty -Path $setupPath -Property ProductName;
    $productName = $msiProductName.Trim();

    $targetResource = @{
        Hostname = $Hostname;
        Path = $setupPath;
        CertificateThumbprint = $CertificateThumbprint;
        ProductName = $productName;
        Ensure = if (Get-InstalledProductEntry -Name $productName) { 'Present' } else { 'Absent' };
    }
    return $targetResource;

} #end function


function Test-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        ## IIS website host header/name, i.e. res.lab.local.
        [Parameter(Mandatory)]
        [System.String] $Hostname,

        ## File path containing the RES ONE Workspace MSIs or the literal path to the management portal MSI.
        [Parameter(Mandatory)]
        [System.String] $Path,

        ## Installed certificate thumbprint to bind to the IIS site.
        [Parameter(Mandatory)]
        [System.String] $CertificateThumbprint,

        ## RES ONE Workspace component version to be installed, i.e. 8.0.3.0
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $Version,

        ## The specified Path is a literal file reference (bypasses the $Version and $Architecture checks).
        [Parameter()]
        [System.Boolean] $IsLiteralPath,

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )

    $targetResource = Get-TargetResource @PSBoundParameters;

    if ($Ensure -ne $targetResource.Ensure) {

        Write-Verbose -Message ($localizedData.ResourceIncorrectPropertyState -f 'Ensure', $Ensure, $targetResource.Ensure);
        Write-Verbose -Message ($localizedData.ResourceNotInDesiredState -f $targetResource.ProductName);
        return $false;

    }
    else {

        Write-Verbose -Message ($localizedData.ResourceInDesiredState -f $targetResource.ProductName);
        return $true;

    }

} #end function


function Set-TargetResource {
    [CmdletBinding()]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    param (
        ## IIS website host header/name, i.e. res.lab.local.
        [Parameter(Mandatory)]
        [System.String] $Hostname,

        ## File path containing the RES ONE Workspace MSIs or the literal path to the management portal MSI.
        [Parameter(Mandatory)]
        [System.String] $Path,

        ## Installed certificate thumbprint to bind to the IIS site.
        [Parameter(Mandatory)]
        [System.String] $CertificateThumbprint,

        ## RES ONE Workspace component version to be installed, i.e. 8.0.3.0
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $Version,

        ## The specified Path is a literal file reference (bypasses the $Version and $Architecture checks).
        [Parameter()]
        [System.Boolean] $IsLiteralPath,

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )

    $resolveROWPackagePathParams = @{
        Path = $Path;
        Component = 'ManagementPortal';
        Version = $Version;
        IsLiteralPath = $IsLiteralPath;
        Verbose = $Verbose;
    }
    $setupPath = Resolve-ROWPackagePath @resolveROWPackagePathParams;

    if ($Ensure -eq 'Present') {

        $arguments = @(
            ('/i "{0}"' -f $setupPath),
            ('HOSTNAME="{0}"' -f $Hostname),
            ('SSL_CERTIFICATE_THUMBPRINT="{0}"' -f $CertificateThumbprint)
        )

    }
    elseif ($Ensure -eq 'Absent') {

        [System.String] $msiProductCode = Get-WindowsInstallerPackageProperty -Path $setupPath -Property ProductCode;
        $arguments = @(
            ('/X{0}' -f $msiProductCode)
        )

    }

    ## Start install/uninstall
    $arguments += '/norestart';
    $arguments += '/qn';
    Start-WaitProcess -FilePath "$env:WINDIR\System32\msiexec.exe" -ArgumentList $arguments -Verbose:$Verbose;

} #end function


## Import the ROW common library functions
$moduleRoot = Split-Path -Path $MyInvocation.MyCommand.Path -Parent;
$moduleParent = Split-Path -Path $moduleRoot -Parent;
Import-Module (Join-Path -Path $moduleParent -ChildPath 'ROWCommon') -Force;

Export-ModuleMember -Function *-TargetResource;
