class GoodsHistory {
  final String id;
  final String name;        // 商品名
  final int price;          // 価格
  final DateTime date;      // 購入日
  final String imageUrl;    // 画像URL（assets or ネット）

  const GoodsHistory({
    required this.id,
    required this.name,
    required this.price,
    required this.date,
    required this.imageUrl,
  });
}
