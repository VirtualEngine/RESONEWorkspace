function Get-ROWComponentInstallPath {
<#
    .SYNOPSIS
        Resolves the installation directory of the specified RES ONE Workspace component.
#>
    [CmdletBinding()]
    [OutputType([System.String])]
    param (
        [Parameter(Mandatory)]
        [ValidateSet('Agent','Console','RelayServer','ReportingServices')]
        [System.String] $Component
    )
    process {

        $installedProducts = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
                                'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*';
        $resProducts = $installedProducts |
            Where-Object { $_.DisplayName -match '^RES' -and $_.DisplayName -match 'Workspace' }

        if ($Component -eq 'Agent') {
            ## Full RES ONE Workspace agent has no notable identifier
            $resProduct = $resProducts |
                Where-Object { $_.DisplayName -match 'Agent' -or ($_.DisplayName -notmatch 'Console' -and $_.DisplayName -notmatch 'Relay Server' -and $_.DisplayName -notmatch 'Reporting Services')}
        }
        elseif ($Component -eq 'Console') {

            $resProduct = $resProducts |
                Where-Object { $_.DisplayName -notmatch 'Agent' -and $_.DisplayName -notmatch 'Relay Server' -and $_.DisplayName -notmatch 'Reporting Services' }
        }
        elseif ($Component -eq 'RelayServer') {
            $resProduct = $resProducts |
                Where-Object { $_.DisplayName -match 'Relay Server' }
        }
        elseif ($Component -eq 'ReportingServices') {
            $resProduct = $resProducts |
                Where-Object { $_.DisplayName -match 'Reporting Services' }
        }

        return $resProduct.InstallLocation;

    } #end process
} #end function Get-ROWComponentInstallPath
