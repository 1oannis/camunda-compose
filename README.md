# Camunda 8 Self-Managed - Docker Compose Deployment for Production Use

> [!NOTE]
>
> This deployment is based on the [Camunda 8 Self-Managed - Docker Compose](https://github.com/camunda/camunda-distributions/tree/main/docker-compose/versions/camunda-8.7) project by Camunda GmbH, licensed under the Apache License 2.0. This project extends the original deployment with additional configuration, scripts, and documentation for production use.


This is a complete Camunda 8 Self-Managed deployment using Docker Compose with all components including Web Modeler and backup capabilities.

## 🚀 Quick Start

### Prerequisites

- **Docker and Docker Compose** must be installed and up-to-date
  - **Tested with**: Docker `28.3.2` and Docker Compose `2.38.2`
  - **Minimum required**: Docker `28.0.0` and Compose `2.38.0`
  - **Note**: Older versions may work but are not guaranteed
- **Version Control**: Git must be set up to manage Docker Compose files and configurations
- **Development Environment**: Choose based on personal preferences, but should provide suitable tools for editing and testing Docker Compose files
  - **Recommended**: Visual Studio Code with extensions: `Container Tools`, `Docker`, and `YAML`
- Ports `80`, `443`, `26500` available

### Resource Requirements

| Environment     | vCPU | RAM   | Disk   |
| --------------- | ---- | ----- | ------ |
| **Minimum**     | 6    | 12 GB | 10 GB  |
| **Recommended** | 11   | 22 GB | 192 GB |
| **Production**  | 12   | 24 GB | 250 GB |

### Initial Setup

1. **Configure Environment**

   ```bash
   cp env.sample .env
   # Edit .env and set your HOSTNAME
   ```

2. **Create Required Directories**

   ```bash
   ./bin/directory_creation_util.sh
   ```

3. **Configure Host-Specific Settings**

   ```bash
   # Copy sample configuration for your hostname
   cp -r configuration/runtime_local_SAMPLEHOST configuration/runtime_local_$(grep HOSTNAME .env | cut -d'=' -f2)

   # Edit the copied configuration files to match your environment
   ```

4. **Start the Platform**

   ```bash
   ./bin/startup.sh
   ```

5. **Access Applications**
   - **Web Modeler**: https://HOSTNAME/modeler
   - **Tasklist**: https://HOSTNAME/tasklist
   - **Operate**: https://HOSTNAME/operate
   - **Optimize**: https://HOSTNAME/optimize
   - **Identity**: https://HOSTNAME/identity
   - **Keycloak**: https://HOSTNAME/auth

## 📁 File Structure & Purpose

### Core Configuration Files

| File                  | Purpose                                                       |
| --------------------- | ------------------------------------------------------------- |
| `docker-compose.yaml` | Main compose file that includes all component files           |
| `env.sample`          | Template for environment configuration                        |
| `.env`                | Your local environment configuration (create from env.sample) |

### Component Configuration Files

| File                       | Components                           | Purpose                            |
| -------------------------- | ------------------------------------ | ---------------------------------- |
| `base-infrastructure.yaml` | elasticsearch, postgres              | Core infrastructure services       |
| `identity.yaml`            | keycloak, identity                   | Authentication and user management |
| `core-services.yaml`       | zeebe, operate, tasklist, connectors | Main Camunda platform services     |
| `optimize.yaml`            | optimize                             | Process analytics and reporting    |
| `web-modeler.yaml`         | web-modeler-\* services              | Process modeling and collaboration |
| `reverse-proxy.yaml`       | traefik                              | Load balancer and SSL termination  |
| `kc-connector.yaml`        | kc-connector                         | Keycloak integration connector     |

### Persistent Data Directories

| Directory                   | Purpose               | Data Persisted                            |
| --------------------------- | --------------------- | ----------------------------------------- |
| `container.postgres/`       | PostgreSQL database   | Identity, Keycloak, and Web Modeler data  |
| `container.elasticsearch/`  | Elasticsearch         | Process data, logs, and search indices    |
| `container.zeebe/`          | Zeebe workflow engine | Process instances and workflow data       |
| `container.web-modeler-db/` | Web Modeler database  | Process models and collaboration data     |
| `container.operate/`        | Operate service       | Operational data and configurations       |
| `container.tasklist/`       | Tasklist service      | Task management data                      |
| `container.optimize/`       | Optimize service      | Analytics and reporting data              |
| `container.traefik/`        | Traefik proxy         | SSL certificates and proxy configurations |

### Configuration Directories

| Directory                        | Purpose                      |
| -------------------------------- | ---------------------------- |
| `configuration/`                 | Runtime configuration files  |
| `configuration/runtime_local_*/` | Host-specific configurations |
| `backups/`                       | Automated backup archives    |

## 🛠️ Management Scripts

### Startup & Shutdown

| Script            | Purpose            | Usage                         |
| ----------------- | ------------------ | ----------------------------- |
| `bin/startup.sh`  | Start all services | `./bin/startup.sh [options]`  |
| `bin/shutdown.sh` | Stop all services  | `./bin/shutdown.sh [options]` |

**Startup Options:**

- `-h, --help`: Show help
- `-d, --detached`: Start in background (default)
- `-f, --follow`: Start and follow logs
- `-v, --verbose`: Enable verbose output

**Shutdown Options:**

- `-h, --help`: Show help
- `-v, --volumes`: Remove volumes (default)
- `-k, --keep`: Keep volumes (preserve data)
- `-f, --force`: Force shutdown without confirmation

### Backup & Restore

| Script                  | Purpose              | Usage                               |
| ----------------------- | -------------------- | ----------------------------------- |
| `bin/make_backup.sh`    | Create system backup | `./bin/make_backup.sh [options]`    |
| `bin/restore_backup.sh` | Restore from backup  | `./bin/restore_backup.sh [options]` |
| `bin/cleanup.sh`        | Clean up old backups | `./bin/cleanup.sh [options]`        |

**Backup Options:**

- `-h, --help`: Show help
- `-d, --destination`: Backup destination (default: ./backups)
- `-n, --name`: Custom backup name
- `-f, --force`: Force backup without stopping services
- `-q, --quick`: Quick backup (skip service shutdown)
- `-v, --verbose`: Enable verbose output

**Restore Options:**

- `-h, --help`: Show help
- `-b, --backup`: Backup file to restore
- `-f, --force`: Force restore without confirmation
- `-v, --verbose`: Enable verbose output

### Utility Scripts

| Script                           | Purpose                                         |
| -------------------------------- | ----------------------------------------------- |
| `bin/directory_creation_util.sh` | Create required directories and set permissions |

## 🔧 Configuration

### Environment Variables

Key configuration files loaded in order:

1. `.env` - Main environment configuration
2. `configuration/runtime.env` - Runtime defaults
3. `configuration/runtime_local_${HOSTNAME}.env` - Host-specific overrides
4. `configuration/runtime_local_${HOSTNAME}/*.env` - Component-specific configs

### Important Variables

| Variable                          | Purpose                    | Default             |
| --------------------------------- | -------------------------- | ------------------- |
| `HOSTNAME`                        | Your domain/hostname       | camunda.example.com |
| `TIMEZONE`                        | System timezone            | Europe/Berlin       |
| `CAMUNDA_*_VERSION`               | Component versions         | Latest 8.7.x        |
| `CORS_ALLOWED_ORIGINS`            | CORS configuration         | https://${HOSTNAME} |
| `RESOURCE_AUTHORIZATIONS_ENABLED` | Enable resource-based auth | false               |
| `MULTI_TENANCY_ENABLED`           | Enable multi-tenancy       | false               |

## 📊 Services Overview

### Core Camunda Services

- **Zeebe**: Workflow engine for process orchestration
- **Operate**: Operations dashboard for monitoring and troubleshooting
- **Tasklist**: Human task management application
- **Identity**: User and client management
- **Optimize**: Advanced analytics and reporting

### Web Modeler Services

- **web-modeler-db**: PostgreSQL database for models
- **web-modeler-restapi**: Backend REST API
- **web-modeler-webapp**: Frontend web application
- **web-modeler-websockets**: Real-time collaboration
- **mailpit**: Local SMTP server for email testing

### Infrastructure Services

- **elasticsearch**: Search and analytics engine
- **postgres**: Relational database
- **keycloak**: Identity and access management
- **traefik**: Reverse proxy and load balancer
- **connectors**: Out-of-the-box system integrations

## 🔒 Security & Access

### Default Access Points

- **Web Modeler**: https://HOSTNAME/modeler
- **Tasklist**: https://HOSTNAME/tasklist
- **Operate**: https://HOSTNAME/operate
- **Optimize**: https://HOSTNAME/optimize
- **Identity**: https://HOSTNAME/identity
- **Keycloak Admin**: https://HOSTNAME/auth

### Authentication

- Uses Keycloak for centralized authentication
- Default admin credentials configured in identity.yaml
- CORS configured for secure cross-origin requests

## 💾 Data Persistence

### What's Backed Up

- All PostgreSQL databases (Identity, Keycloak, Web Modeler)
- Elasticsearch indices and data
- Zeebe process data and snapshots
- All container.\* directories with service data
- Configuration files

### Backup Strategy

- Automated backups with timestamp naming
- Pre-restore backups created automatically
- Configurable backup retention
- Quick backup option for minimal downtime

## 🚨 Troubleshooting

### Common Issues

1. **Port conflicts**: Ensure ports 80, 443, 26500 are available
2. **Resource issues**: Ensure minimum 6 vCPU, 12GB RAM, 10GB disk space
3. **Memory issues**: For production, use at least 12 vCPU, 24GB RAM, 250GB disk
4. **Permission errors**: Run `./bin/directory_creation_util.sh`
5. **SSL issues**: Check Traefik configuration and certificates

### Logs

```bash
# View all logs
docker compose logs -f

# View specific service logs
docker compose logs -f zeebe
docker compose logs -f web-modeler-webapp
```

### Health Checks

```bash
# Check service status
docker compose ps

# Check specific service health
docker compose exec zeebe zeebe-health-check
```

## 🔄 Maintenance

### Regular Tasks

1. **Backups**: Run `./bin/make_backup.sh` regularly
1. **Updates**: Update component versions in configuration files
1. **Monitoring**: Check logs and service health regularly

### Version Updates

1. Update version variables in `configuration/runtime.env`
1. Create backup before updating
1. Follow Camunda's upgrade guides

## 📚 Additional Resources

- [Camunda 8 Documentation](https://docs.camunda.io/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Traefik Documentation](https://doc.traefik.io/traefik/)
- [Camunda Platform 8 Docker Compose Repository](https://github.com/camunda/camunda-platform-docker-compose) - Base deployment version 8.7

## ⚠️ Important Notes

- **Resource Requirements**: Ensure adequate resources based on your environment:
  - **Minimum**: 6 vCPU, 12GB RAM, 10GB disk
  - **Recommended**: 11 vCPU, 22GB RAM, 192GB disk
  - **Production**: 12 vCPU, 24GB RAM, 250GB disk
- Always backup before major changes
- Monitor resource usage, especially memory and disk space
- Keep backups in a separate location

---

> [!CAUTION]
>
> This is the product of a students bachelor's thesis and it might not be up to all requirement of your specific environment. Please use this reposity carefully with a grain of salt.
