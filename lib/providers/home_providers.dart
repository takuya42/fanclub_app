import 'package:hooks_riverpod/hooks_riverpod.dart';

/// 検索クエリ（全タブで共有）
final searchQueryProvider = StateProvider<String>((ref) => '');

/// 現在のタブインデックス
final tabIndexProvider = StateProvider<int>((ref) => 0);
