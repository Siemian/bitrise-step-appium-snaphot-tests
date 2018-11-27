#!/bin/bash
# install required package
npm install -g pixelmatch

# Check for optional params

if [ -z "$export_failed_artifacts" ]; then
	export_failed_artifacts=true
fi

if [ -z "$match_threshold" ]; then
	match_threshold=0.0
fi

originals=()
cd $screenshots_directory

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
	command=`pixelmatch $file $screenshot $resultFile 0.1`
	matchResult=`echo $command | sed 's/.*error: \([0-9.]*\).*/\1/'`

	if [ 1 -eq "$(echo "${match_threshold} >= ${matchResult}" | bc)" ]; then  
	    echo "Successful match for $screenshot"
	else
		echo "Match for $screenshot failed with error rate: $matchResult%"
		failed+=($resultFile)
	fi
done

# If all matches succeeded return with success.
if [[ ${#failed[@]} == 0 ]]; then 
	exit 0
fi

if [[ $export_failed_artifacts = true ]]; then 
	newDir=$BITRISE_DEPLOY_DIR/$one
	for one in "${failed[@]}"
	do 
		mv $one $newDir
	done
fi

exit 1

