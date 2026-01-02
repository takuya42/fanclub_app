// lib/providers/auth_user_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// displayName の変更などプロフィール更新でもイベントが流れるストリーム
final authUserProvider = StreamProvider<User?>(
      (ref) => FirebaseAuth.instance.userChanges(),
);
