# ecommerce_project

Flutter e-commerce app with Firebase and environment-based configuration.

## Firebase Environment Setup

This project uses `--dart-define-from-file` so Firebase values are not hardcoded in `lib/firebase_options.dart`.

### 1) Create local env files

Use the provided templates:

- `env/dev.example.json`
- `env/prod.example.json`

Copy and rename them to local files (these are ignored by git):

```bash
cp env/dev.example.json env/dev.json
cp env/prod.example.json env/prod.json
```

Fill each file with your Firebase project values.

### 2) Run with a selected environment

Development:

```bash
flutter run --dart-define-from-file=env/dev.json
```

Production-like local run:

```bash
flutter run --release --dart-define-from-file=env/prod.json
```

## Notes

- Firebase config values are client configuration values; they are still distributed with the app build.
- Keeping them out of source code helps team workflows and avoids accidental commits of environment-specific config.
