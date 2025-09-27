import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChangeEmailState {
  final String email;
  final String confirm;
  final bool isLoading;

  const ChangeEmailState({
    this.email = '',
    this.confirm = '',
    this.isLoading = false,
  });

  bool get isMatch =>
      email.trim().isNotEmpty &&
          confirm.trim().isNotEmpty &&
          email.trim() == confirm.trim();

  ChangeEmailState copyWith({
    String? email,
    String? confirm,
    bool? isLoading,
  }) {
    return ChangeEmailState(
      email: email ?? this.email,
      confirm: confirm ?? this.confirm,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
