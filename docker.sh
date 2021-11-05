#!/usr/bin/env bash

if [ "$1" != "" ]; then
    IDA_RSA_FILE_PATH="$1"
else
    IDA_RSA_FILE_PATH="${HOME}/.ssh/id_rsa"
fi

if  [ ! -e $IDA_RSA_FILE_PATH ];
    then echo "key file "$IDA_RSA_FILE_PATH" did not exist, please specify correct file path."; exit;
fi


echo "using $IDA_RSA_FILE_PATH as key file"

containerName="phpstan-test"
hostUserId=$(id -u)
dockerUser=www-data

uid=$(id -u)
if [ $uid -gt 100000 ]; then
	uid=1000
fi

sed "s/\$USER_ID/$uid/g" ./docker/php/Dockerfile.dist > ./docker/php/Dockerfile

##add env file
if [ ! -e ./docker-env ]; then
    cp ./docker-env.dist ./docker-env
fi

#stop potentionally running app
docker-compose stop

##build and launch containers
docker-compose build
docker-compose up -d --force-recreate

# setup ssh
docker exec -it $containerName mkdir -p /var/www/.ssh
docker cp --follow-link $IDA_RSA_FILE_PATH $containerName:/var/www/.ssh/id_rsa
docker cp --follow-link ~/.ssh/known_hosts $containerName:/var/www/.ssh/known_hosts

# setup permissions
docker exec $containerName chown -R $dockerUser:$dockerUser /var/www
docker exec $containerName chown -R $dockerUser:$dockerUser /app

# composer selfupdate
docker exec -it $containerName composer selfupdate

#composer cache
docker exec -it $containerName mkdir -p /var/www/cache
docker exec -it $containerName chown -R www-data:www-data /var/www/cache
docker exec -it $containerName chmod -R 775 /var/www/cache

##log into the container
docker exec -it --user $dockerUser $containerName bash
docker-compose stop
