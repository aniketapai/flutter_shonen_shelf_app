import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';

final themeProvider = Provider<ThemeData>((ref) => appDarkTheme);
