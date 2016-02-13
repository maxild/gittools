# Remove every file from Git's index.
git rm --cached -r .
# Rewrite the Git index to pick up all the new line endings.
git reset --hard
# Add all your changed files back, and prepare them for a commit.
# This is your chance to inspect which files, if any, were unchanged.
git add .
# It is perfectly safe to see a lot of messages here that read
# "warning: CRLF will be replaced by LF in file."
# Then commit any changes...
#     git commit -m "Normalize all the line endings"
