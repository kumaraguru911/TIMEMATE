# TIMEMATE
=========================================
# TimeMate - College Timetable App

A beautiful Flutter app to plan and organize college timetables, featuring multiple class inputs, grouping by day, animations, persistent storage, and more.

## Features

- Add, view, and organize multiple classes
- Classes grouped by day for easy viewing
- Animated class list for a modern UI experience
- Persistent storage using Shared Preferences
- Custom fonts with Google Fonts
- Custom launcher icon
- Asset image support
- Gradient backgrounds and modern transitions
- Animated page transitions and card opening (OpenContainer)
- Lottie animation for empty state

## Getting Started

### 1. Clone the repository
```
git clone <your-repo-url>
cd class_timetable_app/class_timetable_app
```

### 2. Install dependencies
```
flutter pub get
```

This will install all required packages, including:
- animations
- lottie

### 3. Add your images
Place your images in the `assets/` folder. Register them in `pubspec.yaml` under the `assets:` section:
```yaml
flutter:
  assets:
    - assets/your_image.png
```

### 4. Run the app
Connect your device or start an emulator, then run:
```
flutter run
```

Or press **F5** in VS Code.

### 5. Custom Launcher Icon
This app uses `flutter_launcher_icons` for a custom app icon. To regenerate icons after changing the image, run:
```
flutter pub run flutter_launcher_icons:main
```

## Screenshots

Here are some screenshots of the app:

<img src="assets/addpage.jpg" alt="add table" width="400"/>

![Add Class Page](assets/addpage.jpg)

![Front Page](assets/front.jpg)

![Home Page](assets/home.jpg)

-------------------------------------------------------------------------

For more information, see the [Flutter documentation](https://docs.flutter.dev/).
e627169 (Initial commit: TimeMate app with enhanced UI and features)
