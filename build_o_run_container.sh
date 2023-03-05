#!/bin/bash

DOCKER_NAME="valgrind_tester"

if [ $# -eq 0 ]; then
    sudo docker stop $DOCKER_NAME
    sudo docker build -t $DOCKER_NAME .
    # sudo docker scan $DOCKER_NAME
    sudo docker image prune -f
elif [ $# -eq 1 ] && [ $1 == "run" ]; then
    sudo docker run -v "$(pwd)":/home/in -it --rm --name $DOCKER_NAME $DOCKER_NAME
else
    echo "USAGE:"
    echo "./$0 [run]"
    echo "or"
    echo "./$0"
fi
