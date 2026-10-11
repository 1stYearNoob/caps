# 🌱 My Capstone Application

A modern Flutter application designed for agricultural management, plant disease detection, real-time weather monitoring, and geolocation mapping.

---

## 📌 Features

- **🔬 AI Plant Disease Detection**: Identify plant diseases from photos using the Roboflow Inference API and receive treatment recommendations powered by Google Gemini AI.
- **📖 Disease Dictionary**: Comprehensive catalog of bacterial, fungal, and viral plant diseases with visual guides and prevention strategies.
- **🌤️ Real-Time Weather & Advisory**: Live weather conditions, hourly forecasts, and automated agricultural tips with local caching using the BLoC pattern.
- **📍 Geolocation & Mapping**: Field mapping and location tracking using OpenStreetMap and Geolocator.
- **🔐 Firebase Authentication & Cloud Storage**: Secure user sign-up/login, scan history logging, and terms-of-service compliance via Firebase Auth and Cloud Firestore.
- **🌐 Multi-Language Support**: In-app translation features for local accessibility.

---

## 🛠️ Prerequisites

Before running the application, make sure you have the following installed on your development machine:

1. **Flutter SDK**: Version `3.10.7` or newer ([Install Flutter](https://docs.flutter.dev/get-started/install)).
2. **Dart SDK**: Included with Flutter.
3. **IDE**: [VS Code](https://code.visualstudio.com/) with Flutter & Dart extensions, or [Android Studio](https://developer.android.com/studio).
4. **Java Development Kit (JDK)**: JDK 17 recommended for Android Gradle builds.
5. **A Device to Run On**:
   - Physical Android device with **USB Debugging** enabled, OR
   - Android Emulator configured via Android Studio, OR
   - Windows Desktop / Chrome / iOS (macOS required for iOS).

---

## 🚀 Getting Started & How to Run

### 1. Clone the Repository

```bash
git clone https://github.com/1stYearNoob/my_capstone_application.git
cd my_capstone_application
```

### 2. Install Project Dependencies

Fetch all required Dart and Flutter packages:

```bash
flutter pub get
```

### 3. Verify Connected Devices

Ensure your phone or emulator is detected by Flutter:

```bash
flutter devices
```

You should see your connected emulator or device listed with an identifier (e.g., `emulator-5554` or `android`).

### 4. Run the Application

#### Option A: Debug Mode (Recommended for development)
Run on your default or currently active device:
```bash
flutter run
```

If multiple devices are connected, specify the target device ID:
```bash
flutter run -d <device_id>
```

#### Option B: Release Mode (Smoother performance)
```bash
flutter run --release
```

---

## 📦 Building the App

To generate installable application packages:

### Android APK (Direct Installation)
```bash
flutter build apk --release
```
The output file will be generated at:
`build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle (Google Play Store)
```bash
flutter build appbundle --release
```
The output file will be generated at:
`build/app/outputs/bundle/release/app-release.aab`

---

## ⚙️ Configuration & API Services

The project uses pre-configured endpoints and services:

| Service | Configuration File | Purpose |
| :--- | :--- | :--- |
| **Firebase** | `lib/firebase_options.dart`<br>`android/app/google-services.json` | Authentication & Cloud Firestore database |
| **OpenWeatherMap** | `lib/data/my_data.dart` | Weather telemetry and forecast |
| **Google Gemini AI** | `lib/data/my_data.dart` | Plant diagnosis insights and advisory |
| **Roboflow** | `lib/services/roboflow_service.dart` | Computer vision model for leaf disease detection |

> **Note**: For production deployments, replace the default API keys in `lib/data/my_data.dart` and `lib/services/roboflow_service.dart` with your own credentials or store them in secure environment variables.

---

## 📂 Project Structure

```text
my_capstone_application/
├── android/                   # Android native platform project and Gradle config
├── assets/                    # Static images, icons, and fonts
├── lib/
│   ├── bloc/                  # State management (WeatherBloc, states, events)
│   ├── data/                  # Disease catalogs, constants, and API configuration
│   ├── functions/             # Global utility functions
│   ├── pages/                 # UI screens (Home, Detect, Weather, Location, Auth)
│   ├── services/              # API services (Auth, Roboflow, Translation)
│   ├── theme/                 # App styling, color palettes, and themes
│   ├── widgets/               # Reusable UI components
│   ├── firebase_options.dart  # Generated Firebase platform configuration
│   └── main.dart              # Application entry point
├── pubspec.yaml               # Package dependencies and asset declarations
└── README.md                  # Project documentation
```

---

## ❓ Troubleshooting

- **Dependency issues / version conflicts**:
  ```bash
  flutter clean
  flutter pub get
  ```
- **Android Gradle build failures**:
  - Run `cd android && ./gradlew clean && cd ..` (or `gradlew.bat clean` on Windows).
  - Verify that your JDK path in Android Studio is set to JDK 17.
- **Permissions error (Camera / Location)**:
  - When launching the app for the first time, allow Camera and Location permissions when prompted by your device OS.
