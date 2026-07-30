# ==========================================
# STAGE 1: Build the Flutter Web Application
# ==========================================
FROM debian:bookworm-slim AS build-env

# Install dependencies required by Flutter
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*

# Clone the stable Flutter SDK from the official repository
# Pin to a specific version for reproducible builds
RUN git clone https://github.com/flutter/flutter.git -b 3.29.3 /opt/flutter

# Set up Flutter binary paths
ENV PATH="/opt/flutter/bin:/opt/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Set working directory for our application
WORKDIR /app

# Copy dependency configuration files first to optimize layer caching
COPY pubspec.yaml pubspec.lock ./

# Fetch project dependencies
RUN flutter pub get

# Copy the complete source code
COPY . .

# Clean existing generated files and rebuild with build_runner in a single layer
RUN find lib/ -name "*.freezed.dart" -delete && find lib/ -name "*.g.dart" -delete \
    && flutter pub run build_runner build --delete-conflicting-outputs

# Declare build-time secrets (passed via docker-compose build args or --build-arg)
# These values are injected into the compiled Dart binary and are not stored in source code.
ARG FIREBASE_API_KEY
ARG FIREBASE_APP_ID
ARG FIREBASE_MESSAGING_SENDER_ID
ARG FIREBASE_PROJECT_ID
ARG FIREBASE_AUTH_DOMAIN
ARG FIREBASE_STORAGE_BUCKET

# Compile the Flutter Web application for production release
# Firebase credentials are passed via --dart-define and baked into the compiled output at build time
RUN flutter build web --release \
    --dart-define=FIREBASE_API_KEY=${FIREBASE_API_KEY} \
    --dart-define=FIREBASE_APP_ID=${FIREBASE_APP_ID} \
    --dart-define=FIREBASE_MESSAGING_SENDER_ID=${FIREBASE_MESSAGING_SENDER_ID} \
    --dart-define=FIREBASE_PROJECT_ID=${FIREBASE_PROJECT_ID} \
    --dart-define=FIREBASE_AUTH_DOMAIN=${FIREBASE_AUTH_DOMAIN} \
    --dart-define=FIREBASE_STORAGE_BUCKET=${FIREBASE_STORAGE_BUCKET}

# ==========================================
# STAGE 2: Serve the Static Assets with Nginx
# ==========================================
FROM nginx:alpine

# Copy custom Nginx routing rules to support GoRouter SPA path rewrites
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy compiled static assets from the builder stage
COPY --from=build-env /app/build/web /usr/share/nginx/html

# Copy project images (static assets outside pubspec.yaml)
COPY --from=build-env /app/web/project_images /usr/share/nginx/html/project_images

# Expose port 80 for traffic
EXPOSE 80

# Run Nginx in foreground mode
CMD ["nginx", "-g", "daemon off;"]
