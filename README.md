# Flutter Riverpod Demo

一个功能完整的 Flutter 应用程序，展示了现代移动应用开发的最佳实践。该项目基于 **Riverpod** 状态管理、**Go Router** 路由导航，集成了应用内购买、第三方登录、网络请求等核心功能。

![Flutter](https://img.shields.io/badge/Flutter-3.5.4-blue)
![Dart](https://img.shields.io/badge/Dart-SDK-blue)
![License](https://img.shields.io/badge/License-MIT-green)

## ✨ 核心特性

### 🏗️ 架构设计
- **状态管理**: 使用 Riverpod 2.6.1 进行现代化状态管理
- **路由导航**: 基于 Go Router 15.1.2 的声明式路由
- **项目架构**: 清晰的分层架构设计（View/Model/Service/Util）
- **响应式设计**: 使用 flutter_screenutil 进行屏幕适配

### 💰 应用内购买系统
- **多类型商品支持**: 消耗型商品（代币）和订阅型商品（Pro/Pro Plus）
- **跨平台兼容**: 支持 iOS App Store 和 Google Play
- **购买流程管理**: 完整的购买、恢复、验证流程
- **错误处理**: 全面的异常处理和用户提示

### 🔐 第三方认证
- **Apple 登录**: 支持 Sign in with Apple
- **Google 登录**: 集成 Google Sign-In
- **权限管理**: iOS 应用跟踪透明度支持

### 🌐 网络与存储
- **HTTP 客户端**: 基于 Dio 的完整网络解决方案
- **SSE 支持**: 服务器发送事件流式数据处理
- **本地存储**: SharedPreferences + 安全存储
- **缓存管理**: 文件缓存和内存缓存
- **网络状态**: 实时网络连接监测

### 🎨 UI/UX 设计
- **Material 3**: 现代化的 Material Design 3 设计系统
- **自定义字体**: Bitter 字体族完整集成
- **屏幕适配**: 多设备尺寸自适应
- **国际化**: 内置国际化支持框架

### 🔧 开发工具
- **日志系统**: 结构化日志记录
- **设备信息**: 跨平台设备标识和信息获取
- **加密工具**: SHA256/MD5 加密算法
- **分享功能**: 内容分享到第三方应用
- **URL 启动**: 外部链接和应用跳转

## 📁 项目结构

```
lib/
├── main.dart                    # 应用入口点
├── view/                        # UI 层
│   ├── my_app.dart             # 应用根组件
│   ├── splash/                 # 启动页
│   ├── home/                   # 主页
│   ├── purchase/               # 购买页面
│   └── not_found/             # 404 页面
├── model/                       # 数据模型
│   ├── product.dart            # 商品模型
│   ├── network_status.dart     # 网络状态
│   └── http_method.dart        # HTTP 方法枚举
├── service/                     # 业务服务层
│   ├── app_service.dart        # 应用服务
│   ├── http_service.dart       # 网络服务
│   ├── storage_service.dart    # 存储服务
│   └── network_service.dart    # 网络监控
├── component/                   # 通用组件
│   ├── global_text.dart        # 全局文本组件
│   └── global_button.dart      # 全局按钮组件
├── constant/                    # 常量配置
│   ├── app_config.dart         # 应用配置
│   ├── theme.dart              # 主题配置
│   └── image_path.dart         # 图片路径
└── util/                        # 工具类
    ├── navigate.dart           # 路由导航
    ├── log.dart                # 日志工具
    ├── toast.dart              # 提示工具
    ├── tool.dart               # 通用工具
    └── secure_storage.dart     # 安全存储
```

## 🚀 快速开始

### 环境要求

- Flutter SDK 3.5.4+
- Dart SDK 3.0+
- iOS 12.0+ / Android API 21+

### 安装依赖

```bash
flutter pub get
```

### 配置第三方服务

1. **Apple 登录配置**
   ```dart
   // lib/constant/app_config.dart
   final appleLoginOnAndroidClientId = 'YOUR_APPLE_CLIENT_ID';
   final appleLoginOnAndroidRedirectUri = 'YOUR_REDIRECT_URI';
   ```

2. **Google 登录配置**
   ```dart
   // lib/constant/app_config.dart
   final androidWebServerClientId = 'YOUR_GOOGLE_CLIENT_ID';
   ```

3. **应用内购买产品ID**
   ```dart
   // lib/constant/app_config.dart
   final token700ProductId = 'com.yourapp.token700';
   final proMonthlyProductId = 'com.yourapp.pro.monthly';
   ```

### 运行应用

```bash
# 调试模式
flutter run

# 发布模式
flutter run --release

# 指定设备
flutter run -d ios
flutter run -d android
```

## 📱 功能展示

### 启动流程
1. **Splash 页面**: 显示应用图标，初始化服务
2. **服务初始化**: 存储服务、应用信息、设备信息
3. **自动导航**: 完成初始化后跳转到主页

### 主页功能
- **Apple 登录**: 一键使用 Apple ID 登录
- **Google 登录**: 快速 Google 账号认证
- **购买入口**: 跳转到应用内购买页面

### 购买系统
- **商品展示**: 显示订阅和消耗型商品
- **价格显示**: 实时获取本地化价格
- **购买流程**: 完整的支付和验证流程
- **恢复购买**: 支持跨设备购买恢复

## 🔧 核心技术栈

### 状态管理
```dart
# Riverpod Provider 示例
final purchaseProvider = ChangeNotifierProvider<PurchaseNotifier>((ref) {
  return PurchaseNotifier();
});
```

### 路由导航
```dart
# Go Router 配置
GoRoute(
  path: '/purchase',
  name: 'purchase',
  builder: (context, state) => const PurchasePage(),
)
```

### 网络请求
```dart
# HTTP 服务调用
final response = await HttpService.instance.get(
  '/api/user/profile',
  queryParameters: {'id': userId},
);
```

### 应用内购买
```dart
# 购买商品
await purchaseNotifier.purchaseProduct('com.app.pro.monthly');
```

## 🛠️ 开发指南

### 添加新页面
1. 在 `lib/view/` 下创建页面文件
2. 在 `util/navigate.dart` 中添加路由
3. 如需状态管理，创建对应的 Provider

### 添加网络接口
1. 在相应的 Service 中添加方法
2. 使用 `HttpService.instance` 进行请求
3. 添加错误处理和日志记录

### 自定义组件
1. 在 `component/` 目录下创建组件
2. 继承 StatelessWidget 或 StatefulWidget
3. 使用全局主题和样式配置

## 📋 依赖清单

### 核心架构
- `flutter_riverpod: ^2.6.1` - 状态管理
- `go_router: ^15.1.2` - 路由导航
- `flutter_screenutil: ^5.9.3` - 屏幕适配

### 网络与存储
- `dio: ^5.8.0+1` - HTTP 客户端
- `shared_preferences: ^2.5.3` - 本地存储
- `flutter_secure_storage: ^9.2.4` - 安全存储
- `connectivity_plus: ^6.1.4` - 网络监控

### 第三方集成
- `sign_in_with_apple: ^7.0.1` - Apple 登录
- `google_sign_in: ^6.2.2` - Google 登录
- `in_app_purchase: ^3.2.3` - 应用内购买

### 工具类库
- `logger: ^2.5.0` - 日志记录
- `crypto: ^3.0.6` - 加密算法
- `uuid: ^4.5.1` - UUID 生成
- `bot_toast: ^4.1.3` - 消息提示

## 🏗️ 构建与发布

### Android 构建
```bash
# 生成 APK
flutter build apk --release

# 生成 App Bundle
flutter build appbundle --release
```

### iOS 构建
```bash
# 生成 iOS 应用
flutter build ios --release

# 使用 Xcode 构建
open ios/Runner.xcworkspace
```

### 版本管理
- 版本格式: `1.0.0+1000001`
- 主版本.次版本.修订号+构建号
- 构建号格式: 主版本(1位).次版本(2位).修订号(2位).构建号(2位)

## 🤝 贡献指南

1. Fork 本仓库
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建 Pull Request

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 📞 联系方式

如有问题或建议，请通过以下方式联系：

- 创建 [Issue](https://github.com/wl1395182472/flutter_riverpod_demo/issues)
- 发送邮件至: your-email@example.com

---

**注意**: 使用前请确保正确配置所有第三方服务的 API 密钥和产品ID。
