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
# Using the stable branch ensures reliability
RUN git clone https://github.com/flutter/flutter.git -b stable /opt/flutter

# Set up Flutter binary paths
ENV PATH="/opt/flutter/bin:/opt/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Run doctor and pre-download development binaries
RUN flutter doctor -v

# Set working directory for our application
WORKDIR /app

# Copy dependency configuration files first to optimize layer caching
COPY pubspec.yaml pubspec.lock ./

# Fetch project dependencies
RUN flutter pub get

# Copy the complete source code
COPY . .

# Clean existing generated files to force a clean full build inside Docker
RUN find lib/ -name "*.freezed.dart" -delete && find lib/ -name "*.g.dart" -delete

# Compile model generation scripts and build-runners
RUN flutter pub run build_runner build --delete-conflicting-outputs

# Compile the Flutter Web application for production release
RUN flutter build web --release

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
