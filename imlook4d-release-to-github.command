#!/usr/bin/env bash    -x

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" # script's directory


# Get revision number
cd "$DIR"

echo "Latest tag = $(git tag --sort=-creatordate |  head -n 1)"

rev=$(zenity --list  --column "tag"  $(git tag --sort=-creatordate ))  # Tags sorted by date
rc=$?; if [[ $rc != 0 ]]; then echo 'Canceled'; exit $rc; fi  # Exit if cancelled

echo "Selected tag =  $rev"

# Switch to master
#git switch master


echo "$rev    https://github.com/JanAxelsson/imlook4d/archive/$rev.zip" > /tmp/imlook4d_release.txt
cat /tmp/imlook4d_release.txt imlook4d/latest_releases.txt > /tmp/imlook4d_added_new_release.txt
mv /tmp/imlook4d_added_new_release.txt imlook4d/latest_releases.txt
 
echo 'imlook4d/latest_releases.txt :'
head 'imlook4d/latest_releases.txt'

#git add .
#git commit -m "Release created tag = $rev"
#git push  


read -n 1 -s -r -p "DONE!  (Press any key to quit!)"
exit
