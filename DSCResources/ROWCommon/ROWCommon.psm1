data localizedData {
    # Localized messages; culture="en-US"
    ConvertFrom-StringData @'
        StartingProcess                 = Starting process '{0}' '{1}'.
        StartingProcessAs               = Starting process '{0}' '{1}' as user '{2}'.
        ProcessExited                   = Process exited with code '{0}'.
        OpeningMSIDatabase              = Opening MSI database '{0}'.
        SearchFilePatternMatch          = Searching for files matching pattern '{0}'.
        LocatedPackagePath              = Located package '{0}'.
        UsingPackageName                = Using package name '{0}'.

        VersionNumberRequiredError      = Version number is required when not using a literal path.
        InvalidPathTypeError            = Specified path '{0}' does not point to a '{1}' file.
        InvalidVersionNumberFormatError = The specified version '{0}' does not match '1.2', '1.2.3' or '1.2.3.4' format.
        UnsupportedVersionError         = Version '{0}' is not supported/untested :(
        UnableToLocatePackageError      = Unable to locate '{0}' package.
        CannotFindPathError             = Cannot find path '{0}' because it does not exist.
        PathCannotContainSpaceError     = Path '{0}' cannot contain spaces. Crazy? I know!
        ROWComponentNotFoundError       = RES ONE Workspace component '{0}' was not found.
        ROWConsoleNotFoundError         = RES ONE Workspace console was not found.

        PwrtechExitCode1Error           = The file was not specified in the command line.
        PwrtechExitCodeError2           = The file was not a valid XML file.
        PwrtechExitCodeError3           = The object was not found in the datastore.
        PwrtechExitCodeError4           = Saving the Custom Resource in the Datastore failed.
        PwrtechExitCodeError5           = Deleting the object or Custom Resource failed.
        PwrtechExitCodeError6           = Invalid Guid specified.
        PwrtechExitCodeError7           = The object specified with Guid does not exist.
        PwrtechExitCodeError8           = The Custom Resource specified with Guid does not exist.
        PwrtechExitCodeError9           = Insufficient rights, the caller belongs to an administrative role which does not have modify permissions for the object type or Custom Resources.
        PwrtechExitCodeError10          = Required command line options not specified.
        PwrtechExitCodeError11          = The path specified for does not exist.
        PwrtechExitCodeError12          = Importing a Building Block via the command line with /passwordfips failed, because the the file name contains a wildcard (* or ? or |).
        PwrtechExitCodeError14          = Importing a Building Block via the command line failed, because no /passwordfips is provided or the password is incorrect.
'@
}

$moduleRoot = Split-Path -Path $MyInvocation.MyCommand.Path -Parent;
$moduleSrcPath = Join-Path -Path $moduleRoot -ChildPath 'Src';
Get-ChildItem -Path $moduleSrcPath -Include '*.ps1' -Recurse |
    ForEach-Object {
        Write-Verbose -Message ('Importing library\source file ''{0}''.' -f $_.FullName);
        . $_.FullName;
    }


Export-ModuleMember -Function *;
