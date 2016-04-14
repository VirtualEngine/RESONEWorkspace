configuration ROWEnvironmentGuid {
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

        ## New RES ONE Workspace Manager environment Guid
        [Parameter(Mandatory)]
        [System.Guid] $EnvironmentGuid
    )
    
    Import-DscResource -ModuleName PSDesiredStateConfiguration;
    
    $dbUsername = $Credential.UserName;
    $dbPassword = $Credential.GetNetworkCredential().Password;
    $environmentGuidString = '{{{0}}}' -f $EnvironmentGuid.ToString().ToUpper();

    Script 'ROWEnvironmentGuid' {
        
        GetScript = {
            $query = "SELECT strValue AS 'EnvironmentGuid' FROM {0}.dbo.tblSettings WHERE lngClassID = 39 AND strSettingLC = 'environmentguid';" -f $using:DatabaseName;
            Write-Verbose ('Executing query: {0}' -f $query);
            $result = & OSQL.EXE -S "$using:DatabaseServer" -U "$using:dbUserName" -P "$using:dbPassword" -Q "$query";
            $targetResource = @{
                Result = ($result.Trim() -match "^$using:environmentGuidString`$");
            }
            return $targetResource;
        }
        
        TestScript = {
            $query = "SELECT strValue AS 'EnvironmentGuid' FROM {0}.dbo.tblSettings WHERE lngClassID = 39 AND strSettingLC = 'environmentguid';" -f $using:DatabaseName;
            Write-Verbose ('Executing query: {0}' -f $query);
            $result = & OSQL.EXE -S "$using:DatabaseServer" -U "$using:dbUsername" -P "$using:dbPassword" -Q "$query";
            return ($result.Trim() -match "^$using:environmentGuidString`$") -as [System.Boolean];
        }
        
        SetScript = {
            $query = "UPDATE {0}.dbo.tblSettings SET strValue = '{1}' WHERE lngClassID = 39 AND strSettingLC = 'environmentguid';" -f $using:DatabaseName, $using:environmentGuidString;
            Write-Verbose ('Executing query: {0}' -f $query);
            $result = & OSQL.EXE -S "$using:DatabaseServer" -U "$using:dbUsername" -P "$using:dbPassword" -Q "$query";
        }
        
    }
    
}