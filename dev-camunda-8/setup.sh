#!/bin/bash

# Camunda Platform 8.7 Setup Script with Traefik v3.4.3
# This script helps you set up and start your Camunda Platform deployment

set -e

echo "🚀 Setting up Camunda Platform 8.7 with Traefik v3.4.3"

# Check if .env file exists
if [ ! -f .env ]; then
    echo "📝 Creating .env file from env.sample..."
    cp env.sample .env
    echo "⚠️  Please edit .env file with your actual domain and email before continuing!"
    echo "   - Set HOSTNAME to your actual domain"
    echo "   - Set ACME_EMAIL to your email for Let's Encrypt certificates"
    echo "   - For production, uncomment the production ACME server and comment out staging"
    exit 1
fi

# Check if required directories exist
echo "📁 Creating required directories..."
mkdir -p /opt/volumes/letsencrypt
mkdir -p ./.optimize
mkdir -p ./.web-modeler

# Create environment config for optimize if it doesn't exist
if [ ! -f ./.optimize/environment-config.yaml ]; then
    echo "📄 Creating Optimize environment config..."
    cat > ./.optimize/environment-config.yaml << EOF
# Optimize environment configuration
# This file can be used to configure Optimize-specific settings
EOF
fi

# Create web modeler cluster config files
echo "📄 Creating Web Modeler cluster configuration files..."

# For identity authentication mode
cat > ./.web-modeler/cluster-config-authentication-mode-identity.env << EOF
# Web Modeler cluster configuration for identity authentication mode
CAMUNDA_MODELER_CLUSTERS_0_AUTHENTICATION_MODE=identity
CAMUNDA_MODELER_CLUSTERS_0_AUTHENTICATION_URL=https://\${HOSTNAME}/auth/realms/camunda-platform
CAMUNDA_MODELER_CLUSTERS_0_AUTHENTICATION_CLIENT_ID=web-modeler
CAMUNDA_MODELER_CLUSTERS_0_AUTHENTICATION_CLIENT_SECRET=XALaRPl5qwTEItdwCMiPS62nVpKs7dL7
CAMUNDA_MODELER_CLUSTERS_0_AUTHENTICATION_AUDIENCE=web-modeler-api
EOF

# For none authentication mode
cat > ./.web-modeler/cluster-config-authentication-mode-none.env << EOF
# Web Modeler cluster configuration for no authentication mode
CAMUNDA_MODELER_CLUSTERS_0_AUTHENTICATION_MODE=none
EOF

echo "✅ Setup complete!"
echo ""
echo "🔧 Next steps:"
echo "1. Edit .env file with your actual domain and email"
echo "2. For production, update ACME_CASERVER to production URL"
echo "3. Run: docker-compose up -d"
echo ""
echo "🌐 Your services will be available at:"
echo "   - Tasklist: https://yourdomain.com/tasklist"
echo "   - Operate: https://yourdomain.com/operate"
echo "   - Optimize: https://yourdomain.com/optimize"
echo "   - Web Modeler: https://yourdomain.com/modeler"
echo "   - Identity: https://yourdomain.com/identity"
echo "   - Keycloak: https://yourdomain.com/auth"
echo "   - Zeebe gRPC: grpc://zeebe.yourdomain.com:26500"
echo "   - Traefik Dashboard: http://localhost:8080 (development only)"
echo ""
echo "🔐 Default credentials:"
echo "   - Username: demo"
echo "   - Password: demo" 