// lib/pages/widgets/social_buttons.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fanclub_app/pages/auth/google_auth.dart';
import 'package:fanclub_app/pages/auth/apple_auth.dart';

class SocialButtons extends ConsumerWidget {
  const SocialButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Map<String, String>> services = [
      {
        'icon': 'https://hackaday.com/wp-content/uploads/2016/08/google-g-logo.png',
        'label': 'Google',
      },
      {
        'icon': 'https://img.icons8.com/?size=100&id=30840&format=png&color=000000',
        'label': 'Apple',
      },
    ];

    Future<void> _handleGoogle() async {
      try {
        final cred = await GoogleAuth.signInWithGoogle();
        final user = cred.user;
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('ようこそ、${user?.displayName ?? user?.email ?? 'ゲスト'}さん')),
          );
          context.go('/home');
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Googleログイン失敗: $e')),
          );
        }
      }
    }

    Future<void> _handleApple() async {
      try {
        final cred = await AppleAuth.signInWithApple();
        final user = cred.user;
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('ようこそ、${user?.displayName ?? user?.email ?? 'ゲスト'}さん')),
          );
          context.go('/home');
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Appleログイン失敗: $e')),
          );
        }
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(services.length, (i) {
        final service = services[i];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(10),
                ),
                onPressed: () async {
                  if (i == 0) {
                    await _handleGoogle();
                  } else {
                    await _handleApple();
                  }
                },
                child: Image.network(
                  service['icon']!,
                  width: 40,
                  height: 40,
                  errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.error, color: Colors.red, size: 40),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                service['label']!,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        );
      }),
    );
  }
}
