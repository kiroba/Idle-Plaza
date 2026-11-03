import 'package:flutter/material.dart';

import 'idle_plaza_home.dart';

/// Standalone Idle Plaza app. The screens live in [IdlePlazaHome] so the
/// Omni-Hub can host the same widget as its Idle Plaza container.
void main() => runApp(const IdlePlazaApp());

class IdlePlazaApp extends StatelessWidget {
  const IdlePlazaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Idle Plaza',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: const Color(0xFF6200EE),
        scaffoldBackgroundColor: const Color(0xFF0F0F1A),
        cardColor: const Color(0xFF1A1A2E),
      ),
      home: const IdlePlazaHome(),
    );
  }
}
