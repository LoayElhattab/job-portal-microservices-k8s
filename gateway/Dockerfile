FROM nginx:1.25-alpine

# Build argument to select which environment config to bake in.
# Compose passes dev/test/prod explicitly; local Kubernetes builds use k8s by default.
# Usage: docker build --build-arg ENVIRONMENT=dev|test|prod|k8s .
ARG ENVIRONMENT=k8s

# Install curl for healthcheck
RUN apk add --no-cache curl

# Remove default config
RUN rm /etc/nginx/conf.d/default.conf

# Copy all environment configs outside nginx's active config directory.
COPY nginx.dev.conf  /tmp/nginx.dev.conf
COPY nginx.test.conf /tmp/nginx.test.conf
COPY nginx.prod.conf /tmp/nginx.prod.conf
COPY nginx.k8s.conf  /tmp/nginx.k8s.conf

# Bake only the selected config as active so nginx does not resolve every env.
RUN cp /tmp/nginx.${ENVIRONMENT}.conf /etc/nginx/conf.d/default.conf \
    && rm /tmp/nginx.*.conf

HEALTHCHECK --interval=10s --timeout=5s --retries=5 --start-period=5s \
  CMD curl -fsS http://localhost:80/health || exit 1

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
