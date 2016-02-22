#!/usr/bin/env roundup
#
#/ usage:  rerun stubbs:test -m rundeck-acls -p get [--answers <>]
#

# Helpers
# -------
[[ -f ./functions.sh ]] && . ./functions.sh

: ${TEST_RUNDECK_PROJECT:=anvils}

TMPFILE=
before() {
	TMPFILE=$(mktemp -t "get-1-test.XXXX")
}
after() {
	rm $TMPFILE
}
# The Plan
# --------
describe "get"

it_gets_system_aclpolicy() {

	cat >$TMPFILE<<-EOF
	description: 'Given user in group "audit" and for resource, then allow action [read].'
	context:
	  project: '.*'
	for:
	  resource:
	    - allow: [read]
	by:
	  group: audit
	EOF
    rerun rundeck-acls: create --aclpolicy system-$$.aclpolicy --file $TMPFILE

   	OUTPUT=$(mktemp -t "get-1-test.XXXX")
    rerun rundeck-acls: get --aclpolicy system-$$.aclpolicy > $OUTPUT

    diff $TMPFILE $OUTPUT
}

it_gets_project_aclpolicy() {

	cat >$TMPFILE<<-EOF
	description: 'Given user in group "audit" and for resource, then allow action [read].'
	for:
	  resource:
	    - allow: [read]
	by:
	  group: audit
	EOF
    rerun rundeck-acls: create --aclpolicy project-$$.aclpolicy --file $TMPFILE --project $TEST_RUNDECK_PROJECT

   	OUTPUT=$(mktemp -t "get-1-test.XXXX")
    rerun rundeck-acls: get --aclpolicy project-$$.aclpolicy --project $TEST_RUNDECK_PROJECT > $OUTPUT

    diff $TMPFILE $OUTPUT
}

