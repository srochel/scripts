#!/bin/bash

directories='1985 1990 1991 1992 1997 1998 1999 2000 2001 2003 2004 2005 2006 2007 2008 2009'
directories='1985 1990 1991 1992 1997 1998 1999'
directories='2000 2001 2003' # 2004 2005 2006 2007 2008 2009'
directories='2004 2005 2006 2007 2008 2009'
directories='2009'
directories='1991 1999 2004 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020'

source_drive="/media/steffen/Seagate Backup Plus Drive"
target_drive="/media/steffen/FamilyDrive4"
top_dirs="Pictures"

#================================================================
homedir="$PWD"
for tdir in $top_dirs; do
  pushd "$source_drive"/"$tdir"
#  directories=`ls`
#  directories='1990'
  for dir in $directories; do
    if [ -d "$dir" ]; then
      echo "Directory " "$tdir"/"$dir"
      pushd "$dir" >& /dev/null
      find . -print > "$homedir"/flist.txt  # find all files
      while IFS= read -r -u13 f ; do  # need file descriptor as ffmpeg is using also file descriptor
	if [ ! -d "$f" ]; then # not a directory
	  if [ -s "$f" ]; then # not a zero byte file
	    if ! cmp --silent "$source_drive"/"$tdir"/"$dir"/"$f" "$target_drive"/"$tdir"/"$dir"/"$f"; then
	      if [ -s "$target_drive"/"$tdir"/"$dir"/"$f" ]; then # target file doesn't exist
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
done

exit
