import 'package:sarathi/features/conversations/application/conversations_controller.dart';
import 'package:sarathi/core/storage/prefs_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sarathi/core/localization/language_provider.dart';
import 'package:sarathi/features/agent/data/cron_task_store.dart';
import 'package:sarathi/features/telegram/telegram_service.dart';
import 'router.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';

/// Root widget: responsive glass theme + router.
class SarathiApp extends ConsumerWidget {
  const SarathiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);
    final appName = ref.watch(currentAppNameProvider);
    final restartKey = ref.watch(appRestartKeyProvider);

    // Eagerly initialize cron task background engine & Telegram bridge on app startup
    ref.watch(cronTaskProvider);
    ref.watch(telegramServiceProvider);

    final prefs = ref.watch(sharedPreferencesProvider);
    ref.listen<String?>(currentConversationIdProvider, (prev, next) {
      if (next != null) {
        prefs.setString('last_active_conversation_id', next);
      } else {
        prefs.remove('last_active_conversation_id');
      }
    });

    return MaterialApp.router(
      key: ValueKey('sarathi_app_${restartKey}_${themeMode.name}'),
      title: appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
