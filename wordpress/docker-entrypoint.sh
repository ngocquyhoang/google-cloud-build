#!/bin/bash

mkdir -p ~/.ssh
ssh-keyscan -H "$BUILD_HOST" >> ~/.ssh/known_hosts
echo -e $BUILD_KEY >> ~/.ssh/id_rsa
chmod 400 ~/.ssh/id_rsa

if [ $? -eq 0 ]
then
	echo $'\n' "------ CONFIG SUCCESSFUL! ---------------------" $'\n'
else
	echo $'\n' "------ CONFIG FAILED! -------------------------" $'\n'
	exit 1
fi

cd /workspace

rsync --progress -avzh \
	--exclude='.git/' \
	--exclude='.git*' \
	--exclude='cloudbuild.yml' \
	--exclude='readme.md' \
	-e "ssh -i ~/.ssh/id_rsa" \
	--rsync-path="rsync" . $BUILD_USER@$BUILD_HOST:$BUILD_PATH

if [ $? -eq 0 ]
then
	echo $'\n' "------ SYNC SUCCESSFUL! -----------------------" $'\n'
	echo $'\n' "------ RELOADING PERMISSION -------------------" $'\n'

	ssh -i ~/.ssh/id_rsa \
		-t $BUILD_USER@$BUILD_HOST \
		"sudo chown -R $BUILD_USER:$BUILD_USER $BUILD_PATH"

	ssh -i ~/.ssh/id_rsa \
		-t $BUILD_USER@$BUILD_HOST \
		"sudo chmod 777 -R $BUILD_PATH"

	echo $'\n' "------ CONGRATS! DEPLOY SUCCESSFUL!!! ---------" $'\n'
	exit 0
else
	echo $'\n' "------ DEPLOY FAILED! -------------------------" $'\n'
	exit 1
fi
