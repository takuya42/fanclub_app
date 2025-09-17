// lib/auth/session.dart
import 'package:flutter/foundation.dart';

class Session extends ChangeNotifier {
  bool _loggedIn = false;
  bool get isLoggedIn => _loggedIn;

  void login() { if (!_loggedIn) { _loggedIn = true; notifyListeners(); } }
  void logout() { if (_loggedIn) { _loggedIn = false; notifyListeners(); } }
}

// シングルトン
final session = Session();
