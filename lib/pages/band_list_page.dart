import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/band_provider.dart';
import '../providers/home_providers.dart';
import '../widgets/search_box.dart';
import '../pages/shakilamo_page.dart';
import '../providers/favorites_providers.dart';

class BandListPage extends ConsumerWidget {
  const BandListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncBands = ref.watch(bandsProvider);
    final query = ref.watch(searchQueryProvider).toLowerCase().trim();

    // 🔹 お気に入りの現在リスト
    final favorites = ref.watch(favoritesProvider);
    final favCtrl = ref.read(favoritesProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('バンド一覧'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: asyncBands.when(
        data: (bands) {
          if (bands.isEmpty) {
            return const Center(child: Text('バンドが登録されていません'));
          }

          // 🔹 重複削除
          final uniqueBands = {for (var b in bands) b.id: b}.values.toList();

          // 🔹 検索フィルタ
          final filteredBands = uniqueBands.where((b) {
            return b.name.toLowerCase().contains(query) ||
                b.genre.toLowerCase().contains(query);
          }).toList();

          return Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(12.0),
                child: SearchBox(),
              ),
              Expanded(
                child: filteredBands.isEmpty
                    ? const Center(child: Text('該当するバンドが見つかりません'))
                    : ListView.builder(
                  itemCount: filteredBands.length,
                  itemBuilder: (context, index) {
                    final band = filteredBands[index];

                    // ✅ ここ追加！ お気に入り判定
                    final isFavorite =
                    favorites.any((f) => f.id == band.id);

                    return Card(
                      color: Colors.grey[900],
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: band.imageUrl.isNotEmpty
                            ? CircleAvatar(
                          backgroundImage:
                          NetworkImage(band.imageUrl),
                        )
                            : const CircleAvatar(
                          backgroundColor: Colors.white12,
                          child: Icon(Icons.music_note,
                              color: Colors.white),
                        ),
                        title: Text(
                          band.name,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16),
                        ),
                        subtitle: Text(
                          band.genre,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13),
                        ),

                        // ❤️ ハートボタン
                        trailing: IconButton(
                          icon: Icon(
                            isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: isFavorite
                                ? Colors.redAccent
                                : Colors.white70,
                          ),
                          onPressed: () {
                            if (isFavorite) {
                              favCtrl.remove(band.id);
                            } else {
                              favCtrl.add(FavoriteItem(
                                id: band.id,
                                name: band.name,
                                imageUrl: band.imageUrl,
                              ));
                            }
                          },
                        ),

                        // 🔹 タップで詳細へ
                        onTap: () {
                          switch (band.pageType.toLowerCase()) {
                            case 'shakilamo':
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ShakilamoPage(
                                    imagePath:
                                    'assets/images/SHAKILAMO.JPG',
                                  ),
                                ),
                              );
                              break;
                            default:
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      '${band.name} のページは準備中です'),
                                ),
                              );
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: Colors.grey),
        ),
        error: (e, _) => Center(
          child: Text(
            '読み込みエラー: $e',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }
}
