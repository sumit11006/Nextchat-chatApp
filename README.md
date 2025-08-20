NexChat

NexChat is a Flutter-based real-time chat application with Firebase backend. It supports authentication, real-time messaging, online/offline status tracking, emojis, and more, providing a smooth and modern messaging experience.

Features

User authentication with Firebase Auth (email/password, Google sign-in, etc.)

Real-time chat powered by Cloud Firestore

Online/offline status and last seen tracking

Send and receive text messages and emojis

Chat UI similar to popular messaging apps

Grouped messages by date

Scroll to the latest message automatically

Responsive UI for mobile devices



Getting Started
Prerequisites

Flutter SDK (latest stable version)

Dart

Firebase project setup

IDE: VSCode / Android Studio
1.Clone the repository:
git clone https://github.com/your-username/nexchat.git
2.Install dependencies:
flutter pub get
3.Setup Firebase:

Create a Firebase project at Firebase Console

Add Android/iOS apps and download google-services.json (Android) / GoogleService-Info.plist (iOS)

Place them in the respective directories

Enable Authentication and Firestore
4.Run the app:
flutter run


