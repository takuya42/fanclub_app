import 'dart:convert';
import 'dart:math';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AppleAuth {
  /// Appleログイン（Firebase連携）
  static Future<UserCredential> signInWithApple() async {
    try {
      // =========================
      // 🛑 シミュレータ対策
      // =========================
      if (!Platform.isIOS || !await SignInWithApple.isAvailable()) {
        throw FirebaseAuthException(
          code: 'apple-not-available',
          message: 'Appleログインは実機のiPhoneでのみ利用できます。',
        );
      }

      // =========================
      // ① nonce生成（必須）
      // =========================
      final rawNonce = _generateNonce();
      final hashedNonce = _sha256ofString(rawNonce);

      // =========================
      // ② Apple認証
      // =========================
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );

      // =========================
      // ③ identityToken チェック
      // =========================
      if (appleCredential.identityToken == null) {
        throw FirebaseAuthException(
          code: 'apple-identity-token-null',
          message: 'Apple認証に失敗しました。',
        );
      }

      // =========================
      // ④ Firebase Credential
      // =========================
      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken!,
        rawNonce: rawNonce,
      );

      // =========================
      // ⑤ Firebase ログイン
      // =========================
      final userCredential =
      await FirebaseAuth.instance.signInWithCredential(oauthCredential);

      return userCredential;
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('🍎 Apple Login Error: $e');
        debugPrint('$stack');
      }

      throw FirebaseAuthException(
        code: 'apple-login-failed',
        message: 'Appleログインに失敗しました。実機でお試しください。',
      );
    }
  }
}

//
// --------------------
// util
// --------------------
//

String _generateNonce([int length = 32]) {
  const charset =
      '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
  final random = Random.secure();
  return List.generate(
    length,
        (_) => charset[random.nextInt(charset.length)],
  ).join();
}

String _sha256ofString(String input) {
  final bytes = utf8.encode(input);
  final digest = sha256.convert(bytes);
  return digest.toString();
}
