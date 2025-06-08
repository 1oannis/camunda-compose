# Camunda 8 Self-Managed - Docker Compose

## Usage

For end user usage, please check the offical documentation of [Camunda 8 Self-Managed Docker Compose](https://docs.camunda.io/docs/next/self-managed/setup/deploy/local/docker-compose/).

---

## Overview of Compose Files and Containers

Below is a mapping of each YAML file to the containers it deploys, along with a brief explanation of their roles:

### `base-infrastructure.yaml`
- **elasticsearch**: Search and analytics engine used by Camunda components for data storage and querying.
- **postgres**: Relational database used for identity and Keycloak data.

### `identity.yaml`
- **keycloak**: Identity and access management (IAM) server for authentication and authorization.
- **identity**: Camunda Identity service, integrates with Keycloak for user and client management.

### `core-services.yaml`
- **zeebe**: Workflow engine for orchestrating process instances.
- **operate**: Operations dashboard for monitoring and troubleshooting process instances.
- **tasklist**: User task management application for human task handling.
- **connectors**: Provides out-of-the-box connectors for integrating with external systems.

### `optimize.yaml`
- **optimize**: Advanced analytics and reporting for process and decision data.

### `web-modeler.yaml`
- **web-modeler-db**: PostgreSQL database for the Web Modeler.
- **mailpit**: Local SMTP server for email testing (used by Web Modeler).
- **web-modeler-restapi**: Backend REST API for the Web Modeler.
- **web-modeler-webapp**: Frontend web application for modeling processes.
- **web-modeler-websockets**: WebSocket server for real-time collaboration in the Web Modeler.

### `monitoring.yaml` (optional, uncomment in `docker-compose.yaml` to enable)
- **kibana**: Visualization tool for logs and metrics, used with Elasticsearch.

---

Each YAML file is included in the main `docker-compose.yaml` file, which orchestrates the full Camunda 8 Self-Managed environment for local development.

# TODO: Auth endpoint hab ich angepasst. Webmodeler funktioniert aber fast alle anderen endpunkte müssen geprüft werden wegen dem redirect. Und was genau soll /app für ein Endpunkt sein? Pls fix

# TODO: Replicate the default access when deployed with Kubernetes:
 https://docs.camunda.io/docs/self-managed/about-self-managed/

In this configuration, Camunda 8 Self-Managed can be accessed as follows:

- Identity, Operate, Optimize, Tasklist, Modeler: https://camunda.example.com/[identity|operate|optimize|tasklist|modeler]
- Web Modeler also exposes a WebSocket endpoint on https://camunda.example.com/modeler-ws. This is only used by the application itself and should not be accessed by users directly.
- Keycloak authentication: https://camunda.example.com/auth
- Zeebe Gateway: grpc://zeebe.camunda.example.com