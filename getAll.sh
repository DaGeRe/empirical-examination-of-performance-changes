#!/bin/bash

projects=$(cat biggestJavaProjectsClean.json | jq ".[] | .full_name" | tr -d "\"")

mkdir -p projects
cd projects

for project in $projects
do
	projectFolderName=$(echo $project | awk -F'/' '{print $2}')
	if [ ! -d $projectFolderName ]
	then
		git clone --filter=tree:0 https://github.com/$project
	else
		echo "Not cloning $projectFolderName, since it is already cloned"
	fi
done

overallMap="{"


for project in $(ls | grep -v ".sh\|.json")
do
	echo "Analyzing $project"
	cd ./$project
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
       
        echo $json_output	
        if [ ! -z "$json_output" ]
	then
		overallMap="$overallMap \"$project\": $json_output,"
	fi
done
withoutLastComma=${overallMap::-1}

cd ..

echo "$withoutLastComma}" > potentialPerformanceChangingCommits.json
