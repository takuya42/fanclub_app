import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth/change_password_controller.dart';

class ChangePasswordPage extends ConsumerStatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  ConsumerState<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends ConsumerState<ChangePasswordPage> {
  final _currentPw = TextEditingController();
  final _newPw = TextEditingController();
  final _newPw2 = TextEditingController();

  final _currentNode = FocusNode();
  final _newNode = FocusNode();
  final _new2Node = FocusNode();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureNew2 = true;

  @override
  void dispose() {
    _currentPw.dispose();
    _newPw.dispose();
    _newPw2.dispose();
    _currentNode.dispose();
    _newNode.dispose();
    _new2Node.dispose();
    super.dispose();
  }

  bool get _isFilled =>
      _currentPw.text.trim().isNotEmpty &&
          _newPw.text.trim().isNotEmpty &&
          _newPw2.text.trim().isNotEmpty;

  bool get _isMatch => _newPw.text.trim() == _newPw2.text.trim();

  Future<void> _submit() async {
    FocusScope.of(context).unfocus(); // キーボード閉じる

    final msg = await ref.read(changePasswordControllerProvider.notifier).changePassword(
      currentPassword: _currentPw.text.trim(),
      newPassword: _newPw.text.trim(),
      newPasswordConfirm: _newPw2.text.trim(),
    );

    if (!mounted) return;

    if (msg == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('パスワードを変更しました')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  InputDecoration _decoration({
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFF121212),
      labelStyle: const TextStyle(color: Colors.white70),
      border: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey.shade800),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey.shade800),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
      ),
      suffixIcon: IconButton(
        color: Colors.white70,
        icon: Icon(obscure ? Icons.visibility : Icons.visibility_off),
        onPressed: onToggle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(changePasswordControllerProvider);
    final isLoading = async.isLoading;
    final canSubmit = _isFilled && _isMatch && !isLoading;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('パスワード変更'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          if (isLoading) const LinearProgressIndicator(minHeight: 2),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 現在のパスワード
                TextField(
                  controller: _currentPw,
                  focusNode: _currentNode,
                  style: const TextStyle(color: Colors.white),
                  obscureText: _obscureCurrent,
                  textInputAction: TextInputAction.next,
                  autocorrect: false,
                  enableSuggestions: false,
                  autofillHints: const [AutofillHints.password],
                  decoration: _decoration(
                    label: '現在のパスワード',
                    obscure: _obscureCurrent,
                    onToggle: () => setState(() => _obscureCurrent = !_obscureCurrent),
                  ),
                  onChanged: (_) => setState(() {}),
                  onSubmitted: (_) => _newNode.requestFocus(),
                ),
                const SizedBox(height: 16),

                // 新しいパスワード
                TextField(
                  controller: _newPw,
                  focusNode: _newNode,
                  style: const TextStyle(color: Colors.white),
                  obscureText: _obscureNew,
                  textInputAction: TextInputAction.next,
                  autocorrect: false,
                  enableSuggestions: false,
                  autofillHints: const [AutofillHints.newPassword],
                  decoration: _decoration(
                    label: '新しいパスワード',
                    obscure: _obscureNew,
                    onToggle: () => setState(() => _obscureNew = !_obscureNew),
                  ),
                  onChanged: (_) => setState(() {}),
                  onSubmitted: (_) => _new2Node.requestFocus(),
                ),
                const SizedBox(height: 16),

                // 新しいパスワード（確認）
                TextField(
                  controller: _newPw2,
                  focusNode: _new2Node,
                  style: const TextStyle(color: Colors.white),
                  obscureText: _obscureNew2,
                  textInputAction: TextInputAction.done,
                  autocorrect: false,
                  enableSuggestions: false,
                  autofillHints: const [AutofillHints.newPassword],
                  decoration: _decoration(
                    label: '新しいパスワード（確認）',
                    obscure: _obscureNew2,
                    onToggle: () => setState(() => _obscureNew2 = !_obscureNew2),
                  ),
                  onChanged: (_) => setState(() {}),
                  onSubmitted: (_) => canSubmit ? _submit() : null,
                ),

                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      _isMatch ? Icons.check_circle : Icons.error_outline,
                      size: 18,
                      color: _isMatch ? Colors.greenAccent : Colors.redAccent,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _isMatch ? '一致しています' : '一致していません',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      disabledBackgroundColor: Colors.white10,
                      disabledForegroundColor: Colors.white38,
                    ),
                    onPressed: canSubmit ? _submit : null,
                    child: isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(),
                    )
                        : const Text('変更する'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
