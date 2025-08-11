import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'screens/home_screen.dart';
import 'screens/home_screen_new.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Custom Slide Show',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // 既存の実装
      home: const MyHomePage(title: 'Custom Slide Show'),
      // 新しいViewModel-View構成
      // home: const HomeScreenNew(title: 'Custom Slide Show'),
    );
  }
}
