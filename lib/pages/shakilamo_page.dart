import 'package:flutter/material.dart';
import 'tabs/bio/bio_tab.dart';
import 'tabs/member/member_tab.dart';
import 'tabs/schedule/schedule_tab.dart';
import 'tabs/shop/shop_tab.dart';

class ShakilamoPage extends StatelessWidget {
  final String imagePath;

  const ShakilamoPage({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, // タブの数
      child: Scaffold(
        appBar: AppBar(
          title: Image.asset(
            'assets/images/shakilamo_logo.png',
            height: 60,
          ),
          centerTitle: true,
          backgroundColor: Colors.black,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
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
