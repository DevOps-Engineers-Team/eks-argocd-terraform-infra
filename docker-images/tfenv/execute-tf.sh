#!/bin/bash

aws sts get-caller-identity

git config --global credential.helper \
    '!f() { echo username=GIT_USERNAME; echo "password=$GIT_PAT"; };f'

tfenv install $TF_VERSION
tfenv use $TF_VERSION
tfenv list

git clone "https://${GIT_USERNAME}@github.com/${GIT_REPO}.git"
cd $REPO_PATH
git checkout $GIT_REVISION
terraform init
$(echo $TF_COMMAND)

