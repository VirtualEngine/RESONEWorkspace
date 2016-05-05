RES ONE Workspace DSC Resources
===============================
## Included Resources
* **ROWBuildingBlock**: Adds/removes a RES ONE Workspace building block
* **ROWCitrixProcessIntercept**: Manages RES ONE Workspace Citrix Process Intercept
* **ROWConsole**: Installs the RES ONE Workspace console
* **ROWCustomResource**: Adds/removes a RES ONE Workspace custom resource
* **ROWDatabase**: Installs the RES ONE Workspace and creates the RES ONE Workspace database
* **ROWDatabaseAgent**: Installs the RES ONE Workspace agent component connected directly to the RES ONE Workspace database
* **ROWEnvironmentGuid**: Sets the RES ONE Workspace Relay Server environment Guid
* **ROWEnvironmentName**: Sets the RES ONE Workspace Relay Server environment name
* **ROWEnvironmentPassword**: Sets the RES ONE Workspace Relay Server environment hashed password
* **ROWLab**: Deploys a single-node RES ONE Workspace lab server environment
* **ROWRelayServer**: Installs the RES ONE Workspace Relay Server component
* **ROWRelayServerAgent**: Installs the RES ONE Workspace agent component connected via a RES ONE Workspace Relay Server

## Required Resources
* **xNetworking**: ROWLab requires https://github.com/PowerShell/xNetworking to create firewall rules

ROWBuildingBlock
================
Adds/removes a RES ONE Workspace building block.
### Syntax
```
ROWBuildingBlock [String] #ResourceName
{
    Path = [String]
    Credential = [PSCredential]
    [ Architecture = [String] { x64 | x86 } ]
    [ Ensure = [String] { Absent | Present } ]
}

```

ROWCitrixProcessIntercept
=========================
Manages the Citrix Process Intercept setting
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
Adds/removes a RES ONE Workspace custom resource.
### Syntax
```
ROWCustomResource [String] #ResourceName
{
    Path = [String]
    Credential = [PSCredential]
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

ROWEnvironmentGuid
==================
Sets the RES ONE Workspace Relay Server environment Guid.
### Syntax
```
ROWEnvironmentGuid [String] #ResourceName
{
    DatabaseServer = [String]
    DatabaseName = [String]
    Credential = [PSCredential]
    EnvironmentGuid = [Guid]
}
```

ROWEnvironmentName
==================
Sets the RES ONE Workspace Relay Server environment name.
### Syntax
```
ROWEnvironmentName [String] #ResourceName
{
    DatabaseServer = [String]
    DatabaseName = [String]
    Credential = [PSCredential]
    EnvironmentName = [String]
}
```

ROWEnvironmentPassword
======================
Sets the RES ONE Workspace Relay Server environment hashed password.
### Syntax
```
ROWEnvironmentPassword [String] #ResourceName
{
    DatabaseServer = [String]
    DatabaseName = [String]
    Credential = [PSCredential]
    EnvironmentPasswordHash = [String]
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
    EnvironmentPasswordHash = [String]
    [ RelayServerPort = [Int32] ]
    [ UseDatabaseProtocolEncryption = [Boolean] ]
    [ EnvironmentGuid = [Guid] ]
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
