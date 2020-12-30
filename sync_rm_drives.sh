#!/bin/bash

#directories='1991 1999 2004 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020'

#source_drive="/media/steffen/Seagate Backup Plus Drive"
source_drive="/media/steffen/FamilyDrive4"
#target_drive="/media/steffen/FamilyDrive4"
target_drive="/media/steffen/Seagate Backup Plus Drive"
#top_dirs="Pictures"
top_dirs="Music"

#================================================================
homedir="$PWD"
pushd "$source_drive"
#top_dirs=`ls`
echo $top_dirs
#================================================================
for tdir in $top_dirs; do
  if [ -d "$tdir" ]; then
    pushd "$source_drive"/"$tdir"
    pwd
    find . -type d -empty -delete  # find all empty directories and delete
    directories=`ls`
    for dir in $directories; do
      if [ -d "$dir" ]; then
        echo "Directory " "$tdir"/"$dir"
        pushd "$dir" >& /dev/null
        find . -print > "$homedir"/flist.txt  # find all files
        while IFS= read -r -u13 f ; do  # need file descriptor as ffmpeg is using also file descriptor
	  if [ ! -d "$f" ]; then # not a directory
	    if [ ! -s "$target_drive"/"$tdir"/"$dir"/"$f" ]; then # target file does not exist
	      echo "target does not exists, removing " "$tdir"/"$dir"/"$f"
	      rm -rf "$source_drive"/"$tdir"/"$dir"/"$f"
	    fi
	  fi
        done 13<"$homedir"/flist.txt
        popd >& /dev/null # $dir
      fi
    done
    find . -type d -empty -delete  # find all empty directories and delete
    find . -type d -empty -print   # should be empty, check if cmd needs to be done recursive
    popd  # "$source_drive"/"$tdir"
  fi
done

pushd "$target_drive"
find . -type d -empty -delete  # find all empty directories and delete
find . -type d -empty -print   # should be empty, check if cmd needs to be done recursive

exit
