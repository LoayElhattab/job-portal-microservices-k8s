# Stage 1: Build Flutter Web
FROM ghcr.io/cirruslabs/flutter:stable AS build-stage

WORKDIR /app

# Copy pubspec files and get dependencies
COPY pubspec.* ./
RUN flutter pub get

# Copy source code and build web
COPY . .
RUN flutter create --platforms=web --no-pub .
RUN flutter build web --release

# Stage 2: Serve with Nginx
FROM nginx:1.25-alpine

# Install envsubst (part of gettext package)
RUN apk add --no-cache gettext bash

# Copy build output from Stage 1
COPY --from=build-stage /app/build/web /usr/share/nginx/html

# Copy configuration and environment template
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY env.template.json /usr/share/nginx/html/env.template.json
COPY docker-entrypoint.sh /docker-entrypoint.sh

# Make entrypoint script executable
RUN chmod +x /docker-entrypoint.sh

# Expose port 80
EXPOSE 80

# Set entrypoint
ENTRYPOINT ["/docker-entrypoint.sh"]
