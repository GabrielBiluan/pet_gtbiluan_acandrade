# Plan: Clean Up Comments Throughout the App

Remove unnecessary comments across all Dart files in `lib/`, keeping only concise, important documentation comments to clearly distinguish core functions and features.

## User Review Required

> [!IMPORTANT]
> - **Comment Policy**: Remove redundant or noisy comments. Retain high-level class/method documentation or key feature markers where necessary for readability.

## Proposed Changes

### Models & Services (`lib/models/`, `lib/services/`)
- Clean comments in `expense.dart`, `category_model.dart`, `auth_service.dart`, `firestore_service.dart`, `storage_service.dart`.

### Screens & Main (`lib/screens/`, `lib/main.dart`)
- Clean comments in `main.dart`, `auth_screen.dart`, `main_container_screen.dart`, `spending_screen.dart`, `transactions_screen.dart`, `categories_screen.dart`, `settings_screen.dart`, `add_edit_expense_screen.dart`.

## Verification Plan

### Automated Tests
- Run `flutter analyze` to ensure zero compilation or syntax errors.
