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

### UI/UX Implementation Notes
- **iPhone Navigation Bar**: The black bar at bottom of iOS screenshots is the iPhone navigation indicator, NOT part of the app design. Do not implement it in the UI.
- **Design Reference**: Always refer to Figma designs in `/assets/designs/` for accurate UI implementation
- **Screenshot Reference**: Screenshots in `/assets/screenshots/` may include system UI elements (status bar, navigation bar) that are not part of the app

### 🎯 FIGMA TO FLUTTER CONVERSION RULES (100% Accuracy)

#### 1. ANALYZE DESIGN SYSTEMATICALLY
When given a design PNG, analyze in this order:
1. **Layout Structure**: Identify all components top to bottom
2. **Spacing**: Measure gaps between elements (use 4px grid)
3. **Typography**: Note all text styles, sizes, weights, colors
4. **Colors**: Extract exact hex codes from design
5. **Interactions**: Identify buttons, gestures, animations
6. **States**: Check for different states (active, inactive, error)

#### 2. COMPONENT MAPPING
```dart
// Always use app's base components
Typography → AppTypography (h1-h4, bodyXL-XS)
Colors → AppColors (primary, secondary, neutral, semantic)
Spacing → AppSpacing (s0-s14, based on 4px grid)
Buttons → Theme buttons with consistent height (48-56h)
```

#### 3. EXACT MEASUREMENTS
- **Text Sizes**: Always use exact .sp from design
- **Spacing**: Round to nearest 4px grid unit
- **Button Heights**: Standard 48h or 56h
- **Border Radius**: Use AppSpacing values (s3=12r, s6=24r)
- **Padding**: Use AppSpacing for consistency

#### 4. COLOR PRECISION
```dart
// If color not in AppColors, use exact hex
Color(0xFF2F3137) // Use exact hex when needed
AppColors.primary // Use theme colors when available
```

#### 5. RESPONSIVE RULES
```dart
// Images
height: 0.35.sh // Percentage of screen
maxHeight: 280.h // Max constraint
minHeight: 200.h // Min constraint

// Containers
padding: EdgeInsets.symmetric(horizontal: AppSpacing.s6)
width: double.infinity // Full width buttons

// Text
maxLines: 3
overflow: TextOverflow.ellipsis
```

#### 6. VIETNAMESE TEXT HANDLING
- Keep original Vietnamese text from design
- Use proper font weights for Vietnamese
- Consider text length for overflow handling

#### 7. COMMON PATTERNS
```dart
// Skip button (top right)
TextStyle(
  fontSize: 16.sp,
  fontWeight: FontWeight.w500,
  color: Color(0xFF2F3137),
)

// Page indicators
height: 8.h
width: currentPage ? 24.w : 8.w
color: active ? AppColors.primary : AppColors.neutral300

// Bottom padding from device
padding: EdgeInsets.only(bottom: 67.h)
```

#### 8. VERIFICATION CHECKLIST
Before completing any UI task:
- [ ] All text matches design (size, weight, color)
- [ ] Spacing matches design (use exact values)
- [ ] Colors are exact (hex codes or theme colors)
- [ ] Layout structure identical to design
- [ ] Responsive on different screen sizes
- [ ] No overflow errors
- [ ] Center alignment where needed
- [ ] Proper padding from screen edges

#### 9. IMPLEMENTATION WORKFLOW
1. **Read design image** thoroughly
2. **List all components** and their properties
3. **Map to app's design system** (colors, typography, spacing)
4. **Implement with exact values**
5. **Test on multiple screen sizes**
6. **Compare screenshot with design**
7. **Fine-tune until 100% match**

#### 10. QUICK REFERENCE
```dart
// Common spacings
s1: 4.h   s2: 8.h   s3: 12.h  s4: 16.h
s5: 20.h  s6: 24.h  s7: 28.h  s8: 32.h
s9: 36.h  s10: 40.h s11: 44.h s12: 48.h

// Common text sizes
h1: 32.sp  h2: 28.sp  h3: 24.sp  h4: 20.sp
bodyXL: 20.sp  bodyL: 18.sp  bodyM: 16.sp
bodyS: 14.sp   bodyXS: 12.sp

// Button heights
Standard: 48.h
Large: 56.h
Small: 40.h
```

## 🎯 Best Practices & Widget System

### 🧩 Core Widget System
**IMPORTANT: Always use app's common widgets for consistency and maintainability**

#### Common Widgets Created:
1. **AppButton** (`/lib/core/widgets/app_button.dart`)
   - Primary color: #9455FDCC (80% opacity)
   - Padding: 12h vertical
   - Factory constructors: `.primary()`, `.secondary()`, `.outline()`, `.text()`, `.danger()`
   - Sizes: Small (40h), Medium (48h), Large (56h)
   - Built-in loading state

2. **AppTextField** (`/lib/core/widgets/app_text_field.dart`)
   - Factory constructors: `.email()`, `.password()`, `.name()`, `.phone()`, `.search()`, `.multiline()`
   - Consistent styling with design system
   - Built-in validation

3. **AppSnackbar** (`/lib/core/widgets/app_snackbar.dart`)
   - Types: `.showSuccess()`, `.showError()`, `.showWarning()`, `.showInfo()`
   - Consistent animations and styling
   - Centralized notification system

4. **AppDialogs** (`/lib/core/widgets/app_dialogs.dart`)
   - Loading, Confirm, Alert dialogs
   - Consistent styling across app

5. **AppLogo** (`/lib/core/widgets/app_logo.dart`)
   - Factory constructors: `.splash()`, `.auth()`, `.compact()`, `.header()`
   - Sizes: Small (60w), Medium (80w), Large (100w), XLarge (120w)
   - Styles: Vertical, Horizontal, LogoOnly, NameOnly

6. **SocialLoginButtons** (`/lib/core/widgets/social_login_buttons.dart`)
   - Consistent social auth buttons
   - Platforms: Google, Facebook, Apple, Twitter
   - Circular design with borders

7. **DividerWithText** (`/lib/core/widgets/divider_with_text.dart`)
   - Factory constructors: `.or()`, `.orLoginWith()`, `.orRegisterWith()`
   - Consistent divider styling

### 🎨 Widget Usage Rules
1. **NEVER create duplicate UI components** - Always check for existing widgets
2. **ALWAYS use AppButton** instead of ElevatedButton/TextButton
3. **ALWAYS use AppTextField** instead of TextFormField
4. **ALWAYS use AppSnackbar** instead of Get.snackbar()
5. **ALWAYS use AppLogo** for logo display
6. **ALWAYS use SocialLoginButtons** for social auth
7. **ALWAYS use DividerWithText** for section dividers

### 🔄 Component Reusability
- Extract common UI patterns into widgets
- Use factory constructors for common variations
- Keep widgets flexible with parameters
- Maintain consistent naming conventions

### 📦 Benefits of Widget System
1. **Consistency**: Uniform UI/UX across the app
2. **Maintainability**: Change once, update everywhere
3. **Development Speed**: Faster feature development
4. **Type Safety**: Factory constructors ensure correct usage
5. **Clean Code**: No duplicate code, follows DRY principle

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

## 📱 Flutter Resolution-Aware Images System

### IMPORTANT: Multi-Resolution Asset Rules
Flutter's resolution-aware image system allows automatic selection of appropriate assets based on device pixel density.

#### Folder Structure Requirements
```
assets/icons/
├── icon_name.png        # 1x resolution (default)
├── 2x/
│   └── icon_name.png    # 2x resolution (same name!)
└── 3x/
    └── icon_name.png    # 3x resolution (same name!)
```

#### Key Rules
1. **Folder Names**: Must be exactly `2x` and `3x` (NOT `2.0x` or `3.0x`)
2. **File Names**: Must be IDENTICAL across all folders
   - ✅ Correct: `tab_home.png` in all three locations
   - ❌ Wrong: `tab_home.png`, `tab_home@2x.png`, `tab_home@3x.png`
3. **Pubspec Declaration**: Must declare ALL folders
   ```yaml
   assets:
     - assets/icons/
     - assets/icons/2x/
     - assets/icons/3x/
   ```

#### Icon Naming Convention
- Use descriptive names with underscores: `tab_home.png`, `icon_search.png`
- Keep names consistent and lowercase
- No special characters or suffixes (@2x, @3x)

#### How It Works
- Flutter automatically selects the right resolution based on device:
  - 1x: Low density screens (mdpi ~160dpi)
  - 2x: Medium density screens (xhdpi ~320dpi)  
  - 3x: High density screens (xxhdpi ~480dpi)
- Only reference the base name in code: `Image.asset('assets/icons/tab_home.png')`
- Flutter handles the rest automatically

#### Common Mistakes to Avoid
1. ❌ Adding @2x or @3x to filenames
2. ❌ Using 2.0x or 3.0x as folder names
3. ❌ Forgetting to declare 2x/3x folders in pubspec.yaml
4. ❌ Different filenames in different resolution folders
5. ❌ Referencing the full path with 2x/3x in code

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