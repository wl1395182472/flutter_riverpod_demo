// 声明所需的插件
import java.util.Properties
import java.io.FileInputStream

plugins {
    // Android 应用插件，提供构建 Android 应用的功能
    id("com.android.application")
    // Kotlin 插件，支持在 Android 项目中使用 Kotlin 语言
    id("kotlin-android")
    // Flutter Gradle 插件必须在 Android 和 Kotlin Gradle 插件之后应用
    // Flutter 插件，支持 Flutter 模块的集成
    id("dev.flutter.flutter-gradle-plugin")
}

// 加载签名密钥配置
// 创建 Properties 对象用于存储密钥信息
val keystoreProperties = Properties()
// 指定密钥属性文件路径
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    // 检查文件是否存在
    // 加载密钥属性文件
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    // TODD: 应用的包名，用于标识应用
    namespace = "com.example.flutter_riverpod_demo"
    // 编译 SDK 版本，从 Flutter 插件获取
    compileSdk = flutter.compileSdkVersion
    // 将 NDK 版本更新为插件所需的最高版本
    ndkVersion = flutter.ndkVersion

    // Java 编译选项配置
    compileOptions {
        // 源代码兼容的 Java 版本
        sourceCompatibility = JavaVersion.VERSION_11
        // 目标 Java 版本
        targetCompatibility = JavaVersion.VERSION_11
    }

    // Kotlin 编译选项配置
    kotlinOptions {
        // Kotlin 编译的目标 JVM 版本
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    // 默认配置，适用于所有构建变体
    defaultConfig {
        // TODD: 应用 ID，用于在应用商店和设备上唯一标识应用
        applicationId = "com.example.flutter_riverpod_demo"
        // 最低支持的 Android SDK 版本
        minSdk = flutter.minSdkVersion
        // 目标 SDK 版本，从 Flutter 插件获取
        targetSdk = flutter.targetSdkVersion
        // 版本号，用于应用更新识别
        versionCode = flutter.versionCode
        // 版本名称，对用户可见的版本标识
        versionName = flutter.versionName
        // 启用多 Dex 支持，解决方法数超过 65535 的限制
        multiDexEnabled = true

        /**
         * 常见 ABI 架构列表（用于 abiFilters）
         * 
         * ABI 名称      描述                 常用于设备
         * armeabi      已废弃，32位 ARM 架构   老旧 ARM 设备
         * armeabi-v7a  较新的 32 位 ARM 架构  大部分 Android 手机
         * arm64-v8a    64 位 ARM 架构        新一代 Android 手机
         * x86          32 位 Intel 架构      模拟器、部分平板
         * x86_64       64 位 Intel 架构      模拟器、部分 Chromebook
         */
        ndk {
            // 指定支持的 CPU 架构
            abiFilters += listOf("arm64-v8a")
            // 调试符号级别，用于崩溃分析
            debugSymbolLevel = "SYMBOL_TABLE"
        }
    }

    // 自动化打包签名配置
    signingConfigs {
        create("release") {
            // 密钥别名
            keyAlias = keystoreProperties["keyAlias"]?.toString()
            // 密钥密码
            keyPassword = keystoreProperties["keyPassword"]?.toString()
            // 密钥库文件路径
            storeFile = keystoreProperties["storeFile"]?.let { file(it.toString()) }
            // 密钥库密码
            storePassword = keystoreProperties["storePassword"]?.toString()
        }
    }

    buildTypes { 
        getByName("release") {
            isMinifyEnabled = true
            isShrinkResources = true
            // 是否对APK包执行ZIP对齐优化，减小zip体积，增加运行效率
            isZipAlignEnabled = true
            //指定混淆的规则文件
            proguardFiles(getDefaultProguardFile("proguard-android.txt"), "proguard-rules.pro")
            //设置签名信息
            signingConfig = signingConfigs.getByName("release")
            
            // TODD: 为 release 版本添加 Google 客户端 ID
            manifestPlaceholders["googleAuthClientId"] = ""
        }
        
        getByName("debug") {
            isMinifyEnabled = true
            isShrinkResources = true
            isZipAlignEnabled = true
            proguardFiles(getDefaultProguardFile("proguard-android.txt"), "proguard-rules.pro")
            signingConfig = signingConfigs.getByName("release")
            
            // TODD: 为 debug 版本添加不同的 Google 客户端 ID
            manifestPlaceholders["googleAuthClientId"] = ""
        }
    }
}

flutter {
    source = "../.."
}
