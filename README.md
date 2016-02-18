# vCenter-roles
Import pre-defined roles for common applications to access vCenter. The privileges for each role are stored in a JSON-format file as a list of privilege Ids (`Get-VIPrivilege | Select Id`).

    Import-VIRole -Name AdminRole -Permission C:\vcenter-roles\Roles\Administrator.json -vCenter vcenter.example.com

Some pre-defined privilege sets are provided in this repo's `\Roles` directory, but the cmdlet accepts any valid JSON file as an argument.

If necessary, roles can be removed with `Remove-VIRole` when connected to the appropriate vCenter server.

# Included Roles:

Find more details on the permissions sets [here](Roles Documentation.md).

# Contributing:

If you have a role you would like to see added to this repo, please open an [issue](https://github.com/rnelson0/vCenter-roles/issues) or [pull request](https://github.com/rnelson0/vCenter-roles/pulls) with the necessary details. You will need to provide the name of the Role, the privilege IDs, and documentation on the required privileges. You can obtain the privilege IDs in a few ways. Launch PowerShell and connect to your vCenter server with `Connect-VIServer`, then use one or more of these methods:

* Get a list of all privileges and choose the correct ones: `Get-VIPrivilege | Select Name, Id`
* Manually create a user with the correct privileges in vCenter and enumerate the privilege IDs: `Get-VIRole View | Get-VIPrivilege | select Name, Id`
* Obtain a list of privilege names from documentation and look up the ID: `Get-VIPrivilege -Name Host | Select Name, Id`

Create a new JSON file with an array of these IDs, titled after the application/use case of the role. For instance, the **View** role's permissions (`System.Anonymous` and `System.View`) would go in a file called `Roles/View.json` that looks like this:

    [
        "System.Anonymous",
        "System.View"
    ]
    
Finally, add the new role's name and privilege documentation to [Roles Documentation.md]((Roles Documentation.md).
