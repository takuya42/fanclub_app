import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../providers/home_providers.dart';
import '../widgets/app_drawer.dart';
import '../widgets/image_slider.dart';
import 'pages/tabs/home_tab.dart';
import 'pages/tabs/goods_tab.dart';

// ★ 強制アップデート
import '../../utils/version_checker.dart';

class HomePage extends HookConsumerWidget {
  final String? email;
  const HomePage({super.key, this.email});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(tabIndexProvider);

    // ★★ 強制アップデートチェック（画面描画後1回だけ実行）
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        checkForceUpdate(context);
      });
      return null;
    }, []);

    // 🔹 タブ2つ
    final tabController = useTabController(
      initialLength: 2,
      initialIndex: currentIndex,
    );

    useEffect(() {
      void listener() {
        ref.read(tabIndexProvider.notifier).state = tabController.index;
      }

      tabController.addListener(listener);
      return () => tabController.removeListener(listener);
    }, [tabController]);

    // 🔹 フェードアニメーション
    final fadeController =
    useAnimationController(duration: const Duration(milliseconds: 800))
      ..forward();

    final fadeAnimation =
    CurvedAnimation(parent: fadeController, curve: Curves.easeIn);

    return FadeTransition(
      opacity: fadeAnimation,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          centerTitle: true,
          title: const Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Stage',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 8,
                  ),
                ),
                TextSpan(
                  text: '+',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 8,
                  ),
                ),
              ],
            ),
          ),
        ),
        drawer: const AppDrawer(),

        // 🔹 全体を1つのスクロールに
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 スライダー部分
              const ImageSlider(),

              // 🔹 タブメニュー
              Container(
                width: double.infinity,
                color: Colors.black,
                child: TabBar(
                  controller: tabController,
                  labelStyle: const TextStyle(fontSize: 13),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.white70,
                  tabs: const [
                    Tab(child: Text('HOME')),
                    Tab(child: Text('NEW GOODS')),
                  ],
                ),
              ),

              // 🔹 タブの中身（HOME / NEW GOODS）
              SizedBox(
                height: MediaQuery.of(context).size.height * 1.5,
                child: TabBarView(
                  controller: tabController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: const [
                    HomeTabContent(),
                    GoodsTabContent(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
