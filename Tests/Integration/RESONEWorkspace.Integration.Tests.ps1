Describe 'Integration\RESONEWorkspace' {

    It 'Should load module without throwing' {

        $repoRoot = (Resolve-Path "$PSScriptRoot\..\..").Path;
        $moduleName = (Get-Item -Path $repoRoot).Name;

        { Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psd1") -Force } | Should Not Throw;

    }
}
