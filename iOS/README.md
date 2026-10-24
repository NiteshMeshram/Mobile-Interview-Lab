# iOS Login & Session Management

A SwiftUI iOS sample app demonstrating authentication and session lifecycle management using **Swift, SwiftUI, async/await, URLSession, and Clean Architecture**. The app uses the DummyJSON authentication API for learning and proof-of-concept purposes.

> **Important:** DummyJSON is a demo API. This project is for learning and interview preparation, not production banking authentication.

## Goals

- Build a maintainable login flow with clear separation of concerns.
- Keep UI state in the Presentation layer and business/session rules in Domain services.
- Store authentication tokens securely using Keychain.
- Restore a session when the app launches.
- Validate token expiry and refresh tokens automatically.
- Save refreshed credentials and schedule the next refresh.
- Support testable networking and storage through mock implementations.

## Technology stack

- Swift and SwiftUI
- Swift Concurrency (`async`/`await`, `Task`, and actor-based coordination where implemented)
- `URLSession`
- Clean Architecture principles
- Keychain for secure token storage
- DummyJSON authentication endpoints
- Protocol-based dependency injection and mock implementations

## Project structure

The following tree reflects the folders and file names visible in the Xcode screenshots. Some files may contain additional implementation details not shown in the screenshots.

```text
Source/
├── Core/
├── Data/
│   ├── DTOs/
│   │   ├── LoginRequestDTO.swift
│   │   ├── LoginResponseDTO.swift
│   │   ├── RefreshTokenRequestDTO.swift
│   │   └── RefreshTokenResponseDTO.swift
│   ├── Network/
│   │   └── Protocols/
│   │       ├── APIClientProtocol.swift
│   │       ├── APIEndpoint.swift
│   │       ├── ExampleAPIClient.swift
│   │       ├── HTTPMethod.swift
│   │       ├── MockAPIClient.swift
│   │       └── RequestBuilder.swift
│   ├── Repositories/
│   │   └── AuthRepositoryImpl.swift
│   └── Storage/
│       ├── KeychainTokenStorage.swift
│       └── MockTokenStorage.swift
├── Domain/
│   ├── Models/
│   │   ├── AuthenticationState.swift
│   │   ├── AuthToken.swift
│   │   └── User.swift
│   ├── Repositories/
│   │   └── AuthRepository.swift
│   └── Services/
│       ├── JWTTokenValidator.swift
│       ├── SessionManager.swift
│       ├── SessionManagerImpl.swift
│       ├── TokenRefreshCoordinator.swift
│       ├── TokenStorage.swift
│       └── TokenValidator.swift
├── UseCases/
│   └── LoginUseCase.swift
├── Presentation/
│   ├── Authentication/
│   │   └── AuthenticatedView.swift
│   └── Login/
│       ├── LoginView.swift
│       └── LoginViewModel.swift
├── Assets/
├── ContentView.swift
└── ExampleApp.swift
```

## Architecture overview

- **Presentation:** `LoginView`, `LoginViewModel`, and `AuthenticatedView` display screens and react to authentication state.
- **Domain:** `AuthToken`, `User`, `AuthenticationState`, repository/service protocols, `LoginUseCase`, and token/session rules define the app's core behavior.
- **Data:** DTOs, `AuthRepositoryImpl`, API client implementations, request-building types, and token-storage implementations handle network and persistence details.
- **App entry point:** `ExampleApp.swift` and the app's dependency setup should create and connect the required implementations.

### Login request flow

```text
LoginView
   ↓
LoginViewModel
   ↓
LoginUseCase
   ↓
AuthRepository (protocol)
   ↓
AuthRepositoryImpl
   ↓
API client / URLSession
   ↓
DummyJSON
```

## Component responsibilities

| Component | Responsibility |
|---|---|
| `LoginView` | Login UI and user input |
| `LoginViewModel` | Coordinates UI actions and exposes state to the view |
| `LoginUseCase` | Represents the login operation |
| `AuthRepository` | Domain-level contract for authentication operations |
| `AuthRepositoryImpl` | Implements authentication requests using the API client |
| `APIClientProtocol` | Abstraction for making API requests |
| `ExampleAPIClient` | Real HTTP networking implementation |
| `MockAPIClient` | Mock networking implementation for tests/previews |
| `RequestBuilder` | Builds URL requests from endpoint and method details |
| Login/refresh DTOs | Model API request and response payloads |
| `AuthToken` | App model representing authentication token data |
| `TokenStorage` | Contract for reading, saving, and deleting tokens |
| `KeychainTokenStorage` | Secure token persistence using Keychain |
| `MockTokenStorage` | Mock token persistence for tests |
| `TokenValidator` | Contract for validating token expiry |
| `JWTTokenValidator` | JWT expiry validation implementation |
| `SessionManager` | Contract for coordinating authentication/session lifecycle |
| `SessionManagerImpl` | Concrete session lifecycle implementation |
| `TokenRefreshCoordinator` | Coordinates refresh work to help avoid duplicate concurrent refreshes |
| `AuthenticationState` | Represents the app's authentication state |
| `AuthenticatedView` | UI shown after successful authentication |
| `User` | User model used by the app |

These are the intended roles implied by the file names and architecture; confirm each role against its implementation when changing the code.

## Authentication flow

### 1. Login

1. The user enters credentials in `LoginView`.
2. `LoginViewModel` invokes `LoginUseCase`.
3. The use case calls the `AuthRepository` abstraction.
4. `AuthRepositoryImpl` sends the login request through the API client.
5. The response DTO is mapped to the app's domain model.
6. The token is saved using `TokenStorage`, implemented by `KeychainTokenStorage` in the app configuration.
7. The session state updates and the UI presents the authenticated screen.

### 2. Session restoration

When the app starts, the session manager can check whether a saved token exists and whether it is still valid.

- If the access token is valid, restore the authenticated session.
- If it is expired and a refresh token is available, attempt a refresh.
- If refresh succeeds, save the new token and continue the session.
- If a valid session cannot be established, show the login screen.

The precise behavior depends on the conditions handled in `SessionManagerImpl`.

### 3. Automatic token refresh

The refresh coordinator/session manager coordinates refresh timing using the token expiry and the configured refresh buffer. On a successful refresh, the app saves the returned token and schedules the next refresh.

Observed development log:

```text
⏰ TOKEN REFRESH: Refresh time reached
🔄 TOKEN REFRESH: Starting refresh...
🌐 API REQUEST
➡️ Method: POST
➡️ URL: https://dummyjson.com/auth/refresh
⬅️ Status Code: 200
✅ API SUCCESS
✅ TOKEN REFRESH: New token received
💾 TOKEN REFRESH: New token saved
⏰ TOKEN REFRESH: Token expires at: [runtime expiry timestamp]
⏰ TOKEN REFRESH: Refresh scheduled in: [runtime seconds]
```

This confirms that, in the observed run:

1. The scheduled refresh started.
2. `POST /auth/refresh` returned HTTP `200`.
3. A new token was received and saved.
4. The app scheduled the next refresh based on the new token expiry.

The expiry timestamp and scheduled interval are runtime values and will vary.

### 4. Logout and session cleanup

When logging out, the expected behavior is to cancel scheduled refresh work, remove saved tokens, and set authentication state to unauthenticated. Ensure a refresh already in progress cannot restore the session after logout.

## API endpoints

Base URL: `https://dummyjson.com`

| Operation | HTTP method | Endpoint |
|---|---|---|
| Login | `POST` | `/auth/login` |
| Refresh token | `POST` | `/auth/refresh` |

Use DummyJSON's current documentation for supported demo credentials and exact request/response fields. API behavior can change independently of this app.

## Networking and testability

The network layer has an `APIClientProtocol` abstraction and both `ExampleAPIClient` and `MockAPIClient`. This design makes it possible to test repository and ViewModel behavior without depending on live network responses.

`RequestBuilder`, `APIEndpoint`, and `HTTPMethod` separate request construction from the API client. DTOs keep API payload models separate from domain models.

## Security considerations

- Store tokens in Keychain, not `UserDefaults`, plain-text files, or source code.
- Never print passwords, access tokens, refresh tokens, or authorization headers. Redact sensitive fields from request/response logs.
- Use HTTPS for network traffic.
- Ensure logout clears credentials and cancels scheduled refresh work.
- Prevent overlapping refresh requests and handle logout/refresh races.
- Use bounded retry/backoff for transient network errors; do not endlessly retry invalid credentials.
- Treat client-side JWT expiry validation as a convenience, not a replacement for server-side authorization.
- DummyJSON is not suitable as a production identity provider. Production apps need an appropriate identity provider and server-side token validation, rotation/revocation, and security controls.

## Build and run

1. Open the Xcode project.
2. Select the `ExampleApp` scheme (or the scheme configured in the project).
3. Choose an iOS simulator or test device.
4. Confirm the deployment target and dependencies in the project settings.
5. Build and run.
6. Use the demo credentials supported by DummyJSON's current authentication documentation.
7. Watch the Xcode console for login and token-refresh lifecycle logs.

The screenshots do not expose the minimum iOS version, dependency manager, or exact Xcode project settings; refer to the project configuration for those details.

## Test checklist

- [ ] Successful login transitions the app to the authenticated state.
- [ ] Invalid credentials display an error without authenticating.
- [ ] A valid saved token restores the session on launch.
- [ ] An expired token triggers refresh when a refresh token is available.
- [ ] A successful refresh saves the new token and schedules the next refresh.
- [ ] Refresh failure produces a safe unauthenticated/error state.
- [ ] Logout removes saved tokens and cancels scheduled refresh work.
- [ ] Concurrent refresh triggers do not create duplicate refresh requests.
- [ ] Repository/ViewModel tests can use `MockAPIClient`.
- [ ] Session/token tests can use `MockTokenStorage`.
- [ ] Logs never expose credentials or tokens.

## Potential next improvements

- Add/verify tests for refresh failure, expiry boundaries, duplicate triggers, and logout races.
- Verify the refresh coordinator enforces a single in-flight refresh.
- Ensure scheduled tasks are retained and cancelled on logout or session replacement.
- Add authenticated-request `401` refresh-and-retry behavior only if required by the app, and test it separately.
- Add CI checks for unit tests, linting, and build validation.
- Ensure verbose networking logs are disabled or redacted in release builds.

## Disclaimer

This is a learning and interview-preparation project. It is not a production-ready authentication implementation.
