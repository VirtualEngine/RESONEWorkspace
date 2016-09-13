function Get-ROWErrorCode {
<#
    .SYNOPSIS
        Resolves a RES ONE Workspace console exit error code to a string.
#>
    [CmdletBinding()]
    [OutputType([System.String])]
    param (
        ## PWRTECH.EXE exit code to resolve to a string
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [System.Int32]
        $ExitCode
    )
    process {

        $errorCodeKeyName = 'PwrtechExitCode{0}Error' -f $ExitCode;
        return $localizedData.$errorCodeKeyName;

    } #end process
} #end function Get-ROWErrorCode
