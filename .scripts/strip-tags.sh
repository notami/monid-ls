#!/bin/bash
# Script name: strip-tags.sh
# Original Author: Ian of DarkStarShout Blog
# Site: http://darkstarshout.blogspot.com/
# Options slightly modified to liking of SavvyAdmin.com

oktags="TALB APIC TCON TPE1 TPE2 TPE3 TIT2 TRCK TYER TCOM TPOS"

indexfile=`mktemp`

#Determine tags present:
find . -iname "*.mp3" -exec eyeD3 --no-color -v {} \; > $indexfile
tagspresent=`sort -u $indexfile | awk -F\): '/^<.*$/ {print $1}' \
| uniq | awk -F\)\> '{print $1}' | awk -F\( '{print $(NF)}' \
| awk 'BEGIN {ORS=" "} {print $0}'`

rm $indexfile

#Determine tags to strip:
tostrip=`echo -n $tagspresent $oktags $oktags \
| awk 'BEGIN {RS=" "; ORS="\n"} {print $0}' | sort | uniq -u \
| awk 'BEGIN {ORS=" "} {print $0}'`

#Confirm action:
echo
echo The following tags have been found in the mp3s:
echo $tagspresent
echo These tags are to be stripped:
echo $tostrip
echo
echo -n Press enter to confirm, or Ctrl+C to cancel...
read dummy

#Strip 'em
stripstring=`echo $tostrip \
| awk 'BEGIN {FS="\n"; RS=" "} {print "--set-text-frame=" $1 ": "}'`

# First pass copies any v1.x tags to v2.3 and strips unwanted tag data.
# Second pass removes v1.x tags, since I don't like to use them.
# Without --no-tagging-time-frame, a new unwanted tag is added.  :-)

find . -iname "*.mp3" \
-exec eyeD3 --to-v2.3 --no-tagging-time-frame $stripstring '{}' \; \
-exec eyeD3 --remove-v1 --no-tagging-time-frame {} \; 

echo "Script complete!"
