// lib/auth/session.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Session extends ChangeNotifier {
  bool _loggedIn = false;
  User? _user;
  StreamSubscription<User?>? _sub;

  bool get isLoggedIn => _loggedIn;
  User? get user => _user;
  String? get uid => _user?.uid;
  String? get email => _user?.email;

  /// Firebase.initializeApp() の後に1回呼ぶ
  Future<void> init() async {
    // 現在の状態を反映
    _applyAuthState(FirebaseAuth.instance.currentUser);

    // 以降はAuthの変化を監視
    _sub?.cancel();
    _sub = FirebaseAuth.instance.authStateChanges().listen(_applyAuthState);
  }

  void _applyAuthState(User? user) {
    _user = user;
    final now = user != null;
    if (now != _loggedIn) {
      _loggedIn = now;
      notifyListeners();
    } else {
      // ユーザー情報の更新をUIへ伝えたい場合は通知しておく
      notifyListeners();
    }
  }

  /// 手動でログイン状態を立てたい時（互換用）
  void login() {
    if (!_loggedIn) {
      _loggedIn = true;
      notifyListeners();
    }
  }

  /// サインアウトして状態を更新
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    if (_loggedIn) {
      _loggedIn = false;
      _user = null;
      notifyListeners();
    }
  }

  /// 互換用（古い呼び出しが残っている場合）
  @Deprecated('Use login() or logout() instead.')
  void setLoggedIn(bool v) => v ? login() : logout();

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

// シングルトン
final session = Session();
