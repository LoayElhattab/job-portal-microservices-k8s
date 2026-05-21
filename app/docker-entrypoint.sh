#!/bin/bash
set -e

# Replace environment variables in the template
# envsubst will take GATEWAY_URL from environment and put it into env.json
envsubst < /usr/share/nginx/html/env.template.json > /usr/share/nginx/html/env.json

# Start Nginx
echo "Starting Nginx..."
exec nginx -g 'daemon off;'
