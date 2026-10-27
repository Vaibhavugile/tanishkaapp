import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")

    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
    // END: FlutterFire Configuration

    id("kotlin-android")

    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

////////////////////////////////////////////////////////////
/// LOAD KEY.PROPERTIES
////////////////////////////////////////////////////////////

val keystoreProperties = Properties()

val keystorePropertiesFile =
    rootProject.file("key.properties")

if (keystorePropertiesFile.exists()) {
    FileInputStream(keystorePropertiesFile).use {
        keystoreProperties.load(it)
    }
}

android {

    ////////////////////////////////////////////////////////////
    /// ANDROID PACKAGE
    ////////////////////////////////////////////////////////////

    namespace = "com.yani.wholesalejewellery"

    compileSdk = flutter.compileSdkVersion

    ndkVersion = flutter.ndkVersion

    ////////////////////////////////////////////////////////////
    /// JAVA
    ////////////////////////////////////////////////////////////

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    ////////////////////////////////////////////////////////////
    /// KOTLIN
    ////////////////////////////////////////////////////////////

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    ////////////////////////////////////////////////////////////
    /// DEFAULT CONFIG
    ////////////////////////////////////////////////////////////

    defaultConfig {

        applicationId = "com.yani.wholesalejewellery"

        minSdk = flutter.minSdkVersion

        targetSdk = flutter.targetSdkVersion

        versionCode = flutter.versionCode

        versionName = flutter.versionName
    }

    ////////////////////////////////////////////////////////////
    /// SIGNING CONFIGURATION
    ////////////////////////////////////////////////////////////

    signingConfigs {

        create("release") {

            if (keystorePropertiesFile.exists()) {

                keyAlias =
                    keystoreProperties["keyAlias"] as String?

                keyPassword =
                    keystoreProperties["keyPassword"] as String?

                storeFile =
                    keystoreProperties["storeFile"]
                        ?.let { file(it as String) }

                storePassword =
                    keystoreProperties["storePassword"] as String?
            }
        }
    }

    ////////////////////////////////////////////////////////////
    /// BUILD TYPES
    ////////////////////////////////////////////////////////////

    buildTypes {

        release {

            //////////////////////////////////////////////////////
            /// USE RELEASE KEYSTORE
            //////////////////////////////////////////////////////

            signingConfig =
                signingConfigs.getByName("release")

            //////////////////////////////////////////////////////
            /// OPTIONAL RELEASE OPTIMIZATION
            //////////////////////////////////////////////////////

            isMinifyEnabled = false

            isShrinkResources = false
        }
    }
}

////////////////////////////////////////////////////////////
/// FLUTTER
////////////////////////////////////////////////////////////

flutter {
    source = "../.."
}