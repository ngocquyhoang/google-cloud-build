#!/bin/bash

mkdir -p /root/.ssh
ssh-keyscan -H "$BUILD_HOST" >> /root/.ssh/known_hosts
echo -e $BUILD_KEY >> /root/.ssh/id_rsa
chmod 400 /root/.ssh/id_rsa

if [ $? -eq 0 ]
then
	echo $'\n' "------ CONFIG SUCCESSFUL! ---------------------" $'\n'
else
	echo $'\n' "------ CONFIG FAILED! -------------------------" $'\n'
	exit 1
fi

cd /workspace

composer global require hirak/prestissimo
composer install --no-dev

rsync --progress -avzh \
	--exclude='.git/' \
	--exclude='.git*' \
	--exclude='cloudbuild.yml' \
	--exclude='.editorconfig' \
	--exclude='.styleci.yml' \
	--exclude='readme.md' \
	-e "ssh -i /root/.ssh/id_rsa" \
	--rsync-path="sudo rsync" . $BUILD_USER@$BUILD_HOST:$BUILD_PATH

if [ $? -eq 0 ]
then
	echo $'\n' "------ SYNC SUCCESSFUL! -----------------------" $'\n'
	echo $'\n' "------ RELOADING PERMISSION -------------------" $'\n'

	ssh -i /root/.ssh/id_rsa \
		-t $BUILD_USER@$BUILD_HOST \
		"sudo chown -R $BUILD_OWNER:$BUILD_OWNER $BUILD_PATH"

	ssh -i /root/.ssh/id_rsa \
		-t $BUILD_USER@$BUILD_HOST \
		"sudo chmod 775 -R $BUILD_PATH"

	ssh -i /root/.ssh/id_rsa \
		-t $BUILD_USER@$BUILD_HOST \
		"sudo chmod 775 -R $BUILD_PATH/storage"

	ssh -i /root/.ssh/id_rsa \
		-t $BUILD_USER@$BUILD_HOST \
		"sudo chmod 775 -R $BUILD_PATH/public"

	echo $'\n' "------ CONGRATS! DEPLOY SUCCESSFUL!!! ---------" $'\n'
	exit 0
else
	echo $'\n' "------ DEPLOY FAILED! -------------------------" $'\n'
	exit 1
fi
