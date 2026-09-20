# 🎬 MOVI — Netflix-Style Flutter Movie App

A premium, Netflix-inspired Flutter movie application with Google Photos integration, Firebase backend, admin dashboard, and stunning glassmorphism UI.

## ✨ Features

- 🎬 Netflix opening animation — Custom N logo with red glow + ta-dum sound
- 🏠 Home screen — Auto-rotating featured movie banner + genre rows
- 🔍 Search — Real-time movie search + browse-by-genre grid
- 🎥 Video player — Full-screen Chewie player with landscape support
- 📸 Google Photos — Paste "Anyone with link" share URLs to play videos
- ☁️ Firebase Storage — Upload videos directly with progress bar
- ⭐ Ratings — Star ratings, view count tracking
- 🎨 Glossy UI — Glassmorphism cards, gradient overlays, micro-animations
- 🧭 Peeled nav bar — Custom-painted curved navigation bar with glass effect
- 🔐 Admin panel — Hidden entry (tap logo 5x), add/delete/manage movies

## Quick Start

### 1. Firebase Setup
```
dart pub global activate flutterfire_cli
flutterfire configure
```

### 2. Firebase Console
- Create Firestore database (test mode)
- Enable Authentication > Email/Password
- Enable Storage (test mode)
- Add admin user in Authentication > Users

### 3. Run
```
C:\flutter\bin\flutter.bat run
```

## 📲 Download APK & Release

Anyone can download and install the latest **Movi** app APK directly from GitHub:

1. Go to the **[Releases](../../releases)** section of this repository.
2. Under **Assets**, click **`movi-app-release.apk`** to download.
3. On your Android device, open the downloaded `.apk` file and tap **Install** (allow "Install from unknown sources" if prompted).

### 🚀 Automated GitHub Actions CI/CD
This repository includes an automated workflow (`.github/workflows/release.yml`) that:
- Automatically builds the **APK** (`movi-app-release.apk`) and **App Bundle** (`movi-app-release.aab`).
- Uploads build artifacts to the Actions summary for instant download.
- Automatically publishes a GitHub Release with downloadable APK/AAB assets when a version tag (`v*`) is pushed.

## Admin Access
Tap the MOVI logo 5 times on the home screen to open Admin Login.

## Google Photos Videos
1. Open video in Google Photos
2. Share > Create link > Anyone with link
3. Copy link
4. Admin Dashboard > Add Movie > Paste link

