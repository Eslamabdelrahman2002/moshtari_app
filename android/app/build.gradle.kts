import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.rasad.sa.mushtary"

    @Suppress("UnstableApiUsage")
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

        // minSdk 26 required by myfatoorah_flutter plugin
        minSdk = 26

        @Suppress("UnstableApiUsage")
        targetSdk = flutter.targetSdkVersion.toInt()
        @Suppress("UnstableApiUsage")
        versionCode = flutter.versionCode.toInt()
        @Suppress("UnstableApiUsage")
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    signingConfigs {
        // Only release signing; let AGP handle debug keystore automatically
        create("release") {
            val keystorePropertiesFile = rootProject.file("key.properties")
            val keystoreProperties = Properties()
            var hasSigningProps = false

            if (keystorePropertiesFile.exists()) {
                FileInputStream(keystorePropertiesFile).use { fis ->
                    keystoreProperties.load(fis)
                }
                if (keystoreProperties.containsKey("storeFile")) {
                    hasSigningProps = true
                }
            }

            if (hasSigningProps) {
                storeFile = file(keystoreProperties["storeFile"].toString())
                storePassword = keystoreProperties["storePassword"].toString()
                keyAlias = keystoreProperties["keyAlias"].toString()
                keyPassword = keystoreProperties["keyPassword"].toString()
            }
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            isDebuggable = false
            signingConfig = signingConfigs.getByName("release")
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }

        debug {
            isDebuggable = true
            // No explicit debug signingConfig; AGP will use the default debug keystore
        }
    }

    buildFeatures {
        buildConfig = true
    }

    packagingOptions {
        resources.excludes.add("META-INF/*")
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    implementation("androidx.multidex:multidex:2.0.1")
}