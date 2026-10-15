# React Native User Directory

A hands-on React Native learning project built with **Expo, TypeScript, and Expo Router** as part of the [Mobile-Interview-Lab](../../README.md) repository.

The goal is to build a production-minded User Directory app while practising React Native development, mobile architecture, API integration, testing, performance, and interview concepts.

## Project Goals

- Build reusable, typed React Native components.
- Display a list of users and their profile details.
- Integrate a REST API and handle loading, success, empty, and error states.
- Implement search, filtering, and pull-to-refresh.
- Add user detail navigation and favourites.
- Practise state management, performance optimization, accessibility, and testing.
- Prepare for React Native developer and mobile architect interviews.

## Tech Stack

- **Framework:** React Native with Expo
- **Language:** TypeScript
- **Navigation:** Expo Router
- **API:** JSONPlaceholder — https://jsonplaceholder.typicode.com/users
- **Development tools:** Node.js, npm, Expo Go, iOS Simulator, and Android Emulator

Additional libraries will be introduced when they are needed and documented here.

## Getting Started

### Prerequisites

- Node.js and npm
- A compatible version of Expo Go for a physical device, or an installed iOS Simulator / Android Emulator
- Git

For native simulator setup, see the [Expo iOS Simulator guide](https://docs.expo.dev/workflow/ios-simulator/) and [Android Emulator guide](https://docs.expo.dev/workflow/android-studio-emulator/).

### Install dependencies

From the repository root:

```bash
cd React-Native/rn-user-directory
npm install
```

### Start the development server

```bash
npx expo start
```

Then choose an option:

- Press `i` to open the iOS Simulator, when available.
- Press `a` to open the Android Emulator, when available.
- Scan the QR code with Expo Go on a compatible physical device. Usually, your computer and device should be on the same Wi-Fi network.

To restart with a cleared Metro cache:

```bash
npx expo start --clear
```

## Project Structure

The app uses Expo Router for file-based routing and follows an MVVM-style presentation structure with Clean Architecture principles.

```text
rn-user-directory/
├── src/
│   ├── app/
│   │   ├── _layout.tsx
│   │   └── index.tsx
│   ├── features/
│   │   └── users/
│   │       ├── domain/
│   │       │   └── models/
│   │       │       └── User.ts
│   │       ├── data/
│   │       │   └── mockUsers.ts
│   │       └── presentation/
│   │           ├── components/
│   │           │   └── UserCard.tsx
│   │           ├── hooks/
│   │           │   └── useUsersViewModel.ts
│   │           └── screens/
│   │               └── UserDirectoryScreen.tsx
│   └── global.css
├── assets/
├── app.json
├── package.json
├── package-lock.json
└── README.md
```

The structure above reflects the current implementation. Additional layers, such as repositories and API services, will be introduced as the project evolves.


## Implementation Roadmap

- [x] **Phase 1:** Application foundation, reusable UI components, typed user model, and MVVM-style presentation structure
- [x] **Phase 2:** User model and static sample data
- [x] **Phase 3:** User list and profile cards using `FlatList`
- [ ] **Phase 4:** REST API integration and request-state handling
- [ ] **Phase 5:** Search, filtering, and pull-to-refresh
- [ ] **Phase 6:** User details and navigation
- [ ] **Phase 7:** Favourites and state management
- [ ] **Phase 8:** Error handling, retry, and performance optimization
- [ ] **Phase 9:** Accessibility, dark mode, and offline considerations
- [ ] **Phase 10:** Unit tests, component tests, linting, and CI/CD

**Current status:** Foundation and static user list completed. Next, integrate the REST API with a repository layer.

Update these checkboxes as each phase is completed.

## Useful Commands

```bash
# Start the app
npx expo start

# Check the project configuration
npx expo-doctor

# Run linting if configured
npx expo lint
```

## Learning Resources

- [Expo Documentation](https://docs.expo.dev/)
- [Expo Router](https://docs.expo.dev/router/introduction/)
- [React Native Documentation](https://reactnative.dev/docs/getting-started)
- [TypeScript Documentation](https://www.typescriptlang.org/docs/)
- [JSONPlaceholder API](https://jsonplaceholder.typicode.com/)

## Related Documentation

See the [Mobile-Interview-Lab root README](../../README.md) for the shared roadmap, cross-platform feature requirements, and progress across iOS, Android, Flutter, and React Native.
