#!/usr/bin/env bash

#build from app's local Dockerfile
sudo docker-compose build

sudo `< .env` docker-compose push
