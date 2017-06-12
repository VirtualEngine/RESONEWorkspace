function Assert-ROWComponent {
<#
    .SYNOPSIS
        Ensures that the RES ONE Workspace component is installed.
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateSet('Agent','Console','RelayServer')]
        [System.String] $Component
    )
    process {

        if (-not (Get-ROWComponentInstallPath -Component $Component)) {
            
            throw ($localizedData.ROWComponentNotFoundError -f $Component);
        }

    } #end process
} #end function Assert-ROWComponent
