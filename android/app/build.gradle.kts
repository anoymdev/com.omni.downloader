import java.util.Properties

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
    // END: FlutterFire Configuration
    id("kotlin-android")
    id("com.chaquo.python")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
}

fun signingValue(name: String, localName: String): String? =
    providers.gradleProperty(name).orElse(providers.environmentVariable(name)).orNull
        ?.takeIf { it.isNotBlank() }
        ?: keystoreProperties.getProperty(name)?.takeIf { it.isNotBlank() }
        ?: keystoreProperties.getProperty(localName)?.takeIf { it.isNotBlank() }

val releaseKeystorePath = signingValue("ANDROID_KEYSTORE_PATH", "storeFile")
val releaseKeystorePassword = signingValue("ANDROID_KEYSTORE_PASSWORD", "storePassword")
val releaseKeyAlias = signingValue("ANDROID_KEY_ALIAS", "keyAlias")
val releaseKeyPassword = signingValue("ANDROID_KEY_PASSWORD", "keyPassword")
val releaseKeystoreFile = releaseKeystorePath?.let { rootProject.file(it) }
val releaseSigningReady = listOf(
    releaseKeystorePath,
    releaseKeystorePassword,
    releaseKeyAlias,
    releaseKeyPassword,
).all { it != null } && releaseKeystoreFile?.isFile == true

android {
    namespace = "com.omni.downloader"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.omni.downloader"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 24
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        ndk {
            abiFilters += listOf("arm64-v8a", "x86_64")
        }
    }

    signingConfigs {
        if (releaseSigningReady) {
            create("release") {
                storeFile = releaseKeystoreFile!!
                storePassword = releaseKeystorePassword!!
                keyAlias = releaseKeyAlias!!
                keyPassword = releaseKeyPassword!!
            }
        }
    }

    buildTypes {
        release {
            if (releaseSigningReady) {
                signingConfig = signingConfigs.getByName("release")
            }
            isMinifyEnabled = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

gradle.taskGraph.whenReady {
    val releaseTaskRequested = allTasks.any {
        it.project == project && it.name.contains("Release")
    }
    if (releaseTaskRequested && !releaseSigningReady) {
        throw GradleException(
            "Release signing is not configured. Provide android/key.properties " +
                "(storeFile, storePassword, keyAlias, keyPassword) or Gradle " +
                "properties/environment variables: ANDROID_KEYSTORE_PATH, " +
                "ANDROID_KEYSTORE_PASSWORD, ANDROID_KEY_ALIAS, ANDROID_KEY_PASSWORD, " +
                "and ensure the keystore file exists."
        )
    }
}

chaquopy {
    defaultConfig {
        version = "3.12"
        val chaquopyPython = providers.gradleProperty("chaquopy.python")
            .orElse(providers.environmentVariable("CHAQUOPY_PYTHON"))
            .orNull
            ?.takeIf { it.isNotBlank() }
        if (chaquopyPython != null) {
            buildPython(chaquopyPython)
        }
        pip {
            install("yt-dlp")
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}
