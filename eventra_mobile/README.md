# Eventra Mobile

Eventra - Event Management App

## Description

This is the mobile application for Eventra, built with Flutter. It provides event management capabilities.

## Getting Started

To run this project, you will need to have [Flutter](https://docs.flutter.dev/get-started/install) installed.

### Prerequisites

- Flutter SDK (>=3.0.0 <4.0.0)
- Dart SDK
- Laravel backend (folder: ../ems) with MySQL configured
- API URL configured for your running platform

### Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Start backend API (Laravel):
   ```bash
   cd ../ems
   php artisan migrate
   php artisan serve --host=127.0.0.1 --port=8000
   ```
4. Run the app:
   ```bash
   flutter run
   ```

### Local API URL

- Flutter Web: use http://127.0.0.1:8000/api
- Android Emulator: use http://10.0.2.2:8000/api
- iOS Simulator/Desktop: use http://127.0.0.1:8000/api

You can override with:

```bash
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8000/api
```

### Common Issues

1. CORS blocked in browser
   - Ensure backend CORS is enabled in Laravel and API is running on port 8000.

2. SQLSTATE[42S02]: Table personal_access_tokens doesn't exist
   - Run migration in backend:
     ```bash
     cd ../ems
     php artisan migrate
     ```
   - This creates Sanctum token table used by login.

## Dependencies

Some of the key libraries used in this project include:
- `http`, `dio` for networking
- `provider` for state management
- `shared_preferences` for local storage
- `flutter_dotenv` for environment configuration
- `shimmer` for loading effects
- `cached_network_image` for image caching

## Build

To build the APK for Android:
```bash
flutter build apk
```

To build for iOS:
```bash
flutter build ios
```
