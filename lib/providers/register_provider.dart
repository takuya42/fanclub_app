import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// ========================
/// 入力コントローラ
/// ========================
final emailControllerProvider =
Provider.autoDispose<TextEditingController>((ref) {
  final c = TextEditingController();
  ref.onDispose(c.dispose);
  return c;
});

final passwordControllerProvider =
Provider.autoDispose<TextEditingController>((ref) {
  final c = TextEditingController();
  ref.onDispose(c.dispose);
  return c;
});

final confirmPasswordControllerProvider =
Provider.autoDispose<TextEditingController>((ref) {
  final c = TextEditingController();
  ref.onDispose(c.dispose);
  return c;
});

/// ========================
/// 入力された文字列
/// ========================
final emailTextProvider = StateProvider<String>((_) => '');
final passwordTextProvider = StateProvider<String>((_) => '');
final confirmPasswordTextProvider = StateProvider<String>((_) => '');

/// ========================
/// パスワードの表示/非表示
/// ========================
final obscurePasswordProvider = StateProvider<bool>((_) => true);
final obscureConfirmPasswordProvider = StateProvider<bool>((_) => true);

/// ========================
/// 入力妥当性チェック
/// メール形式OK & パス6文字以上 & 一致
/// ========================
final isFormValidProvider = Provider<bool>((ref) {
  final email    = ref.watch(emailTextProvider).trim();
  final pass     = ref.watch(passwordTextProvider);
  final confirm  = ref.watch(confirmPasswordTextProvider);

  final emailOk = RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email);
  final passOk  = pass.length >= 6;
  final matchOk = pass == confirm;

  return emailOk && passOk && matchOk;
});

/// ========================
/// アカウント作成処理
/// ========================
final registerActionProvider =
Provider<Future<bool> Function()>((ref) {
  return () async {
    final email = ref.read(emailTextProvider).trim();
    final pass  = ref.read(passwordTextProvider);

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: pass,
      );
      return true;

    } on FirebaseAuthException catch (e) {
      throw Exception(_friendlyError(e));
    }
  };
});

/// ========================
/// エラーメッセージ整形
/// ========================
String _friendlyError(FirebaseAuthException e) {
  switch (e.code) {
    case 'email-already-in-use':
      return 'このメールアドレスは既に使われています。';
    case 'invalid-email':
      return 'メールアドレスの形式が正しくありません。';
    case 'weak-password':
      return 'パスワードが弱すぎます。6文字以上にしてください。';
    default:
      return 'エラー：${e.code}';
  }
}
