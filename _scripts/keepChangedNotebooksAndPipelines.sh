#!/bin/bash
set -x
env=$1
echo $env


git tag

if [ "$env" == "dev" ]
then
  refTag="origin/main"
elif [ "$env" == "stg" ]
then
  refTag=$(git tag -l   --sort=-creatordate  | grep -e 'stg[0-9].[0-9].[0-9]'|head -n1)
else
  refTag=$(git tag -l   --sort=-creatordate  | grep -e 'v[0-9].[0-9].[0-9]'|head -n1)
fi


changed_files=$(git diff --name-only $refTag)

mkdir notebooks_to_deploy
mkdir pipelines_to_deploy
mkdir triggers_to_deploy

for file in $changed_files; do
  echo $file
  if [[ $file =~ workspace/notebook/.* ]]; then
    cp $file notebooks_to_deploy
    echo "Adding notebook for deployment: $file"
  fi
  if [[ $file =~ workspace/pipeline/.* ]]; then
    cp $file pipelines_to_deploy
    echo "Adding pipeline for deployment: $file"
  fi
  if [[ $file =~ workspace/trigger/.* ]]; then
    cp $file triggers_to_deploy
    echo "Adding trigger for deployment: $file"
  fi
done

rm -r workspace/notebook/*
rm -r workspace/pipeline/*
rm -r workspace/trigger/*

cp notebooks_to_deploy/* workspace/notebook
cp pipelines_to_deploy/* workspace/pipeline
cp triggers_to_deploy/* workspace/trigger

rm -r notebooks_to_deploy
rm -r pipelines_to_deploy
rm -r triggers_to_deploy

