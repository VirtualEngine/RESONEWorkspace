@{
    RootModule        = 'ROWCommon.psm1'
    ModuleVersion     = '1.0'
    GUID              = '2989eb60-a53a-4eb3-9b4c-2505ec72d7b7'
    Author            = 'Iain Brighton'
    CompanyName       = 'Virtual Engine'
    Copyright         = '(c) 2016 Virtual Engine Limited. All rights reserved.'
    Description       = 'RES ONE Workspace common function library'
    PowerShellVersion = '4.0'
    FunctionsToExport = @(
                            'Assert-ROWComponent',
                            'Export-ROWBuildingBlockFile',
                            'Get-InstalledProductEntry',
                            'Get-LocalizableRegistryKeyValue',
                            'Get-RegistryValueIgnoreError',
                            'Get-ROWComponentInstallPath',
                            'Get-ROWConsolePath',
                            'Get-ROWErrorCode',
                            'Get-WindowsInstallerPackageProperty',
                            'Import-ROWBuildingBlockFile',
                            'Register-PInvoke',
                            'Resolve-ROWPackagePath',
                            'Save-ROWManagementPortalConfiguration',
                            'Start-WaitProcess'
                        );
}
