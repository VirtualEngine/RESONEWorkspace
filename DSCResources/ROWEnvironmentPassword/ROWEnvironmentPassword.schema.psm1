configuration ROWEnvironmentPassword {
    param (
        ## RES ONE Workspace database server name/instance (equivalient to DBSERVER).
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $DatabaseServer,
        
        ## RES ONE Workspace database name (equivalient to DBNAME).
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [System.String] $DatabaseName,
        
        ## Microsoft SQL database credentials used to update the database.
        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential] $Credential,

        ## New RES ONE Workspace Manager environment hashed password
        [Parameter(Mandatory)]
        [System.String] $EnvironmentPasswordHash
    )
    
    Import-DscResource -ModuleName PSDesiredStateConfiguration;
    
    $dbUsername = $Credential.UserName;
    $dbPassword = $Credential.GetNetworkCredential().Password;

    Script 'ROWEnvironmentPassword' {
        
        GetScript = {
            $query = "SELECT strValue FROM {0}.dbo.tblSettings WHERE lngClassID = 82 AND strSettingLC = 'relayserverpassword';" -f $using:DatabaseName;
            Write-Verbose ('Executing query: {0}' -f $query);
            $result = & OSQL.EXE -S "$using:DatabaseServer" -U "$using:dbUserName" -P "$using:dbPassword" -Q "$query";
            $targetResource = @{
                Result = ($result.Trim() -match "^$using:EnvironmentPasswordHash`$");
            }
            return $targetResource;
        }
        
        TestScript = {
            $query = "SELECT strValue AS 'EnvironmentName' FROM {0}.dbo.tblSettings WHERE lngClassID = 82 AND strSettingLC = 'relayserverpassword';" -f $using:DatabaseName;
            Write-Verbose ('Executing query: {0}' -f $query);
            $result = & OSQL.EXE -S "$using:DatabaseServer" -U "$using:dbUsername" -P "$using:dbPassword" -Q "$query";
            return ($result.Trim() -match "^$using:EnvironmentPasswordHash`$") -as [System.Boolean];
        }
        
        SetScript = {
            $query = "UPDATE {0}.dbo.tblSettings SET strValue = '{1}' WHERE lngClassID = 82 AND strSettingLC = 'relayserverpassword';" -f $using:DatabaseName, $using:EnvironmentPasswordHash;
            Write-Verbose ('Executing query: {0}' -f $query);
            $result = & OSQL.EXE -S "$using:DatabaseServer" -U "$using:dbUsername" -P "$using:dbPassword" -Q "$query";
        }
        
    }
    
}