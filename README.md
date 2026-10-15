# Mobile-Interview-Lab
Mobile Interview Lab (iOS, React Native, Flutter, Android)

A cross-platform mobile development learning repository focused on hands-on practice, technical interview preparation, and real-world mobile application development.

The same set of features will be implemented independently across four platforms:

- **Native iOS:** Swift, SwiftUI, UIKit
- **Native Android:** Kotlin, Jetpack Compose
- **Flutter:** Dart and Flutter
- **React Native:** React Native, TypeScript, Expo

The goal is to understand how the same application requirements are designed, implemented, tested, and optimized using different mobile technologies.

## Repository Structure

```text
Mobile-Interview-Lab/
├── README.md
├── .gitignore
├── iOS/
├── Android/
├── Flutter/
└── React-Native/
```

Each platform will have its own application source code and platform-specific development instructions. All platforms will follow the shared feature roadmap defined in this README.

## Shared Application: User Directory

Our first application will be a **User Directory** that displays users, their profile images, contact information, and detailed profiles.

The feature requirements will remain consistent across platforms. Implementation details, architecture, tooling, and platform-specific behaviour may differ.

### Common Feature Roadmap

#### Phase 1 — Application Foundation
- [ ] Create the application entry screen.
- [ ] Build reusable UI components.
- [ ] Display static sample users.
- [ ] Define typed user models.
- [ ] Establish a consistent layout and styling approach.

#### Phase 2 — User Lists and Images
- [ ] Display user names, email addresses, and cities.
- [ ] Show profile images and placeholder avatars.
- [ ] Handle image loading and failure states.
- [ ] Implement efficient list rendering.
- [ ] Add search and filtering.

#### Phase 3 — REST API Integration
- [ ] Fetch users from a sample REST API.
- [ ] Separate networking logic from UI components.
- [ ] Implement loading, success, empty, and error states.
- [ ] Add retry handling.
- [ ] Implement pagination or infinite scrolling.
- [ ] Add pull-to-refresh.

Sample API: https://jsonplaceholder.typicode.com/users

#### Phase 4 — Navigation and User Details
- [ ] Navigate from the user list to a profile details screen.
- [ ] Pass selected user information between screens.
- [ ] Display complete user details.
- [ ] Implement back navigation.

#### Phase 5 — State Management
- [ ] Manage local screen state.
- [ ] Introduce platform-appropriate state management.
- [ ] Implement favourite users.
- [ ] Handle asynchronous API state.
- [ ] Prevent duplicate requests and stale updates.

#### Phase 6 — Advanced Features
- [ ] Debounced search.
- [ ] Dark mode and theme support.
- [ ] Network error and offline-state handling.
- [ ] Performance optimization.
- [ ] Accessibility support.
- [ ] Platform-specific UI and behaviour.

#### Phase 7 — Testing and Code Quality
- [ ] Unit tests.
- [ ] UI and component/widget tests.
- [ ] API mocking.
- [ ] Error-state testing.
- [ ] Linting and formatting.
- [ ] Code organization and architecture improvements.

#### Phase 8 — Build and CI/CD
- [ ] Configure platform-specific build workflows.
- [ ] Automate tests and quality checks.
- [ ] Build installable application packages.
- [ ] Explore signing and release processes.
- [ ] Document CI/CD workflows.

## Development Environment and Required Tools

Each platform requires a different development toolchain. Install only the tools needed for the platform you are currently working on.

### 1. Native iOS

**Technology:** Swift, SwiftUI, UIKit

Required tools:
- A Mac running a compatible version of macOS.
- Xcode, including the iOS SDK and iOS Simulator.
- Git.
- A code editor or Xcode itself.

Optional or project-dependent:
- Swift Package Manager for dependencies (integrated into Xcode).
- CocoaPods if a selected dependency requires it.
- Fastlane for build and release automation.

Verify the setup:

```bash
xcodebuild -version
swift --version
git --version
```

### 2. Native Android

**Technology:** Kotlin, Jetpack Compose

Required tools:
- Android Studio.
- Android SDK and platform tools.
- Android Emulator or a physical Android device.
- Git.

Optional or project-dependent:
- Java Development Kit compatible with the selected Android Gradle Plugin.
- Gradle tooling, normally managed by the project wrapper.

Verify the setup:

```bash
java -version
adb version
git --version
```

### 3. Flutter

**Technology:** Flutter, Dart

Required tools:
- Flutter SDK, which includes Dart.
- Git.
- Android Studio or Android SDK tools for Android builds.
- Xcode for iOS builds on macOS.
- An editor such as Visual Studio Code or Android Studio.

Verify the setup:

```bash
flutter --version
dart --version
flutter doctor
```

### 4. React Native

**Technology:** React Native, TypeScript, Expo

Required tools for our initial Expo workflow:
- Node.js (LTS recommended by Expo).
- npm.
- Git.
- An editor such as Visual Studio Code.
- Expo Go for compatible projects running on a physical device.

For local native development:
- Xcode and the iOS Simulator for iOS.
- Android Studio and Android SDK tools for Android.

Optional or project-dependent:
- EAS CLI for Expo build and submission workflows.
- CocoaPods and native build tooling when using a development build or native dependencies.

Verify the setup:

```bash
node -v
npm -v
npx expo --version
```

## Setup Instructions

### Repository Setup

Clone the repository:

```bash
git clone <YOUR_REPOSITORY_URL>
cd Mobile-Interview-Lab
```

Choose the platform you want to practise and follow the corresponding instructions below.

### React Native — Current Focus

Navigate to the project:

```bash
cd React-Native/rn-user-directory
```

Install dependencies if required:

```bash
npm install
```

Start Expo:

```bash
npx expo start
```

Use the Expo terminal shortcuts to launch the iOS Simulator or Android emulator, or scan the QR code using Expo Go on a compatible physical device.

### Native iOS

Open the iOS project in Xcode once its project files have been created.

Build and run using an available iOS Simulator or connected device.

### Native Android

Open the Android project in Android Studio once its Gradle project files have been created.

Sync Gradle, select a device, and run the application.

### Flutter

Navigate to the Flutter project once initialized:

```bash
cd Flutter/user_directory
flutter pub get
flutter run
```

## Cross-Platform Learning Approach

1. Define a common feature requirement.
2. Implement it in the current platform.
3. Understand the framework-specific implementation and trade-offs.
4. Test the feature.
5. Document interview questions and key concepts.
6. Repeat the feature in the other platforms.
7. Compare performance, architecture, maintainability, and developer experience.

## Progress Tracking

The root README tracks shared feature requirements. Platform-specific READMEs will document setup instructions, architecture decisions, implementation details, and platform-specific progress.

Only mark a shared feature complete when it has been implemented and verified in the relevant platform.

## Project Status

**Current focus:** React Native + Expo + TypeScript.

**Initial milestone:** A minimal application screen is running on the iOS Simulator and a physical Android device.

**Next milestone:** Build the first reusable component and implement the shared User Directory feature set.

## Disclaimer

This repository is intended for educational purposes, experimentation, and technical interview preparation. Sample API services and demonstration data are not intended for production use.