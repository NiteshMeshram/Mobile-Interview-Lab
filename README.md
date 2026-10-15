# Mobile-Interview-Lab
Mobile Interview Lab (iOS, React Native, Flutter, Android)

A hands-on learning repository for practising mobile development concepts, preparing for technical interviews, and building practical applications across iOS, Flutter, React Native, and Android.

The goal is to build every feature from scratch, understand the underlying concepts, and progressively evolve small applications into production-style projects.

## Repository Structure

```text
Mobile-Interview-Lab/
├── iOS/                         # Swift, SwiftUI, UIKit
├── Flutter/                     # Flutter and Dart
├── React-Native/                # React Native and TypeScript
│   └── rn-user-directory/       # User Directory practice app
├── Android/                     # Kotlin and Android development
├── README.md
└── .gitignore
```

## Current Focus: React Native

**Project:** `rn-user-directory`

**Technology stack:**
- React Native
- Expo
- TypeScript
- Expo Router
- REST API integration (planned)
- Redux Toolkit (planned)

The application will start with simple static components and gradually introduce real-world functionality. Features will be implemented incrementally to reinforce core concepts and interview preparation.

## Planned Feature Roadmap

### Phase 1 — React Native Fundamentals
- [x] Create the Expo + TypeScript project.
- [x] Run the application on the iOS Simulator.
- [x] Run the application on a physical Android device.
- [x] Create a minimal home screen.
- [ ] Build reusable components and understand component composition.
- [ ] Practise props, TypeScript interfaces/types, and component styling.
- [ ] Render multiple users using `map()` and understand React keys.

### Phase 2 — User Directory and Lists
- [ ] Build a user directory with static sample data.
- [ ] Display user names, email addresses, cities, and profile images.
- [ ] Use `FlatList` for efficient list rendering.
- [ ] Handle missing images and image-loading failures.
- [ ] Implement search and filtering.
- [ ] Add pull-to-refresh.

### Phase 3 — REST API Integration
- [ ] Fetch sample users from JSONPlaceholder.
- [ ] Separate API calls into a service layer.
- [ ] Practise `fetch`, promises, and `async/await`.
- [ ] Implement loading, success, empty, and error states.
- [ ] Add retry handling and prevent duplicate requests.
- [ ] Implement pagination or infinite scrolling.

Sample API: https://jsonplaceholder.typicode.com/users

### Phase 4 — Navigation and User Profiles
- [ ] Configure screen navigation using Expo Router.
- [ ] Navigate from the user list to a user details screen.
- [ ] Pass route parameters and display selected user details.
- [ ] Handle back navigation and screen state.

### Phase 5 — State Management
- [ ] Understand local state with `useState`.
- [ ] Practise side effects with `useEffect`.
- [ ] Learn `useMemo` and `useCallback`.
- [ ] Build custom hooks.
- [ ] Integrate Redux Toolkit.
- [ ] Understand Store, Slices, Reducers, Actions, and Selectors.
- [ ] Handle asynchronous API requests using Redux Toolkit's `createAsyncThunk`.
- [ ] Implement favourites and shared application state.

### Phase 6 — Advanced React Native Concepts
- [ ] Improve `FlatList` performance.
- [ ] Implement debounced search.
- [ ] Handle network failures and simulated offline scenarios.
- [ ] Add dark mode and theme support.
- [ ] Explore platform-specific behaviour for iOS and Android.
- [ ] Understand React rendering, reconciliation, and the JavaScript event loop.

### Phase 7 — Testing and Code Quality
- [ ] Add Jest tests.
- [ ] Practise React Native Testing Library.
- [ ] Test components, user interactions, and loading/error states.
- [ ] Mock API requests.
- [ ] Add linting and formatting.
- [ ] Establish a maintainable project structure and separation of concerns.

### Phase 8 — Build and CI/CD
- [ ] Understand Expo development builds.
- [ ] Learn Android and iOS build workflows.
- [ ] Explore EAS Build and EAS Submit.
- [ ] Configure a basic CI pipeline.
- [ ] Learn environment configuration and secure handling of secrets.

## Required Development Tools

### Core tools

| Tool | Purpose |
|---|---|
| Node.js (LTS recommended) | JavaScript runtime and development tooling |
| npm | Package and dependency management |
| Git | Version control |
| Visual Studio Code or another editor | Code editing |
| Expo CLI via `npx expo` | Start and manage the Expo project |

### iOS development

| Tool | Purpose |
|---|---|
| macOS | iOS development environment |
| Xcode | iOS Simulator, SDKs, and native build tools |
| iOS Simulator | Test the application on simulated iPhones |

### Android development

| Tool | Purpose |
|---|---|
| Expo Go | Run compatible Expo projects on a physical Android device |
| Android Studio | Android SDKs, emulator, and native development tools |
| Android Emulator | Test the application on virtual Android devices |

**Optional tools:** Homebrew for installing development utilities, CocoaPods when required by native iOS dependencies, and EAS CLI for supported Expo build and deployment workflows.

For the current Expo Go workflow, a separate native build setup is not required to start practising basic components and API integration.

## Installation and Setup

### 1. Verify the prerequisites

```bash
node -v
npm -v
git --version
```

For iOS development, also verify:

```bash
xcodebuild -version
```

### 2. Navigate to the React Native project

From the repository root:

```bash
cd React-Native/rn-user-directory
```

### 3. Install dependencies

If dependencies are not already installed:

```bash
npm install
```

### 4. Start the application

```bash
npx expo start
```

- Press `i` to open the iOS Simulator.
- Press `a` to open an available Android emulator.
- Scan the QR code using Expo Go to run the application on a compatible physical device.

The Mac and physical device should normally be on the same Wi-Fi network when using the default local connection.

### 5. Validate the project

```bash
npx expo-doctor
```

This checks common Expo project configuration and dependency issues.

## Learning Principles

1. **Build from scratch:** Implement features ourselves rather than copying a complete application.
2. **Learn incrementally:** Add one concept at a time and verify it before proceeding.
3. **Understand the code:** Know why a component, hook, service, or state-management solution is needed.
4. **Practise interview questions:** Connect each implementation to common interview questions and trade-offs.
5. **Maintain code quality:** Use TypeScript, reusable components, clear naming, and appropriate testing.
6. **Support both platforms:** Validate behaviour on iOS and Android wherever practical.
7. **Track progress:** Keep completed features and future tasks updated in this README.

## Project Status

**Current milestone:** Initial Expo + TypeScript setup and minimal screen.

**Next milestone:** Build the first reusable `UserCard` component and practise rendering multiple static users.

## Disclaimer

This repository is intended for learning, experimentation, and interview preparation. Sample APIs and demonstration data are used for practice, not as production data sources.