# MONVERA Ecommerce App

A modern Flutter ecommerce application with authentication, product discovery, cart management, camera capture, and Firebase Cloud Messaging integration.

## Overview

This project demonstrates a clean Flutter architecture using `Provider` for state management and a service-driven data layer built on top of `Dio`.  
It consumes the [EscuelaJS API](https://api.escuelajs.co/) for authentication and products, while Firebase is used for push messaging setup.

## Core Features

- User authentication with token persistence (`flutter_secure_storage`)
- Splash flow with auto session restore and route guard behavior
- Product listing with:
  - pagination (infinite scroll)
  - filtering by title, category, and price range
- Cart management with quantity handling and total price calculation
- Camera capture page with runtime permission handling
- Firebase Cloud Messaging setup:
  - foreground, background, and token refresh listeners
- About page powered by provider/service pattern

## Tech Stack

- Flutter (Material 3, dark theme)
- Dart SDK `^3.11.4`
- State management: `provider`
- Networking: `dio`, `http`
- Local secure storage: `flutter_secure_storage`
- Camera and permissions: `camera`, `permission_handler`
- Push notifications: `firebase_core`, `firebase_messaging`

## Project Structure

```text
lib/
  core/
    constants/
    errors/
    network/
    services/
  models/
  views/pages/
    auth/
    home/
    cart/
    profile/
    about/
    camera/
    products/
    splash/
  widgets/
```

## Getting Started

### 1) Prerequisites

- Flutter SDK installed and configured
- Dart SDK (bundled with Flutter)
- Android Studio / Xcode (for mobile platform builds)
- A Firebase project (for messaging setup)

Check your environment:

```bash
flutter doctor
```

### 2) Install dependencies

```bash
flutter pub get
```

### 3) Configure Firebase environment files

This project uses `--dart-define-from-file` so Firebase values are not hardcoded.

Use templates:

- `env/dev.example.json`
- `env/prod.example.json`

Create local files:

```bash
cp env/dev.example.json env/dev.json
cp env/prod.example.json env/prod.json
```

Fill each file with your Firebase values.

### 4) Run the app

Development:

```bash
flutter run --dart-define-from-file=env/dev.json
```

Production-like local run:

```bash
flutter run --release --dart-define-from-file=env/prod.json
```

## Platform Notes

- Android permissions are configured in `android/app/src/main/AndroidManifest.xml`
  - `POST_NOTIFICATIONS`
  - `WRITE_EXTERNAL_STORAGE`
- iOS permissions are configured in `ios/Runner/Info.plist`
  - `NSCameraUsageDescription`
  - `NSMicrophoneUsageDescription`

## Useful Commands

```bash
flutter analyze
flutter test
flutter clean
```
