# flutter_parental_control

Plugin để kiểm soát thiết bị và ứng dụng trên thiết bị của trẻ em..

## Getting Started
Yêu cầu phần mềm để sử dụng plugin

Plugin yêu cầu phiên bản dart 3.5.0 trở lên.

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
         ref: 0.0.1 # Chọn phiên bản phù hợp
```
2. **Chạy lệnh:** 
    Mở terminal và chạy lệnh sau để tải về các gói phụ thuộc:
    ```bash
    flutter pub get
   ```
3. **Sử dụng trong ứng dụng:**

    Trong ứng dụng để sử dụng plugin cần thêm dòng sau
    ```dart
   import 'package:flutter_parental_control/flutter_parental_control.dart';
   ```
## Các cách xử lý khi có lỗi
Khi gặp lỗi build.gradle thì có thể thử các cách sau:
### Cách 1. **Cập nhật tệp `android/setting.gradle` và `gradle-wrapper.properties`:**

   Thay đổi phiên bản của các thành phần sau:
   Trong `android/setting.gradle` cập nhật:
   ```groovy
   id "com.android.application" version "8.0.2" apply false // chọn phiên bản phù hợp
   ```
   Trong `gradle-wrapper.properties` cập nhật:
   ```properties
   distributionUrl=https\://services.gradle.org/distributions/gradle-8.10.2-bin.zip #thay đổi phiên bản phù hơp
   ```
   
### Cách 2. **Cập nhật tệp `android/build.gradle` và `app/build.gradle`:**
   Nếu cách trên không được thì thử cách này:
Bước 1:
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
   ```
Bước 2:
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
```
   
## Sử dụng

### Để sử dụng chức năng Google Map cần thêm API Key vào `AndroidManifest.xml` và `AppDelegate.swift`:
Android:
```xml
        <application>
        <!--        Thêm API key vào đây-->
        <meta-data android:name="com.google.android.geo.API_KEY"
        android:value="YOUR_API_KEY"/>
        </application>
```
iOS:
   ```swift
    GMSServices.provideAPIKey("YOUR_API_KEY")
   ```
Nếu cần lấy vị trí của thiết bị thì cần thêm quyền vào `Info.plist`:
   ```text
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>This app needs access to location when open.</string>
   ```

