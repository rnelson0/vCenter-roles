<#
.Synopsis
   Create a vCenter role for Log Insight
.DESCRIPTION
   Create a vCenter role for Log Insight using the minimum permissions required
.EXAMPLE
   New-LogInsightRole
.EXAMPLE
   New-LogInsightRole 'LI-Access'
.INPUTS
   $LogInsight_Role (string)
#>
function New-LogInsightRole
{
    Param
    (
        # The name of the role for the Log Insight user
        [String]
        $LogInsight_Role = 'LogInsight-Access'
    )

    Begin
    {
    }
    Process
    {
        New-VIRole $LogInsight_Role
        Set-VIRole $LogInsight_Role -AddPrivilege (Get-VIPrivilege -id  Host.Config.AdvancedConfig)
        Set-VIRole $LogInsight_Role -AddPrivilege (Get-VIPrivilege -id  Host.Config.NetService)
        Set-VIRole $LogInsight_Role -AddPrivilege (Get-VIPrivilege -id  Host.Config.Network)
        Set-VIRole $LogInsight_Role -AddPrivilege (Get-VIPrivilege -id  Host.Config.Settings)
        Set-VIRole $LogInsight_Role -AddPrivilege (Get-VIPrivilege -id  System.Anonymous)
        Set-VIRole $LogInsight_Role -AddPrivilege (Get-VIPrivilege -id  System.Read)
        Set-VIRole $LogInsight_Role -AddPrivilege (Get-VIPrivilege -id  System.View)

        Get-VIRole $LogInsight_Role | Select Name,PrivilegeList
    }
    End
    {
    }
}