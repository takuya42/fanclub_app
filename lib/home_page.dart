// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kf_drawer/kf_drawer.dart';

import '../providers/home_providers.dart';
import '../widgets/app_drawer.dart';
import '../widgets/image_slider.dart';
import 'pages/tabs/news_tab.dart';
import 'pages/tabs/pickup_tab.dart';
import 'pages/tabs/interview_tab.dart';
import 'pages/tabs/release_tab.dart';
import '../widgets/search_box.dart';

class HomePage extends HookConsumerWidget {
  final String? email;
  const HomePage({super.key, this.email});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(tabIndexProvider);

    // TabController を Riverpod の index と同期
    final tabController = useTabController(
      initialLength: 4,
      initialIndex: currentIndex,
    );

    useEffect(() {
      void listener() {
        ref.read(tabIndexProvider.notifier).state = tabController.index;
      }

      tabController.addListener(listener);
      return () => tabController.removeListener(listener);
    }, [tabController]);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ホーム'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.group_add),
                Text('新規登録', style: TextStyle(fontSize: 10)),
              ],
            ),
            onPressed: () => context.go('/register'),
          ),
          IconButton(
            icon: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.logout),
                Text('ログアウト', style: TextStyle(fontSize: 10)),
              ],
            ),
            onPressed: () => context.go('/login'),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: SearchBox(),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const ImageSlider(),
                  Container(
                    width: double.infinity,
                    color: Colors.black,
                    child: TabBar(
                      controller: tabController,
                      labelStyle: const TextStyle(fontSize: 12),
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Colors.white70,
                      tabs: const [
                        Tab(child: Text('NEWS')),
                        Tab(child: Text('PICK UP')),
                        Tab(child: Text('INTERVIEW')),
                        Tab(
                          child: Text(
                            'NEW\nRELEASE',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 500,
                    child: TabBarView(
                      controller: tabController,
                      children: const [
                        NewsTabContent(),
                        PickUpTabContent(),
                        InterviewTabContent(),
                        ReleaseTabContent(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
