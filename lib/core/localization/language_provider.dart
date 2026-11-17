import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_strings.dart';

/// Single default English provider for clean architecture.
final currentAppNameProvider = Provider<String>((ref) => 'Sarathi');
final languageProvider = Provider<String>((ref) => 'en');
final appRestartKeyProvider = StateProvider<int>((ref) => 0);

extension LocalizationExtension on BuildContext {
  String t(String key) => AppStrings.get(key);
}

extension ConsumerLocalizationExtension on WidgetRef {
  String t(String key) => AppStrings.get(key);
}
