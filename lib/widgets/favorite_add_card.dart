import 'package:flutter/material.dart';
import '../theme/mypage_palette.dart';

class FavoriteAddCard extends StatelessWidget {
  final VoidCallback? onTap;
  const FavoriteAddCard({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pal = MyPagePalette.fromBrightness(theme.brightness == Brightness.dark);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          color: pal.panel,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: pal.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: pal.accentBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: pal.border),
              ),
              child: Icon(Icons.add, color: pal.accentFg, size: 26),
            ),
            const SizedBox(height: 10),
            const Text('お気に入りを追加', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(
              'よく見るバンド/グループを\n登録できます',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}
