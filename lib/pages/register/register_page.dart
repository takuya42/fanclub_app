import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/register_provider.dart';
import 'widgets/register_form.dart';
import 'widgets/social_buttons.dart';
import 'widgets/appbar_clipper.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  bool agreeToTerms = false;
  bool isLoading = false;

  /// 🔗 Notion 利用規約リンク
  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('URLを開けませんでした: $url')),
        );
      }
    }
  }

  /// 📨 新規登録処理
  Future<void> _register() async {
    setState(() => isLoading = true);

    try {
      final ok = await ref.read(registerActionProvider)();
      if (ok && mounted) {
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst("Exception: ", ""))),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = ref.watch(isFormValidProvider);

    return Scaffold(
      backgroundColor: Colors.black,

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: ClipPath(
          clipper: const CustomAppBarClipper(),
          child: AppBar(
            title: const Text(
              '新規登録',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, size: 28),
              onPressed: () => context.go('/home'),
            ),
            backgroundColor: Colors.blue,
            elevation: 0,
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            16 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 30),

              /// ✉️ メール／パスワード入力フォーム
              const RegisterForm(),
              const SizedBox(height: 20),

              /// 📘 利用規約チェック
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Checkbox(
                    value: agreeToTerms,
                    onChanged: (v) => setState(() => agreeToTerms = v ?? false),
                    activeColor: Colors.redAccent,
                  ),
                  Flexible(
                    child: Wrap(
                      children: [
                        const Text(
                          '利用規約に同意します',
                          style: TextStyle(color: Colors.white),
                        ),
                        TextButton(
                          onPressed: () => _openUrl(
                            "https://www.notion.so/flutter-family/StagePlus-2c2b5c1f2cef807884b7c319a93f9633",
                          ),
                          child: const Text(
                            '（利用規約を読む）',
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              /// 🔥 Google ログインボタン
              const SocialButtons(),
              const SizedBox(height: 32),

              /// 🆕 新規登録ボタン（ローディング付き）
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ElevatedButton(
                  onPressed: (agreeToTerms && canSubmit && !isLoading)
                      ? _register
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (agreeToTerms && canSubmit)
                        ? Colors.redAccent
                        : Colors.grey.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  )
                      : const Text(
                    '新規登録',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
