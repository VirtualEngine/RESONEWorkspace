function Get-ROWConsolePath {
<#
    .SYNOPSIS
        Returns the RES ONE Workspace console path.
#>
    [CmdletBinding()]
    [OutputType([System.String])]
    param ( )
    begin {

        Assert-ROWComponent -Component 'Console';

    }
    process {

        $pwrtechRootPath = Get-ROWComponentInstallPath -Component 'Console';
        $pwrtechPath = Join-Path -Path $pwrtechRootPath -ChildPath 'pwrtech.exe';
        if (-not (Test-Path -Path $pwrtechPath -PathType Leaf)) {
            
            throw ($localizedData.ROWConsoleNotFoundError);
        }
        return $pwrtechPath;

    } #end process
} #end function GetROAConsolePath
