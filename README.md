# vCenter-roles
Import pre-defined roles for common applications to access vCenter. The privileges for each role are stored in a JSON-format file as a list of privilege Ids (`Get-VIPrivilege | Select Id`).

    Import-VIRole -Name AdminRole -Permission C:\vcenter-roles\Roles\Administrator.json -vCenter vcenter.example.com

Some pre-defined privilege sets are provided in this repo's `\Roles` directory, but the cmdlet accepts any valid JSON file as an argument.

If necessary, roles can be removed with `Remove-VIRole` when connected to the appropriate vCenter server.

# Included Roles:

Find more details on the permissions sets [here](Roles Documentation.md).
