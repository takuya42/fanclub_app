import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:fanclub_app/pages/auth/google_auth.dart';
import 'package:fanclub_app/pages/auth/apple_auth.dart';
import 'package:fanclub_app/repositories/user_repository.dart';

class SocialButtons extends ConsumerWidget {
  const SocialButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    // --------------------
    // Google ログイン
    // --------------------
    Future<void> _handleGoogle() async {
      try {
        final cred = await GoogleAuth.signInWithGoogle();
        final user = cred.user;

        if (user == null) {
          throw Exception('Google user is null');
        }

        // アカウント作成（初回のみ）
        await UserRepository.createIfNeeded(user, 'google');

        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ようこそ、${user.displayName ?? 'ゲスト'}さん')),
        );
        context.go('/home');
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Googleログイン失敗: $e')),
        );
      }
    }

    // --------------------
    // Apple ログイン（審査重要）
    // --------------------
    Future<void> _handleApple() async {
      try {
        final cred = await AppleAuth.signInWithApple();
        final user = cred.user;

        if (user == null) {
          throw Exception('Apple user is null');
        }

        // 🔴 最重要：アカウントID作成（existsチェック済）
        await UserRepository.createIfNeeded(user, 'apple');

        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appleログイン成功')),
        );
        context.go('/home');
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Appleログイン失敗: $e')),
        );
      }
    }

    return Column(
      children: [
        // Google
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ElevatedButton(
            onPressed: _handleGoogle,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.g_mobiledata, size: 28),
                SizedBox(width: 12),
                Text(
                  'Googleでログイン',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Apple
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ElevatedButton(
            onPressed: _handleApple,
            style: ElevatedButton.styleFrom(
              side: const BorderSide(color: Colors.white, width: 2),
              foregroundColor: Colors.white,
              backgroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.apple, size: 26),
                SizedBox(width: 12),
                Text(
                  'Appleでログイン',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
