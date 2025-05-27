import 'package:bot_toast/bot_toast.dart' show BotToast;
import 'package:flutter/material.dart'
    show
        StatefulWidget,
        State,
        BuildContext,
        Widget,
        Image,
        Hero,
        Center,
        Expanded,
        MainAxisSize,
        Column,
        SafeArea,
        Scaffold;
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart' show GoogleSignIn;
import 'package:sign_in_with_apple/sign_in_with_apple.dart'
    show
        WebAuthenticationOptions,
        generateNonce,
        SignInWithAppleAuthorizationException,
        SignInWithAppleNotSupportedException,
        SignInWithAppleCredentialsException,
        SignInWithApple,
        AppleIDAuthorizationScopes,
        AuthorizationErrorCode;

import '../../component/global_button.dart' show GlobalButton;
import '../../constant/app_config.dart' show AppConfig;
import '../../constant/image_path.dart' show ImagePath;
import '../../util/log.dart' show Log;
import '../../util/toast.dart' show Toast;
import '../../util/tool.dart' show Tool;

/// 应用主页组件
///
/// 提供以下主要功能：
/// - Apple 登录
/// - Google 登录
/// - 跳转到购买页面
/// - 应用图标展示
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// 苹果登录在Android平台的Web认证配置
  /// 配置客户端ID和重定向URI，用于处理Apple登录的OAuth流程
  final webAuthenticationOptions = WebAuthenticationOptions(
    clientId: AppConfig.instance.appleLoginOnAndroidClientId,
    redirectUri: Uri.parse(AppConfig.instance.appleLoginOnAndroidRedirectUri),
  );

  /// 谷歌登录工具单例
  /// 配置必要的权限范围和服务器客户端ID
  final _googleSignIn = GoogleSignIn(
    scopes: ['email', 'openid'], // 请求邮箱和OpenID权限
    serverClientId: AppConfig.instance.androidWebServerClientId,
  );

  /// 处理Apple登录逻辑
  ///
  /// 执行以下步骤：
  /// 1. 生成防重放攻击的nonce值
  /// 2. 调用Apple登录API获取凭证
  /// 3. 处理各种登录异常情况
  /// 4. 显示相应的成功或失败提示
  void _handleAppleLogin() async {
    // 显示加载提示
    final cancel = BotToast.showLoading();
    try {
      // 为了防止使用Apple返回的凭据进行重播攻击，我们在凭证请求中包含一个nonce。
      // Firebase是苹果返回的id令牌中的一个临时符号，预计将匹配'rawNonce'的sha256散列。
      final rawNonce = generateNonce();
      final nonce = Tool.instance.generateSHA256(rawNonce);

      // 获取apple验证信息
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email, // 请求邮箱权限
          AppleIDAuthorizationScopes.fullName, // 请求姓名权限
        ],
        nonce: nonce,
        webAuthenticationOptions: WebAuthenticationOptions(
          clientId: AppConfig.instance.appleLoginOnAndroidClientId,
          redirectUri:
              Uri.parse(AppConfig.instance.appleLoginOnAndroidRedirectUri),
        ),
      );

      // 提取身份令牌
      final appleToken = credential.identityToken;
      if (appleToken != null) {
        // TODO: 这里可以使用appleToken进行后续操作，比如发送到服务器进行验证
        Toast.show('Apple login successful: $appleToken');
      } else {
        Toast.show('Apple login failed: identityToken is null');
      }
    } catch (error, stackTrace) {
      // 处理Apple登录相关异常
      if (error is SignInWithAppleAuthorizationException) {
        // 处理苹果登录错误
        switch (error.code) {
          case AuthorizationErrorCode.canceled:
            Toast.show('Apple login canceled');
            break;
          case AuthorizationErrorCode.invalidResponse:
            Toast.show('Invalid response from Apple');
            break;
          case AuthorizationErrorCode.failed:
            Toast.show('Apple login failed');
            break;
          case AuthorizationErrorCode.notHandled:
            Toast.show('Apple login request not handled');
            break;
          case AuthorizationErrorCode.notInteractive:
            Toast.show('Apple login not interactive');
            break;
          case AuthorizationErrorCode.credentialExport:
            Toast.show('Failed to export credentials');
            break;
          case AuthorizationErrorCode.credentialImport:
            Toast.show('Failed to import credentials');
            break;
          case AuthorizationErrorCode.matchedExcludedCredential:
            Toast.show('Credential was excluded');
            break;
          case AuthorizationErrorCode.unknown:
            // 检查是否是错误代码1000（认证服务暂时不可用）
            if (error.message.contains('error 1000')) {
              Toast.show(
                'Apple login failed: Authentication service temporarily unavailable',
              );
            } else {
              Toast.show('Apple login error: ${error.message}');
            }
            break;
        }
      } else if (error is SignInWithAppleNotSupportedException) {
        // 设备不支持Apple登录
        Toast.show('Apple login not supported on this device');
      } else if (error is SignInWithAppleCredentialsException) {
        // 凭证相关错误
        Toast.show('Apple credentials error: ${error.message}');
      } else {
        // 处理其他未知错误
        Toast.show('Apple login failed: $error');
        Log.instance.logger.e(
          'Apple login failed',
          error: error,
          stackTrace: stackTrace,
        );
      }
    } finally {
      // 无论成功还是失败，都要关闭加载提示
      cancel();
    }
  }

  /// 处理Google登录逻辑
  ///
  /// 执行以下步骤：
  /// 1. 显示加载提示
  /// 2. 先登出现有账户以确保选择新账户
  /// 3. 调用Google登录API获取账户信息
  /// 4. 获取身份令牌用于服务器验证
  /// 5. 处理异常情况并显示相应提示
  void _handleGoogleLogin() async {
    // 显示加载提示
    final cancel = BotToast.showLoading();
    try {
      // 先登出已有账户，确保用户可以选择账户
      await _googleSignIn.signOut();
      // 发起Google登录请求
      final googleSignInAccount = await _googleSignIn.signIn();
      if (googleSignInAccount != null) {
        // 获取认证信息
        final authentication = await googleSignInAccount.authentication;
        final googleToken = authentication.idToken;
        if (googleToken != null) {
          // TODO: 这里可以使用googleToken进行后续操作，比如发送到服务器进行验证
          Toast.show('Google Play login successful: $googleToken');
        } else {
          Toast.show('Google Play login failed: idToken is null');
        }
      } else {
        // 用户取消了登录
        Toast.show('Google Play login canceled');
      }
    } catch (error, stackTrace) {
      // 记录错误日志
      Log.instance.logger.e(
        'Google login failed',
        error: error,
        stackTrace: stackTrace,
      );
      Toast.show('Google login failed: $error');
    } finally {
      // 无论成功还是失败，都要关闭加载提示
      cancel();
    }
  }

  /// 跳转到购买页面
  ///
  /// 使用Go Router导航到购买页面，
  /// 并处理购买页面的返回结果
  void _goToPurchase() async {
    final result = await context.push('/purchase');
    if (result != null) {
      Toast.show('Purchase result: $result');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 应用图标展示区域
            Expanded(
              child: Center(
                child: Hero(
                  tag: 'app_icon',
                  child: Image.asset(
                    '${ImagePath.instance.icon}app_icon.png',
                  ),
                ),
              ),
            ),
            // 购买按钮
            Hero(
              tag: 'Purchase',
              child: GlobalButton(
                onPressed: _goToPurchase,
                mainAxisSize: MainAxisSize.max,
                text: 'Purchase',
              ),
            ),
            // Apple登录按钮
            GlobalButton(
              onPressed: _handleAppleLogin,
              mainAxisSize: MainAxisSize.max,
              iconWidget: Image.asset(
                '${ImagePath.instance.global}apple.ico',
                width: 20.0,
                height: 20.0,
              ),
              text: 'Apple Login',
            ),
            // Google登录按钮
            GlobalButton(
              onPressed: _handleGoogleLogin,
              mainAxisSize: MainAxisSize.max,
              iconWidget: Image.asset(
                '${ImagePath.instance.global}google.ico',
                width: 20.0,
                height: 20.0,
              ),
              text: 'Google Play Login',
            ),
          ],
        ),
      ),
    );
  }
}
