import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

const Color kShellColor = Color(0xFF552583);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarContrastEnforced: false,
    ),
  );
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
        colorScheme: ColorScheme.fromSeed(seedColor: kShellColor),
        scaffoldBackgroundColor: kShellColor,
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
  static const String h5Url = 'https://jh-h5.panalow.cc/';

  late final WebViewController _controller;
  late final String _currentUrl;
  int _loadingProgress = 0;

  @override
  void initState() {
    super.initState();
    _currentUrl = h5Url;
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(kShellColor)
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
        backgroundColor: kShellColor,
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
