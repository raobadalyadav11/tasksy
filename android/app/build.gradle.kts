plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

def localProperties = new Properties()
def localPropertiesFile = rootProject.file('local.properties')
if (localPropertiesFile.exists()) {
    localPropertiesFile.withReader('UTF-8') { reader ->
        localProperties.load(reader)
    }
}

def flutterVersionCode = localProperties.getProperty('flutter.versionCode')
if (flutterVersionCode == null) {
    flutterVersionCode = '1'
}

def flutterVersionName = localProperties.getProperty('flutter.versionName')
if (flutterVersionName == null) {
    flutterVersionName = '1.0'
}

android {
    namespace = "com.tasksy.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = '1.8'
    }

    sourceSets {
        main.java.srcDirs += 'src/main/kotlin'
    }

    defaultConfig {
        applicationId = "com.tasksy.app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutterVersionCode.toInteger()
        versionName = flutterVersionName
        multiDexEnabled = true
    }

    signingConfigs {
        release {
            keyAlias = localProperties.getProperty('keyAlias')
            keyPassword = localProperties.getProperty('keyPassword')
            storeFile = localProperties.getProperty('storeFile') != null ? file(localProperties.getProperty('storeFile')) : null
            storePassword = localProperties.getProperty('storePassword')
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.release
            minifyEnabled = true
            shrinkResources = true
            proguardFiles = getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
        debug {
            signingConfig = signingConfigs.debug
            debuggable = true
        }
    }
}

flutter {
    source = '../..'
}

dependencies {
    implementation("androidx.multidex:multidex:2.0.1")
}