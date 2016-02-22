#!/usr/bin/env roundup
#
#/ usage:  rerun stubbs:test -m rundeck-acls -p update [--answers <>]
#

# Helpers
# -------
[[ -f ./functions.sh ]] && . ./functions.sh

: ${TEST_RUNDECK_PROJECT:=anvils}

TMPFILE=
before() {
	TMPFILE=$(mktemp -t "update-1-test.XXXX")
}
after() {
	rm $TMPFILE
}

# The Plan
# --------
describe "update"

it_fails_on_non_existent_system_aclpolicy() {
    if ! error_out=$(rerun rundeck-acls: update --aclpolicy nonexistent-$$.aclpolicy --file $TMPFILE 2>&1)
    then
		echo "$error_out" | grep "ERROR: System ACL Policy File does not exist: nonexistent-$$.aclpolicy"
    else
    	echo >&2 "Should have thrown a validation error"
    	return 1
	fi
}

it_updates_system_aclpolicy() {
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
    rerun rundeck-acls: update --aclpolicy anyone-allow-resource-$$.aclpolicy --file $TMPFILE
}
