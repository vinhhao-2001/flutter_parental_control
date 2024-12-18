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

## Xử lý khi có lỗi

Khi gặp lỗi build.gradle khi thêm plugin thì có thể thử cách sau:

### Cập nhật tệp `android/setting.gradle` và `gradle-wrapper.properties`:

Thay đổi phiên bản của các thành phần sau:
Trong `android/setting.gradle` cập nhật:

   ```groovy
   id "com.android.application" version "8.0.2" apply false // chọn phiên bản phù hợp
   ```

Trong `gradle-wrapper.properties` thay đổi phiên bản của gradle phù hợp:

   ```properties
   distributionUrl=https\://services.gradle.org/distributions/gradle-8.10.2-bin.zip
   ```

Nếu có lỗi do phiên bản của flutter thì thêm đoạn code sau vào build.gradle của project:

   ```groovy
   subprojects {
    afterEvaluate { project ->
        if (project.plugins.hasPlugin("com.android.application") ||
                project.plugins.hasPlugin("com.android.library")) {
            project.android {
                compileSdkVersion 34
            }
        }
     }
    }
   ```

## Sử dụng bản đồ

### Để sử dụng chức năng Google Map cần thêm API Key vào `AndroidManifest.xml` và `AppDelegate.swift`:

Android:

```xml

<application>
    <!--        Thêm API key vào đây-->
    <meta-data android:name="com.google.android.geo.API_KEY" android:value="YOUR_API_KEY" />
</application>
```

iOS:

   ```swift
    GMSServices.provideAPIKey("YOUR_API_KEY")
   ```

Nếu cần lấy vị trí của thiết bị thì cần thêm quyền vào `Info.plist` với iOS:

   ```text
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>This app needs access to location when open.</string>
   ```

