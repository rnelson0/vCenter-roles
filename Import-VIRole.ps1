function Import-VIRole
{
    <#  
            .SYNOPSIS
            Imports a vSphere role based on pre-defined configuration values
            .DESCRIPTION
            The Import-VIRole cmdlet is used to parse through a list of pre-defined permissions to create a new role. Often, this is to support a particular vendor's set of requirements for access into vSphere.
            .NOTES
            Written by Chris Wahl for community usage
            Twitter: @ChrisWahl
            GitHub: chriswahl
            .LINK
            https://github.com/chriswahl
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true,Position = 0,HelpMessage = 'Name of the role')]
        [ValidateNotNullorEmpty()]
        [ValidatePattern('^[A-Za-z ]+$')] #Alpha and space only
        [String]$Name,
        [Parameter(Mandatory = $true,Position = 1,HelpMessage = 'Path to the JSON file containing permissions')]
        [ValidateNotNullorEmpty()]
        [String]$Permission,
        [Parameter(Mandatory = $true,Position = 2,HelpMessage = 'vCenter Server IP or FQDN')]
        [ValidateNotNullorEmpty()]
        [String]$vCenter
    )

    Process {

        Write-Verbose -Message 'Importing required modules and snapins'
        $powercli = Get-PSSnapin -Name VMware.VimAutomation.Core -Registered
        try 
        {
            switch ($powercli.Version.Major) {
                {
                    $_ -ge 6
                }
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
                    throw 'This script requires PowerCLI version 5 or later'
                }
            }
        }
        catch 
        {
            throw $_
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

        Write-Verbose -Message 'Ignoring self-signed SSL certificates for vCenter Server (optional)'
        $null = Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -DisplayDeprecationWarnings:$false -Scope User -Confirm:$false

        Write-Verbose -Message 'Connecting to vCenter'
        try 
        {
            $null = Connect-VIServer -Server $vCenter -ErrorAction Stop -Session ($global:DefaultVIServers | Where-Object -FilterScript {
                    $_.name -eq $vCenter
            }).sessionId
        }
        catch 
        {
            throw 'Could not connect to vCenter'
        }

        Write-Verbose -Message 'Check to see if the role exists'
        if (Get-VIRole -Name $Name -ErrorAction SilentlyContinue) 
        {
            throw 'Role already exists'
        }

        Write-Verbose -Message 'Read the JSON file'
        try
        {
            $null = Test-Path $Permission
            [array]$PermArray = Get-Content -Path $Permission -Raw | ConvertFrom-Json
        }
        catch
        {
            throw $_
        }

        Write-Verbose -Message 'Parse the permission array for IDs'
        $PermList = Get-VIPrivilege -Id $PermArray

        Write-Verbose -Message 'Create the role'
        New-VIRole -Name $Name | Set-VIRole -AddPrivilege $PermList

    } # End of process
} # End of function