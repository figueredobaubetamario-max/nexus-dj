import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'app_state.dart';
import 'screens/dj_screen.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await WakelockPlus.enable();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DJAppState()),
      ],
      child: const NexusDJApp(),
    ),
  );
}

class NexusDJApp extends StatelessWidget {
  const NexusDJApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NEXUS DJ',
      debugShowCheckedModeBanner: false,
      theme: nexusTheme,
      home: const DJScreen(),
    );
  }
}