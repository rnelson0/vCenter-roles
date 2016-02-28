# vCenter-roles
Import pre-defined roles for common applications to access vCenter. The privileges for each role are stored in a JSON-format file as a list of privilege Ids (`Get-VIPrivilege | Select Id`).

    Import-VIRole -Name AdminRole -Permission C:\vcenter-roles\Roles\Administrator.json -vCenter vcenter.example.com

Some pre-defined privilege sets are provided in this repo's `\Roles` directory, but the cmdlet accepts any valid JSON file as an argument.

If necessary, roles can be removed with `Remove-VIRole` when connected to the appropriate vCenter server.

# Included Roles:

View the [Roles](Roles) directory for a list of provided roles.

# Contributing:

If you have a role you would like to see added to this repo, please open an [issue](https://github.com/rnelson0/vCenter-roles/issues) or [pull request](https://github.com/rnelson0/vCenter-roles/pulls) with the necessary details. You will need a number of items to describe the role:

1. Product Description: Name of the product or use case the role is designed to be used with.
1. Product Version: Version number of the product, or "N/A" if describing a use case.
1. Reference URL: Link to documentation of the product or use case and its required privileges.
1. Vendor: Name of the vendor, or "N/A" if based on a common use case.
1. vCenter Release: Major and Minor Version of vCenter the privileges support. (e.g '6.0' or '5.5')
1. Privileges: A list of all the VIPrivileges, by ID, not by Name.

If you do not have a list of privileges by ID, you can obtain the privilege IDs in a few ways. Launch PowerShell and connect to your vCenter server with `Connect-VIServer`, then use one or more of these methods:

* Get a list of all privileges and choose the correct ones: `Get-VIPrivilege | Select Name, Id`
* Manually create a user with the correct privileges in vCenter and enumerate the privilege IDs: `Get-VIRole View | Get-VIPrivilege | select Name, Id`
* Obtain a list of privilege names from documentation and look up the ID: `Get-VIPrivilege -Name Host | Select Name, Id`

Create a new JSON file with an array of these IDs, titled after the application/use case of the role. For instance, the **View** role's permissions (`System.Anonymous` and `System.View`) would go in a file called `Roles/View.json` that looks like this:

	{
		"product_description": "Sample View-only role",
		"product_version": "N/A"
		"reference_url": "https://example.com/sample_view-only_role.html",
		"vendor": "N/A",
		"vcenter_schema": "6.0",
		"privileges": [
			"System.Anonymous",
			"System.View"
		]
	}

You can validate your json with one of the many online tools, such as [JSONLint](http://jsonlint.com/).
