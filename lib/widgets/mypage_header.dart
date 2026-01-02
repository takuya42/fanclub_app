import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/mypage_palette.dart';

class MyPageHeader extends ConsumerWidget {
  final MyPagePalette pal;
  final String displayName;
  final AsyncValue<String?> accountIdAsync;
  final bool isLoggedIn;
  final VoidCallback onEditPressed;

  const MyPageHeader({
    super.key,
    required this.pal,
    required this.displayName,
    required this.accountIdAsync,
    required this.isLoggedIn,
    required this.onEditPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: pal.panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: pal.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 丸アイコン
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: pal.accentBg,
              border: Border.all(color: pal.border),
            ),
            child: Icon(Icons.person, color: pal.accentFg, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 表示名 + 編集
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        displayName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: pal.fg,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isLoggedIn) ...[
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: onEditPressed,
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('編集'),
                        style: TextButton.styleFrom(
                          foregroundColor: pal.fg,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    accountIdAsync.maybeWhen(
                      data: (id) => (isLoggedIn && (id != null && id.isNotEmpty))
                          ? _chip(context, pal, label: '@$id', singleLine: true)
                          : const SizedBox.shrink(),
                      orElse: () => const SizedBox.shrink(),
                    ),
                    _chip(context, pal, label: '会員ステータス：通常', singleLine: true),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(BuildContext context, MyPagePalette pal,
      {required String label, bool singleLine = false, double? maxWidth}) {
    final theme = Theme.of(context);
    final limits = singleLine
        ? BoxConstraints(maxWidth: maxWidth ?? MediaQuery.of(context).size.width * 0.55)
        : const BoxConstraints();

    return ConstrainedBox(
      constraints: limits,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: pal.chipBg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: pal.border),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(color: pal.muted),
          maxLines: singleLine ? 1 : null,
          overflow: singleLine ? TextOverflow.ellipsis : TextOverflow.visible,
          softWrap: !singleLine,
        ),
      ),
    );
  }
}
