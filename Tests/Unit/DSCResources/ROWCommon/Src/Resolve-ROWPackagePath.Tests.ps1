## Import the ROACommon module
$moduleRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..\..\DSCResources\ROWCommon\ROWCommon.psd1").Path;
Import-Module $moduleRoot -Force;

Describe 'RESONEWorkspace\ROWCommon\Resolve-ROWPackagePath' {

    It 'Should resolve 2016 (v9.12) Full Agent installer' {
        
        $v912InstallerMsi = 'RES-ONE-Workspace-2016.msi';
        New-Item -Path $TestDrive -Name $v912InstallerMsi -ItemType File -Force -ErrorAction SilentlyContinue;

        $result = Resolve-ROWPackagePath -Path $TestDrive -Component FullAgent -Version 9.12;

        $result.EndsWith($v912InstallerMsi) | Should Be $true;
    }

    It 'Should resolve 2016 SR1 (9.12.1) Full Agent installer' {
        
        $v912InstallerMsi = 'RES-ONE-Workspace-2016.msi';
        New-Item -Path $TestDrive -Name $v912InstallerMsi -ItemType File -Force -ErrorAction SilentlyContinue;
        $v9121InstallerMsi = 'RES-ONE-Workspace-2016-SR1.msi';
        New-Item -Path $TestDrive -Name $v9121InstallerMsi -ItemType File -Force -ErrorAction SilentlyContinue;

        $result = Resolve-ROWPackagePath -Path $TestDrive -Component FullAgent -Version 9.12;

        $result.EndsWith($v9121InstallerMsi) | Should Be $true;
    }

    It 'Should resolve explicit 2016 (v.9.12.0) Full Agent installer' {
        
        $v912InstallerMsi = 'RES-ONE-Workspace-2016.msi';
        New-Item -Path $TestDrive -Name $v912InstallerMsi -ItemType File -Force -ErrorAction SilentlyContinue;
        $v9121InstallerMsi = 'RES-ONE-Workspace-2016-SR1.msi';
        New-Item -Path $TestDrive -Name $v9121InstallerMsi -ItemType File -Force -ErrorAction SilentlyContinue;

        $result = Resolve-ROWPackagePath -Path $TestDrive -Component FullAgent -Version 9.12.0;

        $result.EndsWith($v912InstallerMsi) | Should Be $true;
    }

    It 'Should resolve v10.0.0.0 Full Agent installer' {
        
        $v10InstallerMsi = 'RES-ONE-Workspace-10.0.0.0.msi';
        New-Item -Path $TestDrive -Name $v10InstallerMsi -ItemType File -Force -ErrorAction SilentlyContinue;

        $result = Resolve-ROWPackagePath -Path $TestDrive -Component FullAgent -Version 10.0;

        $result.EndsWith($v10InstallerMsi) | Should Be $true;
    }

    It 'Should resolve later v10.0.100.0 Full Agent installer' {
        
        $v10InstallerMsi = 'RES-ONE-Workspace-10.0.0.0.msi';
        New-Item -Path $TestDrive -Name $v10InstallerMsi -ItemType File -Force -ErrorAction SilentlyContinue;
        $v10100InstallerMsi = 'RES-ONE-Workspace-10.0.100.0.msi';
        New-Item -Path $TestDrive -Name $v10100InstallerMsi -ItemType File -Force -ErrorAction SilentlyContinue;

        $result = Resolve-ROWPackagePath -Path $TestDrive -Component FullAgent -Version 10.0;

        $result.EndsWith($v10100InstallerMsi) | Should Be $true;
    }

    It 'Should resolve v10.0.0.0 Agent Only installer' {
        
        $v10AgentOnlyMsi = 'RES-ONE-Workspace-Agent-10.0.0.0.msi';
        New-Item -Path $TestDrive -Name $v10AgentOnlyMsi -ItemType File -Force -ErrorAction SilentlyContinue;

        $result = Resolve-ROWPackagePath -Path $TestDrive -Component AgentOnly -Version 10.0;

        $result.EndsWith($v10AgentOnlyMsi) | Should Be $true;
    }

    It 'Should resolve v10.0.0.0 Console installer' {
        
        $v10ConsoleMsi = 'RES-ONE-Workspace-Console-10.0.0.0.msi';
        New-Item -Path $TestDrive -Name $v10ConsoleMsi -ItemType File -Force -ErrorAction SilentlyContinue;

        $result = Resolve-ROWPackagePath -Path $TestDrive -Component Console -Version 10.0;

        $result.EndsWith($v10ConsoleMsi) | Should Be $true;
    }

    It 'Should resolve v10.0.0.0 Relay Server installer' {
        
        if ([System.Environment]::Is64BitOperatingSystem) {
            $v10RelayServerMsi = 'RES-ONE-Workspace-Relay-Server(x64)-10.0.0.0.msi';
        }
        else {
            $v10RelayServerMsi = 'RES-ONE-Workspace-Relay-Server(x86)-10.0.0.0.msi';
        }
        New-Item -Path $TestDrive -Name $v10RelayServerMsi -ItemType File -Force -ErrorAction SilentlyContinue;

        $result = Resolve-ROWPackagePath -Path $TestDrive -Component RelayServer -Version 10.0;

        $result.EndsWith($v10RelayServerMsi) | Should Be $true;
    }

    It 'Should resolve v10.0.0.0 Reporting Services installer' {
        
        $v10ReportingServicesMsi = 'RES-ONE-Workspace-Reporting-Services-10.0.0.0.msi';
        New-Item -Path $TestDrive -Name $v10ReportingServicesMsi -ItemType File -Force -ErrorAction SilentlyContinue;

        $result = Resolve-ROWPackagePath -Path $TestDrive -Component ReportingServices -Version 10.0;

        $result.EndsWith($v10ReportingServicesMsi) | Should Be $true;
    }

    It 'Should resolve v10.0.0.0 Management Portal installer' {
        
        $v10InstallerMsi = 'RES ONE Workspace Management Portal 10.0.0.0.msi';
        New-Item -Path $TestDrive -Name $v10InstallerMsi -ItemType File -Force -ErrorAction SilentlyContinue;

        $result = Resolve-ROWPackagePath -Path $TestDrive -Component ManagementPortal -Version 10.0;

        $result.EndsWith($v10InstallerMsi) | Should Be $true;
    }

    It 'Should throw when "ManagementPortal" component is specified on versions prior to v10' {

        { Resolve-ROWPackagePath -Path $TestDrive -Component ManagementPortal -Version 9.12 } | Should Throw 'Version 10 is required';
    }

} #end describe
