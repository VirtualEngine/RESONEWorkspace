function Save-ROWManagementPortalConfiguration {
<#
    .SYNOPSIS
        Writes a RES ONE Workspace Management Portal web configuration file.
#>
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'WindowsAuthentication')]
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

    $webConsoleConfigTemplate = @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<webConsoleConfiguration>
    <managementService>
        <#ManagementServicePlaceholder#>
    </managementService>
    <#AuthenticationPlaceholder#>
</webConsoleConfiguration>
'@

$webConsoleManagementServiceSqlAuthenticationTemplate = @'
<database type="<#DatabaseType#>" server="<#DatabaseServer#>" name="<#DatabaseName#>"
            user="<#DatabaseUser#>" password="<#DatabasePassword#>"
            useWindowsAuthentication="false" />
'@

$webConsoleManagementServiceWindowsAuthenticationTemplate = @'
<database type="<#DatabaseType#>" server="<#DatabaseServer#>" name="<#DatabaseName#>"
            useWindowsAuthentication="true" />
'@

$webConsoleSqlAuthenticationTemplate = @'
<authentication type="IdentityBroker">
        <identityServer serverUrl="<#ServerUrl#>"
            applicationUrl="<#ApplicationUrl#>" clientId="<#ClientId#>"
            clientSecret="<#ClientSecret#>" />
    </authentication>
'@

$webConsoleWindowsAuthenticationTemplate = @'
<authentication type="Windows" />
'@

    if ($null -ne $Credential) {

        $managementService = $webConsoleManagementServiceSqlAuthenticationTemplate;
        $managementService = $managementService.Replace('<#DatabaseType#>', 'MSSQL');
        $managementService = $managementService.Replace('<#DatabaseServer#>', $DatabaseServer);
        $managementService = $managementService.Replace('<#DatabaseName#>', $DatabaseName);
        $managementService = $managementService.Replace('<#DatabaseUser#>', $Credential.Username);
        $managementService = $managementService.Replace('<#DatabasePassword#>', $Credential.GetNetworkCredential().Password);

        $webConsoleConfig = $webConsoleConfigTemplate.Replace('<#ManagementServicePlaceholder#>', $managementService);
    }
    else {

        $webConsoleConfig = $webConsoleConfigTemplate.Replace('<#ManagementServicePlaceholder#>', $webConsoleManagementServiceWindowsAuthenticationTemplate);
    }

    if ($PSCmdlet.ParameterSetName -eq 'IdentityBroker') {

        $identityServer = $webConsoleSqlAuthenticationTemplate;
        $identityServer = $identityServer.Replace('<#ServerUrl#>', $IdentityBrokerUrl);
        $identityServer = $identityServer.Replace('<#ApplicationUrl#>', $ApplicationUrl);
        $identityServer = $identityServer.Replace('<#ClientId#>', $ClientId);
        $identityServer = $identityServer.Replace('<#ClientSecret#>', $ClientSecret.GetNetworkCredential().Password);

        $webConsoleConfig = $webConsoleConfig.Replace('<#AuthenticationPlaceholder#>', $identityServer);
    }
    else {

        $webConsoleConfig = $webConsoleConfig.Replace('<#AuthenticationPlaceholder#>', $webConsoleWindowsAuthenticationTemplate);
    }

    Set-Content -Value $webConsoleConfig -Path $Path -Encoding UTF8;

} #end function
