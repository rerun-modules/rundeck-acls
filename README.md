## Overview

Use *rundeck-acls* to administrate Rundeck system ACL policies.

## Common options

Most of the rundeck-acls commands use the same options to connect to the rundeck serverto administrate. Several of these can be defaulted to environment variable values.

	-<$RUNDECK_URL> --user <$RUNDECK_USER> --password <$RUNDECK_PASSWORD> --apikey <$APIKEY>


> Note, --apikey <> and [--username --password <>] are mutually exclusive.

## Examples

There are no ACLs for this project yet:

	$ rerun  rundeck-acls:list

Add a new ACL policy to the project:

	$ rerun  rundeck-acls:create --file anyone-allow-resource.aclpolicy

Run the listing again. The 'anyone-allow-resource.aclpolicy' policy is shown.

	$ rerun  rundeck-acls:list --project foo
	anyone-allow-resource.aclpolicy

Get the ACL policy file

	$ rerun  rundeck-acls-get --aclpolicy anyone-allow-resource.aclpolicy
	description: 'Given user in group ".*" and for project, then allow action [read].'
	context:
	  application: 'rundeck'
	for:
	  project:
	    - allow: [read]
	by:
	  group: '.*'


Delete an ACL Policy

	$ rerun  rundeck-acls:delete --aclpolicy anyone-allow-resource.aclpolicy
