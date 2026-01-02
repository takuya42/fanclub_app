import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../providers/favorites_providers.dart';
import '../theme/mypage_palette.dart';

class FavoritesSection extends HookConsumerWidget {
  final double height;
  const FavoritesSection({super.key, this.height = 180});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pal = MyPagePalette.fromBrightness(
      Theme.of(context).brightness == Brightness.dark,
    );
    final favorites = ref.watch(favoritesProvider);

    if (favorites.isEmpty) {
      return Container(
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: pal.panel,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: pal.border),
        ),
        child: Text(
          'お気に入りはまだありません',
          style: TextStyle(
            color: pal.muted,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: favorites.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final f = favorites[i];
          return FavoriteCard(pal: pal, item: f);
        },
      ),
    );
  }
}

/// 🩷 お気に入りカード（カード全体が画像）
class FavoriteCard extends HookConsumerWidget {
  final MyPagePalette pal;
  final FavoriteItem item;

  const FavoriteCard({
    super.key,
    required this.pal,
    required this.item,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDeleting = useState(false);

    void delete() {
      HapticFeedback.selectionClick();
      isDeleting.value = true;
      Future.delayed(const Duration(milliseconds: 300), () {
        ref.read(favoritesProvider.notifier).remove(item.id);
        isDeleting.value = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('「${item.name}」をお気に入りから削除しました')),
        );
      });
    }

    // ✅ 表示する画像を決定
    Widget buildImage() {
      if (item.name.toUpperCase() == 'SHAKILAMO') {
        return Image.asset(
          'assets/images/SHAKILAMO.JPG',
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (_, __, ___) => _fallbackImage(pal),
        );
      }

      final path = item.imageUrl;
      if (path == null || path.isEmpty) return _fallbackImage(pal);

      if (path.startsWith('assets/')) {
        return Image.asset(
          path,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        );
      } else {
        return Image.network(
          path,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (_, __, ___) => _fallbackImage(pal),
        );
      }
    }

    // ✅ カード全体が画像
    return Container(
      width: 200,
      height: 180,
      decoration: BoxDecoration(
        color: pal.panel,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: pal.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          buildImage(),

          // 左上のハートボタン
          Positioned(
            top: 8,
            left: 8,
            child: Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              child: IconButton(
                padding: EdgeInsets.zero,
                splashRadius: 22,
                onPressed: delete,
                icon: const Icon(
                  Icons.favorite,
                  color: Colors.redAccent,
                  size: 26,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallbackImage(MyPagePalette pal) {
    return Container(
      color: pal.accentBg,
      child: Center(
        child: Icon(Icons.image_not_supported, color: pal.accentFg),
      ),
    );
  }
}
