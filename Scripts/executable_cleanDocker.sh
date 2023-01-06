#!/bin/bash

docker volume rm $(docker volume ls -f dangling=true -q)
docker rmi $(docker images --quiet --filter "dangling=true")
