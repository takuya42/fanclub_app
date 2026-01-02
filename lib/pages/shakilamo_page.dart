import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/favorites_providers.dart';
import 'tabs/bio/bio_tab.dart';
import 'tabs/member/member_tab.dart';
import 'tabs/schedule/schedule_tab.dart';
import 'tabs/shop/shop_tab.dart';

class ShakilamoPage extends ConsumerWidget {
  final String imagePath;

  const ShakilamoPage({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);
    final notifier = ref.read(favoritesProvider.notifier);

    // このページ専用データ（お気に入り対象）
    const bandId = 'shakilamo';
    const bandName = 'SHAKILAMO';
    const logoPath = 'assets/images/shakilamo_logo.png'; // ← 画像パス指定

    final isFavorite = favorites.any((f) => f.id == bandId);

    void toggleFavorite() {
      if (isFavorite) {
        notifier.remove(bandId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('「SHAKILAMO」をお気に入りから削除しました')),
        );
      } else {
        notifier.add(
          const FavoriteItem(
            id: bandId,
            name: bandName,
            imageUrl: 'assets/images/SHAKILAMO.JPG', // ← ここでロゴ画像を登録
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('「SHAKILAMO」をお気に入りに追加しました')),
        );
      }
    }

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Image.asset(
            logoPath,
            height: 60,
          ),
          centerTitle: true,
          backgroundColor: Colors.black,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),

          // ❤️ 右上ハートボタン
          actions: [
            IconButton(
              onPressed: toggleFavorite,
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.redAccent : Colors.white,
                size: 28,
              ),
              tooltip: isFavorite ? 'お気に入りから削除' : 'お気に入りに追加',
            ),
          ],

          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.grey,
            tabs: [
              Tab(child: Text('BIO', style: TextStyle(fontSize: 14))),
              Tab(child: Text('MEMBER', style: TextStyle(fontSize: 14))),
              Tab(child: Text('SCHEDULE', style: TextStyle(fontSize: 10))),
              Tab(child: Text('SHOP', style: TextStyle(fontSize: 14))),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            BioTab(imagePath: imagePath),
            const MemberTab(),
            const ScheduleTab(),
            const ShopTab(),
          ],
        ),
      ),
    );
  }
}
