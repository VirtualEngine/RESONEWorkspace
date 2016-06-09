RES ONE Workspace DSC Resources
===============================
## Included Resources
* **ROWConsole**: Installs the RES ONE Workspace console
* **ROWDatabase**: Installs the RES ONE Workspace and creates the RES ONE Workspace database
* **ROWDatabaseAgent**: Installs the RES ONE Workspace agent component connected directly to the RES ONE Workspace database
* **ROWLab (Compsite)**: Deploys a single-node RES ONE Workspace lab server environment and configures required firewall rules
* **ROWLabBuildingBlock (Compsite)**: Adds/removes a RES ONE Workspace building block
 * **NOTE: Requires Windows Management Framework 5.**
* **ROWLabCitrixProcessIntercept (Compsite)**: Manages RES ONE Workspace Citrix Process Intercept
* **ROWLabDatabaseAgent (Compsite)**: Deploys a RES ONE Workspace lab database agent and configures required firewall rules
* **ROWLabRelayServerAgent (Compsite)**: Deploys a RES ONE Workspace lab Relay Server agent and configures required firewall rules
* **ROWRelayServer**: Installs the RES ONE Workspace Relay Server component
* **ROWRelayServerAgent**: Installs the RES ONE Workspace agent component connected via a RES ONE Workspace Relay Server

## Required Resources
* **xNetworking**: ROWLab requires https://github.com/PowerShell/xNetworking to create server firewall rules
* **LegacyNetworking**: ROWLabDatabaseAgent and ROWLabRelayServerAgent require https://github.com/VirtualEngine/LegacyNetworking to create client firewall rules

ROWConsole
==========
Installs the RES ONE Workspace console component.
### Syntax
```
ROWConsole [String] #ResourceName
{
    DatabaseServer = [String]
    DatabaseName = [String]
    Credential = [PSCredential]
    Path = [String]
    [ UseDatabaseProtocolEncryption = [Boolean] ]
    [ Version = [String] ]
    [ IsLiteralPath = [Boolean] ]
    [ Ensure = [String] { Absent | Present } ]
}
```

ROWDatabase
===========
Installs the RES ONE Workspace and creates the RES ONE Workspace database.
### Syntax
```
ROWDatabase [String] #ResourceName
{
    DatabaseServer = [String]
    DatabaseName = [String]
    Credential = [PSCredential]
    SQLCredential = [PSCredential]
    Path = [String]
    [ UseDatabaseProtocolEncryption = [Boolean] ]
    [ Version = [String] ]
    [ IsLiteralPath = [Boolean] ]
    [ Ensure = [String] { Absent | Present } ]
}
```

ROWDatabaseAgent
================
Installs the RES ONE Workspace agent component connected directly to the RES ONE Workspace database.
### Syntax
```
ROWDatabaseAgent [String] #ResourceName
{
    Agent = [String] { Full | AgentOnly }
    DatabaseServer = [String]
    DatabaseName = [String]
    Credential = [PSCredential]
    Path = [String]
    InheritSettings = [Boolean]
    EnableWorkspaceComposer = [Boolean]
    [ UseDatabaseProtocolEncryption = [Boolean] ]
    [ NoDesktopShortcut = [Boolean] ]
    [ NoStartMenuShortcut = [Boolean] ]
    [ ServiceAccountCredential = [PSCredential] ]
    [ AddToWorkspace = [String[]] ]
    [ Version = [String] ]
    [ IsLiteralPath = [Boolean] ]
    [ Ensure = [String] { Absent | Present } ]
}
```

ROWLab
======
Deploys a single-node RES ONE Workspace lab server environment.
### Syntax
```
ROWLab [String] #ResourceName
{
    DatabaseServer = [String]
    DatabaseName = [String]
    Credential = [PSCredential]
    SQLCredential = [PSCredential]
    Path = [String]
    Version = [String]
    [ RelayServerPort = [Int32] ]
    [ UseDatabaseProtocolEncryption = [Boolean] ]
    [ Ensure = [String] { Absent | Present } ]
}
```

ROWLabBuildingBlock
===================
Adds/removes a RES ONE Workspace building block. **NOTE: Requires Windows Management Framework 5.** 
### Syntax
```
ROWLabBuildingBlock [String] #ResourceName
{
    Path = [String]
    PsDscRunAsCredential = [PSCredential]
    [ Architecture = [String] { x64 | x86 } ]
    [ Ensure = [String] { Absent | Present } ]
}
```

ROWLabCitrixProcessIntercept
============================
Manages Process Intercept setting on Citrix XenApp/XenDesktop application publishing servers.
### Syntax
```
ROWCitrixProcessIntercept [String] #ResourceName
{
    Ensure = [String] { Absent | Present }
    [ Architecture = [String] { x64 | x86 } ]
}
```

ROWLabCustomResource
====================
Adds/removes a RES ONE Workspace custom resource. **NOTE: Requires Windows Management Framework 5.**
### Syntax
```
ROWLabCustomResource [String] #ResourceName
{
    Path = [String]
    PsDscRunAsCredential = [PSCredential]
    [ ResourcePath = [String] ]
    [ Architecture = [String] { x64 | x86 } ]
    [ Ensure = [String] { Absent | Present } ]
}
```

ROWLabDatabaseAgent
===================
Installs the RES ONE Workspace agent component connected directly to the RES ONE Workspace database and configures local firewall rule(s).
### Syntax
```
ROWLabDatabaseAgent [String] #ResourceName
{
    Agent = [String] { Full | AgentOnly }
    DatabaseServer = [String]
    DatabaseName = [String]
    Credential = [PSCredential]
    Path = [String]
    [ InheritSettings = [Boolean] ]
    [ EnableWorkspaceComposer = [Boolean] ]
    [ UseDatabaseProtocolEncryption = [Boolean] ]
    [ NoDesktopShortcut = [Boolean] ]
    [ NoStartMenuShortcut = [Boolean] ]
    [ ServiceAccountCredential = [PSCredential] ]
    [ AddToWorkspace = [String[]] ]
    [ Version = [String] ]
    [ IsLiteralPath = [Boolean] ]
    [ Ensure = [String] { Absent | Present } ]
}
```

ROWLabRelayServerAgent
======================
Installs the RES ONE Workspace agent component connected via a RES ONE Workspace Relay Server and configures local firewall rule(s).
### Syntax
```
ROWLabRelayServerAgent [String] #ResourceName
{
    Agent = [String] { Full | AgentOnly }
    EnvironmentGuid = [Guid]
    EnvironmentPassword = [PSCredential]
    Path = [String]
    [ InheritSettings = [Boolean] ]
    [ EnableWorkspaceComposer = [Boolean] ]
    [ EnvironmentPasswordIsHashed = [Boolean] ]
    [ RelayServerDiscovery = [Boolean] ]
    [ RelayServerList = [String[]] ]
    [ RelayServerDnsName = [String] ]
    [ NoDesktopShortcut = [Boolean] ]
    [ NoStartMenuShortcut = [Boolean] ]
    [ AddToWorkspace = [String[]] ]
    [ Version = [String] ]
    [ IsLiteralPath = [Boolean] ]
    [ Ensure = [String] { Absent | Present } ]
}
```

ROWRelayServer
==============
Installs the RES ONE Workspace Relay Server component.
### Syntax
```
ROWRelayServer [String] #ResourceName
{
    DatabaseServer = [String]
    DatabaseName = [String]
    Credential = [PSCredential]
    Path = [String]
    Port = [Int32]
    [ UseDatabaseProtocolEncryption = [Boolean] ]
    [ CachePath = [String] ]
    [ Version = [String] ]
    [ IsLiteralPath = [Boolean] ]
    [ Ensure = [String] { Absent | Present } ]
}
```

ROWRelayServerAgent
===================
Installs the RES ONE Workspace agent component connected via a RES ONE Workspace Relay Server.
### Syntax
```
ROWRelayServerAgent [String] #ResourceName
{
    Agent = [String] { Full | AgentOnly }
    EnvironmentGuid = [Guid]
    EnvironmentPassword = [PSCredential]
    Path = [String]
    InheritSettings = [Boolean]
    EnableWorkspaceComposer = [Boolean]
    [ EnvironmentPasswordIsHashed = [Boolean] ]
    [ RelayServerDiscovery = [Boolean] ]
    [ RelayServerList = [String[]] ]
    [ RelayServerDnsName = [String] ]
    [ NoDesktopShortcut = [Boolean] ]
    [ NoStartMenuShortcut = [Boolean] ]
    [ AddToWorkspace = [String[]] ]
    [ Version = [String] ]
    [ IsLiteralPath = [Boolean] ]
    [ Ensure = [String] { Absent | Present } ]
}

```
