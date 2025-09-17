// lib/pages/register/widgets/register_form.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fanclub_app/providers/register_provider.dart';

class RegisterForm extends ConsumerWidget {
  const RegisterForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController    = ref.watch(emailControllerProvider);
    final passwordController = ref.watch(passwordControllerProvider);
    final obscure            = ref.watch(obscurePasswordProvider);
    final canSubmit          = ref.watch(isFormValidProvider);

    Future<void> _create() async {
      try {
        final ok = await ref.read(registerActionProvider)();
        if (ok && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('アカウントを作成しました。ログイン済みです。')),
          );
          context.go('/home');
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
          );
        }
      }
    }

    InputDecoration _decoration(String hint) => InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey),
      filled: true,
      fillColor: Colors.grey[900],
      border: _border(Colors.white),
      enabledBorder: _border(Colors.white),
      focusedBorder: _border(Colors.blue),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'メールアドレス',
            style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: Colors.white),
          decoration: _decoration('fanclub@email.com'),
          onChanged: (v) => ref.read(emailTextProvider.notifier).state = v, // ★重要
        ),
        const SizedBox(height: 15),

        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'パスワード（6文字以上）',
            style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: passwordController,
          obscureText: obscure,
          style: const TextStyle(color: Colors.white),
          decoration: _decoration('********').copyWith(
            suffixIcon: IconButton(
              onPressed: () => ref.read(obscurePasswordProvider.notifier).state = !obscure,
              icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: Colors.white70),
            ),
          ),
          onChanged: (v) => ref.read(passwordTextProvider.notifier).state = v, // ★重要
        ),
        const SizedBox(height: 24),



        const SizedBox(height: 8),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: canSubmit ? _create : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: canSubmit ? Colors.blue : Colors.blue.withOpacity(0.45),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              disabledBackgroundColor: Colors.blue.withOpacity(0.35), // 無効でも見える
              disabledForegroundColor: Colors.white70,
            ),
            child: const Text('アカウント作成', style: TextStyle(fontSize: 18)),
          ),
        ),
      ],
    );
  }

  static OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide(color: color),
  );
}
