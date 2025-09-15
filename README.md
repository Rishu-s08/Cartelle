# Cartelle 🚀

Cartelle is a **location-based shopping & reminder app** built with **Flutter + Firebase**. It allows users to create shopping lists, get reminders based on **time or location**, and manage stores/areas with **draggable markers and radius selection**.

This repo contains the **MVP** version of the app, which is now **open-source** for learning, contributing, and experimentation.

---

## 🖥 Features

* Location-based shopping lists
* Time-based & geofenced reminders
* Add/edit/delete locations with draggable markers
* Adjustable radius selection for location triggers
* Push notifications for reminders
* Simple and elegant UI

---

## 🛠 Tech Stack

* **Frontend:** Flutter
* **Backend / Realtime DB:** Firebase Firestore & Firebase Auth
* **Push Notifications:** Flutter local Notification
* **Geolocation:** flutter\_background\_geolocation / Google Maps API
* **Environment Variables:** `.env` file for Google API keys

---

## ⚡ Getting Started

### 1. Clone the Repo

```bash
git clone https://github.com/Rishu-s08/cartelle.git
cd cartelle
```

### 2. Create `.env` File

Create a `.env` file in the root folder and add your Google API key:

```env
GOOGLE_API_KEY=your_google_maps_api_key_here
```

> ⚠ **Never commit `.env` to GitHub**. `.env` is already in `.gitignore`.

### 3. Access API Key in Flutter

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  final googleApiKey = dotenv.env['GOOGLE_API_KEY'];
  runApp(MyApp(googleApiKey: googleApiKey));
}
```

### 4. Install Dependencies

```bash
flutter pub get
```

### 5. Run the App

```bash
flutter run
```

---

## 🤝 How to Contribute

We welcome contributions from anyone! Here’s how to get started:

1. **Fork the repo**
2. **Create a new branch**

   ```bash
   git checkout -b feature/your-feature-name
   ```
3. **Make your changes** (fix bugs, add features, improve UI)
4. **Push your branch**

   ```bash
   git push origin feature/your-feature-name
   ```
5. **Open a Pull Request**
6. **Wait for review and merge**

**Contribution Guidelines:**

* Write clean and well-commented code
* Keep UI consistent with existing style
* Avoid committing `.env` or secrets
* Test features before submitting PR

---

## 📂 Directory Structure (simplified)

```
/lib
  /core     # all core files i.e constants, services, helpers, utils etc
  /features     # all features
    /feature 1
      /screens
      /repository
      /controller
    /feature 2
      ...
  /theme      # theme
  ./app_router    # routing
  ./main.dart
```

---

## ⚠ Notes

* This is an **MVP**, not production-ready.
* For real deployment, consider **API key restrictions**, **Firebase rules**, and **secure storage of secrets**.
* Feel free to fork, improve, or use as a learning project.
