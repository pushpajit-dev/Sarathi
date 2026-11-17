import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sarathi/app/router.dart';
import 'package:sarathi/app/theme/glass_tokens.dart';
import 'package:sarathi/app/theme/theme_controller.dart';
import 'package:sarathi/core/localization/language_provider.dart';
import 'package:sarathi/shared/widgets/app_icons.dart';
import 'package:sarathi/features/settings/ui/personas_sheet.dart';
import 'package:url_launcher/url_launcher.dart';

/// Main settings menu grouping all app configurations into sleek glass tiles.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _openUrl(BuildContext context, String urlString) async {
    final uri = Uri.parse(urlString);
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        final fallbackLaunched = await launchUrl(
          uri,
          mode: LaunchMode.platformDefault,
        );
        if (!fallbackLaunched && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not open $urlString')),
          );
        }
      }
    } catch (e) {
      try {
        await launchUrl(uri);
      } catch (err) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error opening link: $err')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.glass;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          ref.t('settings'),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        children: [
          _SectionHeader(title: ref.t('aiEngine')),
          _SettingsTile(
            icon: AppIcons.download,
            title: ref.t('localModels'),
            subtitle: ref.t('localModelsSub'),
            onTap: () => context.push(AppRoutes.settingsLocalModels),
          ),
          _SettingsTile(
            icon: AppIcons.cpu,
            title: ref.t('aiProviders'),
            subtitle: ref.t('aiProvidersSub'),
            onTap: () => context.push(AppRoutes.settingsProviders),
          ),
          _SettingsTile(
            icon: AppIcons.brain,
            title: ref.t('personas'),
            subtitle: ref.t('personasSub'),
            onTap: () => PersonasSheet.show(context),
          ),
          _SettingsTile(
            icon: AppIcons.sparkles,
            title: ref.t('hermes'),
            subtitle: ref.t('hermesSub'),
            onTap: () => context.push(AppRoutes.settingsHermes),
          ),
          _SettingsTile(
            icon: AppIcons.sliders,
            title: ref.t('modelParams'),
            subtitle: ref.t('modelParamsSub'),
            onTap: () => context.push(AppRoutes.settingsModels),
          ),
          _SettingsTile(
            icon: AppIcons.plug,
            title: ref.t('mcpServers'),
            subtitle: ref.t('mcpServersSub'),
            onTap: () => context.push(AppRoutes.settingsMcp),
          ),
          _SettingsTile(
            icon: AppIcons.wrench,
            title: ref.t('agentTools'),
            subtitle: ref.t('agentToolsSub'),
            onTap: () => context.push('/settings/tools'),
          ),

          const SizedBox(height: 12),
          _SectionHeader(title: ref.t('integrationsStorage')),
          _SettingsTile(
            icon: AppIcons.send,
            title: ref.t('telegramBridge'),
            subtitle: ref.t('telegramBridgeSub'),
            onTap: () => context.push('/settings/telegram'),
          ),
          _SettingsTile(
            icon: AppIcons.folder,
            title: ref.t('storagePerms'),
            subtitle: ref.t('storagePermsSub'),
            onTap: () => context.push('/settings/storage'),
          ),
          _SettingsTile(
            icon: AppIcons.brain,
            title: ref.t('memoryContext'),
            subtitle: ref.t('memoryContextSub'),
            onTap: () => context.push('/settings/memory'),
          ),
          _SettingsTile(
            icon: AppIcons.sparkles,
            title: ref.t('scheduledTasks'),
            subtitle: ref.t('scheduledTasksSub'),
            onTap: () => context.push(AppRoutes.settingsTasks),
          ),

          const SizedBox(height: 12),
          _SectionHeader(title: ref.t('preferencesSystem')),

          // Single-line 3-button Theme Selector (Dark / Light / System)
          const _ThemeModeRow(),
          const SizedBox(height: 2),

          _SettingsTile(
            icon: AppIcons.phoneInHand,
            title: ref.t('dataAbout'),
            subtitle: ref.t('dataAboutSub'),
            onTap: () => context.push('/settings/about'),
          ),

          const SizedBox(height: 12),
          _SectionHeader(title: ref.t('communityDeveloper')),

          // Developer NoishiXzen Card with Compact Icons (Hidden Raw Links)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: tokens.glassColor,
              borderRadius: BorderRadius.circular(tokens.radiusSm),
              border: Border.all(color: tokens.glassBorder, width: 0.8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: tokens.accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: tokens.accent.withValues(alpha: 0.35),
                          width: 0.8,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.verified_user_rounded,
                          color: tokens.accent,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ref.t('developedBy'),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            ref.t('developedByDesc'),
                            style: TextStyle(
                              fontSize: 11,
                              color: tokens.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),

                // Icon buttons for small space (icon-only to avoid overflow)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _CompactLinkButton(
                      icon: Icons.code_rounded,
                      tooltip: 'GitHub: pushpajit-dev',
                      color: tokens.accent,
                      onTap: () =>
                          _openUrl(context, 'https://github.com/pushpajit-dev'),
                    ),
                    _CompactLinkButton(
                      icon: Icons.public_rounded,
                      tooltip: 'Website: aivorygen.netlify.app',
                      color: const Color(0xFF00D2FF),
                      onTap: () =>
                          _openUrl(context, 'https://aivorygen.netlify.app'),
                    ),
                    _CompactLinkButton(
                      icon: Icons.chat_bubble_rounded,
                      tooltip: 'Discord: Join Server',
                      color: const Color(0xFF5865F2),
                      onTap: () =>
                          _openUrl(context, 'https://discord.gg/Dcg2GreJ'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _CompactLinkButton extends StatelessWidget {
  const _CompactLinkButton({
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Container(
            width: 48,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: color.withValues(alpha: 0.35),
                width: 0.8,
              ),
            ),
            child: Center(
              child: Icon(icon, size: 19, color: color),
            ),
          ),
        ),
      ),
    );
  }
}

/// Single-line 3-button theme selector: Dark / Light / System.
class _ThemeModeRow extends ConsumerWidget {
  const _ThemeModeRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.glass;
    final currentMode = ref.watch(themeModeProvider);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: tokens.glassColor,
        borderRadius: BorderRadius.circular(tokens.radiusSm),
        border: Border.all(color: tokens.glassBorder, width: 0.8),
      ),
      child: Row(
        children: [
          _buildThemeBtn(
            context,
            ref,
            label: ref.t('themeDark'),
            icon: AppIcons.moon,
            mode: ThemeMode.dark,
            currentMode: currentMode,
          ),
          const SizedBox(width: 4),
          _buildThemeBtn(
            context,
            ref,
            label: ref.t('themeLight'),
            icon: AppIcons.sun,
            mode: ThemeMode.light,
            currentMode: currentMode,
          ),
          const SizedBox(width: 4),
          _buildThemeBtn(
            context,
            ref,
            label: ref.t('themeSystem'),
            icon: AppIcons.smartphone,
            mode: ThemeMode.system,
            currentMode: currentMode,
          ),
        ],
      ),
    );
  }

  Widget _buildThemeBtn(
    BuildContext context,
    WidgetRef ref, {
    required String label,
    required IconData icon,
    required ThemeMode mode,
    required ThemeMode currentMode,
  }) {
    final tokens = context.glass;
    final isSelected = currentMode == mode;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          ref.read(themeModeProvider.notifier).setMode(mode);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 36,
          decoration: BoxDecoration(
            color: isSelected
                ? tokens.accent.withValues(alpha: 0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(tokens.radiusSm - 2),
            border: Border.all(
              color: isSelected
                  ? tokens.accent.withValues(alpha: 0.45)
                  : Colors.transparent,
              width: 0.8,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14,
                color: isSelected ? tokens.accent : tokens.textSecondary,
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? tokens.accent : tokens.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 8, 6, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 0.9,
              fontSize: 10.5,
              color: context.glass.textSecondary,
            ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData? icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.glass;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: tokens.glassColor,
        borderRadius: BorderRadius.circular(tokens.radiusSm),
        child: InkWell(
          borderRadius: BorderRadius.circular(tokens.radiusSm),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(tokens.radiusSm),
              border: Border.all(color: tokens.glassBorder, width: 0.8),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: tokens.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: tokens.accent.withValues(alpha: 0.25),
                      width: 0.8,
                    ),
                  ),
                  child: Icon(icon, color: tokens.accent, size: 16),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 11.5,
                              color: tokens.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                Icon(
                  AppIcons.chevronRight,
                  size: 14,
                  color: tokens.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
