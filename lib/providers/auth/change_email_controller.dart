import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'change_email_state.dart';

class ChangeEmailController extends StateNotifier<ChangeEmailState> {
  ChangeEmailController() : super(const ChangeEmailState());

  void setEmail(String value) {
    state = state.copyWith(email: value);
  }

  void setConfirm(String value) {
    state = state.copyWith(confirm: value);
  }

  Future<String?> submit() async {
    if (!state.isMatch) {
      return "メールアドレスが一致していません";
    }

    try {
      state = state.copyWith(isLoading: true);

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        state = state.copyWith(isLoading: false);
        return "ログインしていません";
      }

      // Firebase Auth に新しいメールを登録
      await user.updateEmail(state.email);
      await user.reload(); // 最新の状態を取得

      state = state.copyWith(isLoading: false);
      return null; // 成功時はエラーメッセージなし
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false);
      return e.message ?? "メールアドレス変更に失敗しました";
    }
  }
}

// Provider
final changeEmailControllerProvider =
StateNotifierProvider<ChangeEmailController, ChangeEmailState>((ref) {
  return ChangeEmailController();
});
