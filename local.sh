#!/bin/zsh

set -ex

ENV_CONFIG=.env-local

docker-compose --env-file $ENV_CONFIG -f docker-compose-compute.yml build contour-tiles
#docker-compose --env-file $ENV_CONFIG -f docker-compose-compute.yml up
