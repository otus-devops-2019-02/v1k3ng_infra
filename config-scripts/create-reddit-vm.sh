#!/bin/bash
gcloud compute instances create reddit-app \
        --machine-type=g1-small \
        --tags puma-server \
        --restart-on-failure \
	--image-family=reddit-full

