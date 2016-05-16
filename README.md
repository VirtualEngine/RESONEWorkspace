RES ONE Workspace DSC Resources
===============================
## Included Resources
* **ROWBuildingBlock**: Adds/removes a RES ONE Workspace building block
* **ROWCitrixProcessIntercept**: Manages RES ONE Workspace Citrix Process Intercept
* **ROWConsole**: Installs the RES ONE Workspace console
* **ROWCustomResource**: Adds/removes a RES ONE Workspace custom resource
* **ROWDatabase**: Installs the RES ONE Workspace and creates the RES ONE Workspace database
* **ROWDatabaseAgent**: Installs the RES ONE Workspace agent component connected directly to the RES ONE Workspace database
* **ROWLab**: Deploys a single-node RES ONE Workspace lab server environment
* **ROWRelayServer**: Installs the RES ONE Workspace Relay Server component
* **ROWRelayServerAgent**: Installs the RES ONE Workspace agent component connected via a RES ONE Workspace Relay Server

## Required Resources
* **xNetworking**: ROWLab requires https://github.com/PowerShell/xNetworking to create firewall rules
* **LegacyNetworking**: ROWDatabaseAgent and ROWRelayServerAgent require https://github.com/VirtualEngine/LegacyNetworking to create firewall rules

ROWBuildingBlock
================
Adds/removes a RES ONE Workspace building block. **NOTE: Requires Windows Management Framework 5.** 
### Syntax
```
ROWBuildingBlock [String] #ResourceName
{
    Path = [String]
    PsDscRunAsCredential = [PSCredential]
    [ Architecture = [String] { x64 | x86 } ]
    [ Ensure = [String] { Absent | Present } ]
}

```

ROWCitrixProcessIntercept
=========================
Manages Process Intercept setting on Citrix XenApp/XenDesktop application publishing servers.
### Syntax
```
ROWCitrixProcessIntercept [String] #ResourceName
{
    Ensure = [String] { Absent | Present }
    [ Architecture = [String] { x64 | x86 } ]
}
```

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
    [ Architecture = [String] { x64 | x86 } ]
    [ Ensure = [String] { Absent | Present } ]
}
```

ROWCustomResource
=================
Adds/removes a RES ONE Workspace custom resource. **NOTE: Requires Windows Management Framework 5.**
### Syntax
```
ROWCustomResource [String] #ResourceName
{
    Path = [String]
    PsDscRunAsCredential = [PSCredential]
    [ ResourcePath = [String] ]
    [ Architecture = [String] { x64 | x86 } ]
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
    [ Architecture = [String] { x64 | x86 } ]
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
    [ Architecture = [String] { x64 | x86 } ]
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
    [ Architecture = [String] { x64 | x86 } ]
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
    [ Architecture = [String] { x64 | x86 } ]
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
    [ Architecture = [String] { x64 | x86 } ]
    [ Ensure = [String] { Absent | Present } ]
}

```
