import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'features/voice_agent/presentation/voice_agent_screen.dart';
import 'features/discovery/presentation/worker_discovery_screen.dart';
import 'features/multilingual/presentation/multilingual_demo_screen.dart';
import 'shared/widgets/app_drawer.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(const ProviderScope(child: NearaApp()));
}

class NearaApp extends StatelessWidget {
  const NearaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Neara',
      theme: buildAppTheme(),
      home: const _RootShell(),
    );
  }
}

class _RootShell extends StatefulWidget {
  const _RootShell();

  @override
  State<_RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<_RootShell> {
  int _index = 0; // 0: Voice Agent, 1: Worker Discovery, 2: Multilingual Demo

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(onSelectScreen: _setScreenFromDrawer),
      body: SafeArea(
        child: IndexedStack(
          index: _index,
          children: [
            VoiceAgentScreen(
              onOpenDrawer: () => Scaffold.of(context).openDrawer(),
            ),
            const WorkerDiscoveryScreen(),
            const MultilingualDemoScreen(),
          ],
        ),
      ),
    );
  }

  void _setScreenFromDrawer(int index) {
    setState(() {
      _index = index;
    });
  }
}
