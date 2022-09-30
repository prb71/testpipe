#!/bin/bash
# Exit if any of the intermediate steps fail
set -xe
sonar_url=$1
sonar_user_name=$2
sonar_password=$3
repo_password=$4
repo_name=$5
service_name=$6
repo_username=$7
programming_language=$8
repo_type=$9

echo "clonning project repository"
if [ $repo_type == "github" ]; then
 git clone https://$repo_username:$repo_password@bitbucket.org/myacc/$repo_name.git /tmp/$service_name
elif [ $repo_type == "azure" ]; then
 git clone https://$repo_username:$repo_password@dev.azure.com/kuberdigitech/Kuber%20Platform/_git/$repo_name /tmp/$service_name
else
 git clone https://$repo_password@github.com/$repo_username/$repo_name.git /tmp/$service_name
fi

echo "downloding sonar scanner" 
wget -q https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.7.0.2747-linux.zip
unzip  -q  sonar-scanner-cli-4.7.0.2747-linux.zip
export PATH="./sonar-scanner-4.7.0.2747-linux/bin:$PATH"

if [ $programming_language = "dotnet" ]; then
  echo "Running sonar scanner with sonar username=$sonar_user_name password=$sonar_password ........"
#   cd /tmp/$service_name
  dotnet-sonarscanner begin /k:$service_name /d:sonar.host.url=http://"$sonar_url" /d:sonar.projectBaseDir=/tmp/"$service_name"  /n:"$service_name" /d:sonar.login="$sonar_user_name"  /d:sonar.password="$sonar_password"
  dotnet build /tmp/$service_name
  dotnet-sonarscanner end  /d:sonar.login="$sonar_user_name"  /d:sonar.password="$sonar_password"
elif [ $programming_language = "java" ]; then
  echo "Running sonar scanner with sonar username=$sonar_user_name password=$sonar_password ........"
  mvn clean verify sonar:sonar -Dsonar.projectName="$service_name" -Dsonar.projectKey="$service_name" -Dsonar.projectBaseDir=/tmp/"$service_name" -Dsonar.sources=/tmp/"$service_name" -Dsonar.host.url=http://"$sonar_url" -Dsonar.login="$sonar_user_name" -Dsonar.password="$sonar_password"
else
  echo "Running sonar scanner with sonar username=$sonar_user_name password=$sonar_password ........"
  sonar-scanner  -Dsonar.projectBaseDir=/tmp/"$service_name" -Dsonar.sources=/tmp/"$service_name"  -Dsonar.projectName="$service_name" -Dsonar.login="$sonar_user_name" -Dsonar.password="$sonar_password"  -Dsonar.projectKey="$service_name" -Dsonar.host.url=http://"$sonar_url"
fi
