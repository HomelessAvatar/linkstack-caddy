# syntax=docker/dockerfile:1
ARG PHP_VERSION=8.4

# Step 1: Extract official Caddy binary
FROM caddy:2-alpine AS caddy-bin

# Step 2: Download LinkStack Release
FROM alpine:3.21 AS linkstack-src
ARG LINKSTACK_VERSION=v4.8.6
RUN apk add --no-cache curl unzip && \
    curl -fsSL -o /tmp/linkstack.zip "https://github.com/LinkStackOrg/LinkStack/releases/download/${LINKSTACK_VERSION}/linkstack.zip" && \
    mkdir -p /htdocs-src && \
    unzip -q /tmp/linkstack.zip -d /htdocs-src && \
    rm /tmp/linkstack.zip

# Step 3: Build LinkStack Caddy Image
FROM php:${PHP_VERSION}-fpm-alpine

LABEL org.opencontainers.image.title="LinkStack Caddy"
LABEL org.opencontainers.image.description="Ultra-lightweight, high-performance LinkStack link-in-bio image powered by Alpine Linux, PHP 8.4-FPM, and Caddy v2 with HTTP/3 support."
LABEL org.opencontainers.image.source="https://github.com/HomelessAvatar/linkstack-caddy"
LABEL org.opencontainers.image.licenses="GPL-3.0-or-later"

# Install runtime & build dependencies for PHP extensions
RUN apk add --no-cache \
    bash \
    curl \
    tzdata \
    ca-certificates \
    su-exec \
    freetype \
    libjpeg-turbo \
    libpng \
    libwebp \
    libzip \
    icu-libs \
    freetype-dev \
    libjpeg-turbo-dev \
    libpng-dev \
    libwebp-dev \
    libzip-dev \
    icu-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install -j$(nproc) gd zip intl bcmath pdo_mysql \
    && apk del freetype-dev libjpeg-turbo-dev libpng-dev libwebp-dev libzip-dev icu-dev \
    && rm -rf /var/cache/apk/* /tmp/*

# Copy Caddy binary from caddy-bin stage
COPY --from=caddy-bin /usr/bin/caddy /usr/bin/caddy

# Copy LinkStack source code template
COPY --from=linkstack-src /htdocs-src /htdocs-template

# Copy configurations
COPY Caddyfile /etc/caddy/Caddyfile
COPY config/php.ini /usr/local/etc/php/conf.d/custom.ini
COPY config/fpm-pool.conf /usr/local/etc/php-fpm.d/zz-custom.conf
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh && \
    mkdir -p /htdocs /etc/caddy /var/log/caddy && \
    chown -R www-data:www-data /htdocs /var/log/caddy

WORKDIR /htdocs
EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]
