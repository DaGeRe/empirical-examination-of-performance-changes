project=$1
if [ -z "$project" ]
then
	echo "Project needs to be specified!"
fi

commits=$(cat potentialPerformanceChangingCommits.json | jq ".$project" | grep ":" | awk '{print $1}' | tr -d "\":")

mkdir -p results/$project

cd projects/$project

for commit in $commits
do

	predecessor=$(git rev-parse $commit~1)
	echo "Analyzing $commit vs $predecessor"

	git checkout $commit
	ant realclean &> ../../results/$project/$commit"_clean.txt"
	ant microbench &> ../../results/$project/$commit.txt
	git checkout $predecessor
	ant realclean &> ../../results/$project/$commit"_clean.txt"
	ant microbench &> ../../results/$project/$predecessor.txt


done
