<#
.Synopsis
   Create a vCenter role for vSphere Data Protection (VDP)
.DESCRIPTION
   Create a vCenter role for VDP using the minimum permissions required

   Privileges described at https://kb.vmware.com/kb/2072861
.EXAMPLE
   New-VDPRole
.EXAMPLE
   New-VDPRole 'VDP-Backups'
.INPUTS
   $VDP_Role (string)
#>
function New-VDPRole
{
    Param
    (
        # The name of the role for the VDP user
        [String]
        $VDP_Role = 'VDP-Access'
    )

    Begin
    {
    }
    Process
    {
        $PrivilegeList = Get-VIPrivilege -Id @(
            'Global.ManageCustomFields'
            'Global.LogEvent'
            'Global.CancelTask'
            'Global.Licenses'  
            'Global.Settings'  
            'Global.DisableMethods'
            'Global.EnableMethods'
            'Folder.Create'    
            'Datastore.Rename' 
            'Datastore.Move'   
            'Datastore.Delete' 
            'Datastore.Browse' 
            'Datastore.DeleteFile'
            'Datastore.FileManagement'
            'Datastore.AllocateSpace'
            'Network.Delete'   
            'Network.Config'   
            'Network.Assign'   
            'DVSwitch.Create'  
            'DVSwitch.Modify'  
            'DVPortgroup.Create'
            'DVPortgroup.Modify'
            'VirtualMachine.Inventory.Create'
            'VirtualMachine.Inventory.Register'
            'VirtualMachine.Inventory.Delete'
            'VirtualMachine.Inventory.Unregister'
            'VirtualMachine.Interact.PowerOn'
            'VirtualMachine.Interact.PowerOff'
            'VirtualMachine.Interact.Reset'
            'VirtualMachine.Interact.ConsoleInteract'
            'VirtualMachine.Interact.DeviceConnection'
            'VirtualMachine.Interact.ToolsInstall'
            'VirtualMachine.Interact.GuestControl'
            'VirtualMachine.GuestOperations.Query'
            'VirtualMachine.GuestOperations.Modify'
            'VirtualMachine.GuestOperations.Execute'
            'VirtualMachine.Config.Rename'
            'VirtualMachine.Config.Annotation'
            'VirtualMachine.Config.AddExistingDisk'
            'VirtualMachine.Config.AddNewDisk'
            'VirtualMachine.Config.RemoveDisk'
            'VirtualMachine.Config.RawDevice'
            'VirtualMachine.Config.HostUSBDevice'
            'VirtualMachine.Config.CPUCount'
            'VirtualMachine.Config.Memory'
            'VirtualMachine.Config.EditDevice'
            'VirtualMachine.Config.AddRemoveDevice'
            'VirtualMachine.Config.Settings'
            'VirtualMachine.Config.Resource'
            'VirtualMachine.Config.UpgradeVirtualHardware'
            'VirtualMachine.Config.ResetGuestInfo'
            'VirtualMachine.Config.AdvancedConfig'
            'VirtualMachine.Config.DiskLease'
            'VirtualMachine.Config.SwapPlacement'
            'VirtualMachine.Config.DiskExtend'
            'VirtualMachine.Config.ChangeTracking'
            'VirtualMachine.Config.ReloadFromPath'
            'VirtualMachine.State.CreateSnapshot'
            'VirtualMachine.State.RevertToSnapshot'
            'VirtualMachine.State.RemoveSnapshot'
            'VirtualMachine.Provisioning.MarkAsTemplate'
            'VirtualMachine.Provisioning.DiskRandomAccess'
            'VirtualMachine.Provisioning.DiskRandomRead'
            'VirtualMachine.Provisioning.GetVmFiles'
            'Resource.AssignVMToPool'
            'Task.Create'      
            'Task.Update'      
            'Sessions.ValidateSession'
            'Extension.Register'
            'Extension.Update'
            'VApp.ApplicationConfig'
            'VApp.Export'      
            'VApp.Create'      
            'VApp.Unregister'  
            'VApp.PowerOn'     
            'VApp.PowerOff'    
            'VApp.Rename'      
            'Profile.Create'   
            'Profile.Export'   
            'EAM.Modify'       
            'AutoDeploy.Profile.Create'
            'AutoDeploy.Rule.Create'
            'VcIntegrity.General'
        )
        New-VIRole $VDP_Role
        Set-VIRole $VDP_Role -AddPrivilege $PrivilegeList

        Get-VIRole $VDP_Role | Select Name,PrivilegeList
    }
    End
    {
    }
}