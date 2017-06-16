function New-ROWManagementPortalConfiguration {
<#
    .SYNOPSIS
        Creates a RES ONE Workspace Management Portal web configuration file.
#>
    [CmdletBinding(DefaultParameterSetName = 'WindowsAuthentication')]
    param (
        ## Path to RES ONE Workspace Management Portal web configuration file
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.String] $Path,

        ## RES ONE Workspace database server/instance name.
        [Parameter(Mandatory)]
        [System.String] $DatabaseServer,

        ## RES ONE Workspace database name.
        [Parameter(Mandatory)]
        [System.String] $DatabaseName,
        
        ## RES ONE Workspace database access credential. Leave blank to use Windows Authentication for database access.
        [Parameter()]
        [SYstem.Management.Automation.PSCredential] $Credential,

        ## RES ONE Identity Broker server Uri.
        [Parameter(Mandatory, ParameterSetName = 'IdentityBroker')]
        [System.String] $IdentityBrokerUrl,

        ## RES ONE Identity Broker application Uri.
        [Parameter(Mandatory, ParameterSetName = 'IdentityBroker')]
        [System.String] $ApplicationUrl,

        ## RES ONE Identity Broker client Id.        
        [Parameter(Mandatory, ParameterSetName = 'IdentityBroker')]
        [System.String] $ClientId,

        ## RES ONE Identity Broker client shared secret.
        [Parameter(Mandatory, ParameterSetName = 'IdentityBroker')]
        [System.Management.Automation.PSCredential] $ClientSecret        
    )

    ## Call method in ROWCommon module
    Save-ROWManagementPortalConfiguration @PSBoundParameters;

} #end function
