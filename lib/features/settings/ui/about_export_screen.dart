import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sarathi/app/theme/glass_tokens.dart';
import 'package:sarathi/core/db/app_database.dart';
import 'package:sarathi/core/localization/language_provider.dart';
import 'package:sarathi/shared/widgets/app_icons.dart';
import 'package:sarathi/shared/widgets/app_logo.dart';
import 'package:sarathi/shared/widgets/glass_button.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutExportScreen extends ConsumerWidget {
  const AboutExportScreen({super.key});

  Future<void> _exportData(BuildContext context, WidgetRef ref) async {
    final db = ref.read(appDatabaseProvider);
    final conversations = await db.conversationsDao.getAll();

    final exportList = <Map<String, dynamic>>[];
    for (final conv in conversations) {
      final messages = await db.messagesDao.getForConversation(conv.id);
      exportList.add({
        'conversation': {
          'id': conv.id,
          'title': conv.title,
          'personaId': conv.personaId,
          'createdAt': conv.createdAt.toIso8601String(),
          'updatedAt': conv.updatedAt.toIso8601String(),
        },
        'messages': messages
            .map((m) => {
                  'id': m.id,
                  'role': m.role,
                  'content': m.content,
                  'toolName': m.toolName,
                  'createdAt': m.createdAt.toIso8601String(),
                })
            .toList(),
      });
    }

    final jsonStr = const JsonEncoder.withIndent('  ').convert(exportList);
    await Clipboard.setData(ClipboardData(text: jsonStr));

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Exported ${conversations.length} conversations to clipboard (JSON)!'),
        ),
      );
    }
  }

  Future<void> _wipeData(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(ref.t('wipeConfirmTitle')),
        content: Text(ref.t('wipeConfirmMsg')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(ref.t('cancel')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(ref.t('wipeEverything')),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final db = ref.read(appDatabaseProvider);
      await db.customStatement('DELETE FROM messages;');
      await db.customStatement('DELETE FROM conversations;');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All chat history wiped cleanly.')),
        );
      }
    }
  }

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
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening link: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.glass;
    final appName = ref.watch(currentAppNameProvider);


    return Scaffold(
      appBar: AppBar(
        title: Text(
          ref.t('dataAbout'),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // App Logo & Branded Header
          Center(
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: tokens.accent.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: AppLogo(
                    size: 80,
                    borderRadius: BorderRadius.circular(20),
                    showGlow: false,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  appName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.2,
                      ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: tokens.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: tokens.accent.withValues(alpha: 0.35),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    ref.t('version'),
                    style: TextStyle(
                      color: tokens.accent,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  ref.t('appTagline'),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: tokens.textSecondary, fontSize: 12.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // DEVELOPER & COMPACT ICON LINKS
          Text(
            ref.t('communityDeveloper'),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: tokens.textSecondary,
                ),
          ),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(16),
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
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: tokens.accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: tokens.accent.withValues(alpha: 0.35),
                          width: 0.8,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.verified_user_rounded,
                          color: tokens.accent,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
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
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            ref.t('developedByDesc'),
                            style: TextStyle(
                              fontSize: 11.5,
                              color: tokens.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 14),

                // Sleek compact icon buttons: GitHub, Website, Discord (icon-only for small screens)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // GitHub Icon Button
                    _CompactSocialIconButton(
                      icon: Icons.code_rounded,
                      tooltip: 'GitHub: pushpajit-dev',
                      color: tokens.accent,
                      onTap: () =>
                          _openUrl(context, 'https://github.com/pushpajit-dev'),
                    ),

                    // Website Icon Button
                    _CompactSocialIconButton(
                      icon: Icons.public_rounded,
                      tooltip: 'Website: aivorygen.netlify.app',
                      color: const Color(0xFF00D2FF),
                      onTap: () =>
                          _openUrl(context, 'https://aivorygen.netlify.app'),
                    ),

                    // Discord Icon Button
                    _CompactSocialIconButton(
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
          const SizedBox(height: 24),

          // CHANGELOG 1.0 - 5.1
          Text(
            ref.t('changelog'),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: tokens.textSecondary,
                ),
          ),
          const SizedBox(height: 10),

          const _ChangelogSection(),
          const SizedBox(height: 24),

          // DATA MANAGEMENT
          Text(
            ref.t('dataManagement'),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: tokens.textSecondary,
                ),
          ),
          const SizedBox(height: 10),

          GlassButton(
            label: ref.t('exportHistory'),
            icon: AppIcons.download,
            expanded: true,
            onPressed: () => _exportData(context, ref),
          ),
          const SizedBox(height: 12),

          OutlinedButton.icon(
            icon: const Icon(AppIcons.trash2, color: Colors.redAccent),
            label: Text(
              ref.t('wipeData'),
              style: const TextStyle(color: Colors.redAccent),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: Colors.redAccent),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(tokens.radiusSm),
              ),
            ),
            onPressed: () => _wipeData(context, ref),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _CompactSocialIconButton extends StatelessWidget {
  const _CompactSocialIconButton({
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
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            width: 48,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: color.withValues(alpha: 0.35),
                width: 0.8,
              ),
            ),
            child: Center(
              child: Icon(icon, size: 20, color: color),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChangelogSection extends StatelessWidget {
  const _ChangelogSection();

  static const _releases = [
    (
      version: 'v5.1 (Current)',
      badge: 'Material 3 & Multilingual',
      icon: Icons.rocket_launch_rounded,
      color: Color(0xFF00E5FF),
      points: [
        '✨ Sarathi brand transformation and NoishiXzen ecosystem links',
        '🌐 9-language localization with instant app reload',
        '🎨 Modern Material 3 UI/UX with smooth transitions',
        '📱 Android curvy roundness squircle launcher icon compliance',
        '🎯 Interactive spotlight coachmark tour on first launch',
      ]
    ),
    (
      version: 'v5.0',
      badge: 'Offline LLM & Cron',
      icon: Icons.offline_bolt_rounded,
      color: Color(0xFFB388FF),
      points: [
        '⚡ Native llama.cpp GGUF on-device neural inference',
        '⏰ Autonomous background cron task scheduler',
        '🤖 Hermes persistent self-evolving memory system',
        '💬 24/7 Telegram bridge background service',
      ]
    ),
    (
      version: 'v4.0',
      badge: 'Multimodal & Studio',
      icon: Icons.palette_rounded,
      color: Color(0xFFFF4081),
      points: [
        '🖼️ Multimodal AI image generation engine',
        '📁 Device MediaStore sync to Pictures/Sarathi album',
        '🔍 Full-resolution image zoom & batch management',
        '💻 JetBrains Mono code syntax highlighter',
      ]
    ),
    (
      version: 'v3.0',
      badge: 'Agentic MCP Mesh',
      icon: Icons.hub_rounded,
      color: Color(0xFF69F0AE),
      points: [
        '🔌 Model Context Protocol (MCP) tool integration',
        '⏱️ Live execution timeline with arguments inspector',
        '🛡️ Security approval guardrails for critical actions',
      ]
    ),
    (
      version: 'v2.0',
      badge: 'Multi-Provider Mesh',
      icon: Icons.cloud_sync_rounded,
      color: Color(0xFFFFAB40),
      points: [
        '☁️ OpenAI, Claude, Gemini, Groq, Ollama streaming providers',
        '🎛️ Custom temperature, top_p & context window tuning',
        '🎭 Modular system personas (General, Coding, Research)',
      ]
    ),
    (
      version: 'v1.0',
      badge: 'Foundation',
      icon: Icons.inventory_2_rounded,
      color: Color(0xFF90CAF9),
      points: [
        '🗄️ Local Drift SQLite reactive persistence engine',
        '🔐 Hardware keystore encryption for API credentials',
        '💬 Real-time streaming chat UI with tree branching',
      ]
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final tokens = context.glass;

    return Column(
      children: _releases.map((release) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: tokens.glassColor,
            borderRadius: BorderRadius.circular(tokens.radiusSm),
            border: Border.all(color: tokens.glassBorder, width: 0.8),
          ),
          child: ExpansionTile(
            shape: const Border(),
            leading: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: release.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(release.icon, size: 17, color: release.color),
            ),
            title: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 6,
              runSpacing: 2,
              children: [
                Text(
                  release.version,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: release.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    release.badge,
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                      color: release.color,
                    ),
                  ),
                ),
              ],
            ),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: release.points
                      .map((p) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2.5),
                            child: Text(
                              p,
                              style: TextStyle(
                                fontSize: 12,
                                height: 1.35,
                                color: tokens.textSecondary,
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
