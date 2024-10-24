# flutter_parental_control

Plugin to control devices and applications on children's devices.

## Getting Started

This project is a starting point for a Flutter
[plug-in package](https://flutter.dev/to/develop-plugins),
a specialized package that includes platform-specific implementation code for
Android and iOS.

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Installation

To install this plugin, follow these steps:

1. **Add dependency:**

   In your Flutter project's `pubspec.yaml` file, add `flutter_parental_control` as a dependency:

   ```yaml
   dependencies:
     flutter:
       sdk: flutter
     flutter_parental_control:
        git:
            url: https://github.com/vinhhao-2001/flutter_parental_control.git
            ref: 0.0.1
2. **In android/build.gradle:**
    Add code:
    buildscript {
      repositories {
         google()
         mavenCentral()
      }

      dependencies {
      classpath "io.realm:realm-gradle-plugin:10.14.0" // add line
      }
   }
3. **In android/build.gradle:**
    Add: in plugins
   id 'kotlin-kapt'
   id "realm-android"
