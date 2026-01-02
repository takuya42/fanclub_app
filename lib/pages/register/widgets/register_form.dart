// lib/pages/register/widgets/register_form.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fanclub_app/providers/register_provider.dart';

class RegisterForm extends ConsumerWidget {
  const RegisterForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController       = ref.watch(emailControllerProvider);
    final passwordController    = ref.watch(passwordControllerProvider);
    final confirmController     = ref.watch(confirmPasswordControllerProvider);

    final obscurePass           = ref.watch(obscurePasswordProvider);
    final obscureConfirm        = ref.watch(obscureConfirmPasswordProvider);

    final email                 = ref.watch(emailTextProvider);
    final pass                  = ref.watch(passwordTextProvider);
    final confirm               = ref.watch(confirmPasswordTextProvider);

    final canSubmit             = ref.watch(isFormValidProvider);

    // パスワード一致チェック
    final bool isMatch = pass.isNotEmpty && confirm.isNotEmpty && pass == confirm;

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
        /// メール
        const Text(
          'メールアドレス',
          style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: Colors.white),
          decoration: _decoration('example@mail.com'),
          onChanged: (v) => ref.read(emailTextProvider.notifier).state = v,
        ),
        const SizedBox(height: 20),

        /// パスワード
        const Text(
          'パスワード（6文字以上）',
          style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: passwordController,
          obscureText: obscurePass,
          style: const TextStyle(color: Colors.white),
          decoration: _decoration('********').copyWith(
            suffixIcon: IconButton(
              onPressed: () => ref.read(obscurePasswordProvider.notifier).state = !obscurePass,
              icon: Icon(
                obscurePass ? Icons.visibility_off : Icons.visibility,
                color: Colors.white70,
              ),
            ),
          ),
          onChanged: (v) => ref.read(passwordTextProvider.notifier).state = v,
        ),
        const SizedBox(height: 20),

        /// パスワード確認
        const Text(
          'パスワード確認',
          style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: confirmController,
          obscureText: obscureConfirm,
          style: const TextStyle(color: Colors.white),
          decoration: _decoration('********').copyWith(
            suffixIcon: IconButton(
              onPressed: () => ref.read(obscureConfirmPasswordProvider.notifier).state = !obscureConfirm,
              icon: Icon(
                obscureConfirm ? Icons.visibility_off : Icons.visibility,
                color: Colors.white70,
              ),
            ),
          ),
          onChanged: (v) => ref.read(confirmPasswordTextProvider.notifier).state = v,
        ),

        const SizedBox(height: 10),

        /// 🔥 一致 / 不一致 メッセージ
        if (pass.isNotEmpty && confirm.isNotEmpty)
          Text(
            isMatch ? '✔ パスワードが一致しています' : '✘ パスワードが一致していません',
            style: TextStyle(
              color: isMatch ? Colors.greenAccent : Colors.redAccent,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),

        const SizedBox(height: 20),
      ],
    );
  }

  static OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide(color: color),
  );
}
