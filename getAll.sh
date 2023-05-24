#!/bin/bash

projects=$(cat biggestJavaProjectsClean.json | jq ".[] | .full_name" | tr -d "\"")

for project in $projects
do
	git clone $project
done

overallMap="{"

for project in $(ls | grep -v ".sh\|.json")
do
	cd $project
	commit_data=$(git log --oneline | grep "performance\|slow\|fast\|optimization\|cache")
	
	map="{"
	
	while IFS= read -r line; do
	  commit_id=$(echo $line | awk '{print $1}')
	  commit_comment=${line#* }
	  escapedComment=$(echo $commit_comment | tr "\"" "'")
	  map="$map \"$commit_id\": \"$escapedComment\","
	done <<< $commit_data
	
	withoutLastComma=${map::-1}
	
	json_output=$(jq -n "$withoutLastComma}")

	echo "$json_output"
	
	cd ..
	
	overallMap="$overallMap \"$project\": $json_output,"
done
withoutLastComma=${overallMap::-1}

jq -n "$withoutLastComma}" > potentialPerformanceChangingCommits.json
