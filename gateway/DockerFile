FROM nginx:1.25-alpine

# Build argument to select which environment config to bake in
# Usage: docker build --build-arg ENVIRONMENT=dev|test|prod .
ARG ENVIRONMENT=prod

# Install curl for healthcheck
RUN apk add --no-cache curl

# Remove default config
RUN rm /etc/nginx/conf.d/default.conf

# Copy all environment configs
COPY nginx.dev.conf  /etc/nginx/conf.d/nginx.dev.conf
COPY nginx.test.conf /etc/nginx/conf.d/nginx.test.conf
COPY nginx.prod.conf /etc/nginx/conf.d/nginx.prod.conf

# Bake the correct config as the active one at build time
RUN cp /etc/nginx/conf.d/nginx.${ENVIRONMENT}.conf /etc/nginx/conf.d/default.conf

HEALTHCHECK --interval=10s --timeout=5s --retries=5 --start-period=5s \
  CMD curl -fsS http://localhost:80/health || exit 1

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]