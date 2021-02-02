#!/bin/bash
# SPDX-License-Identifier: MIT

# A shell wrapper around ansible-test.

set -uo pipefail

ME=$(basename "$0")
SCRIPTDIR=$(readlink -f "$(dirname "$0")")

. "$SCRIPTDIR/utils.sh"

if [ "${LSR_ROLE2COLL_NAMESPACE:-}" = "" -o "${LSR_ROLE2COLL_NAME:-}" = "" ]; then
    lsr_info "${ME}: Collection format only." 
	exit 1
fi

LSR_ROLE2COLL_TOP="$LSR_TOX_ENV_DIR"/ansible_collections/"$LSR_ROLE2COLL_NAMESPACE"/"$LSR_ROLE2COLL_NAME"

rval=0
if [ -d "$LSR_ROLE2COLL_TOP" ]; then
  cd "$LSR_ROLE2COLL_TOP"
  for test in $( ansible-test sanity --list-tests ); do
    lsr_info "${ME}: Running $test ..."
    ansible-test sanity --test $test; r=$? || :
    rval=$( expr $rval + $r )
  done
else
  lsr_info "${ME}: $LSR_ROLE2COLL_TOP not found."
  exit 1
fi
exit $rval
