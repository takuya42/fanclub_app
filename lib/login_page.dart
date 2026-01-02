import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'services/user_repository.dart';
import 'services/account_id_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// 🔹 ログイン処理
  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnack('メールとパスワードを入力してください');
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await UserRepository.instance.ensureCurrentUserDoc();
      await AccountIdService.instance.ensureForCurrentUser();

      if (mounted) context.go('/home', extra: email);
    } on FirebaseAuthException catch (e) {
      _showSnack(_friendlyError(e));
    } catch (e) {
      _showSnack('ログインに失敗しました：$e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _friendlyError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'メールアドレスの形式が正しくありません。';
      case 'user-not-found':
      case 'wrong-password':
        return 'メールアドレスまたはパスワードが違います。';
      case 'user-disabled':
        return 'このユーザーは無効化されています。';
      case 'email-already-in-use':
        return 'このメールアドレスは既に使われています。';
      case 'weak-password':
        return 'パスワードが弱すぎます。6文字以上にしてください。';
      default:
        return 'エラー：${e.code}';
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  /// ➡️ ホーム画面へ遷移（常時有効）
  void _goToHome() {
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ログイン'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded),
            tooltip: 'ホームへ',
            onPressed: _goToHome,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // ✉️ メールアドレス
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'メールアドレス'),
            ),
            const SizedBox(height: 16),

            // 🔒 パスワード
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              onSubmitted: (_) => _isLoading ? null : _login(),
              decoration: InputDecoration(
                labelText: 'パスワード',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => context.push('/forgotPassword'),
                child: const Text('パスワードをお忘れですか？'),
              ),
            ),

            // 🚪 ログインボタン
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isLoading ? null : _login,
                child: _isLoading
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text('ログイン'),
              ),
            ),
            const SizedBox(height: 8),

            // 🆕 新規登録ページへ
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonal(
                onPressed: _isLoading ? null : () => context.push('/register'),
                child: const Text('新規登録'),
              ),
            ),

            const Spacer(),
            Text(
              'ログインすると利用規約に同意したものとみなされます。',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
