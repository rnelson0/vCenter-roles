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
        $PrivilegeList = Get-VIPrivilege -Id @(
            'Host.Config.AdvancedConfig'
            'Host.Config.NetService'
            'Host.Config.Network'
            'Host.Config.Settings'
            'System.Anonymous'
            'System.Read'
            'System.View'
        )
        New-VIRole $LogInsight_Role
        Set-VIRole $LogInsight_Role -AddPrivilege $PrivilegeList

        Get-VIRole $LogInsight_Role | Select Name,PrivilegeList
    }
    End
    {
    }
}