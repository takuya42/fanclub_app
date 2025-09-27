import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth/change_email_controller.dart';

class ChangeEmailPage extends ConsumerWidget {
  const ChangeEmailPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(changeEmailControllerProvider);
    final ctrl  = ref.read(changeEmailControllerProvider.notifier);

    final canSubmit = state.isMatch && !state.isLoading;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('メールアドレス変更'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 新しいメール
            TextField(
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: '新しいメールアドレス',
                border: OutlineInputBorder(),
                labelStyle: TextStyle(color: Colors.white70),
              ),
              onChanged: ctrl.setEmail,
            ),
            const SizedBox(height: 12),

            // 確認用メール
            TextField(
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: '確認用メールアドレス',
                border: OutlineInputBorder(),
                labelStyle: TextStyle(color: Colors.white70),
              ),
              onChanged: ctrl.setConfirm,
              onSubmitted: (_) async {
                if (!canSubmit) return;
                final msg = await ctrl.submit();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(msg ?? 'メールアドレスを変更しました')),
                );
                if (msg == null) Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),

            // 一致チェック
            Row(
              children: [
                Icon(
                  state.isMatch ? Icons.check_circle : Icons.error_outline,
                  color: state.isMatch ? Colors.greenAccent : Colors.redAccent,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  state.isMatch ? '一致しています' : '一致していません',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ボタン
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: canSubmit
                    ? () async {
                  final msg = await ctrl.submit();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(msg ?? 'メールアドレスを変更しました')),
                  );
                  if (msg == null) Navigator.pop(context);
                }
                    : null,
                child: state.isLoading
                    ? const SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text('変更する'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
