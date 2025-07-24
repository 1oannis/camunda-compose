#!/bin/bash

docker compose --env-file .env \
  --env-file configuration/runtime.env \
  --env-file configuration/runtime_local_${HOSTNAME:-SAMPLEHOST}.env \
  --env-file configuration/runtime_local_${HOSTNAME:-SAMPLEHOST}/base-infrastructure.env \
  --env-file configuration/runtime_local_${HOSTNAME:-SAMPLEHOST}/identity.env \
  --env-file configuration/runtime_local_${HOSTNAME:-SAMPLEHOST}/core-services.env \
  --env-file configuration/runtime_local_${HOSTNAME:-SAMPLEHOST}/web-modeler.env \
  up -d
