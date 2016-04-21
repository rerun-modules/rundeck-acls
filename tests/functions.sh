# 
# Test functions for command tests.
#

# - - -
# Your functions declared here.
# - - -


clean_acls () {
	local project=$1
    for acl in $(rerun  rundeck-acls: list);
    do
        rerun rundeck-acls:delete --aclpolicy $acl;
    done;
    for acl in $(rerun  rundeck-acls: list --project $project);
    do
        rerun rundeck-acls:delete --aclpolicy $acl --project $project;
    done
}