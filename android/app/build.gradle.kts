// android/app/build.gradle.kts
plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android") // 👈 تم التغيير من "kotlin-android" ليتوافق مع الإعدادات
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") version "4.4.2"
}

android {
    namespace = "com.rasad.sa.mushtary"
    compileSdk = flutter.compileSdkVersion.toInt()
    ndkVersion = "28.0.12433566"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.rasad.sa.mushtary"
        // FIX: تم تثبيت minSdk على 26 لدعم مكتبة myfatoorah_flutter الحديثة وبعض مكونات Firebase
        minSdk = 26

        targetSdk = flutter.targetSdkVersion.toInt()
        versionCode = flutter.versionCode.toInt()
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    // ✅ Use the modern AndroidX version of Multidex
    implementation("androidx.multidex:multidex:2.0.1")
    // You can also try 2.0.2 or 2.0.0 if 2.0.1 doesn't resolve immediately.
}