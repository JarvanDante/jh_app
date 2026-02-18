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
  int _loadingProgress = 0;

  @override
  void initState() {
    super.initState();
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
      ..loadRequest(Uri.parse(h5Url));
  }

  Future<bool> _handleBack() async {
    if (await _controller.canGoBack()) {
      await _controller.goBack();
      return false;
    }
    return true;
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
