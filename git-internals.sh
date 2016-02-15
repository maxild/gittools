#!/usr/bin/env bash

# There are many ways to compute object ids (here for blob)

echo "Hello World" > hello.txt

# Adding to the index (staging area) will make git store blob object
git add .

tree .git

# Calculate sha1 of blob (digest of file contents)
printf "blob 12\000Hello World\n" | shasum

# Committing to the repo will make git create tree and commit objects
git commit -m"First hello"

# Make git compute object id and optionally create a blob (-t blob is the default type, -w means actually write into the object database)
echo "Hello World" | git hash-object -w --stdin

# Can we read back contents from the object database
cat .git/objects/55/7db03de997c86a4a028e1ebd3a1ceb225be238

# No the file has been packed (compressed....via zlib)
alias deflate="perl -MCompress::Zlib -e 'undef $/; print uncompress(<>)'"
# This will print 'blob 12Hello World' to stdout

# How will git write out the tree (dir containing hello.txt)
# update-index will register file contents in the working tree to the index
# Note: Filename and contents (hash) is supplied when writing the tree...efficient to move big files around
git update-index --add --cache-info 100644 557 557db03de997c86a4a028e1ebd3a1ceb225be238 hello.txt

git cat-file -t 557db
git cat-file -p 557db

# Turns shorhand hashes into a full hash (40 char hex identifier)
git rev-parse 557db
git rev-parse HEAD
git rev-parse master
git rev-parse master~
git rev-parse 'master^{tree}'

# REV:FILE filish: looking at tthe graph...going back ti REV (hash). Look into the Tree...loook for file...cat-file -p..end of story
git show 557db03
git show 557db03:src/AmortTable.cs

# Merge scenaries (git show in the middle of a merge...conflict)
# :0:FILE : Index
# :1:FILE : Common ancestor (merge base...middle)
# :2:FILE : Target (the current brnach you are on...right or left)
# :3:FILE : Merging in *the branch you are bringing in...right or left)
git show :1:somefile.cs | subl

# Commitish: Shorthand for commit hashes
# Treish: Sharthand for tree hashes
