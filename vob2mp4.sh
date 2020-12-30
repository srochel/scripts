#!/bin/bash

directories='1985 1990 1991 1992 1997 1998 1999 2000 2001 2003 2004 2005 2006 2007 2008 2009'
directories='2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020'

drive="/media/steffen/Seagate Backup Plus Drive/Pictures"
#drive="/media/steffen/Seagate Backup Plus Drive/Videos"
#drive="/media/steffen/Seagate Backup Plus Drive/Steffen"
#drive="/media/steffen/Seagate Backup Plus Drive/Steffen-GoogleDrive"
#drive="/media/steffen/Seagate Backup Plus Drive/Robert"

#================================================================
shopt -s nocasematch # make string substitution case insensitive
homedir="$PWD"
rm -rf vobfailures.txt
echo item: "$drive"
pushd "$drive"
directories=`ls`
echo $directories
for dir in $directories; do
#  echo "$dir"
  if [ -d "$dir" ]; then
    pushd "$dir"
    pwd
    mkdir -p "$homedir"/"$dir"
    find . -iname "*.vob" -print > "$homedir"/"$dir"/voblist.txt  # find all .vob and .VOB files
    pushd "$homedir"/"$dir"
    rm -rf mp4list.txt
    touch mp4list.txt
    while IFS= read -r -u13 vobname ; do  # need file descriptor as ffmpeg is using also file descriptor
      f="$vobname"
      echo vob "$f"
      workdir="${f%/*}"
      echo "$workdir"
      mkdir -p "$workdir"
      outfile="${f%.*}.mp4"  # change file extension from .vob/.VOB to .mp4
      echo "$outfile"
      cp "$drive"/"$dir"/"$f" ./"$f"
      if ffmpeg -i ./"$f" -b:v 9800k -b:a 256k ./"$outfile" >& /dev/null; then
        cp ./"$outfile" "$drive"/"$dir"/"$outfile"
        echo mp4-success "$outfile"
        echo "$outfile" >> mp4list.txt
      else
        echo mp4-failure "$outfile"
        echo "$drive"/"$dir"/"$f" >> "$homedir"/vobfailures.txt
      fi
      rm -rf ./"$outfile" ./"$f"
    done 13<voblist.txt
    popd  # "$homedir"/"$dir" 
    popd  # $dir
  fi
done
popd # $drive

exit
