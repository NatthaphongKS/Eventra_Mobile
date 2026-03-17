import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'utils/app_theme.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('th', null);
  runApp(const EventraApp());
}

class EventraApp extends StatelessWidget {
  const EventraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eventra',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const LoginScreen(),
    );
  }
}
