configuration ROWCitrixProcessIntercept {
<#
    .SYNOPSIS
        Manages the RES ONE Workspace Citrix Process Intercept setting
#>
    param (
        [Parameter(Mandatory)] [ValidateSet('Present','Absent')]
        [System.String] $Ensure,

        ## The target node's architecture.
        [Parameter()] [ValidateSet('x64','x86')]
        [System.String] $Architecture = 'x64'
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration;

    if ($Architecture -eq 'x64') {
        $key = 'HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\RES\Workspace Manager';
    }
    elseif ($Architecture -eq 'x86') {
        $key = 'HKEY_LOCAL_MACHINE\SOFTWARE\RES\Workspace Manager';
    }

    Registry 'ROWCitrixProcessIntercept' {
        Key       = $key;
        ValueName = 'CTXRunComposer';
        ValueData = 'automatic';
        ValueType = 'String';
        Ensure    = $Ensure;
    }

} #end configuration ROWCitrixProcessIntercept
