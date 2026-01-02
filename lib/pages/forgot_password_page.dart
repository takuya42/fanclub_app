// lib/pages/forgot_password_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordPage extends StatefulWidget {
  final String? initialEmail;
  const ForgotPasswordPage({super.key, this.initialEmail});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailCtrl = TextEditingController();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialEmail != null && widget.initialEmail!.isNotEmpty) {
      _emailCtrl.text = widget.initialEmail!;
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendReset() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      _snack('メールアドレスを入力してください');
      return;
    }
    setState(() => _isSending = true);
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      _snack('再設定メールを送信しました。メールをご確認ください。');
      Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      _snack(_friendly(e));
    } catch (e) {
      _snack('送信に失敗しました：$e');
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  String _friendly(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email': return 'メールアドレスの形式が正しくありません。';
      case 'user-not-found': return 'このメールアドレスのユーザーは見つかりません。';
      case 'missing-email': return 'メールアドレスを入力してください。';
      default: return 'エラー：${e.code}';
    }
  }

  void _snack(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('パスワードの再設定')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text('登録済みのメールアドレスを入力してください。\n再設定用のリンクをお送りします。'),
            const SizedBox(height: 16),
            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _isSending ? null : _sendReset(),
              decoration: const InputDecoration(labelText: 'メールアドレス'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isSending ? null : _sendReset,
                child: _isSending
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('再設定メールを送信'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
