import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../providers/account_id_provider.dart';
import '../providers/auth_user_provider.dart';
import '../providers/membership_providers.dart';
import '../providers/favorites_providers.dart';
import '../theme/mypage_palette.dart';
import '../widgets/mypage_header.dart';
import '../widgets/favorites_section.dart';

class MyPage extends ConsumerWidget {
  const MyPage({super.key});

  void _back(BuildContext context) =>
      context.canPop() ? context.pop() : context.go('/home');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final pal = MyPagePalette.fromBrightness(isDark);

    // ログイン判定
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;

    // 会員情報
    final memberAsync = ref.watch(membershipControllerProvider);
    final nameFromMember = memberAsync.maybeWhen(
      data: (s) => s.form.displayName.trim(),
      orElse: () => '',
    );

    // Authの表示名（フォールバック）
    final authUser = ref.watch(authUserProvider).value;
    final nameFromAuth = (authUser?.displayName?.trim().isNotEmpty ?? false)
        ? authUser!.displayName!.trim()
        : '';
    final displayName = nameFromMember.isNotEmpty
        ? nameFromMember
        : (nameFromAuth.isNotEmpty ? nameFromAuth : 'ユーザー名');

    // @accountId
    final accountIdAsync = ref.watch(userAccountIdProvider);

    return Scaffold(
      backgroundColor: pal.bg,
      appBar: AppBar(
        backgroundColor: pal.bg,
        foregroundColor: pal.fg,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => _back(context),
          tooltip: '戻る',
        ),
        title: const Text('マイページ'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          // ───── プロフィールヘッダ ─────
          MyPageHeader(
            pal: pal,
            displayName: displayName,
            accountIdAsync: accountIdAsync,
            isLoggedIn: isLoggedIn,
            onEditPressed: () => context.push('/membership'),
          ),

          const SizedBox(height: 18),

          // ───── クイックアクセス ─────
          _groupLabel('クイックアクセス', pal, theme),
          const SizedBox(height: 8),
          _listCard(
            pal: pal,
            children: [
              if (isLoggedIn) ...[
                _item(
                  context,
                  pal: pal,
                  icon: Icons.badge_outlined,
                  title: '会員情報',
                  subtitle: '登録内容の確認・変更',
                  onTap: () => context.push('/membership'),
                ),
                _divider(pal),
              ],
              _item(
                context,
                pal: pal,
                icon: Icons.inventory_2_outlined,
                title: 'グッズ購入履歴',
                subtitle: 'これまでの物販オーダー',
                onTap: () => context.push('/goods-history'),
              ),

              //チケット購入履歴（今後使う時のために）

              //          _divider(pal),
              //        _item(
              //          context,
              //            pal: pal,
              //            icon: Icons.confirmation_number_outlined,
              //            title: 'チケット購入履歴',
              //             subtitle: 'ライブ・イベントの履歴',
              //            onTap: () {},
              //       ),
            ],
          ),

          const SizedBox(height: 18),

          // ───── お気に入りセクション ─────
          _groupLabel('お気に入り', pal, theme),
          const SizedBox(height: 8),
          const FavoritesSection(height: 180),

          const SizedBox(height: 20),

          // ───── ログアウト ─────
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: pal.fg,
                side: BorderSide(color: pal.border),
                backgroundColor: pal.panel,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () => _confirmAndSignOut(context),
              icon: const Icon(Icons.logout),
              label: const Text('ログアウト'),
            ),
          ),
        ],
      ),
    );
  }

  // ───── 補助UI部品 ─────
  Widget _groupLabel(String text, MyPagePalette pal, ThemeData theme) {
    return Text(
      text,
      style: theme.textTheme.labelLarge?.copyWith(
        color: pal.muted,
        fontWeight: FontWeight.w700,
        letterSpacing: .2,
      ),
    );
  }

  Widget _listCard(
      {required MyPagePalette pal, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: pal.panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: pal.border),
      ),
      child: Column(children: children),
    );
  }

  Widget _divider(MyPagePalette pal) =>
      Divider(height: 1, thickness: 1, color: pal.border);

  Widget _item(
    BuildContext context, {
    required MyPagePalette pal,
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: pal.accentBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: pal.border),
              ),
              child: Icon(icon, color: pal.accentFg, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: pal.fg,
                        fontWeight: FontWeight.w600,
                      )),
                  if (subtitle != null) ...[
                    const SizedBox(height: 3),
                    Text(subtitle,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: pal.muted)),
                  ]
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: pal.muted),
          ],
        ),
      ),
    );
  }
}

// ───── ログアウト確認 ─────
Future<void> _confirmAndSignOut(BuildContext context) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        backgroundColor: Colors.black,
        surfaceTintColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Colors.white24),
        ),
        title: const Text(
          '本当にログアウトしますか？',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
        ),
        content: const Text(
          '再度ログインが必要になります。',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Colors.white, foregroundColor: Colors.black),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('ログアウト'),
          ),
        ],
      );
    },
  );

  if (ok != true) return;

  try {
    await FirebaseAuth.instance.signOut();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('ログアウトしました')));
    context.go('/login');
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('ログアウトに失敗しました: $e')));
  }
}
