import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sarathi/app/theme/glass_tokens.dart';
import 'package:sarathi/core/storage/prefs_provider.dart';
import 'package:sarathi/shared/widgets/app_icons.dart';
import 'package:sarathi/shared/widgets/glass_button.dart';

/// Clean, concise small-points guide dialog (no confusing multi-step overlays).
class TutorialOverlay extends ConsumerWidget {
  const TutorialOverlay({super.key, required this.onFinish});

  final VoidCallback onFinish;

  static void show(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => TutorialOverlay(
        onFinish: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.glass;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(tokens.radiusLg),
          border: Border.all(color: tokens.glassBorder, width: 0.8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(18),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: tokens.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: tokens.accent.withValues(alpha: 0.35),
                      width: 0.8,
                    ),
                  ),
                  child: Icon(AppIcons.sparkles, color: tokens.accent, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick Guide',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Essential pointers to get the most out of Sarathi',
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
            const SizedBox(height: 18),
            const Divider(height: 1),
            const SizedBox(height: 14),

            // Small Points List
            _GuidePoint(
              icon: Icons.alt_route_rounded,
              title: '3 Operating Modes',
              description:
                  'Switch between Chat (regular LLM), Autonomous Agent (runs tools), and Local (100% offline on-device GGUF) via the top bar.',
              color: tokens.accent,
            ),
            const SizedBox(height: 12),
            _GuidePoint(
              icon: Icons.cloud_done_rounded,
              title: 'Universal AI Mesh & Direct Sign-In',
              description:
                  'Connect Google Gemini, Claude, ChatGPT, Groq or Ollama. Use one-tap web links in Settings to register and get keys.',
              color: const Color(0xFF00D2FF),
            ),
            const SizedBox(height: 12),
            _GuidePoint(
              icon: Icons.auto_awesome_motion_rounded,
              title: 'Multimodal Vision, Audio & Docs',
              description:
                  'Attach images, audio recordings, or PDFs. Supportive models automatically inspect and analyze your files.',
              color: const Color(0xFFFFAB40),
            ),
            const SizedBox(height: 12),
            _GuidePoint(
              icon: Icons.build_circle_outlined,
              title: 'Tools, MCP & Scheduled Tasks',
              description:
                  'The Agent can execute web searches, math calculations, local files, and automated background reminders.',
              color: const Color(0xFF69F0AE),
            ),

            const SizedBox(height: 20),

            // Dismiss Button
            GlassButton(
              label: 'Got it',
              icon: Icons.check_circle_outline_rounded,
              expanded: true,
              onPressed: () {
                HapticFeedback.lightImpact();
                ref.read(sharedPreferencesProvider).setBool('tutorial_seen', true);
                onFinish();
              },
            ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GuidePoint extends StatelessWidget {
  const _GuidePoint({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tokens = context.glass;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  fontSize: 11.5,
                  height: 1.35,
                  color: tokens.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
