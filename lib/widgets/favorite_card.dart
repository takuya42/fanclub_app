import 'package:flutter/material.dart';
import '../theme/mypage_palette.dart';

class FavoriteCard extends StatelessWidget {
  final String id;
  final String title;
  final String? imageUrl;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final VoidCallback? onTap;

  const FavoriteCard({
    super.key,
    required this.id,
    required this.title,
    this.imageUrl,
    required this.isFavorite,
    required this.onToggleFavorite,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pal = MyPagePalette.fromBrightness(theme.brightness == Brightness.dark);

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none, // ハートを隠さない
        children: [
          // カード本体
          Container(
            width: 200,
            decoration: BoxDecoration(
              color: pal.panel,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: pal.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 画像（内側に角丸）
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(
                      height: 110,
                      width: double.infinity,
                      child: (imageUrl != null && imageUrl!.isNotEmpty)
                          ? Image.network(
                        imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _imageFallback(pal),
                      )
                          : _imageFallback(pal),
                    ),
                  ),
                ),
                // タイトル
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),

          // 左上ハート（背景なし・押しやすい）
          Positioned(
            top: 10,
            left: 10,
            child: SizedBox(
              width: 40,
              height: 40,
              child: Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  splashRadius: 22,
                  onPressed: onToggleFavorite,
                  tooltip: isFavorite ? 'お気に入りを外す' : 'お気に入りに追加',
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    size: 26,
                    color: isFavorite ? Colors.redAccent : pal.muted,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imageFallback(MyPagePalette pal) {
    return Container(
      color: pal.accentBg,
      child: Center(
        child: Icon(Icons.image_not_supported_outlined, color: pal.accentFg),
      ),
    );
  }
}
