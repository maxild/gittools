#!/usr/bin/env bash

# git subtree split -prefix=subdir_to_remove -b new_project_branch

# git filter-branch --subdirectory-filter subdir_to_remove new_project_branch

# Credits to: https://jimmy.schementi.com/splitting-up-a-git-repo

# Step 0: A fresh clone of the Domus project, before we rewrite the history

# ---------------------------
# Extract subtree
# ---------------------------

# Step 1:
#   first we remove all non-wanted files from all git commits with the
#   git filter-branch command. Any commits that do not touch those paths
#   will be removed because of the --ignore-unmatch flag.

# PATHS_TO_KEEP="./some_dir ./some_other_dir .env Procfile"
# git filter-branch -f --index-filter "git rm --ignore-unmatch --cached -qr -- . && git reset -q \$GIT_COMMIT -- $PATHS_TO_KEEP" --prune-empty -- HEAD

# NOTES:
# 1. The -- HEAD means to only do this transformation in the current branch.
#    You can replace it with -- --all to do it across all branches.
#    Or `--tag-name-filter cat -- --all` to do it across all branches AND tags.

# PATHS_TO_KEEP="./src/Codegen .gitignore .gitattributes .editorconfig build.cake build.config build.ps1 build.sh cake.config Directory.Build.props GitVersion.yml global.json NuGet.config NuGet.public.config ./tools/nuget.exe"
# git filter-branch -f --index-filter "git rm --ignore-unmatch --cached -qr -- . && git reset -q \$GIT_COMMIT -- $PATHS_TO_KEEP" --prune-empty -- "dev"

# ---------------------------
# Unify all commits by maxild
# ---------------------------
git filter-branch -f --commit-filter '
    if [ "$GIT_AUTHOR_NAME" = "Morten Maxild" ];
    then
        GIT_AUTHOR_NAME="maxild";
        GIT_AUTHOR_EMAIL="mmaxild@gmail.com";
        git commit-tree "$@";
    else
        git commit-tree "$@";
    fi' HEAD
