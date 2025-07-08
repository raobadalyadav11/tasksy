# 📱 Tasksy - Professional Todo & Habit Tracker

<div align="center">
  <img src="assets/images/logo.png" alt="Tasksy Logo" width="120" height="120">
  
  **Boost your productivity with smart task management, habit tracking, and detailed analytics.**
  
  [![Flutter](https://img.shields.io/badge/Flutter-3.8.0+-blue.svg)](https://flutter.dev/)
  [![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
  [![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey.svg)](https://flutter.dev/)
</div>

## ✨ Features

### 📋 **Task Management**
- Create, organize, and track daily tasks
- Set due dates, priorities, and categories
- Recurring tasks (daily, weekly, monthly)
- Smart filtering and search
- Swipe gestures for quick actions

### 🎯 **Habit Tracking**
- Build lasting habits with streak tracking
- Visual progress indicators and heatmaps
- Customizable habit colors and frequencies
- Milestone celebrations and rewards

### 📊 **Analytics Dashboard**
- Detailed productivity statistics
- Visual charts and progress tracking
- Category breakdowns and trends
- Weekly/monthly/yearly insights

### 🔔 **Smart Reminders**
- Customizable notifications with sound
- Task due date reminders
- Daily habit check-ins
- Overdue task alerts
- Streak milestone celebrations

### 🎨 **Customization**
- Multiple themes (light, dark, premium)
- Personalized color schemes
- Custom notification sounds
- Flexible layout options

### 💰 **Monetization**
- Non-intrusive banner ads
- Rewarded ads for premium features
- Interstitial ads with skip options
- Premium theme unlocks

## 🚀 Getting Started

### Prerequisites
- Flutter 3.8.0 or higher
- Dart 3.0.0 or higher
- Android Studio / VS Code
- Android SDK / Xcode (for iOS)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/tasksy/tasksy-app.git
   cd tasksy-app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Building for Production

#### Android
```bash
flutter build apk --release
# or for app bundle
flutter build appbundle --release
```

#### iOS
```bash
flutter build ios --release
```

## 🏗️ Architecture

### Project Structure
```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── task.dart
│   └── habit.dart
├── screens/                  # UI screens
│   ├── home_screen.dart
│   ├── habits_screen.dart
│   ├── analytics_screen.dart
│   └── settings_screen.dart
├── services/                 # Business logic
│   ├── storage_service.dart
│   ├── notification_service.dart
│   ├── ad_service.dart
│   └── popup_service.dart
├── widgets/                  # Reusable components
│   ├── task_card.dart
│   └── progress_card.dart
└── utils/                    # Utilities
    ├── constants.dart
    ├── validators.dart
    └── error_handler.dart
```

### Key Technologies
- **Flutter**: Cross-platform mobile framework
- **SharedPreferences**: Local data storage
- **flutter_local_notifications**: Push notifications
- **google_mobile_ads**: AdMob integration
- **fl_chart**: Data visualization
- **another_flushbar**: Enhanced notifications
- **overlay_support**: Custom overlays

## 📱 Screenshots

| Home Screen | Habit Tracker | Analytics | Settings |
|-------------|---------------|-----------|----------|
| ![Home](screenshots/home.png) | ![Habits](screenshots/habits.png) | ![Analytics](screenshots/analytics.png) | ![Settings](screenshots/settings.png) |

## 🎯 Key Features Breakdown

### Task Management
- ✅ CRUD operations (Create, Read, Update, Delete)
- ✅ Priority system with visual indicators
- ✅ Category organization
- ✅ Due date tracking with overdue detection
- ✅ Recurring task automation
- ✅ Search and filtering capabilities

### Habit Tracking
- ✅ Streak counting and visualization
- ✅ Progress percentage tracking
- ✅ Customizable habit colors
- ✅ Frequency settings (daily/weekly/monthly)
- ✅ Completion history
- ✅ Milestone celebrations

### Analytics
- ✅ Task completion statistics
- ✅ Habit streak analytics
- ✅ Category breakdown charts
- ✅ Productivity trend graphs
- ✅ Time-based filtering
- ✅ Visual progress indicators

### Notifications
- ✅ Local push notifications
- ✅ Custom notification sounds
- ✅ Smart reminder scheduling
- ✅ Notification permission handling
- ✅ Background notification processing

## 🔧 Configuration

### AdMob Setup
1. Replace test ad unit IDs in `lib/services/ad_service.dart`
2. Update `android/app/src/main/AndroidManifest.xml` with your AdMob App ID
3. Configure iOS ad settings in `ios/Runner/Info.plist`

### Notification Setup
1. Configure notification icons in `android/app/src/main/res/`
2. Set up iOS notification permissions in `ios/Runner/Info.plist`
3. Customize notification sounds in `assets/sounds/`

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Material Design for beautiful icons
- Open source community for valuable packages
- Beta testers and early users for feedback

## 📞 Support

- 📧 Email: support@tasksy.app
- 🌐 Website: [tasksy.app](https://tasksy.app)
- 🐛 Issues: [GitHub Issues](https://github.com/tasksy/tasksy-app/issues)
- 💬 Discussions: [GitHub Discussions](https://github.com/tasksy/tasksy-app/discussions)

## 🚀 Roadmap

- [ ] Cloud synchronization
- [ ] Team collaboration features
- [ ] Widget support
- [ ] Apple Watch integration
- [ ] Web version
- [ ] Desktop applications

---

<div align="center">
  Made with ❤️ using Flutter
  
  **[Download on Google Play](https://play.google.com/store/apps/details?id=com.tasksy.app)** | **[Download on App Store](https://apps.apple.com/app/tasksy/id123456789)**
</div>