# Plan: Reduce App to 50% Finished (Core Basic Necessities)

Simplifying the Personal Expense Tracker to 50% completion as requested, keeping basic core functionality intact and fully working.

## User Review Required

> [!IMPORTANT]
> - **Retained Features (50%)**:
>   - Firebase Authentication (Login & Register)
>   - Simple Expense Model & Firestore Service (Add expense, display list with `StreamBuilder`, delete expense)
>   - Basic Home/Dashboard Screen with Total Expenses and Expense List (`ListView`)
>   - Simple Add Expense form (`Form`, `TextFormField`, `ElevatedButton`)
> - **Simplified/Removed Features**:
>   - Separate Categories management screen & category icon URLs
>   - Advanced filters (Daily/Weekly/Monthly/Yearly dropdown) and search
>   - Receipt image upload & advanced selection controls (Switch, Radio)

## Proposed Changes

### [MODIFY] [lib/screens/main_container_screen.dart](file:///C:/Users/USER/StudioProjects/pet_gtbiluan_acandrade/lib/screens/main_container_screen.dart)
- Simplify navigation to a single core Home screen showing total expenses and list of transactions, plus logout.

### [REMOVE / SIMPLIFY]
- Streamline screens to focus solely on authentication, basic expense addition, and real-time expense list display.

## Verification Plan

### Automated Tests
- Run `flutter analyze` to ensure zero compilation errors.

### Manual Verification
- Test login/registration.
- Test adding an expense and viewing it in the real-time list (`StreamBuilder`).
