#requires -Version 3
function Import-VIRole {
    <#
    .SYNOPSIS
        Imports a vSphere role based on pre-defined configuration values
    .DESCRIPTION
        The Import-VIRole cmdlet is used to parse through a list of pre-defined privileges to create a new role. Often, this is to support a particular vendor's set of requirements for access into vSphere.
    .PARAMETER Name
        Name of the role. Only alpha and space characters are allowed.
    .PARAMETER RoleFile
        Path to the JSON file describing the role, including the privileges
    .PARAMETER vCenter
        vCenter Server IP or FQDN
    .EXAMPLE
        Import-VIRole -Name Banana -RoleFile "C:\Banana.json" -vCenter VC1.FQDN
        Creates a new role named Banana, using the privileges list stored in Banana.json, and applies it to the VC1.FQDN vCenter Server
    .NOTES
        Written by Chris Wahl for community usage
        Twitter: @ChrisWahl
        GitHub: chriswahl

        Maintained by Rob Nelson and contributors.
    .LINK
        https://github.com/rnelson0/vCenter-roles/
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true, Position = 0, HelpMessage = 'Name of the role')]
        [ValidateNotNullorEmpty()]
        [ValidatePattern('^[A-Za-z ]+$')] #Alpha and space only
        [String]$Name,

        [Parameter(Mandatory = $true, Position = 1, HelpMessage = 'Path to the JSON file describing the role')]
        [ValidateNotNullorEmpty()]
        [Alias("Permission")]
        [String]$RoleFile,

        [Parameter(Mandatory = $true, Position = 2, HelpMessage = 'vCenter Server IP or FQDN')]
        [ValidateNotNullorEmpty()]
        [String]$vCenter,

        [Parameter(Position = 3, HelpMessage = 'Overwrites existing Role by same name')]
        [Switch]$Overwrite = $false
    )

    Begin {
        Write-Verbose -Message "Detecting if PowerCLI is available"
        $PowerCLI = Get-Module -ListAvailable VMware.PowerCLI
        if (-not $PowerCLI) {
            Throw 'The PowerCLI module must be installed to continue'
        }
    }

    Process {
        If ([System.Net.ServicePointManager]::CertificatePolicy -eq $null -or [System.Net.ServicePointManager]::CertificatePolicy.ToString() -ne "TrustAllCertsPolicy" -and
            [System.Version]$PSVersionTable.PSVersion -lt [System.Version]"6.0.0") {
            Write-Verbose -Message 'Allowing untrusted SSL certs'
            Add-Type -TypeDefinition @"
        using System.Net;
        using System.Security.Cryptography.X509Certificates;
        public class TrustAllCertsPolicy : ICertificatePolicy {
            public bool CheckValidationResult(
                ServicePoint srvPoint, X509Certificate certificate,
                WebRequest request, int certificateProblem) {
                return true;
            }
        }
"@
            [System.Net.ServicePointManager]::CertificatePolicy = New-Object -TypeName TrustAllCertsPolicy
        }

        Write-Verbose -Message "Ignoring self-signed SSL certificates for vCenter server '$vCenter' (optional)"
        $null = Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -DisplayDeprecationWarnings:$false -Scope User -Confirm:$false

        Write-Verbose -Message "Connecting to vCenter server '$vCenter'"
        Try {
            $null = Connect-VIServer -Server $vCenter -ErrorAction Stop -Session ($global:DefaultVIServers | Where-Object -FilterScript {
                    $_.name -eq $vCenter
                }).sessionId
        }
        Catch {
            Throw "Could not connect to vCenter server '$vCenter'"
        }

        Write-Verbose -Message "Check to see if role '$Name' exists"
        $RoleExists = Get-VIRole -Name $Name -Server $vCenter -ErrorAction SilentlyContinue
        if ($RoleExists -And (! $Overwrite)) {
            Throw 'Role already exists.'
        }

        Write-Verbose -Message "Reading the role file '$RoleFile'"
        $null = Test-Path $RoleFile
        $JSONOutput = Get-Content -Path $RoleFile -Raw | ConvertFrom-Json
        $RoleHash = @{}
        $JSONOutput | Get-Member -MemberType NoteProperty | Where-Object { -not [string]::IsNullOrEmpty($JSONOutput."$($_.name)") } | ForEach-Object { $RoleHash.add($_.name, $JSONOutput."$($_.name)") }

        Write-Verbose -Message "Found the following object in '$RoleFile':"
        $RoleHash.Keys | ForEach-Object {
            $Key = $_
            $Value = $RoleHash.$Key
            if ($Key -ne "privileges") {
                Write-Verbose "$Key : $Value"
            }
            else {
                Write-Verbose "$key : ["
                Foreach ($Privilege in $Value) {
                    Write-Verbose "    $privilege,"
                }
                Write-Verbose "]"
            }
        }

        $PrivilegesArray = $RoleHash.privileges
        Write-Verbose -Message 'Parsing the privileges array for IDs'
        $PrivilegesList = Get-VIPrivilege -Server $vCenter -Id $PrivilegesArray -ErrorVariable MissingPerm -ErrorAction SilentlyContinue

        Write-Verbose -Message "Identifying any privileges in the list that are not present on vCenter server '$vCenter'"
        if ($MissingPrivileges) {
            foreach ($MissingPrivilege in $MissingPrivileges) {
                $PrivilegesID = ($MissingPrivilege.Exception.Message.Split("'"))[1]
                Write-Warning -Message "Privilege ID '$PrivilegesID' not found"
            }
        }

        if ((! $RoleExists) -Or !$Overwrite) {
            Write-Verbose -Message "Creating the role '$Name'"
            $null = New-VIRole -Server $vCenter -Name $Name | Set-VIRole -Server $vCenter -AddPrivilege $PrivilegesList
        }
        elseif ($RoleExists -And ($OverWrite)) {
            Write-Verbose -Message "Overwriting the role '$Name'"
            $null = Get-VIRole -Server $vCenter -Name $Name | Set-VIRole -Server $vCenter -RemovePrivilege *
            $null = Get-VIRole -Server $vCenter -Name $Name | Set-VIRole -Server $vCenter -AddPrivilege $PrivilegesList
        }

        Write-Verbose -Message "Disconnecting from vCenter server '$vCenter'"
        $null = Disconnect-VIServer -Server $vCenter -Confirm:$false
    }
}
