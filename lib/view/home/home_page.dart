import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../component/global_button.dart';
import '../../constant/app_config.dart';
import '../../constant/image_path.dart';
import '../../util/log.dart';
import '../../util/toast.dart';
import '../../util/tool.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// 苹果登录配置
  final webAuthenticationOptions = WebAuthenticationOptions(
    clientId: AppConfig.instance.appleLoginOnAndroidClientId,
    redirectUri: Uri.parse(AppConfig.instance.appleLoginOnAndroidRedirectUri),
  );

  /// 谷歌登录工具单例
  final _googleSignIn = GoogleSignIn(
    scopes: ['email', 'openid'],
    serverClientId: AppConfig.instance.androidWebServerClientId,
  );

  // 添加Apple登录方法
  void _handleAppleLogin() async {
    final cancel = BotToast.showLoading();
    try {
      //为了防止使用Apple返回的凭据进行重播攻击，我们在凭证请求中包含一个nonce。使用登录时
      //Firebase是苹果返回的id令牌中的一个临时符号，预计将匹配'rawnence'的sha256散列。
      final rawNonce = generateNonce();
      final nonce = Tool.instance.generateSHA256(rawNonce);
      //获取apple验证信息
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
        webAuthenticationOptions: WebAuthenticationOptions(
          clientId: AppConfig.instance.appleLoginOnAndroidClientId,
          redirectUri:
              Uri.parse(AppConfig.instance.appleLoginOnAndroidRedirectUri),
        ),
      );
      final appleToken = credential.identityToken;
      if (appleToken != null) {
        // TODO: 这里可以使用appleToken进行后续操作，比如发送到服务器进行验证
        Toast.show('Apple login successful: $appleToken');
      } else {
        Toast.show('Apple login failed: identityToken is null');
      }
    } catch (error, stackTrace) {
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
            // 检查是否是错误代码1000
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
        Toast.show('Apple login not supported on this device');
      } else if (error is SignInWithAppleCredentialsException) {
        Toast.show('Apple credentials error: ${error.message}');
      } else {
        // 处理其他错误
        Toast.show('Apple login failed: $error');
        Log.instance.logger.e(
          'Apple login failed',
          error: error,
          stackTrace: stackTrace,
        );
      }
    } finally {
      cancel();
    }
  }

  void _handleGoogleLogin() async {
    final cancel = BotToast.showLoading();
    try {
      await _googleSignIn.signOut();
      final googleSignInAccount = await _googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final authentication = await googleSignInAccount.authentication;
        final googleToken = authentication.idToken;
        if (googleToken != null) {
          // TODO: 这里可以使用googleToken进行后续操作，比如发送到服务器进行验证
          Toast.show('Google Play login successful: $googleToken');
        } else {
          Toast.show('Google Play login failed: idToken is null');
        }
      } else {
        Toast.show('Google Play login canceled');
      }
    } catch (error, stackTrace) {
      Log.instance.logger.e(
        'Google login failed',
        error: error,
        stackTrace: stackTrace,
      );
      Toast.show('Google login failed: $error');
    } finally {
      cancel();
    }
  }

  void _goToPurchase() async {
    final result = await context.push('/purchase');
    if (result != null) {
      Toast.show('Purchase result: $result');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Image.asset(
                '${ImagePath.instance.icon}app_icon.png',
              ),
            ),
          ),
          GlobalButton(
            onPressed: _goToPurchase,
            mainAxisSize: MainAxisSize.max,
            text: 'Purchase',
          ),
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
    );
  }
}
