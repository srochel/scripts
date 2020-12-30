#!/bin/bash

#directories='1991 1999 2004 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020'

source_drive="/media/steffen/Seagate Backup Plus Drive"
target_drive="/media/steffen/FamilyDrive4"
#target_drive="/media/steffen/Seagate Backup Plus Drive"
#source_drive="/media/steffen/FamilyDrive4"
#top_dirs="Pictures"
#top_dirs="Music"

#================================================================
homedir="$PWD"
pushd "$source_drive"
top_dirs=`ls`
echo $top_dirs
#================================================================
for tdir in $top_dirs; do
  if [ -d "$tdir" ]; then
    pushd "$source_drive"/"$tdir"
    pwd
    directories=`ls`
    for dir in $directories; do
      if [ -d "$dir" ]; then
        echo "Directory " "$tdir"/"$dir"
        pushd "$dir" >& /dev/null
        find . -print > "$homedir"/flist.txt  # find all files
	rm -rf "$homedir"/proclist.txt
        while IFS= read -r -u13 f ; do  # need file descriptor as ffmpeg is using also file descriptor
	  echo "$tdir"/"$dir"/"$f" >> "$homedir"/proclist.txt
	  if [ ! -d "$f" ]; then # not a directory
	    if [ -s "$f" ]; then # not a zero byte file
	      if ! cmp --silent "$source_drive"/"$tdir"/"$dir"/"$f" "$target_drive"/"$tdir"/"$dir"/"$f"; then
	        if [ -s "$target_drive"/"$tdir"/"$dir"/"$f" ]; then # target file does exist
                  echo "$tdir"/"$dir"/"$f" " exists, but might not be equivalent"
	          ls -al "$source_drive"/"$tdir"/"$dir"/"$f"
	          ls -al "$target_drive"/"$tdir"/"$dir"/"$f"
                else
		  echo "target does not exists, copying " "$tdir"/"$dir"/"$f"
		  workdir="${f%/*}" # need to create dir name from file name
		  mkdir -p "$target_drive"/"$tdir"/"$dir"/"$workdir" # create directory if doesn't exist
		  cp "$source_drive"/"$tdir"/"$dir"/"$f" "$target_drive"/"$tdir"/"$dir"/"$f"
	        fi
	      fi
	    fi
	  fi
        done 13<"$homedir"/flist.txt
        popd >& /dev/null # $dir
      fi
    done
    popd  # "$source_drive"/"$tdir"
  fi
done

exit
