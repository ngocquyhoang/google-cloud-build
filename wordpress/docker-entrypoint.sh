#!/bin/bash

mkdir -p /root/.ssh
ssh-keyscan -H "$BUILD_HOST" >> /root/.ssh/known_hosts
echo -e $BUILD_KEY >> /root/.ssh/id_rsa
chmod 400 /root/.ssh/id_rsa

rsync --progress -avzh \
	--exclude='.git/' \
	--exclude='.git*' \
	--exclude='cloudbuild.yml' \
	--exclude='readme.md' \
	-e "ssh -i /root/.ssh/id_rsa" \
	--rsync-path="sudo rsync" . $BUILD_USER@$BUILD_HOST:$BUILD_PATH

ssh -i /root/.ssh/id_rsa \
	-t $BUILD_USER@$BUILD_HOST \
	"sudo chown -R $BUILD_USER:$BUILD_USER $BUILD_PATH"

ssh -i /root/.ssh/id_rsa \
	-t $BUILD_USER@$BUILD_HOST \
	"sudo chmod 777 -R $BUILD_PATH"
