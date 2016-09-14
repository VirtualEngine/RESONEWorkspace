@{
    RootModule           = 'RESONEWorkspace.psm1';
    ModuleVersion        = '2.1.3';
    GUID                 = 'da2df370-2b26-4319-aae7-ec4eebfd478d';
    Author               = 'Iain Brighton';
    CompanyName          = 'Virtual Engine';
    Copyright            = '(c) 2016 Virtual Engine Limited. All rights reserved.';
    Description          = 'RES ONE Workspace PowerShell cmdlets and configuration DSC resources. These resources are provided AS IS, and are not supported through any means.';
    PowerShellVersion    = '4.0';
    FunctionsToExport    = @('Import-ROWBuildingBlock','Export-ROWBuildingBlock');
    DscResourcesToExport = @('ROWBuildingBlock', 'ROWConsole', 'ROWDatabase', 'ROWDatabaseAgent','ROWRelayServer','ROWRelayServerAgent');

    PrivateData = @{
        PSData = @{
            Tags = @('VirtualEngine','RES','ONE','Workspace','Manager','DSC');
            LicenseUri = 'https://github.com/VirtualEngine/RESONEWorkspace/blob/master/LICENSE';
            ProjectUri = 'https://github.com/VirtualEngine/RESONEWorkspace';
        } # End of PSData hashtable
    } # End of PrivateData hashtable
}
