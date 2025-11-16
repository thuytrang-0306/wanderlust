# Wanderlust

Wanderlust is a comprehensive travel platform built with Flutter. It includes a feature-rich mobile application for users and a powerful web-based admin panel for management and analytics.

## 🚀 Features

### 📱 User Application
- Discover and book travel experiences.
- Plan and create custom itineraries.
- Engage with a community of travelers.
- Receive notifications and updates.

### 🖥️ Admin Panel
The project includes a separate admin web application for managing the platform.
- **Dashboard:** Get a quick overview of key metrics and recent activities.
- **Analytics:** In-depth analytics on users, revenue, and content engagement.
- **User Management:** View, manage, and monitor all registered users.
- **Business Management:** Manage business partners, listings, and verifications.
- **Content Moderation:** Review and manage user-generated content, blogs, and listings.
- **Settings:** Configure system settings, email templates, and admin roles.

## 🛠️ Tech Stack

- **Framework:** [Flutter](https://flutter.dev/)
- **Backend & Database:** [Firebase](https://firebase.google.com/) (Authentication, Firestore, Storage)
- **State Management:** [GetX](https://pub.dev/packages/get)
- **UI:** [flutter_screenutil](https://pub.dev/packages/flutter_screenutil) for responsive design.
- **Environment Variables:** [flutter_dotenv](https://pub.dev/packages/flutter_dotenv)

## ⚙️ Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (version 3.x.x or higher)
- A configured Firebase project.

### Installation & Setup

1.  **Clone the repository:**
    ```bash
    git clone <your-repository-url>
    cd wanderlust
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Set up Firebase:**
    - Download your `google-services.json` file from the Firebase console and place it in the `android/app/` directory.
    - Download your `GoogleService-Info.plist` file and place it in the `ios/Runner/` directory.

4.  **Set up Environment Variables:**
    - Create a `.env` file in the root of the project.
    - Add any necessary environment variables (e.g., API keys). Refer to the source code for required variables.

## ▶️ How to Run

### Mobile Application
To run the main user-facing application, use the following command:
```bash
flutter run
```
Select your desired device (iOS Simulator, Android Emulator, or a physical device).

### Admin Web Panel
To run the admin dashboard, use the following command:
```bash
flutter run -d chrome --target lib/main_admin.dart
```
This will launch the admin panel in a Google Chrome browser window.