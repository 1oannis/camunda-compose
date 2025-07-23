#! /bin/bash
echo "--------------------------------"
echo "Creating directories and setting permissions..."

if [ ! -d ./container.traefik/letsencrypt ]; then
  echo "Creating traefik directory..."
  sudo mkdir -p ./container.traefik/letsencrypt
fi
echo "Setting permissions for traefik directory..."
sudo chown 0:0 -R ./container.traefik
sudo chmod 600 -R ./container.traefik

if [ ! -d ./container.elasticsearch/data ]; then
  echo "Creating elasticsearch directory..."
  sudo mkdir -p ./container.elasticsearch/data
fi
echo "Setting permissions for elasticsearch directory..."
sudo chown 1000:0 -R ./container.elasticsearch
sudo chmod 700 -R ./container.elasticsearch

if [ ! -d ./container.postgres/data ]; then
  echo "Creating postgres directory..."
  sudo mkdir -p ./container.postgres/data
fi
echo "Setting permissions for postgres directory..."
sudo chown 0:0 -R ./container.postgres
sudo chmod 700 -R ./container.postgres

if [ ! -d ./container.zeebe/data ]; then
  echo "Creating zeebe directory..."
  sudo mkdir -p ./container.zeebe/data
fi
echo "Setting permissions for zeebe directory..."
sudo chown 1001:1001 -R ./container.zeebe
sudo chmod 700 -R ./container.zeebe

if [ ! -d ./container.operate/tmp ]; then
  echo "Creating operate directory..."
  sudo mkdir -p ./container.operate/tmp
fi
echo "Setting permissions for operate directory..."
sudo chown 1001:1001 -R ./container.operate
sudo chmod 700 -R ./container.operate

if [ ! -d ./container.tasklist/tmp ]; then
  echo "Creating tasklist directory..."
  sudo mkdir -p ./container.tasklist/tmp
fi
echo "Setting permissions for tasklist directory..."
sudo chown 1001:1001 -R ./container.tasklist
sudo chmod 700 -R ./container.tasklist

if [ ! -d ./container.web-modeler-db/data ]; then
  echo "Creating web-modeler-db directory..."
  sudo mkdir -p ./container.web-modeler-db/data
fi
echo "Setting permissions for web-modeler-db directory..."
sudo chown 0:0 -R ./container.web-modeler-db
sudo chmod 700 -R ./container.web-modeler-db

if [ ! -d ./container.optimize/configuration ]; then
  echo "Creating optimize directory..."
  sudo mkdir -p ./container.optimize/configuration
fi
echo "Setting permissions for optimize directory..."
sudo chown 1001:1001 -R ./container.optimize
sudo chmod 600 -R ./container.optimize

echo "Directories created and permissions set."
echo "Please run 'docker compose up -d' to start the services."
echo "--------------------------------"