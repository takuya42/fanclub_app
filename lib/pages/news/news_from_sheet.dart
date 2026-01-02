import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';
import 'dart:convert';

class NewsFromSheet extends StatefulWidget {
  const NewsFromSheet({super.key});

  @override
  State<NewsFromSheet> createState() => _NewsFromSheetState();
}

class _NewsFromSheetState extends State<NewsFromSheet> {
  List<Map<String, String>> newsList = [];
  bool isLoading = true;

  // 🔹 公開スプレッドシートのCSV URL
  final sheetUrl =
      'https://docs.google.com/spreadsheets/d/e/2PACX-1vQgQT4qOXJJDBXev0FcPJqMPcL-lklQxbONDenSXQyWRmEo_L7Hf3DycBRQdtmlYLUwDpBTjbH0Oo1U/pub?gid=0&single=true&output=csv';

  @override
  void initState() {
    super.initState();
    fetchSheet();
  }

  /// 🔹 CSV取得処理
  Future<void> fetchSheet() async {
    try {
      final response = await http.get(Uri.parse(sheetUrl));
      if (response.statusCode == 200) {
        final csvString = utf8.decode(response.bodyBytes);
        final rows = const CsvToListConverter(eol: '\n').convert(csvString);

        if (rows.length <= 1) throw Exception('CSVが空です');

        final headers = rows.first.cast<String>();
        final items = rows.skip(1).map((r) {
          final map = <String, String>{};
          for (int i = 0; i < headers.length && i < r.length; i++) {
            map[headers[i]] = r[i].toString();
          }
          return map;
        }).toList();

        if (!mounted) return;
        setState(() {
          newsList = items;
          isLoading = false;
        });
      } else {
        throw Exception('HTTPエラー: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ スプレッドシート取得エラー: $e');
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  /// 🔁 手動更新
  Future<void> _refresh() async {
    await fetchSheet();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.redAccent),
      );
    }

    if (newsList.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: Text(
            '現在ニュースはありません。',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: Colors.redAccent,
      onRefresh: _refresh,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        shrinkWrap: true, // ← スクロールの親の中で使えるように
        padding: const EdgeInsets.all(8),
        itemCount: newsList.length,
        itemBuilder: (context, index) {
          final n = newsList[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  n['date'] ?? '',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  n['title'] ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  n['desc'] ?? '',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
