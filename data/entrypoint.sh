#!/bin/sh

set -e

echo "Starting the nginx"

/usr/sbin/nginx

if [ -z "$1" ]
then
    /bin/bash
else
	exec "$@"
fi