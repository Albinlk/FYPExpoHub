# fyp_expo_hub

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Docker Deployment

To build and run the web application container locally or on a server using Docker Compose:

```bash
# Build and start the container in detached mode
docker compose up -d --build

# View logs
docker compose logs -f

# Stop the container
docker compose down
```

The application will be accessible at `http://localhost:8080` by default.

