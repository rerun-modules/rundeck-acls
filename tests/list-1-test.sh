#!/usr/bin/env roundup
#
#/ usage:  rerun stubbs:test -m rundeck-acls -p list [--answers <>]
#

# Helpers
# -------
[[ -f ./functions.sh ]] && . ./functions.sh

: ${TEST_RUNDECK_PROJECT:=anvils}

TMPFILE=
before() {
	TMPFILE=$(mktemp -t "list-1-test.XXXX")
#	clean_acls $TEST_RUNDECK_PROJECT
}
after() {
	echo rm $TMPFILE
}
# The Plan
# --------
describe "list"

it_lists_system_aclpolicy() {
	local aclpolicy="system-$$.aclpolicy"
	local start_list=($(rerun rundeck-acls: list))
	local after_list=()

	cat >$TMPFILE<<-EOF
	description: 'Given user in group "audit" and for resource, then allow action [read].'
	context:
	  application: rundeck
	for:
	  resource:
	    - allow: [read]
	by:
	  group: audit
	EOF
    rerun rundeck-acls: create --aclpolicy $aclpolicy --file $TMPFILE
    after_list=($(rerun rundeck-acls: list))

    rerun rundeck-acls: delete --aclpolicy $aclpolicy

    (( ${#after_list[*]} == (${#start_list[*]} +1) ))
    echo "${after_list[@]}" | grep $aclpolicy

}

it_lists_project_aclpolicy() {
	local aclpolicy=project-$$.aclpolicy
	local start_list=($(rerun rundeck-acls: list --project $TEST_RUNDECK_PROJECT))
	local created_list=() deleted_list=()

	cat >$TMPFILE<<-EOF
	description: 'Given user in group "dev" and for node matching "tags: www", then allow action [read,run].'
	for:
	  node:
	    - contains:
	        tags: 'www'
	      allow: [run,read]
	by:
	  group: 'dev'
	EOF
    rerun rundeck-acls: create --aclpolicy $aclpolicy --file $TMPFILE --project $TEST_RUNDECK_PROJECT
    created_list=($(rerun rundeck-acls: list --project $TEST_RUNDECK_PROJECT))
    (( ${#created_list[*]} == (${#start_list[*]} +1) ))

    rerun rundeck-acls: delete --aclpolicy $aclpolicy --project $TEST_RUNDECK_PROJECT
	deleted_list=($(rerun rundeck-acls: list --project $TEST_RUNDECK_PROJECT))

    (( ${#deleted_list[*]} == ${#start_list[*]} ))


}