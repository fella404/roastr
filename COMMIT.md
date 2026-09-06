# Commit Message

feat: implement authentication login flow

Full authentication system for Roastr POS app including login, token management, and role-based navigation.

## Changes

### Backend
- Add CORS middleware to Express server

### Frontend
- Add auth models (User, LoginResponse, AuthState)
- Add AuthService for API calls (login, getCurrentUser, logout)
- Add AuthProvider for state management with token expiry handling
- Update LoginPage with login logic, loading state, and error SnackBar
- Update router with auth guard (redirect based on auth state & role)
- Update main.dart to initialize auth on startup
- Update PrimaryButton to support loading text state

## Files

| New | Modified |
|-----|----------|
| `client/lib/features/auth/models/user_model.dart` | `client/lib/features/auth/screens/login_page.dart` |
| `client/lib/features/auth/models/auth_state.dart` | `client/lib/shared/widgets/primary_button.dart` |
| `client/lib/features/auth/services/auth_service.dart` | `client/lib/routing/router.dart` |
| `client/lib/features/auth/providers/auth_provider.dart` | `client/lib/main.dart` |
| | `server/src/index.js` |
