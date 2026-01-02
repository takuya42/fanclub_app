import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PurchaseCompletePage extends StatefulWidget {
  const PurchaseCompletePage({super.key});

  @override
  State<PurchaseCompletePage> createState() => _PurchaseCompletePageState();
}

class _PurchaseCompletePageState extends State<PurchaseCompletePage> {
  bool _isLoading = true; // 最初はローディング状態

  @override
  void initState() {
    super.initState();

    // 1.5秒後にチェックアイコンに切り替え
    Future.delayed(const Duration(seconds: 1, milliseconds: 500), () {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ✅ ローディング or チェックアイコン
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: _isLoading
                      ? const SizedBox(
                    key: ValueKey('loading'),
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 6,
                    ),
                  )
                      : const Icon(
                    key: ValueKey('check'),
                    Icons.check_circle_outline,
                    color: Colors.white,
                    size: 100,
                  ),
                ),
                const SizedBox(height: 24),

                // 🎉 メッセージ
                const Text(
                  '購入が完了しました 🎉',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                const Text(
                  'ご購入ありがとうございました。\n購入履歴からご確認いただけます。',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // 📦 「購入履歴へ」ボタン
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.history),
                    label: const Text(
                      '購入履歴へ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      context.go('/goods-history');
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // 🏠 「ホームに戻る」ボタン
                TextButton.icon(
                  icon: const Icon(Icons.home, color: Colors.white70),
                  label: const Text(
                    'ホームに戻る',
                    style: TextStyle(color: Colors.white70, fontSize: 15),
                  ),
                  onPressed: () => context.go('/home'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
