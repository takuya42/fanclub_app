import 'package:flutter/material.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> checkForceUpdate(BuildContext context) async {
  final remoteConfig = FirebaseRemoteConfig.instance;

  await remoteConfig.setConfigSettings(RemoteConfigSettings(
    fetchTimeout: const Duration(seconds: 5),
    minimumFetchInterval: const Duration(minutes: 1),
  ));

  await remoteConfig.fetchAndActivate();
  final minRequired = remoteConfig.getString('min_required_version');

  final info = await PackageInfo.fromPlatform();
  final current = info.version;

  if (_isLowerVersion(current, minRequired)) {
    _showForceUpdateDialog(context);
  }
}

bool _isLowerVersion(String current, String min) {
  List<int> c = current.split('.').map(int.parse).toList();
  List<int> m = min.split('.').map(int.parse).toList();

  for (int i = 0; i < m.length; i++) {
    if (c[i] < m[i]) return true;
    if (c[i] > m[i]) return false;
  }
  return false;
}

void _showForceUpdateDialog(BuildContext context) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("アップデートが必要です"),
      content: const Text("最新バージョンに更新してご利用ください。"),
      actions: [
        TextButton(
          onPressed: () {
            launchUrl(
              Uri.parse("https://apps.apple.com/jp/app/あなたのアプリURL"),
              mode: LaunchMode.externalApplication,
            );
          },
          child: const Text("アップデートする"),
        ),
      ],
    ),
  );
}
