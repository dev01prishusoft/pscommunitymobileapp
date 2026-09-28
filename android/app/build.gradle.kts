import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")

if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.unviora.app"
    compileSdk = 37
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.unviora.app"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
       if (keystorePropertiesFile.exists()) { 
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
       }
    }
     
    buildTypes {
        release {
            val isReleaseBuild = gradle.startParameter.taskNames.any {
                it.contains("release", ignoreCase = true) || it.contains("bundle", ignoreCase = true)
            }
            if (!keystorePropertiesFile.exists()) {
                if (isReleaseBuild) {
                    throw GradleException("key.properties required for release builds")
                }
            } else {
                signingConfig = signingConfigs.getByName("release")
            }
            
            isMinifyEnabled    = false
            isShrinkResources = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
        
        debug {
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

gradle.taskGraph.whenReady {
    if (!keystorePropertiesFile.exists()) {
        val hasReleaseTask = allTasks.any {
            it.name.contains("Release", ignoreCase = true) || it.name.contains("bundle", ignoreCase = true)
        }
        if (hasReleaseTask) {
            throw GradleException("key.properties required for release builds")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
