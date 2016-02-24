#requires -Version 3
function Import-VIRole
{
    <#  
        .SYNOPSIS
        Imports a vSphere role based on pre-defined configuration values
        .DESCRIPTION
        The Import-VIRole cmdlet is used to parse through a list of pre-defined permissions to create a new role. Often, this is to support a particular vendor's set of requirements for access into vSphere.
        .PARAMETER Name
        Name of the role. Only alpha and space characters are allowed.
        .PARAMETER Permission
        Path to the JSON file containing permissions
        .PARAMETER vCenter
        vCenter Server IP or FQDN
        .EXAMPLE
        Import-VIRole -Name Banana -PermissionsFile "C:\Banana.json" -vCenter VC1.FQDN
        Creates a new role named Banana, using the permission list stored in Banana.json, and applies it to the VC1.FQDN vCenter Server
        .NOTES
        Written by Chris Wahl for community usage
        Twitter: @ChrisWahl
        GitHub: chriswahl
        .LINK
        https://github.com/rnelson0/vCenter-roles/
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true,Position = 0,HelpMessage = 'Name of the role')]
        [ValidateNotNullorEmpty()]
        [ValidatePattern('^[A-Za-z ]+$')] #Alpha and space only
        [String]$Name,
        [Parameter(Mandatory = $true,Position = 1,HelpMessage = 'Path to the JSON file containing permissions')]
        [ValidateNotNullorEmpty()]
        [Alias("Permission")]
        [String]$PermissionsFile,
        [Parameter(Mandatory = $true,Position = 2,HelpMessage = 'vCenter Server IP or FQDN')]
        [ValidateNotNullorEmpty()]
        [String]$vCenter,
        [Parameter(Position = 3,HelpMessage = 'Overwrites existing Role by same name')]
        [Switch]$Overwrite=$false
    )

    Process {

        Write-Verbose -Message 'Importing PowerCLI modules and snapins'
        $powercli = Get-PSSnapin -Name VMware.VimAutomation.Core -Registered
        Try 
        {
            Switch ($powercli.Version.Major) {
                { $_ -ge 6 }
                {
                    Import-Module -Name VMware.VimAutomation.Core -ErrorAction Stop
                    Write-Verbose -Message 'PowerCLI 6+ module imported'
                }
                5
                {
                    Add-PSSnapin -Name VMware.VimAutomation.Core -ErrorAction Stop
                    Write-Warning -Message 'PowerCLI 5 snapin added; recommend upgrading your PowerCLI version'
                }
                default 
                {
                    Throw 'This script requires PowerCLI version 5 or later'
                }
            }
        }
        Catch 
        {
            Throw $_
        }

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

        Write-Verbose -Message "Ignoring self-signed SSL certificates for vCenter server '$vCenter' (optional)"
        $null = Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -DisplayDeprecationWarnings:$false -Scope User -Confirm:$false

        Write-Verbose -Message "Connecting to vCenter server '$vCenter'"
        Try 
        {
            $null = Connect-VIServer -Server $vCenter -ErrorAction Stop -Session ($global:DefaultVIServers | Where-Object -FilterScript {
                    $_.name -eq $vCenter
            }).sessionId
        }
        Catch 
        {
            Throw "Could not connect to vCenter server '$vCenter'"
        }

        Write-Verbose -Message "Check to see if role '$Name' exists"
        $RoleExists = Get-VIRole -Name $Name -Server $vCenter -ErrorAction SilentlyContinue
        if ($RoleExists -And (! $Overwrite)) 
        {
            Throw 'Role already exists.'
        }
    
        Write-Verbose -Message "Read the permissions file '$PermissionsFile'"
        $null = Test-Path $PermissionsFile
        [array]$PermissionsArray = Get-Content -Path $PermissionsFile -Raw | ConvertFrom-Json


        Write-Verbose -Message 'Parse the permissions array for IDs'
        $PermissionsList = Get-VIPrivilege -Id $PermissionsArray -ErrorVariable MissingPerm -ErrorAction SilentlyContinue

        Write-Verbose -Message "Identify any permissions in the list that are not present on vCenter server '$vCenter'"
        if ($MissingPermissions)
        {
            foreach ($MissingPermission in $MissingPermissions)
            {
                $PermissionID = ($MissingPermission.Exception.Message.Split("'"))[1]
                Write-Warning -Message "Permission ID '$PermissionID' not found"
            }
        }

        if ((! $RoleExists) -Or !$Overwrite)
        {
            Write-Verbose -Message "Create the role '$Name'"
            New-VIRole -Name $Name | Set-VIRole -AddPrivilege $PermissionsList
        }
        elseif ($RoleExists -And ($OverWrite)) 
        {
            Write-Verbose -Message "Overwrite the role '$Name'"
            Get-VIRole -Name $Name | Set-VIRole -RemovePrivilege *
            Get-VIRole -Name $Name | Set-VIRole -AddPrivilege $PermissionsList
        }
    }
}
