<#
.Synopsis
   Create a vCenter role for Log Insight
.DESCRIPTION
   Create a vCenter role for Log Insight using the minimum permissions required
   
   Privileges documented at https://communities.vmware.com/people/cferber/blog/2015/11/19/minimum-vcenter-permissions-required-for-vrealize-operations-and-vrealize-loginsight
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