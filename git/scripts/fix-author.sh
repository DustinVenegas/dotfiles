#!/bin/sh
# SUMMARY
#   !!WARNING!! Changes commit hashes (destructive)
#   Fixup (modify) author and commiter email addresses
#   and names.
#
# USAGE
#   Update the script to fill in OLD_EMAIL, CORRECT_NAME,
#   an CORRECT_EMAIL.
#
# CLEANUP
#   refs/original hanging around in your repository?
#   That is the filter-branch backup! Make sure the
#   repo looks ok. Then add the alias below. Run it
#   with `git delete-refs-original-backup`
#
#	# Just ran filter-branches? WAIT until you're sure. This removes the backup references at refs/original/*
#	delete-refs-original-backup = "!git for-each-ref --format='%(refname)' refs/original/ | xargs -n 1 git update-ref -d"
#
# SOURCE
#   https://help.github.com/articles/changing-author-info/

git filter-branch --env-filter '
OLD_EMAIL="old@example.org"
CORRECT_NAME="Updated Example Name"
CORRECT_EMAIL="new@example.org"
if [ "$GIT_COMMITTER_EMAIL" = "$OLD_EMAIL" ]
then
    export GIT_COMMITTER_NAME="$CORRECT_NAME"
    export GIT_COMMITTER_EMAIL="$CORRECT_EMAIL"
fi
if [ "$GIT_AUTHOR_EMAIL" = "$OLD_EMAIL" ]
then
    export GIT_AUTHOR_NAME="$CORRECT_NAME"
    export GIT_AUTHOR_EMAIL="$CORRECT_EMAIL"
fi
' --tag-name-filter cat -- --branches --tags
