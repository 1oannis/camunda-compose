# Camunda Platform 8.7 with Traefik v3.4.3

This configuration sets up Camunda Platform 8.7 with Traefik v3.4.3 as a reverse proxy, providing HTTPS access to all services with proper authentication.

## 🚀 Quick Start

1. **Run the setup script:**
   ```bash
   ./setup.sh
   ```

2. **Edit the environment file:**
   ```bash
   nano .env
   ```
   Update the following variables:
   - `HOSTNAME=yourdomain.com` (your actual domain)
   - `ACME_EMAIL=your-email@yourdomain.com` (for Let's Encrypt certificates)

3. **Start the services:**
   ```bash
   docker-compose up -d
   ```

## 🌐 Service URLs

Once deployed, your services will be available at:

- **Tasklist**: https://yourdomain.com/tasklist
- **Operate**: https://yourdomain.com/operate
- **Optimize**: https://yourdomain.com/optimize
- **Web Modeler**: https://yourdomain.com/modeler
- **Identity**: https://yourdomain.com/identity
- **Keycloak Auth**: https://yourdomain.com/auth
- **Zeebe gRPC**: grpc://zeebe.yourdomain.com:26500
- **Mailpit UI**: https://yourdomain.com/mail
- **Kibana**: https://yourdomain.com/kibana (if monitoring enabled)
- **Traefik Dashboard**: http://localhost:8080 (development only)

## 🔐 Authentication

### Default Credentials
- **Username**: demo
- **Password**: demo

### Authentication Flow
1. All services use Keycloak for authentication
2. Services are configured with Identity authentication mode
3. Cross-origin requests are properly handled with forwarded headers
4. All external URLs use HTTPS, internal communication remains HTTP

## 🔧 Configuration Details

### Traefik Configuration
- **Version**: v3.4.3
- **Entry Points**: HTTP (80) → HTTPS (443) redirect
- **TLS**: Let's Encrypt with automatic certificate generation
- **Dashboard**: Available at http://localhost:8080 (development only)

### Security Features
- **HTTPS Only**: All external access is HTTPS
- **HTTP to HTTPS Redirect**: Automatic redirection
- **Forwarded Headers**: Proper X-Forwarded-Proto and X-Forwarded-Host headers
- **Internal Communication**: HTTP within Docker networks (secure)

### Service Configuration
- **Zeebe**: gRPC exposed on port 26500, REST API via Traefik
- **Web Modeler**: WebSocket support for real-time collaboration
- **Keycloak**: Proxy forwarding enabled for proper header handling
- **All Services**: Proper issuer URLs for JWT token validation

## 📁 File Structure

```
dev-camunda-8/
├── docker-compose.yaml          # Main compose file
├── reverse-proxy.yaml           # Traefik configuration
├── base-infrastructure.yaml     # Elasticsearch, PostgreSQL
├── identity.yaml               # Keycloak, Identity
├── core-services.yaml          # Zeebe, Operate, Tasklist, Connectors
├── optimize.yaml               # Optimize service
├── web-modeler.yaml           # Web Modeler components
├── monitoring.yaml             # Kibana (optional)
├── env.sample                  # Environment variables template
├── setup.sh                    # Setup script
└── README-TRAEFIK.md          # This file
```

## 🔄 Environment Variables

### Required Variables
- `HOSTNAME`: Your domain name
- `ACME_EMAIL`: Email for Let's Encrypt certificates

### Optional Variables
- `TRAEFIK_DASHBOARD_ENABLED`: Enable Traefik dashboard (default: true)
- `TRAEFIK_DASHBOARD_INSECURE`: Allow insecure dashboard access (default: true)
- `ACME_CASERVER`: Let's Encrypt server URL (staging for testing, production for live)

### Authentication Variables
- `ZEEBE_AUTHENTICATION_MODE`: Set to 'identity' for secure access
- `MULTI_TENANCY_ENABLED`: Enable multi-tenancy (default: false)
- `RESOURCE_AUTHORIZATIONS_ENABLED`: Enable resource-based permissions (default: false)

## 🛠️ Troubleshooting

### Common Issues

1. **Certificate Issues**
   - Check that your domain points to this server
   - Verify ACME_EMAIL is set correctly
   - For testing, use staging Let's Encrypt server

2. **Authentication Problems**
   - Ensure all services are healthy: `docker-compose ps`
   - Check Keycloak logs: `docker-compose logs keycloak`
   - Verify issuer URLs are correct in service configurations

3. **WebSocket Issues**
   - Web Modeler WebSocket is available at `/modeler-ws`
   - Check browser console for connection errors
   - Verify TLS configuration for WebSocket upgrade

4. **Service Health**
   ```bash
   # Check all services
   docker-compose ps
   
   # Check specific service logs
   docker-compose logs -f [service-name]
   
   # Restart specific service
   docker-compose restart [service-name]
   ```

### Logs and Debugging
```bash
# View all logs
docker-compose logs -f

# View Traefik logs
docker-compose logs -f traefik

# View Keycloak logs
docker-compose logs -f keycloak

# Check Traefik dashboard
curl http://localhost:8080/api/http/routers
```

## 🔒 Security Considerations

### Production Deployment
1. **Disable Traefik Dashboard**: Set `TRAEFIK_DASHBOARD_ENABLED=false`
2. **Use Production Let's Encrypt**: Change `ACME_CASERVER` to production URL
3. **Strong Passwords**: Change default passwords in Keycloak
4. **Network Security**: Ensure only necessary ports are exposed
5. **Regular Updates**: Keep all images updated

### Network Security
- Internal communication uses HTTP (secure within Docker networks)
- External access requires HTTPS
- All services are protected behind Traefik
- gRPC access requires proper authentication

## 📊 Monitoring

### Available Metrics
- **Traefik**: Available at http://localhost:8080/metrics
- **Camunda Services**: Health endpoints at `/actuator/health`
- **Elasticsearch**: Available internally for logging

### Log Aggregation
- All services log to stdout/stderr
- Use `docker-compose logs` to view logs
- Consider external log aggregation for production

## 🔄 Updates and Maintenance

### Updating Services
```bash
# Pull latest images
docker-compose pull

# Update services
docker-compose up -d

# Check for updates
docker-compose images
```

### Backup and Restore
- **Volumes**: Backup `/opt/volumes/letsencrypt` for certificates
- **Databases**: Backup PostgreSQL and Elasticsearch data
- **Configuration**: Backup `.env` and configuration files

## 📞 Support

For issues specific to this Traefik configuration:
1. Check service logs
2. Verify environment variables
3. Ensure domain DNS is properly configured
4. Test with staging Let's Encrypt first

For Camunda Platform issues, refer to the official documentation:
- [Camunda Platform Documentation](https://docs.camunda.io/)
- [Traefik Documentation](https://doc.traefik.io/traefik/) 