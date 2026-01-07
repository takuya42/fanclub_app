import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter/foundation.dart';

class AppleAuth {
  static Future<UserCredential> signInWithApple() async {
    try {
      final appleCredential =
      await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        // nonce は使わない（簡易方式）
      );

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      return await FirebaseAuth.instance
          .signInWithCredential(oauthCredential);
    } catch (e) {
      debugPrint('🍎 Apple login error: $e');
      rethrow; // ← SocialButtons の catch に渡す
    }
  }
}
