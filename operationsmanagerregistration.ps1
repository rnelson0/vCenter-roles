<#
.Synopsis
   Create a vCenter role for vRealize Operations Manager Registration
.DESCRIPTION
   Create vCenter role for vRealize Operations Manager Registration using the minimum permissions required

   Privileges documented at https://communities.vmware.com/people/cferber/blog/2015/11/19/minimum-vcenter-permissions-required-for-vrealize-operations-and-vrealize-loginsight
.EXAMPLE
   New-OperationsManagerRole
.EXAMPLE
   New-OperationsManagerRole 'vROps-Reg'
.INPUTS
   $OperationsManager_Role (string)
#>
function New-OperationsManagerRegistrationRole
{
    Param
    (
        # The name of the role for the vCenter Operations Manager Registration user
        [String]
        $OperationsManagerRegistration_Role = 'vROps-Registration'
    )

    Begin
    {
    }
    Process
    {
        $PrivilegeList = Get-VIPrivilege -Id @(
            'Extension.Register'
            'Extension.Unregister'
            'Extension.Update'
            'Global.Licenses'
        )
        New-VIRole $OperationsManagerRegistration_Role
        Set-VIRole $OperationsManagerRegistration_Role -AddPrivilege $PrivilegeList                                                      

        Get-VIRole $OperationsManagerRegistration_Role | Select Name, PrivilegeList
    }
    End
    {
    }
}
