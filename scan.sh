#!/bin/bash
# Exit if any of the intermediate steps fail
set -xe
sonar_url=$1
sonar_user_name=$2
sonar_password=$3
github_token=$4
github_repo_url=$5
service_name=$6
github_user_name=$7
programming_language=$8

export GITHUB_TOKEN=$github_token
## cloning code from gitrepo
echo "Setting up git credentials" && git config --global credential.helper 'store' && echo "https://$github_user_name:$github_token@github.com" > ~/.git-credentials
git clone $github_repo_url /tmp/$service_name 

# downloding sonar scanner 
wget -q https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.7.0.2747-linux.zip
unzip  -q  sonar-scanner-cli-4.7.0.2747-linux.zip
export PATH="./sonar-scanner-4.7.0.2747-linux/bin:$PATH"

if [ $programming_language = "dotnet" ]; then
  echo "Running sonar scanner with sonar username=$sonar_user_name password=$sonar_password ........"
  dotnet-sonarscanner begin /k:$service_name /d:sonar.host.url=http://"$sonar_url" /d:sonar.projectBaseDir=/tmp/"$service_name"  /n:"$service_name" /d:sonar.login="$sonar_user_name"  /d:sonar.password="$sonar_password"
  dotnet build /tmp/$service_name
  dotnet-sonarscanner end  /d:sonar.login="$sonar_user_name"  /d:sonar.password="$sonar_password"
elif [ $programming_language = "java" ]; then
  echo "Running sonar scanner with sonar username=$sonar_user_name password=$sonar_password ........"
  mvn clean -f /tmp/$service_name verify sonar:sonar -Dsonar.projectName="$service_name" -Dsonar.projectKey="$service_name" -Dsonar.projectBaseDir=/tmp/"$service_name" -Dsonar.host.url=http://"$sonar_url" -Dsonar.login="$sonar_user_name" -Dsonar.password="$sonar_password"
else
  echo "Running sonar scanner with sonar username=$sonar_user_name password=$sonar_password ........"
  sonar-scanner  -Dsonar.projectBaseDir=/tmp/"$service_name" -Dsonar.sources=/tmp/"$service_name"  -Dsonar.projectName="$service_name" -Dsonar.login="$sonar_user_name" -Dsonar.password="$sonar_password"  -Dsonar.projectKey="$service_name" -Dsonar.host.url=http://"$sonar_url"
fi
