import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const JHApp());
}

class JHApp extends StatelessWidget {
  const JHApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'JH App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6C2AAE)),
        useMaterial3: true,
      ),
      home: const H5ShellPage(),
    );
  }
}

class H5ShellPage extends StatefulWidget {
  const H5ShellPage({super.key});

  @override
  State<H5ShellPage> createState() => _H5ShellPageState();
}

class _H5ShellPageState extends State<H5ShellPage> {
  static const String _localDevUrlIOS = 'http://192.168.254.141:5173/';
  static const String _localDevUrlAndroid = 'http://192.168.254.141:5173/';

  String get h5Url => Platform.isAndroid ? _localDevUrlAndroid : _localDevUrlIOS;

  late final WebViewController _controller;
  late String _currentUrl;
  int _loadingProgress = 0;

  @override
  void initState() {
    super.initState();
    _currentUrl = h5Url;
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            setState(() => _loadingProgress = progress);
          },
          onPageFinished: (_) {
            setState(() => _loadingProgress = 100);
          },
        ),
      )
      ..loadRequest(Uri.parse(_currentUrl));
  }

  Future<bool> _handleBack() async {
    if (await _controller.canGoBack()) {
      await _controller.goBack();
      return false;
    }
    return true;
  }

  Future<void> _changeUrl() async {
    final inputController = TextEditingController(text: _currentUrl);
    final next = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('设置 H5 地址'),
        content: TextField(
          controller: inputController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'http://192.168.x.x:5173/',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, inputController.text.trim()),
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (next == null || next.isEmpty) return;
    final uri = Uri.tryParse(next);
    if (uri == null || !(uri.isScheme('http') || uri.isScheme('https'))) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('地址格式不正确，请输入 http/https 地址')),
      );
      return;
    }

    setState(() {
      _currentUrl = next;
      _loadingProgress = 0;
    });
    await _controller.loadRequest(uri);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final canPop = await _handleBack();
        if (canPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _currentUrl,
            style: const TextStyle(fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            IconButton(
              onPressed: _changeUrl,
              icon: Icon(Icons.link),
              tooltip: '修改地址',
            ),
            IconButton(
              onPressed: () {
                setState(() => _loadingProgress = 0);
                _controller.reload();
              },
              icon: const Icon(Icons.refresh),
              tooltip: '刷新',
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              if (_loadingProgress < 100)
                LinearProgressIndicator(
                  value: _loadingProgress / 100,
                  minHeight: 2,
                ),
              Expanded(child: WebViewWidget(controller: _controller)),
            ],
          ),
        ),
      ),
    );
  }
}
