
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

// ★ Googleフォームの「送信 → リンク」
const String kContactFormUrl =
    'https://docs.google.com/forms/d/e/1FAIpQLSeSBLx9DN_g5ER99R_pe_uNwmrx7IfL5UpT7_ah631Zpa6fFQ/viewform?embedded=true';

class ContactWebViewPage extends StatefulWidget {
  final String initialUrl;
  const ContactWebViewPage({super.key, this.initialUrl = kContactFormUrl});

  @override
  State<ContactWebViewPage> createState() => _ContactWebViewPageState();
}

class _ContactWebViewPageState extends State<ContactWebViewPage> {
  late final WebViewController _controller;
  bool _loading = true;
  String _currentUrl = kContactFormUrl;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)

      ..setUserAgent(
        'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) '
            'AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 '
            'Mobile/15E148 Safari/604.1',
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() {
              _loading = true;
              _currentUrl = url;
            });
          },
          onUrlChange: (c) {
            if (c.url != null) _currentUrl = c.url!;
          },
          onPageFinished: (_) => setState(() => _loading = false),
          onWebResourceError: (e) {
            setState(() => _loading = false);
            // 必要ならここでSnackBar等
            debugPrint('Web error: ${e.errorCode} ${e.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.initialUrl));
  }

  Future<void> _reload() async {
    try {
      await _controller.reload();
    } catch (_) {
      // ホットリロード後にチャンネルが切れた場合の保険
      await _controller.loadRequest(Uri.parse(_currentUrl));
    }
  }

  Future<void> _openInSafari() async {
    final ok = await launchUrl(Uri.parse(_currentUrl),
        mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('外部ブラウザで開けませんでした。')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('お問い合わせ'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _reload),
          IconButton(icon: const Icon(Icons.open_in_browser), onPressed: _openInSafari),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading)
            Align(
              alignment: Alignment.topCenter,
              child: LinearProgressIndicator(
                minHeight: 2,
                color: cs.primary,
                backgroundColor: cs.surfaceVariant,
              ),
            ),
        ],
      ),
    );
  }
}
