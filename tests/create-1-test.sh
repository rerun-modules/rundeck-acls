#!/usr/bin/env roundup
#
#/ usage:  rerun stubbs:test -m rundeck-acls -p create [--answers <>]
#

# Helpers
# -------
[[ -f ./functions.sh ]] && . ./functions.sh

: ${TEST_RUNDECK_PROJECT:=anvils}

TMPFILE=

before() {
	TMPFILE=$(mktemp -t "create-1-test.XXXX")
}
after() {
	rm $TMPFILE
}

# The Plan
# --------
describe "create"

it_fails_on_invalid_system_aclpolicy() {
	cat >$TMPFILE<<-EOF
	description: 'Some nonsense text'
	gobblygook:
	EOF
    if ! error_out=$(rerun rundeck-acls: create --aclpolicy invalid.aclpolicy --file $TMPFILE 2>&1)
    then
		echo "$error_out" | grep 'ERROR: validation error'
    else
    	echo >&2 "Should have thrown a validation error"
    	return 1
	fi
}

it_uploads_and_registers_system_aclpolicy() {
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
    rerun rundeck-acls: create --aclpolicy anyone-allow-resource-$$.aclpolicy --file $TMPFILE
    rerun rundeck-acls: delete --aclpolicy anyone-allow-resource-$$.aclpolicy
}

it_fails_for_project_policy_containing_context() {
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

	if ! error_out=$(rerun rundeck-acls: create --aclpolicy invalid.aclpolicy --file $TMPFILE --project $TEST_RUNDECK_PROJECT 2>&1)
	then
		echo "$error_out" | grep 'ERROR: validation error: Context section should not be specified'
	else
		echo "Should have thrown a validation error"
		return 1
	fi
}

it_uploads_and_registers_project_aclpolicy() {
	cat >$TMPFILE<<-EOF
	description: 'Given user in group "audit" and for resource, then allow action [read].'
	for:
	  resource:
	    - allow: [read]
	by:
	  group: audit
	EOF
    rerun rundeck-acls: create --aclpolicy project.aclpolicy --file $TMPFILE --project $TEST_RUNDECK_PROJECT
    rerun rundeck-acls: delete --aclpolicy project.aclpolicy --project $TEST_RUNDECK_PROJECT
}


