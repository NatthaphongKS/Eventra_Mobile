# Eventra Mobile

Eventra Mobile is a Flutter application for event management with Firebase backend integration.

## Features

- Firebase Authentication (sign in/sign up/sign out)
- Event listing by status (Upcoming, Ongoing, Done)
- Create and manage events
- Event detail and event search
- Guest check-in tracking per event
- Adaptive launcher icon setup for Android and launcher icon for iOS

## Tech Stack

- Flutter (Material 3)
- Firebase Core
- Firebase Authentication
- Cloud Firestore

## Project Structure

```text
lib/
	main.dart
	firebase_options.dart
	View/
		login.dart
		register.dart
		home_screen.dart
		event_form_screen.dart
		event_detail_screen.dart
		event_checkin_screen.dart
		search_screen.dart
		forgot_password.dart
	models/
		events.dart
	widgets/
		event_card.dart
	utils/
		app_theme.dart
```

## Prerequisites

- Flutter SDK installed
- Dart SDK compatible with the constraint in `pubspec.yaml`:
	- `sdk: ^3.11.1`
- Android Studio / Xcode (depending on target platform)
- Firebase project configured for your app

## Setup

1. Clone repository and enter project folder.
2. Install dependencies.
3. Run app.

```bash
cd eventra_mobile2
flutter pub get
flutter run
```

## Firebase Configuration

This project already includes Firebase setup files:

- `lib/firebase_options.dart`
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist` (if needed, add from Firebase Console)

If you need to reconfigure Firebase:

1. Install FlutterFire CLI.
2. Run `flutterfire configure`.
3. Replace generated `lib/firebase_options.dart`.
4. Ensure platform config files are present for Android/iOS.

## Launcher Icon

Launcher icon is configured in `pubspec.yaml` via `flutter_launcher_icons`:

- Source image: `assets/image/clicknextIcon.png`
- Android adaptive icon: enabled
- iOS icon generation: enabled

Regenerate icons:

```bash
dart run flutter_launcher_icons
```

## Common Commands

```bash
# Install dependencies
flutter pub get

# Run app on connected device/emulator
flutter run

# Analyze code
flutter analyze

# Run tests
flutter test

# Build APK (release)
flutter build apk --release
```

## Notes

- Display app name is set to **Eventra Mobile**.
- Package/bundle identifiers are intentionally unchanged to avoid affecting signing and Firebase mapping.

## Troubleshooting

- If analyzer still shows stale file-name warnings after file renaming, restart Dart Analysis Server or reload VS Code window.
- If dependency resolution fails, verify your Flutter/Dart version meets `pubspec.yaml` constraints.

## License

This project is for educational/development
