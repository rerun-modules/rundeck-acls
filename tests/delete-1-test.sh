#!/usr/bin/env roundup
#
#/ usage:  rerun stubbs:test -m rundeck-acls -p delete [--answers <>]
#

# Helpers
# -------
[[ -f ./functions.sh ]] && . ./functions.sh

# The Plan
# --------
describe "delete"

TMPFILE=
: ${TEST_RUNDECK_PROJECT:=anvils}

before() {
	TMPFILE=$(mktemp -t "delete-1-test.XXXX")
}
after() {
	rm $TMPFILE
}

it_deletes_system_aclpolicy() {
	cat >$TMPFILE<<-EOF
	description: 'Given user in group ".*" and for resource, then allow action [read].'
	context:
	  project: '.*'
	for:
	  resource:
	    - allow: [read]
	by:
	  group: '.*'
	EOF
    rerun rundeck-acls: create --aclpolicy anyone-allow-resource.aclpolicy --file $TMPFILE
    acls=($(rerun rundeck-acls: list))
    test ${#acls[*]} = 1 
    test "anyone-allow-resource.aclpolicy" = ${acls[0]}

    rerun rundeck-acls: delete --aclpolicy anyone-allow-resource.aclpolicy
    acls=($(rerun rundeck-acls: list))
    test ${#acls[*]} = 0 
}

it_deletes_project_aclpolicy() {
	cat >$TMPFILE<<-EOF
	description: 'Given user in group "audit" and for resource, then allow action [read].'
	for:
	  resource:
	    - allow: [read]
	by:
	  group: audit
	EOF
    rerun rundeck-acls: create --aclpolicy anyone-allow-resource.aclpolicy --file $TMPFILE --project $TEST_RUNDECK_PROJECT
    acls=($(rerun rundeck-acls: list --project $TEST_RUNDECK_PROJECT))
    test ${#acls[*]} = 1 
    test "anyone-allow-resource.aclpolicy" = ${acls[0]}

    rerun rundeck-acls: delete --aclpolicy anyone-allow-resource.aclpolicy --project $TEST_RUNDECK_PROJECT
    acls=($(rerun rundeck-acls: list -project $TEST_RUNDECK_PROJECT))
    test ${#acls[*]} = 0 
}
