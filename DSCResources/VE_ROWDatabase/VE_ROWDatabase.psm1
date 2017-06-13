# Localized messages
data localizedData
{
    # culture="en-US"
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
        [System.Management.Automation.CredentialAttribute()] $Credential,

        ## Microsoft SQL database credentials used to create the database (equivalient to DBCREATEUSER/DBCREATEPASSWORD).
        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()] $SQLCredential,

        ## File path containing the RES ONE Workspace MSIs or the literal path to the legacy console MSI.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Path,

        ## File path to a RES ONE Service Store license file to import.
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $LicensePath,

        ## Use Database protocol encryption
        [Parameter()]
        [System.Boolean] $UseDatabaseProtocolEncryption,

        ## Use FIPS compliant security algorithms to encrypt data in the database
        [Parameter()]
        [System.Boolean] $UseFIPSEncryption,

        ## RES ONE Workspace component version to be installed, i.e. 9.9.3
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $Version,

        ## The specified Path is a literal file reference (bypasses the Version and Architecture checks).
        [Parameter()]
        [System.Boolean] $IsLiteralPath,

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )

    $setupPath = Resolve-ROWPackagePath -Path $Path -Component 'Console' -Version $Version -IsLiteralPath:$IsLiteralPath -Verbose:$Verbose;
    [System.String] $msiProductName = Get-WindowsInstallerPackageProperty -Path $setupPath -Property ProductName;
    $productName = $msiProductName.Trim();

    $targetResource = @{
        Path = $setupPath;
        ProductName = $productName;
        Ensure = if (Get-InstalledProductEntry -Name $productName) { 'Present' } else { 'Absent' };
    }

    return $targetResource;

} #end function Get-TargetResource


function Test-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
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
        [System.Management.Automation.CredentialAttribute()] $Credential,

        ## Microsoft SQL database credentials used to create the database (equivalient to DBCREATEUSER/DBCREATEPASSWORD).
        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()] $SQLCredential,

        ## File path containing the RES ONE Workspace MSIs or the literal path to the legacy console MSI.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Path,

        ## File path to a RES ONE Service Store license file to import.
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $LicensePath,

        ## Use Database protocol encryption
        [Parameter()]
        [System.Boolean] $UseDatabaseProtocolEncryption,

        ## Use FIPS compliant security algorithms to encrypt data in the database
        [Parameter()]
        [System.Boolean] $UseFIPSEncryption,

        ## RES ONE Workspace component version to be installed, i.e. 9.9.3
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $Version,

        ## The specified Path is a literal file reference (bypasses the Version and Architecture checks).
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

} #end function Test-TargetResource


function Set-TargetResource {
    [CmdletBinding()]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
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
        [System.Management.Automation.CredentialAttribute()] $Credential,

        ## Microsoft SQL database credentials used to create the database (equivalient to DBCREATEUSER/DBCREATEPASSWORD).
        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()] $SQLCredential,

        ## File path containing the RES ONE Workspace MSIs or the literal path to the legacy console MSI.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Path,

        ## File path to a RES ONE Service Store license file to import.
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $LicensePath,

        ## Use Database protocol encryption
        [Parameter()]
        [System.Boolean] $UseDatabaseProtocolEncryption,

        ## Use FIPS compliant security algorithms to encrypt data in the database
        [Parameter()]
        [System.Boolean] $UseFIPSEncryption,

        ## RES ONE Workspace component version to be installed, i.e. 9.9.3
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $Version,

        ## The specified Path is a literal file reference (bypasses the Version and Architecture checks).
        [Parameter()]
        [System.Boolean] $IsLiteralPath,

        [Parameter()]
        [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )

    $setupPath = Resolve-ROWPackagePath -Path $Path -Component 'Console' -Version $Version -IsLiteralPath:$IsLiteralPath -Verbose:$Verbose;
    if ($Ensure -eq 'Present') {

        $arguments = @(
            ('/i "{0}"' -f $setupPath),
            ('DBSERVER="{0}"' -f $DatabaseServer),
            ('DBNAME="{0}"' -f $DatabaseName),
            ('DBUSER="{0}"' -f $Credential.Username),
            ('DBPASSWORD="{0}"' -f $Credential.GetNetworkCredential().Password),
            ('DBTYPE="MSSQL"'),
            ('DBCREATE="yes"'),
            ('DBCREATEUSER="{0}"' -f $SQLCredential.Username),
            ('DBCREATEPASSWORD="{0}"' -f $SQLCredential.GetNetworkCredential().Password)
        )

        if ($PSBoundParameters.ContainsKey('UseDatabaseProtocolEncryption')) {

            if ($UseDatabaseProtocolEncryption -eq $true) {

                $arguments += 'DBPROTOCOLENCRYPTION="yes"';
            }
        }

        if ($PSBoundParameters.ContainsKey('UseFIPSEncryption')) {

            if ($UseFIPSEncryption -eq $true) {
                
                $arguments += 'DBFIPS="yes"';
            }
        }

        if ($PSBoundParameters.ContainsKey('LicensePath')) {

            $arguments += 'DBIMPORTLICENSE="{0}"' -f $LicensePath;
        }

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

} #end function Set-TargetResource


## Import the ROWCommon library functions
$moduleRoot = Split-Path -Path $MyInvocation.MyCommand.Path -Parent;
$moduleParent = Split-Path -Path $moduleRoot -Parent;
Import-Module (Join-Path -Path $moduleParent -ChildPath 'ROWCommon') -Force;

Export-ModuleMember -Function *-TargetResource;
