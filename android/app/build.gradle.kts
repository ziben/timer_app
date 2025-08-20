plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

import java.text.SimpleDateFormat
import java.util.Date

android {
    namespace = "com.example.timer_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.timer_app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    // 自定义APK输出名称
    applicationVariants.all {
        outputs.all { 
            val versionName = defaultConfig.versionName
            val versionCode = defaultConfig.versionCode
            val date = SimpleDateFormat("yyyyMMdd").format(Date())
            val buildType = buildType.name
            (this as com.android.build.gradle.internal.api.BaseVariantOutputImpl).outputFileName = "TimerApp_v${versionName}_${date}_${buildType}.apk"            
        }
    }
}

flutter {
    source = "../.."
}
