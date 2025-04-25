# Camunda 8 Platform - Production Deployment

This directory contains a production-ready Docker Compose deployment of Camunda 8 Platform.

## Components

- **Zeebe**: Workflow engine
- **Operate**: Operations view for monitoring and managing workflow instances
- **Tasklist**: User task management interface
- **Optimize**: Process analytics and reporting
- **Identity**: User management and authentication
- **Connectors**: Integration connectors for external systems
- **Elasticsearch**: Database for workflow data
- **Keycloak**: Authentication server
- **PostgreSQL**: Database for identity services
- **Web Modeler**: BPMN and DMN modeling tool
  - Web Modeler WebApp
  - Web Modeler REST API
  - Web Modeler WebSockets
  - Web Modeler DB
  - Mailpit (for email sending)
- **Kibana** (optional): Analytics and visualization dashboard for Elasticsearch

## Directory Structure

```
docker.camunda-8/
├── bin/                        # Management scripts
│   ├── make_backup              # Script to create a backup
│   ├── restore_backup           # Script to restore from backup
├── configuration/              # Configuration files
│   ├── runtime.env              # Base environment configuration
│   ├── runtime_local_*.env      # Host-specific configuration
├── container.<component>/      # Service-specific directories
│   ├── docker-config            # Docker container configuration
│   ├── docker-entrypoint.d      # Initialization scripts
│   ├── data                     # Persisted data
│   └── rw                       # Transfer area
├── backup/                     # Backup storage
├── docker-compose.yaml         # Main Docker Compose file
├── connector-secrets.txt       # Connector secrets (SMTP, etc.)
└── README.md                   # This documentation
```

## Getting Started

1. Configure the environment in `configuration/runtime.env`
2. Create host-specific configuration in `configuration/runtime_local_$(hostname).env`
3. Start the platform with `docker-compose up -d`

## Environment Configuration

Copy the sample host configuration:

```bash
cp configuration/runtime_local_SAMPLEHOST.env configuration/runtime_local_$(hostname).env
```

Edit the host-specific file to adjust:
- Host addresses
- Passwords
- Resource allocations
- Network ports

## Deployment Options

The full deployment includes all components. For specific use cases, you can deploy a subset:

- Core components only: `docker-compose up -d zeebe operate tasklist elasticsearch`
- Without Web Modeler: Skip the web-modeler-* services
- With Kibana (for monitoring): `docker-compose --profile kibana up -d`

## Backup and Restore

### Creating a Backup

```bash
./bin/make_backup
```

Backups are stored in the `backup/` directory.

### Restoring from Backup

```bash
./bin/restore_backup backup/camunda_backup_TIMESTAMP
```

## Security Considerations

For production deployment:

1. Modify all default passwords in the configuration files
2. Configure TLS/SSL for all exposed endpoints
3. Set up network security controls
4. Implement regular backup schedules
5. Consider scaling individual components based on load

## Maintenance

- Monitor container health with `docker-compose ps`
- View logs with `docker-compose logs -f [service]`
- Update individual services with `docker-compose up -d [service]`

## Web Modeler

The Web Modeler allows you to create and edit BPMN, DMN, and Form schemas. Access it at:

```
http://${HOST}:8070
```

It uses the following components:
- Web Modeler WebApp: The user interface
- Web Modeler REST API: Backend services
- Web Modeler WebSockets: Real-time collaboration
- PostgreSQL database: Storage for models
- Mailpit: Email service for notifications 