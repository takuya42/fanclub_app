import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';

class BottomNavLayout extends StatelessWidget {
  final Widget child;
  const BottomNavLayout({super.key, required this.child});

  int _indexFor(String loc) {
    if (loc.startsWith('/newslist')) return 0;
    if (loc.startsWith('/home')) return 1;
    if (loc.startsWith('/settings')) return 2;

    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _indexFor(location);

    return Scaffold(
      body: child,
        bottomNavigationBar: ConvexAppBar(
          items: const [
            TabItem(icon: Icons.campaign, title: 'お知らせ'),
            TabItem(icon: Icons.home, title: 'ホーム'),
            TabItem(icon: Icons.settings, title: '設定'),
          ],
          initialActiveIndex: currentIndex,     // ← 現在のタブを反映
          backgroundColor: Colors.black,
          color: Colors.white70,
          activeColor: Colors.white,
          onTap: (i) {
            switch (i) {
              case 0:
                context.go('/newslist');
                break;
              case 1:
                context.go('/home');
                break;
              case 2:
                context.go('/settings');
                break;
            }
          },
        ),
    );
  }
}