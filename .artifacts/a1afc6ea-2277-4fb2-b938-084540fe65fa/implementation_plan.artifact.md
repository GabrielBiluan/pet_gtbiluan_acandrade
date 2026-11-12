# Plan: Align 100% App with Reference UI and 4-Tab Layout

Updating the app to precisely match the user's reference screenshots and requirements (4 bottom tabs, Month navigation header, specific UI headers and layout).

## User Review Required

> [!IMPORTANT]
> - **4 Bottom Navigation Tabs**: `Spending`, `Transactions`, `Categories`, `Settings`.
> - **Month Selector Header**: "November" (or current month) with `<` and `>` arrow navigation across Spending and Transactions.
> - **Transactions Tab**: Matches reference UI with individual expense rows, category icons, dates, amounts, and top actions (`Sort`, `Export`, `Edit`, `+`).
> - **Spending Tab**: Month selector, "Show Spending" (Daily, Weekly, Monthly, Yearly), Total Expenses summary, and category breakdown.
> - **Settings Tab**: Account info, logout, color palette info.

## Proposed Changes

### [NEW / UPDATE] [lib/screens/settings_screen.dart](file:///C:/Users/USER/StudioProjects/pet_gtbiluan_acandrade/lib/screens/settings_screen.dart)
- Dedicated Settings tab with user profile, theme preferences, and logout option.

### [UPDATE] [lib/screens/spending_screen.dart](file:///C:/Users/USER/StudioProjects/pet_gtbiluan_acandrade/lib/screens/spending_screen.dart)
- Add Month navigation header ("November" with `<` and `>`), integration with selected month filtering, and "Show Spending" dropdown.

### [UPDATE] [lib/screens/transactions_screen.dart](file:///C:/Users/USER/StudioProjects/pet_gtbiluan_acandrade/lib/screens/transactions_screen.dart)
- Add Month navigation header ("November" with `<` and `>`), `Sort` and `Export` actions, and reference-style transaction list items.

### [UPDATE] [lib/screens/main_container_screen.dart](file:///C:/Users/USER/StudioProjects/pet_gtbiluan_acandrade/lib/screens/main_container_screen.dart)
- 4 bottom tabs: `Spending`, `Transactions`, `Categories`, `Settings`.

## Verification Plan

### Automated Tests
- Run `flutter analyze` to ensure zero compilation errors.

### Manual Verification
- Test all 4 tabs, month navigation (`< >`), spending filters, transaction CRUD, and settings.
