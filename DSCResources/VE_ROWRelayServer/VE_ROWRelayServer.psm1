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
        [System.UInt16] $Port,

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
        
        [Parameter()] [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )

    $setupPath = ResolveROWPackagePath -Path $Path -Component 'RelayServer' -Version $Version -IsLiteralPath:$IsLiteralPath -Verbose:$Verbose;
    [System.String] $msiProductName = GetWindowsInstallerPackageProperty -Path $setupPath -Property ProductName;
    $productName = $msiProductName.Trim();
    $targetResource = @{
        Path = $setupPath;
        ProductName = $productName;
        Ensure = if (GetProductEntry -Name $productName) { 'Present' } else { 'Absent' };       
    }
    return $targetResource; 
    
} #end function Get-TargetResource


function Test-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
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
        [System.UInt16] $Port,

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
        
        [Parameter()] [ValidateSet('Present','Absent')]
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
        [System.UInt16] $Port,

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
        
        [Parameter()] [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )

    $setupPath = ResolveROWPackagePath -Path $Path -Component 'RelayServer' -Version $Version -IsLiteralPath:$IsLiteralPath -Verbose:$Verbose;
    if ($Ensure -eq 'Present') {
    
        $arguments = @(
            ('/i "{0}"' -f $setupPath),
            ('DBSERVER="{0}"' -f $DatabaseServer),
            ('DBNAME="{0}"' -f $DatabaseName),
            ('DBUSER="{0}"' -f $Credential.Username),
            ('DBPASSWORD="{0}"' -f $Credential.GetNetworkCredential().Password),
            ('DBTYPE="MSSQL"'),
            ('PORT="{0}"' -f $Port)
        )

        if ($PSBoundParameters.ContainsKey('CachePath')) {
            $arguments += 'CACHEPATH="{0}"' -f $CachePath;
        }

    }
    elseif ($Ensure -eq 'Absent') {

        [System.String] $msiProductCode = GetWindowsInstallerPackageProperty -Path $setupPath -Property ProductCode;
        $arguments = @(
            ('/X{0}' -f $msiProductCode)
        )

    }

    ## Start install/uninstall
    $arguments += '/norestart';
    $arguments += '/qn';
    StartWaitProcess -FilePath "$env:WINDIR\System32\msiexec.exe" -ArgumentList $arguments -Verbose$Verbose;
    
} #end function Set-TargetResource


## Import the ROWCommon library functions
$moduleRoot = Split-Path -Path $MyInvocation.MyCommand.Path -Parent;
$moduleParent = Split-Path -Path $moduleRoot -Parent;
Import-Module (Join-Path -Path $moduleParent -ChildPath 'VE_ROWCommon') -Force;

Export-ModuleMember -Function *-TargetResource;
