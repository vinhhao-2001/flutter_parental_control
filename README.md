# flutter_parental_control

Plugin để kiểm soát thiết bị và ứng dụng trên thiết bị của trẻ em..

## Getting Started

This project is a starting point for a Flutter
[plug-in package](https://flutter.dev/to/develop-plugins),
a specialized package that includes platform-specific implementation code for
Android and iOS.

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Cài đặt

Để cài đặt plugin này, hãy làm theo các bước sau:

1. **Thêm phụ thuộc:**

   Mở tệp `pubspec.yaml` trong dự án Flutter của bạn và thêm đoạn code sau:
   ```yaml
   dependencies:
     flutter:
       sdk: flutter
     realm: ^20.0.0 # thêm realm
     flutter_parental_control: # thêm plugin
       git:
         url: https://github.com/vinhhao-2001/flutter_parental_control.git
         ref: 0.0.1
   
2. **Cập nhật tệp `android/build.gradle`:**

    Mở tệp `build.gradle` trong thư mục `android` của dự án và thêm dòng code bên dưới.
    Nếu chưa có phần `buildscript` thì thêm cả đoạn code bên dưới vào phần đầu của file:
    ```groovy
    buildscript {
      repositories {
         google()
         mavenCentral()
      }

      dependencies {
      classpath "io.realm:realm-gradle-plugin:10.14.0" // thêm dòng này
      }
   }
3. **In `app/build.gradle`:**

   Mở tệp `build.gradle` trong thư mục `android/app` của dự án và sửa lại đoạn code sau:
    ```groovy
   plugins {
    id "com.android.application"
    id "kotlin-android"
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id 'kotlin-kapt'
    id "realm-android"
    id "dev.flutter.flutter-gradle-plugin"
   }
4. Chạy lệnh:
   
    Mở terminal và chạy lệnh sau để tải về các gói phụ thuộc:
    ```bash
    flutter pub get