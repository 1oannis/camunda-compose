# docker.keycloak

Dockerized Keycloak based on configuration information by LDIF files.

## Synopsis

Environment to create an LDAP Provider based on Keycloak software.

## Motivation
        
Easy setup of an LDAP provider to act independantly from any other databases.

## Getting started

As preparation, a common network infrastructure with the named networks ````frontend```` is expected.


For an initial start from scratch based on a cloned repository, just start with:

````
git clone --recurse-submodules git@gitlab.smile.de:Group-HKA/docker.keycloak.git
cd docker.keycloak

# Create the necessary configuration files (copy and take a look into SAMPLE files):
mkdir ./configuration/runtime_local_${HOSTNAME}/
cp -pv ./configuration/runtime_local_SAMPLEHOST/* ./configuration/runtime_local_${HOSTNAME}/
cp ./configuration/runtime_local_SAMPLEHOST.env ./configuration/runtime_local_${HOSTNAME}.env

# Create a common network
docker network create frontend
docker network create backend
# Starting the configuration container
docker compose up --detach
````

Usual Keycloak connectivity is provided on host ports 8080/TCP and 8443/TCP.

## Test and Deploy

Take a look onto the admin GUI at https://${HOSTNAME}:8443/admin

For debugging, use the environment variable KEYCLOAK_DEVMODE to non-empty value
which will be interpreted by the startup scripts to start in development mode,
which is the easiest way to try Keycloak from a container for development or testing purposes.
The GUI in that case will be available at http://${HOSTNAME}:8080/

````
docker compose down
(export KEYCLOAK_DEVMODE=1; docker compose up --build --detach)
docker compose logs -f
````

## API Reference

There are parameters as files to adapt the container:
- kc_admin_user.txt
- kc_admin_password.txt

- kc_hostname.txt
- kc_cert.pem
- kc_key.pem

- keycloak.conf

- postgres_db.txt
- postgres_user.txt
- postgres_password.txt
- postgres_initdb_args.txt

- RUNTIME_HTTP_PROXY
- RUNTIME_HTTPS_PROXY
- DOCKER_PORT_KEYCLOAK_HTTP
- DOCKER_PORT_KEYCLOAK_HTTPS
- DOCKER_NETWORK_FRONTEND

More general, the underlying software version can be changed by defining an argument
````KEYCLOAK_TAG````
within an appropriate file docker-compose.yml.

## Source

To fetch the original repository content, please use:
````
git clone --recurse-submodules git@gitlab.smile.de:Group-HKA/docker.keycloak.git
````
This will lead to a directory structure like:
````
.
|-- Dockerfile.keycloak         => Docker build definition
|-- LICENSE
|-- README.md                   => THIS file.
├── bin				=> Docker Host Scripts
├── configuration		=> Configuration files
│   ├── runtime.env		=> Host-independant configuration file
│   ├── runtime.env		=> Host-independant configuration file
│   ├── runtime_local_SAMPLEHOST.env	=> Sample host-specific configuration file
│   └── runtime_local_SAMPLEHOST	=> Directory with additional sample configuration files i.e. secrets
├── container.keycloak
│   ├── docker-config		=> Docker Container Healthcheck
│   ├── docker-entrypoint.d     => Docker Container initialization scripts (shell)
│   └── rw			=> Transfer area (written by container)
├── docker-compose.yml          ==> Global configuration file
└── README.md                   ==> This file
````

## Contributors

Guenther Schreiner <guenther.schreiner@smile.de>

## License

The GNU General Public License v3.0

