#!/bin/bash

# Check for optional params

if [ -z "$export_failed_artifacts" ]; then
	export_failed_artifacts=true
fi

originals=()
cd $screenshots_directory
git clone git@github.com:mapbox/pixelmatch.git


# retrieve all original images that are stored
for f in *
do 
  case "$f" in
    *original*) originals+=($f);; 
  esac
done

failed=()
# check if screenshots matches original images
for file in "${originals[@]}"
do
	pattern="_original"
	screenshot=${file/$pattern/}
	resultPostfix="_result"
	resultFile=${file/$pattern/$resultPostfix}

	# remove top bar from screenshots
	convert $file -gravity North -chop 0x40 $file
	convert $screenshot -gravity North -chop 0x40 $screenshot

	# compare images using pixelmatch
	command=`$PWD/pixelmatch/bin/pixelmatch $file $screenshot $resultFile 0.1`
	matchResult=`echo $command | sed 's/.*error: \([0-9.]*\).*/\1/'`
	if [ $matchResult != "0" ]; then
		echo "Match for $screenshot failed with error rate: $matchResult%"
		failed+=($resultFile)
	fi
done

# If all matches succeeded return with success.
if [ ${#failed[@]} == 0 ]; then 
	exit 0
fi

if [ $export_failed_artifacts = true ]; then 
	newDir=$BITRISE_DEPLOY_DIR/$one
	for one in "${failed[@]}"
	do 
		mv $one $newDir
	done
fi

exit 1

