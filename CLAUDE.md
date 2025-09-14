# Wanderlust - Travel App Project Context

## 🎯 Project Overview
**Wanderlust** is a comprehensive travel application built with Flutter, designed to help users discover, plan, and share their travel experiences.

## 🏗️ Architecture

### Clean Architecture + GetX Pattern
```
lib/
├── core/           # Core functionality, shared across features
├── data/           # Data layer (repositories, models, datasources)
├── domain/         # Business logic (entities, repositories, usecases)
├── presentation/   # UI layer (pages, controllers, widgets)
└── app/           # App configuration (routes, bindings, themes)
```

## 🛠️ Technology Stack

### Core Technologies
- **Flutter**: 3.7.2+ with FVM for version management
- **Dart**: Latest stable version
- **State Management**: GetX 4.6.6
- **Dependency Injection**: GetX
- **Navigation**: GetX routing system

### Backend & Database
- **Firebase Auth**: User authentication
- **Cloud Firestore**: NoSQL database
- **Firebase Storage**: Media storage
- **Firebase Core**: 3.6.0

### UI & Design
- **Responsive Design**: flutter_screenutil 5.9.3
- **Typography**: Gilroy font family
- **Design System**: Custom 4px grid system
- **Colors**: Primary (Green #65A30D), Secondary (Orange #FF812C)

## 📱 Platform Configuration

### Android
- **Package**: `com.wanderlust.app`
- **Min SDK**: 23 (Android 6.0)
- **Target SDK**: Latest
- **NDK Version**: 27.0.12077973
- **Kotlin Version**: 1.9.24

### iOS
- **Bundle ID**: `com.wanderlust.app`
- **Minimum iOS**: 12.0
- **Swift Version**: Latest

### Web
- **PWA Support**: Enabled
- **Firebase Web**: Configured

## 🎨 Design System

### Typography (Gilroy Font)
- **Headings**: H1 (32sp), H2 (28sp), H3 (24sp), H4 (20sp)
- **Body**: XL (20sp), L (18sp), M (16sp), S (14sp), XS (12sp)
- **Font Weights**: Light (300), Regular (400), Medium (500), SemiBold (600), Bold (700)

### Color Palette
```dart
Primary: #9455FD (Purple - Main actions, CTAs, links, inputs)
Secondary: #3D1A73 (Deep Purple - Secondary focus)
Success: #86FB84
Warning: #FDF28D
Error: #F87B7B
Neutral: #2F3137 to #F5F7F8 (Text, backgrounds, borders)

Gradients:
- Gradient 101: #C4CDF4 → #EDE0FF
- Gradient 202: #C8D4FF → #DFF4FF
- Gradient 303: #BEEBFE → #DDFFF7
- Gradient 505: #D0FCEF → #E6F5C5
```

### Spacing System (4px Grid)
- Base unit: 4px
- Scale: s0 (0px) to s14 (56px)
- Semantic: paddingXS (8px) to paddingXXL (32px)

## 🔧 Development Commands

### Flutter Commands
```bash
# Use FVM for Flutter commands
fvm flutter run
fvm flutter clean
fvm flutter pub get
fvm flutter build apk
fvm flutter build ios
```

### Platform-specific Run
```bash
# Android
fvm flutter run -d emulator-5554

# iOS
fvm flutter run -d 41AD1EEA-9456-41C4-885C-6378F1900004

# Web
fvm flutter run -d chrome
```

### Maintenance
```bash
# Clean build
fvm flutter clean && fvm flutter pub get

# iOS specific
cd ios && pod install
cd ios && pod deintegrate && pod install

# Android specific
cd android && ./gradlew clean
```

## 📦 Key Dependencies

### State & Navigation
- `get: ^4.6.6` - State management, routing, DI

### UI Components
- `flutter_screenutil: ^5.9.3` - Responsive design
- `cached_network_image: ^3.4.1` - Image caching
- `shimmer: ^3.0.0` - Loading effects
- `lottie: ^3.1.2` - Animations

### Backend Services
- `firebase_core: ^3.6.0`
- `firebase_auth: ^5.3.1`
- `cloud_firestore: ^5.4.4`
- `firebase_storage: ^12.3.4`

### Storage & Persistence
- `get_storage: ^2.1.1` - Local storage
- `sqflite: ^2.4.1` - SQLite database

### Utilities
- `dio: ^5.6.0` - HTTP client
- `image_picker: ^1.2.0` - Image selection
- `permission_handler: ^11.4.0` - Permissions
- `connectivity_plus: ^6.1.1` - Network status

## 🚧 Known Issues & Solutions

### Android Build Issues
1. **MainActivity ClassNotFoundException**
   - Solution: Ensure MainActivity.kt is in `/android/app/src/main/kotlin/com/wanderlust/app/`

2. **Kotlin Version Conflicts**
   - Current version: 1.9.24
   - Located in: `/android/settings.gradle.kts`

### iOS Build Issues
1. **Xcode DerivedData Cache**
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData/*
   ```

2. **Pod Installation Issues**
   ```bash
   cd ios && pod deintegrate && pod install --repo-update
   ```

### Temporarily Disabled Packages
- **firebase_messaging**: APNS token issues on iOS
- **firebase_analytics**: Kotlin version conflicts
- **flutter_stripe**: Major Kotlin incompatibility

## 📂 Project Structure

### Core Components
```
/lib/core/
├── base/           # Base classes (Controller, Repository, View)
├── constants/      # App constants (colors, typography, spacing)
├── services/       # Core services (Firebase, Storage, Connectivity)
├── utils/          # Utilities (Logger, Extensions, Helpers)
└── widgets/        # Reusable widgets
```

### Feature Modules
```
/lib/presentation/
├── pages/          # Screen pages
├── controllers/    # GetX controllers
└── widgets/        # Feature-specific widgets
```

## 🔐 Environment Configuration

### Firebase Projects
- **Android**: `google-services.json` in `/android/app/`
- **iOS**: `GoogleService-Info.plist` in `/ios/Runner/`
- **Web**: Configuration in `firebase_options.dart`

### Environment Variables
- `.env` file for API keys and configuration
- Not committed to git

## 🚀 Current State

### Implemented Features
- ✅ Splash screen with animations
- ✅ Design System showcase
- ✅ Base architecture setup
- ✅ Firebase integration
- ✅ Responsive design system

### Next Development Phase
1. Authentication flow (Login/Register)
2. User profile management
3. Main navigation structure
4. Home/Discovery screen
5. Trip planning features

## 📝 Development Guidelines

### IMPORTANT: Build & Test After Each Task
**⚠️ ALWAYS check for compilation errors after completing any task:**
```bash
# QUICKEST METHOD - Build debug APK (no need to wait for emulator)
fvm flutter build apk --debug

# Alternative - Analyze code without building
fvm flutter analyze
```

### IMPORTANT: Post-Task Cleanup & Optimization
**🧹 When user confirms "OK" or task completion, ALWAYS:**
1. **Review all staged changes** - Check what was added/modified
2. **Identify cleanup opportunities:**
   - Remove unused files, imports, variables
   - Delete temporary/test files
   - Clean up commented code
   - Remove debug prints/logs
3. **Optimize for production:**
   - Check for performance issues
   - Ensure proper error handling
   - Verify no hardcoded values
   - Confirm no sensitive data exposed
4. **Summary report:**
   - List what was implemented
   - Highlight any cleanup done
   - Note any potential improvements
5. **Keep codebase production-ready** at all times

**Only run on actual devices/emulators when needed for UI testing:**
```bash
fvm flutter run -d chrome  # Web (fastest runtime)
fvm flutter run -d emulator-5554  # Android emulator
fvm flutter run  # Any available device
```

**After implementing new features/files:**
1. Save all files
2. Run the app to check for compilation errors
3. Fix any errors before moving to next task
4. Use hot reload (r) to test changes

### Code Style
- Follow Flutter/Dart best practices
- Use GetX reactive state management
- Implement repository pattern for data
- Keep widgets small and reusable
- **ALWAYS import required packages at the top of files**
- **Check for unused imports and remove them**

### Git Workflow
- Branch: `dev/base_wanderlust` (current)
- Main branch for production
- Feature branches from dev

### Testing
- Unit tests for business logic
- Widget tests for UI components
- Integration tests for critical flows
- **Run app after each implementation to catch errors early**

## 👥 Team Notes

### For Claude AI
- Project uses FVM (Flutter Version Management)
- Always use `fvm flutter` instead of `flutter`
- ConnectivityService needs platform check for web
- **IMPORTANT: Always run app after implementing features to check for compilation errors**
- **Fix all errors before proceeding to next task**

### Asset Notes
- `/assets/designs/` folder (21MB) - **FOR REFERENCE ONLY, NOT FOR APP USE**
  - Contains design mockups and specifications
  - Should NOT be referenced in code
  - Already in .gitignore
- `/assets/screenshots/` folder - **FOR DOCUMENTATION ONLY**
  - App screenshots for documentation
  - Should NOT be used in actual app
- **Actual app assets should be in:**
  - `/assets/images/` - App images
  - `/assets/icons/` - App icons  
  - `/assets/animations/` - Lottie animations
  - `/assets/fonts/` - Font files

### Important Paths
- MainActivity: `/android/app/src/main/kotlin/com/wanderlust/app/MainActivity.kt`
- Info.plist: `/ios/Runner/Info.plist`
- Firebase options: `/lib/firebase_options.dart`

## 🎯 Success Metrics
- App runs on Android ✅
- App runs on iOS ✅
- App runs on Web ✅
- Clean architecture implemented ✅
- Design system integrated ✅

---

Last Updated: September 11, 2024
Flutter Doctor: All checks passed
Platforms: Android, iOS, Web