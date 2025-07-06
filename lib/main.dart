import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widgets/auth_wrapper.dart';
import 'package:flutter_shonen_shelf/theme/app_theme.dart';
import 'providers/service_providers.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(const ProviderScope(child: MyApp()));
  } catch (e) {
    runApp(const ProviderScope(child: MyApp()));
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final fontSize = ref.watch(fontSizeProvider);
    final baseTextTheme = ThemeData.dark().textTheme;
    final customTextTheme = baseTextTheme.copyWith(
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(fontSize: fontSize),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(fontSize: fontSize - 2),
      bodySmall: baseTextTheme.bodySmall?.copyWith(fontSize: fontSize - 4),
      titleLarge: baseTextTheme.titleLarge?.copyWith(fontSize: fontSize + 2),
      titleMedium: baseTextTheme.titleMedium?.copyWith(fontSize: fontSize),
      titleSmall: baseTextTheme.titleSmall?.copyWith(fontSize: fontSize - 2),
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(
        fontSize: fontSize + 4,
      ),
      headlineSmall: baseTextTheme.headlineSmall?.copyWith(
        fontSize: fontSize + 2,
      ),
    );
    return MaterialApp(
      title: 'Shonen Shelf',
      theme: ThemeData.light().copyWith(textTheme: customTextTheme),
      darkTheme: appDarkTheme.copyWith(textTheme: customTextTheme),
      themeMode: themeMode,
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}
