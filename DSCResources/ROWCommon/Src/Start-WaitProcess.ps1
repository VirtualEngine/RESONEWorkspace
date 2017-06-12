function Start-WaitProcess {
<#
    .SYNOPSIS
        Starts and waits for a process to exit.
    .NOTES
        This is an internal function and shouldn't be called from outside.
#>
    [CmdletBinding(SupportsShouldProcess)]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess', '')]
    [OutputType([System.Int32])]
    param (
        # Path to process to start.
        [Parameter(Mandatory)]
        [System.String] $FilePath,

        # Arguments (if any) to apply to the process.
        [Parameter()]
        [System.String[]] $ArgumentList,

        # Credential to start the process as.
        [Parameter()]
        [AllowNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()] $Credential,

        # Working directory
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $WorkingDirectory = (Split-Path -Path $FilePath -Parent)
    )
    process {

        $startInfo = New-Object System.Diagnostics.ProcessStartInfo;
        $startInfo.UseShellExecute = $false; #Necessary for I/O redirection and just generally a good idea
        $process = New-Object System.Diagnostics.Process;
        $process.StartInfo = $startInfo;
        $startInfo.FileName = $FilePath;

        $startInfo.RedirectStandardError = $true
        $startInfo.RedirectStandardOutput = $true
        $exitCode = 0;

        $displayParams = '<None>';
        if ($ArgumentList) {

            $arguments = [System.String]::Join(' ', $ArgumentList);
            $displayParams = $arguments;
            $startInfo.Arguments = $arguments;
        }

        try {

            if($PSBoundParameters.ContainsKey('Credential')) {

                $commandLine = '"{0}" {1}' -f $startInfo.FileName, $startInfo.Arguments;
                Write-Verbose ($localizedData.StartingProcessAs -f $FilePath, $displayParams, $Credential.UserName);
                Register-PInvoke;
                [Source.NativeMethods]::CreateProcessAsUser(
                    $commandLine,
                    $Credential.GetNetworkCredential().Domain,
                    $Credential.GetNetworkCredential().UserName,
                    $Credential.GetNetworkCredential().Password,
                    [ref] $exitCode
                );
            }
            else {

                Write-Verbose ($localizedData.StartingProcess -f $FilePath, $displayParams);
                [ref] $null = $process.Start();
                $process.WaitForExit();

                if ($process) {
                    
                    $exitCode = $process.ExitCode;
                }
            }

            Write-Verbose ($localizedData.ProcessExited -f $exitCode);
            return $exitCode;

        }
        catch {

            throw;
        }

    } #end process
} #end function Start-WaitProcess
