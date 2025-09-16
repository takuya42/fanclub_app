import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';



class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({Key? key}) : super(key: key);

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _currentPw = TextEditingController();

  @override
  void dispose() {
    _currentPw.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('パスワード変更')),
      body: Padding(
      padding: const EdgeInsets.all(16),
        child: TextField(
          controller: _currentPw,
          obscureText: true,

        ),
      ),
    );
  }
}
