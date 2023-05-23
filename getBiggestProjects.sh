#!/bin/bash

RESULTS_PER_PAGE=100
TOTAL_PAGES=10

excluded="doocs/advanced-java ityouknow/spring-boot-examples GrowingGit/GitHub-Chinese-Top-Charts geekxh/hello-algorithm gyoogle/tech-interview-for-developer macrozheng/mall-swarm lihengming/spring-boot-api-project-seed dyc87112/SpringBoot-Learning JeffLi1993/springboot-learning-example hollischuang/toBeTopJavaer eugenp/tutorials TheAlgorithms/Java Snailclimb/JavaGuide"

overallMap="["

for ((page=1; page <= TOTAL_PAGES; page++)); do
  url="https://api.github.com/search/repositories?q=stars:>1000+language:Java&type=repositories&ref=advsearch&s=stars&o=desc&per_page=$RESULTS_PER_PAGE&page=$page"
  response=$(curl -s -H "Authorization: Bearer $ACCESS_TOKEN" "$url")

  echo $url

  #echo $response
  # Example: Extract repository names from response
  repository_names=$(echo "$response" | jq -r '[.items[] | {full_name: .full_name, stargazers_count: .stargazers_count}]')
  for name in $repository_names
  do
  	isInExcluded=$(echo $excluded | grep -w -q $name)
  	if [ ! $isInExcluded ]
  	then
  		echo -n "$name "
  	fi
  done
  echo
  
  echo "Page $page: $repository_names"
  
  cleanedNames=$(echo $repository_names | tr -d "\[\]")
  overallMap="$overallMap $cleanedNames,"
done

withoutLastComma=${overallMap::-1}

echo "$withoutLastComma]"
jq -n "$withoutLastComma]" > biggestJavaProjects.json
