#!/bin/bash

directories='1985 1990 1991 1992 1997 1998 1999 2000 2001 2003 2004 2005 2006 2007 2008 2009'
directories='2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020'
#directories='2002'
drive="/media/steffen/Seagate Backup Plus Drive/Pictures"
drive="/media/steffen/FamilyDrive4/"

#================================================================
shopt -s nocasematch # make string substitution case insensitive
homedir="$PWD"
echo item: "$drive"
pushd "$drive" >& /dev/null
pwd
directories=`ls`
for dir in $directories; do
  pushd "$dir" >& /dev/null
  rm -rf "$homedir"/"$dir"
  rm -rf "$homedir"/"$dir"_mp4missing.txt
  mkdir "$homedir"/"$dir"
  find . -iname "*.vob" -print > "$homedir"/"$dir"/voblist.txt  # find all .vob and .VOB files
  while IFS= read -r -u13 f ; do  # need file descriptor as ffmpeg is using also file descriptor
    outfile="${f%.*}.mp4"  # change file extension from .vob/.VOB to .mp4
    if [ -s "$outfile" ]; then  # mp4 file exists and is not empty
      echo "Deleting " "$dir"/"$f"
      rm "$f"
    else
      echo "$f" >> "$homedir"/"$dir"_mp4missing.txt
    fi
  done 13<"$homedir"/"$dir"/voblist.txt
  popd >& /dev/null # $dir
  if [ -s "$homedir"/"$dir"_mp4missing.txt ]; then
    echo "Missing mp4 files " "$dir" " for"
    tail "$homedir"/"$dir"_mp4missing.txt
  fi
done
popd >& /dev/null # $drive

exit
