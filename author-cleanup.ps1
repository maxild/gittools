# Helper commands
#    git shortlog -sne
#    git log --stat --name-only --committer="tts" --pretty=format:"" | sort -u

#
# Files
#

# Remove Src/GlobalAssemblyInfo.cs, WiX/wix.targets from all commits
# Note: We are using index-filter, as it doesn't have to check out each revision (much faster)
#      git filter-branch --tree-filter 'rm -f -- Src/GlobalAssemblyInfo.cs WiX/wix.targets' HEAD
$files_to_remove='readme_git_tfs.txt Lofus.vssscc localtestrun.testrunconfig Src/GlobalAssemblyInfo.cs WiX/wix.targets'
git filter-branch -f --prune-empty --index-filter 'git rm --cached --ignore-unmatch -q -- ${files_to_remove}' HEAD

#
# Folder trees
#

# Remove Wix folder content from all commits
#git filter-branch --tree-filter 'rm -rf -- WiX/wix.targets' HEAD #slow
#git filter-branch --index-filter 'git rm --cached --ignore-unmatch -- WiX/wix.targets' HEAD

# Remove all files under Src/Provider, UnitTests/Provider, Src/HisFx, UnitTests/HisFx
$folders_to_remove='Src/Provider UnitTests/Provider Src/HisFx UnitTests/HisFx'
git filter-branch -f --prune-empty --index-filter 'git rm --cached --ignore-unmatch -qr -- ${folders_to_remove}' HEAD

# Remove all files under Provider
#git filter-branch --tree-filter 'git rm -rf Src/Provider' HEAD # todo
#git filter-branch --tree-filter 'git rm -rf UnitTests/Provider' HEAD # todo
# Remove all files under HisFx
#git filter-branch --tree-filter 'git rm -rf Src/HisFx' HEAD # todo
#git filter-branch --tree-filter 'git rm -rf UnitTests/HisFx' HEAD # todo

#
# Normalize all line-endings to LF in the entire history
#

# turn off any automated git end-of-line handling
git config core.autocrlf false

# Remove .gitattributes from all commits
git filter-branch -f --prune-empty --index-filter 'git rm --cached --ignore-unmatch -q -- .gitattributes' -- --all

# Convert all the text files to LF line endings (-z and -0 switches because of possible spaces in paths, not likely)
git filter-branch -f --prune-empty --tree-filter 'git ls-files -z | xargs -0 dos2unix --quiet --safe 2>&1 >/dev/null' -- --all

# TODO: Create new .gitattributes containing at least
#      * text=auto

# remove deprecated option
git config --unset core.autocrlf

#
# Tab to Spaces in *.cs files
#

git filter-branch -f --prune-empty --tree-filter 'find . -name "*.cs" -type f | xargs expand -t 4'

#
# Authors
#

# MKP has one redundant commit a1105b3777eae30c76ec98ab952bb2eccafab23a

# Skip commits by MKP (skip_commit will squash
# the current commit with the next one, and next one is my compensating/rollback commit)
# Because we are rewriting history we cannot use
#     git rebase --onto <commit-id>~ <commit-id> HEAD
# to remove MKP's one commit
#################################################
# git rebase --onto master~3 master~2 master
#   Before:  1---2---3---4---5  master
#   After:   1---2---4'---5' master
#################################################
git filter-branch -f --commit-filter '
        if [ "$GIT_AUTHOR_EMAIL" = "MKP@brf.dk" ];
        then
                skip_commit "$@";
        else
                git_commit_non_empty_tree "$@";
        fi' HEAD

# Skip commits by Morten Vestergard Pedersen
git filter-branch -f --commit-filter '
        if [ "$GIT_AUTHOR_EMAIL" = "mvp@brf.dk" ];
        then
                skip_commit "$@";
        else
                git commit-tree "$@";
        fi' HEAD

# Skip commits by mik
git filter-branch -f --commit-filter '
        if [ "$GIT_AUTHOR_EMAIL" = "mik@brfkredit.tfs.local" ];
        then
                skip_commit "$@";
        else
                git commit-tree "$@";
        fi' HEAD

# Unify all commits by maxild
git filter-branch -f --commit-filter '
        if [ "$GIT_AUTHOR_EMAIL" = "MOM@brf.dk" ];
        then
                GIT_AUTHOR_NAME="maxild";
                GIT_AUTHOR_EMAIL="mmaxild@gmail.com";
                git commit-tree "$@";
        else
                git commit-tree "$@";
        fi' HEAD

#
# Finalization
#

# Remove any empty commits
git filter-branch -f --commit-filter 'git_commit_non_empty_tree "$@"' HEAD

#
# Housekeeping
#

git fsck --full
git prune
git gc --aggressive

git reflog expire --expire=now
git gc --prune=now
