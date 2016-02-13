#!/usr/bin/env bash
# Helper commands
#    git shortlog -sne
#    git log --stat --name-only --committer="tts" --pretty=format:"" | sort -u

#
# Normalize all line-endings to LF in the entire history
#

# turn off any automated git end-of-line handling
git config core.autocrlf false

# Remove .gitattributes from all commits
git filter-branch -f --prune-empty --index-filter 'git rm --cached --ignore-unmatch -q -- .gitattributes' -- --all

# Convert all the text files to LF line endings (-z and -0 switches because of possible spaces in paths, not likely)
git filter-branch -f --prune-empty --tree-filter 'git ls-files -z | xargs -0 dos2unix --quiet --safe' -- --all

# TODO: Create new .gitattributes containing at least
#      * text=auto

# remove deprecated option
git config --unset core.autocrlf

#
# Files
#

# Remove Src/GlobalAssemblyInfo.cs, WiX/wix.targets from all commits
# Note: We are using index-filter, as it doesn't have to check out each revision (much faster)
#      git filter-branch --tree-filter 'rm -f -- Src/GlobalAssemblyInfo.cs WiX/wix.targets' HEAD
git filter-branch -f --prune-empty --index-filter 'git rm --cached --ignore-unmatch -q -- localtestrun.testrunconfig Lofus.vssscc normalize-crlf.ps1 normalize-line-endings.ps1 normalize-tabs-to-spaces.ps1 readme_git_tfs.txt Src/GlobalAssemblyInfo.cs WiX/wix.targets' -- --all

#
# Folder trees
#

# Remove Wix folder content from all commits
#git filter-branch --tree-filter 'rm -rf -- WiX/wix.targets' HEAD #slow
#git filter-branch --index-filter 'git rm --cached --ignore-unmatch -- WiX/wix.targets' HEAD

# Remove all files under Src/Provider, UnitTests/Provider, Src/HisFx, UnitTests/HisFx
git filter-branch -f --prune-empty --index-filter 'git rm --cached --ignore-unmatch -qr -- Src/Provider UnitTests/Provider Src/HisFx UnitTests/HisFx' -- --all


#
# Tab to Spaces in *.cs files
#

git filter-branch -f --prune-empty --tree-filter 'find . -name '*.cs' ! -type d -exec bash -c 'expand -t 4 "$0" > /tmp/e && mv /tmp/e "$0"' {} \;'

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

# Skip commits by Morten Vestergard Pedersen (not necessary because of files and folders wped out)
git filter-branch -f --commit-filter '
        if [ "$GIT_AUTHOR_EMAIL" = "mvp@brf.dk" ];
        then
                skip_commit "$@";
        else
                git commit-tree "$@";
        fi' HEAD

# Skip commits by mik (not necessary because of files and folders wped out)
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

# Unify all commits by tts
git filter-branch -f --commit-filter '
        if [ "$GIT_AUTHOR_EMAIL" = "tts@brfkredit.tfs.local" ];
        then
                GIT_AUTHOR_NAME="Thomas Thomsen Skovsende";
                GIT_AUTHOR_EMAIL="tts@brf.dk";
                git commit-tree "$@";
        else
                git commit-tree "$@";
        fi' HEAD

# Unify all commits by tts
git filter-branch -f --commit-filter '
        if [ "$GIT_AUTHOR_EMAIL" = "ktr@brf.dk" ];
        then
                GIT_AUTHOR_NAME="Kenneth Rasmussen";
                git commit-tree "$@";
        else
                git commit-tree "$@";
        fi' HEAD


# Normalize every tab to 4 spaces
find . -name '*.cs' ! -type d -exec bash -c 'expand -t 4 "$0" > /tmp/e && mv /tmp/e "$0"' {} \;

#
# Finalization
#

# Remove any empty commits
git filter-branch -f --commit-filter 'git_commit_non_empty_tree "$@"' HEAD

# Note: remember to clone your rewrited repo to clean up
# all your left over objects (easier than gc)
