RES ONE Workspace DSC Resources
===============================

## Included Resources

* **ROWBuildingBlock**: Imports a RES ONE Automation building block
* **ROWConsole**: Installs the RES ONE Workspace console
* **ROWDatabase**: Installs the RES ONE Workspace and creates the RES ONE Workspace database
* **ROWDatabaseAgent**: Installs the RES ONE Workspace agent component connected directly to the RES ONE Workspace database
* **ROWLab (Composite)**: Deploys a single-node RES ONE Workspace lab server environment and configures required firewall rules
* **ROWLabCitrixProcessIntercept (Composite)**: Manages RES ONE Workspace Citrix Process Intercept
* **ROWLabDatabaseAgent (Composite)**: Deploys a RES ONE Workspace lab database agent and configures required firewall rules
* **ROWLabRelayServerAgent (Composite)**: Deploys a RES ONE Workspace lab Relay Server agent and configures required firewall rules
* **ROWManagementPortal**: Deploys the RES ONE Workspace (v10 and later) web management portal
* **ROWManagementPortalConfig**: Creates a RES ONE Workspace (v10 and later) web management portal configuration file
* **ROWRelayServer**: Installs the RES ONE Workspace Relay Server component
* **ROWRelayServerAgent**: Installs the RES ONE Workspace agent component connected via a RES ONE Workspace Relay Server
* **ROWReportingServices**: Installs the RES ONE Workspace reporting services component

## Required Resources

* **xNetworking**: ROWLab requires https://github.com/PowerShell/xNetworking to create server firewall rules
* **LegacyNetworking**: ROWLabDatabaseAgent and ROWLabRelayServerAgent require https://github.com/VirtualEngine/LegacyNetworking to create client firewall rules

ROWBuildingBlock
===================

Imports a RES ONE Workspace building block.

### Syntax

```
ROWBuildingBlock [String] #ResourceName
{
    Path = [String]
    [ Overwrite = [Boolean] ]
    [ Delete = [Boolean] ]
    [ DeleteFromDisk = [Boolean] ]
    [ Credential = [PSCredential] ]
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
    [ UseFIPSEncryption = [Boolean] ]
    [ LicensePath = [String] ]
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
    [ ForceRestart = [Boolean] ]
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
    [ BuildingBlockPath = [String] ]
    [ BuildingBlockCredential = [PSCredential] ]
    [ DeleteBuildingBlock = [Boolean] ]
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
    [ ForceRestart = [Boolean] ]
    [ InterceptManagedApplications = [Boolean] ]
    [ Architecture = [String] { x64 | x86 } ]
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
    [ ForceRestart = [Boolean] ]
    [ InterceptManagedApplications = [Boolean] ]
    [ Architecture = [String] { x64 | x86 } ]
    [ Ensure = [String] { Absent | Present } ]
}
```

ROWManagementPortal
===================

Installs the RES ONE Workspace (v10 and later) web management portal component.

### Syntax

```
ROWManagementPortal [String] #ResourceName
{
    HostHeader = [String]
    CertificateThumbprint = [String]
    Path = [String]
    [ Port = [UInt16] ]
    [ Version = [String] ]
    [ IsLiteralPath = [Boolean] ]
    [ Ensure = [String] { Absent | Present }]
}
```

ROWManagementPortalConfig
=========================

Creates RES ONE Workspace (v10 and later) web management portal configuration file.

### Syntax

```
ROWManagementPortalConfig [String] #ResourceName
{
    Path = [string]
    DatabaseServer = [String]
    DatabaseName = [String]
    [Credential = [PSCredential]]
    [IdentityBrokerUrl = [String] ]
    [ApplicationUrl = [String] ]
    [ClientId = [String] ]
    [ClientSecret = [PSCredential]]
    [Ensure = [string]{ Absent | Present } ]
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
    [ ForceRestart = [Boolean] ]
    [ Ensure = [String] { Absent | Present } ]
}
```

ROWReportingServices
====================

Installs the RES ONE Workspace reporting services component.

### Syntax

```
ROWReportingServices [String] #ResourceName
{
    Path = [String]
    [ Version = [String] ]
    [ IsLiteralPath = [Boolean] ]
    [ Ensure = [String] { Absent | Present } ]
}
```
