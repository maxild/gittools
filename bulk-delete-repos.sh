#!/usr/bin/env bash

# NOTES:
# Without credentials, you will receive all public repositories of the user.
# With credentials you will also receive the private ones.
# Public repos
#  $ curl "https://api.github.com/users/maxild/repos?per_page=100&page=1" | jq -r '.[] | .name'
#  $ curl "https://api.github.com/users/maxild/repos?per_page=100&page=1" 2>/dev/null | jq -r '.[] | .name'
#
# TODO: Can't get this to work
# Private repos
#  $ curl -H "Accept: application/vnd.github.v3+json" -H "Authorization: token $GITHUB_TOKEN" "https://api.github.com/users/maxild/repos?type=private&per_page=100&page=1" | jq -r '.[] | .name'
repos=(
  #depends
)

# require a personal access token with 'delete_repo' perm
# https://github.com/settings/tokens/new
GITHUB_TOKEN=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

# Register a  https://github.com/settings/tokens/new
for i in "${repos[@]}"
do
  # This is the best way when 2FA is enabled
  #curl -v -X DELETE -u $GITHUB_TOKEN:x-oauth-basic "https://api.github.com/repos/maxild/$i";
  # Note this requires entering password at the commandline
  #curl -X DELETE -u $GITHUB_USER:$GITHUB_PASSWORD -H "Authorization: token $GITHUB_TOKEN" "https://api.github.com/repos/maxild/$i";
done
