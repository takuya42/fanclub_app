import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AppleAuth {
  static final _auth = FirebaseAuth.instance;

  // ===== nonce ユーティリティ =====
  static String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  static String _sha256ofString(String input) =>
      sha256.convert(utf8.encode(input)).toString();

  /// Appleでサインイン（iOS）
  static Future<UserCredential> signInWithApple() async {
    // 1) nonce を生成し、ハッシュをリクエストに付与
    final rawNonce = _generateNonce();
    final hashedNonce = _sha256ofString(rawNonce);

    // 2) AppleID の認可を取得
    final appleCred = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: hashedNonce,
    );

    // 3) Firebase OAuthCredential を作成
    final oauthCredential = OAuthProvider('apple.com').credential(
      idToken: appleCred.identityToken,
      rawNonce: rawNonce,
      // authorizationCode は通常不要（Web連携時などで使用）
    );

    // 4) Firebase ログイン
    return await _auth.signInWithCredential(oauthCredential);
  }

  static Future<void> signOut() async {
    // AppleはSDKにサインアウトAPIなし。Firebase側をログアウトすればOK
    await _auth.signOut();
  }
}
