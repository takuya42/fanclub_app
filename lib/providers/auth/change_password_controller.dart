import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangePasswordController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  /// 成功: null / 失敗: ユーザー向けメッセージ
  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirm,
  }) async {
    // 入力チェック
    if (currentPassword.isEmpty || newPassword.isEmpty || newPasswordConfirm.isEmpty) {
      return 'すべて入力してください';
    }
    if (newPassword != newPasswordConfirm) {
      return '新しいパスワードが一致しません';
    }
    if (newPassword.length < 6) {
      return '新しいパスワードは6文字以上にしてください';
    }

    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email;
    if (user == null || email == null) {
      return 'ログイン情報を取得できませんでした';
    }

    try {
      state = const AsyncLoading();

      // 再認証（updatePasswordが弾かれるのを防ぐ）
      final cred = EmailAuthProvider.credential(email: email, password: currentPassword);
      await user.reauthenticateWithCredential(cred);

      // パスワード更新
      await user.updatePassword(newPassword);

      state = const AsyncData(null);
      return null; // 成功
    } on FirebaseAuthException catch (e) {
      state = AsyncError(e, StackTrace.current);
      switch (e.code) {
        case 'wrong-password':
          return '現在のパスワードが違います';
        case 'weak-password':
          return 'パスワードが弱すぎます（より複雑にしてください）';
        case 'requires-recent-login':
          return 'セキュリティのため再ログインが必要です。いったんサインインし直してください。';
        default:
          return 'エラーが発生しました: ${e.message ?? e.code}';
      }
    } catch (_) {
      state = const AsyncError('unknown', StackTrace.empty);
      return '予期しないエラーが発生しました';
    }
  }
}

final changePasswordControllerProvider =
AsyncNotifierProvider<ChangePasswordController, void>(ChangePasswordController.new);
