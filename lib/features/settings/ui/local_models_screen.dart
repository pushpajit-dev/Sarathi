import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sarathi/app/theme/glass_tokens.dart';
import 'package:sarathi/features/local_models/data/local_model_info.dart';
import 'package:sarathi/features/local_models/data/local_model_store.dart';
import 'package:sarathi/shared/widgets/app_icons.dart';
import 'package:sarathi/shared/widgets/glass_card.dart';

class LocalModelsScreen extends ConsumerStatefulWidget {
  const LocalModelsScreen({super.key});

  @override
  ConsumerState<LocalModelsScreen> createState() => _LocalModelsScreenState();
}

class _LocalModelsScreenState extends ConsumerState<LocalModelsScreen> {
  String? _expandedModelId;
  int _selectedFilterIndex = 0; // 0: All, 1: Chat, 2: Image, 3: Video, 4: Audio

  @override
  Widget build(BuildContext context) {
    final tokens = context.glass;
    final state = ref.watch(localModelStoreProvider);
    final notifier = ref.read(localModelStoreProvider.notifier);

    final totalRamGb = state.totalDeviceRamGb;
    final allocatedRamGb = state.totalAllocatedRamMb / 1024.0;
    final ramUsagePercent = (allocatedRamGb / totalRamGb).clamp(0.0, 1.0);

    final uncensoredModels =
        state.models.where((m) => m.isUncensored).toList();
    final standardChatModels = state.models
        .where((m) =>
            (m.type == LocalModelType.chatGguf ||
                m.type == LocalModelType.uncensoredGguf) &&
            !m.isUncensored)
        .toList();
    final imageModels = state.models
        .where((m) => m.type == LocalModelType.imageModel)
        .toList();
    final videoModels = state.models
        .where((m) => m.type == LocalModelType.videoModel)
        .toList();
    final audioModels = state.models
        .where((m) => m.type == LocalModelType.audioModel)
        .toList();

    final allChatCount = uncensoredModels.length + standardChatModels.length;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Local & Edge AI Models',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(AppIcons.plus, size: 20),
            tooltip: 'Import GGUF / Model',
            onPressed: () async {
              HapticFeedback.lightImpact();
              final imported = await notifier.importModelFromFile();
              if (imported != null && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Imported "${imported.name}" successfully!'),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // 1. Device RAM Memory Gauge
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(AppIcons.cpu, size: 18, color: tokens.accent),
                    const SizedBox(width: 8),
                    Text(
                      'DEVICE RAM ALLOCATION',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${allocatedRamGb.toStringAsFixed(2)} / ${totalRamGb.toStringAsFixed(1)} GB',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: tokens.accent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: ramUsagePercent,
                    minHeight: 8,
                    backgroundColor: tokens.glassBorder,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      ramUsagePercent > 0.85
                          ? Colors.orangeAccent
                          : tokens.accent,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.models.any((m) => m.isLoadedInRam)
                      ? '⚡ Active models run 100% on-device with zero-latency & complete privacy.'
                      : '⚪ No models currently loaded in RAM. Tap "Load into RAM" on any model below.',
                  style: TextStyle(
                    fontSize: 11,
                    color: tokens.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 2. Import Button
          OutlinedButton.icon(
            icon: Icon(AppIcons.upload, size: 16, color: tokens.accent),
            label: const Text(
              'Import .GGUF / Model from Storage',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            style: OutlinedButton.styleFrom(
              backgroundColor: tokens.glassColor,
              foregroundColor: Theme.of(context).colorScheme.onSurface,
              side: BorderSide(
                color: tokens.accent.withValues(alpha: 0.4),
                width: 0.8,
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(tokens.radiusSm),
              ),
            ),
            onPressed: () async {
              HapticFeedback.lightImpact();
              final imported = await notifier.importModelFromFile();
              if (imported != null && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Imported "${imported.name}" successfully!'),
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 14),

          // 3. Category Filter Tabs (All / Chat / Image / Video / Audio)
          Container(
            decoration: BoxDecoration(
              color: tokens.glassColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: tokens.glassBorder, width: 0.8),
            ),
            padding: const EdgeInsets.all(4),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterTab(
                    index: 0,
                    label: 'All (${state.models.length})',
                    icon: AppIcons.layers,
                    tokens: tokens,
                  ),
                  const SizedBox(width: 4),
                  _buildFilterTab(
                    index: 1,
                    label: '💬 Chat ($allChatCount)',
                    icon: AppIcons.messageSquare,
                    tokens: tokens,
                  ),
                  const SizedBox(width: 4),
                  _buildFilterTab(
                    index: 2,
                    label: '🎨 Image (${imageModels.length})',
                    icon: AppIcons.image,
                    tokens: tokens,
                  ),
                  const SizedBox(width: 4),
                  _buildFilterTab(
                    index: 3,
                    label: '🎬 Video (${videoModels.length})',
                    icon: Icons.movie_filter_rounded,
                    tokens: tokens,
                  ),
                  const SizedBox(width: 4),
                  _buildFilterTab(
                    index: 4,
                    label: '🎙️ Audio (${audioModels.length})',
                    icon: Icons.graphic_eq_rounded,
                    tokens: tokens,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // 4. 🔥 Uncensored Models Section
          if (_selectedFilterIndex == 0 || _selectedFilterIndex == 1) ...[
            _buildSectionHeader(
              title: '🔥 UNCENSORED & ABLITERATED SLMS (${uncensoredModels.length})',
              subtitle: 'Zero alignment refusals & abliterated weights for unrestricted edge tasks.',
              icon: AppIcons.zap,
              color: Colors.deepOrangeAccent,
              tokens: tokens,
            ),
            if (uncensoredModels.isEmpty)
              _buildEmptyCategoryCard(
                title: 'No Uncensored Models Found',
                subtitle: 'Download or import abliterated / heretic GGUFs for unrestricted local generation.',
                icon: AppIcons.zap,
                tokens: tokens,
              )
            else
              ...uncensoredModels.map((m) => _buildModelCard(m, tokens, state, notifier)),
            const SizedBox(height: 14),
          ],

          // 5. 💬 Standard Chat Models Section
          if (_selectedFilterIndex == 0 || _selectedFilterIndex == 1) ...[
            _buildSectionHeader(
              title: '💬 STANDARD CHAT & REASONING (${standardChatModels.length})',
              subtitle: 'GGUF LLM models for offline intelligence, text generation & agents.',
              icon: AppIcons.messageSquare,
              color: tokens.accent,
              tokens: tokens,
            ),
            if (standardChatModels.isEmpty)
              _buildEmptyCategoryCard(
                title: 'No Standard Chat Models Found',
                subtitle: 'Import .gguf files (e.g. Qwen, Llama, DeepSeek) to chat 100% offline.',
                icon: AppIcons.cpu,
                tokens: tokens,
              )
            else
              ...standardChatModels.map((m) => _buildModelCard(m, tokens, state, notifier)),
            const SizedBox(height: 14),
          ],

          // 6. 🎨 Image Models Section
          if (_selectedFilterIndex == 0 || _selectedFilterIndex == 2) ...[
            _buildSectionHeader(
              title: '🎨 IMAGE & DIFFUSION MODELS (${imageModels.length})',
              subtitle: 'Neural diffusion models for generating images & visual artwork.',
              icon: AppIcons.image,
              color: Colors.purpleAccent,
              tokens: tokens,
            ),
            if (imageModels.isEmpty)
              _buildEmptyCategoryCard(
                title: 'No Image Models Found',
                subtitle: 'Import .safetensors or diffusion checkpoints for on-device image generation.',
                icon: AppIcons.image,
                tokens: tokens,
              )
            else
              ...imageModels.map((m) => _buildModelCard(m, tokens, state, notifier)),
            const SizedBox(height: 14),
          ],

          // 7. 🎬 Video Generative Models Section
          if (_selectedFilterIndex == 0 || _selectedFilterIndex == 3) ...[
            _buildSectionHeader(
              title: '🎬 VIDEO GENERATIVE MODELS (${videoModels.length})',
              subtitle: 'On-device temporal latent video diffusion models with Android device compatibility.',
              icon: Icons.movie_filter_rounded,
              color: Colors.amberAccent,
              tokens: tokens,
            ),
            if (videoModels.isEmpty)
              _buildEmptyCategoryCard(
                title: 'No Video Models Found',
                subtitle: 'Import AnimateDiff or SVD-based video diffusion GGUF weights.',
                icon: Icons.movie_filter_rounded,
                tokens: tokens,
              )
            else
              ...videoModels.map((m) => _buildModelCard(m, tokens, state, notifier)),
            const SizedBox(height: 14),
          ],

          // 8. 🎙️ Audio Generative & Speech Models Section
          if (_selectedFilterIndex == 0 || _selectedFilterIndex == 4) ...[
            _buildSectionHeader(
              title: '🎙️ AUDIO & SPEECH MODELS (${audioModels.length})',
              subtitle: 'On-device speech-to-text, audio synthesis & voice recognition models.',
              icon: Icons.graphic_eq_rounded,
              color: Colors.tealAccent,
              tokens: tokens,
            ),
            if (audioModels.isEmpty)
              _buildEmptyCategoryCard(
                title: 'No Audio Models Found',
                subtitle: 'Import Whisper or Voice synthesis GGUF models for on-device audio.',
                icon: Icons.graphic_eq_rounded,
                tokens: tokens,
              )
            else
              ...audioModels.map((m) => _buildModelCard(m, tokens, state, notifier)),
            const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterTab({
    required int index,
    required String label,
    required IconData icon,
    required GlassTokens tokens,
  }) {
    final isSelected = _selectedFilterIndex == index;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedFilterIndex = index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? tokens.accent.withValues(alpha: 0.22)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? tokens.accent : Colors.transparent,
            width: 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: isSelected ? tokens.accent : tokens.textSecondary,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? Theme.of(context).colorScheme.onSurface
                    : tokens.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required GlassTokens tokens,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 13, color: color),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.6,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10,
                    color: tokens.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCategoryCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required GlassTokens tokens,
  }) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 24, color: tokens.textSecondary.withValues(alpha: 0.5)),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10.5,
                color: tokens.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModelCard(
    LocalModelInfo model,
    GlassTokens tokens,
    LocalModelState state,
    LocalModelStoreNotifier notifier,
  ) {
    final isExpanded = _expandedModelId == model.id;
    final isActive = state.activeModelId == model.id;
    final isDownloaded = model.isDownloaded;
    final isDownloading = state.isDownloading(model.id);
    final downloadProgress = state.getProgress(model.id);
    final downloadStatus = state.getStatus(model.id);

    final modelIcon = model.type == LocalModelType.videoModel
        ? Icons.movie_filter_rounded
        : (model.type == LocalModelType.audioModel
            ? Icons.graphic_eq_rounded
            : (model.type == LocalModelType.imageModel
                ? AppIcons.image
                : AppIcons.cpu));

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Icon, Title, Badges, Status Chip
            Row(
              children: [
                Icon(modelIcon, size: 18, color: tokens.accent),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        model.name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Wrap(
                        spacing: 4,
                        runSpacing: 2,
                        children: [
                          _buildTag(
                            model.categoryBadge,
                            tokens,
                            color: model.isUncensored ? Colors.deepOrangeAccent : null,
                            bgColor: model.isUncensored
                                ? Colors.deepOrangeAccent.withValues(alpha: 0.16)
                                : null,
                          ),
                          _buildTag(model.quantization, tokens),
                          _buildTag(model.formattedSize, tokens),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                // Status Chip with Dynamic State Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: model.isLoadedInRam
                        ? const Color(0xFF10B981).withValues(alpha: 0.18)
                        : isDownloading
                            ? tokens.accent.withValues(alpha: 0.18)
                            : isDownloaded
                                ? const Color(0xFF10B981).withValues(alpha: 0.12)
                                : tokens.glassBorder.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: model.isLoadedInRam
                          ? const Color(0xFF10B981).withValues(alpha: 0.6)
                          : isDownloading
                              ? tokens.accent.withValues(alpha: 0.6)
                              : isDownloaded
                                  ? const Color(0xFF10B981).withValues(alpha: 0.4)
                                  : tokens.glassBorder,
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: model.isLoadedInRam || isDownloaded
                              ? const Color(0xFF10B981)
                              : isDownloading
                                  ? tokens.accent
                                  : tokens.textSecondary,
                          boxShadow: model.isLoadedInRam
                              ? [
                                  const BoxShadow(
                                    color: Color(0xFF10B981),
                                    blurRadius: 6,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        model.isLoadedInRam
                            ? 'RAM Active'
                            : isDownloading
                                ? '${(downloadProgress * 100).toInt()}%'
                                : isDownloaded
                                    ? 'Downloaded'
                                    : 'Preset',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: model.isLoadedInRam
                              ? const Color(0xFF10B981)
                              : isDownloading
                                  ? tokens.accent
                                  : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Hardware & Android Device System Requirement Banner
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: tokens.glassBorder.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: tokens.glassBorder.withValues(alpha: 0.35),
                  width: 0.6,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.memory_rounded, size: 12, color: tokens.accent),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      model.hardwareRequirements,
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w500,
                        color: tokens.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            if (model.description != null && model.description!.isNotEmpty) ...[
              Text(
                model.description!,
                style: TextStyle(fontSize: 11, color: tokens.textSecondary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
            ],

            // Download Progress Bar (when downloading)
            if (isDownloading) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: downloadProgress,
                  minHeight: 5,
                  backgroundColor: tokens.glassBorder,
                  valueColor: AlwaysStoppedAnimation<Color>(tokens.accent),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    downloadStatus ?? '',
                    style: TextStyle(fontSize: 10, color: tokens.textSecondary),
                  ),
                  Text(
                    '${(downloadProgress * 100).toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: tokens.accent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],

            // Action Buttons Row & Organizer Cell Toggle
            Row(
              children: [
                if (!isDownloaded && !isDownloading && model.downloadUrl != null)
                  ElevatedButton.icon(
                    icon: const Icon(AppIcons.download, size: 13),
                    label: const Text('Download Model', style: TextStyle(fontSize: 11)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: tokens.accent,
                      foregroundColor: tokens.onAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      minimumSize: Size.zero,
                    ),
                    onPressed: () {
                      notifier.downloadModel(model);
                    },
                  )
                else if (isDownloading)
                  OutlinedButton.icon(
                    icon: const Icon(Icons.close, size: 13),
                    label: const Text('Cancel Download', style: TextStyle(fontSize: 11)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      minimumSize: Size.zero,
                    ),
                    onPressed: () {
                      notifier.cancelDownload(model.id);
                    },
                  )
                else ...[
                  ElevatedButton.icon(
                    icon: Icon(
                      model.isLoadedInRam ? Icons.check_circle : Icons.play_arrow_rounded,
                      size: 14,
                    ),
                    label: Text(
                      model.isLoadedInRam
                          ? (isActive ? 'Active in RAM' : 'Select Model')
                          : 'Load into RAM',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: model.isLoadedInRam
                          ? (isActive ? tokens.accent : const Color(0xFF10B981))
                          : tokens.glassBorder.withValues(alpha: 0.6),
                      foregroundColor: model.isLoadedInRam ? Colors.white : Theme.of(context).colorScheme.onSurface,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      minimumSize: Size.zero,
                    ),
                    onPressed: () {
                      if (model.isLoadedInRam) {
                        if (!isActive) {
                          notifier.setActiveModel(model.id);
                        }
                      } else {
                        notifier.loadModelIntoRam(model.id);
                      }
                    },
                  ),
                  if (model.isLoadedInRam) ...[
                    const SizedBox(width: 6),
                    IconButton(
                      icon: const Icon(Icons.eject_rounded, size: 16),
                      tooltip: 'Unload from RAM',
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        notifier.unloadModelFromRam(model.id);
                      },
                    ),
                  ],
                ],

                const Spacer(),

                // Dropdown Organizer Cell Toggle
                InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _expandedModelId = isExpanded ? null : model.id;
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: tokens.glassBorder.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: tokens.glassBorder.withValues(alpha: 0.4), width: 0.6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isExpanded ? 'Hide Specs' : 'Specs & Tuning',
                          style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: tokens.textSecondary),
                        ),
                        const SizedBox(width: 3),
                        Icon(
                          isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                          size: 16,
                          color: tokens.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Dropdown Organizer Cell (Tuning, Parameters & System Details)
            if (isExpanded) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: tokens.glassColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: tokens.glassBorder.withValues(alpha: 0.5), width: 0.8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(AppIcons.sliders, size: 13, color: tokens.accent),
                        const SizedBox(width: 6),
                        const Text(
                          'Model Organizer & Configuration',
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Model Type Toggle
                    Row(
                      children: [
                        Text('Role / Kind:', style: TextStyle(fontSize: 11, color: tokens.textSecondary)),
                        const Spacer(),
                        DropdownButton<LocalModelType>(
                          value: model.type,
                          isDense: true,
                          dropdownColor: Theme.of(context).colorScheme.surface,
                          underline: const SizedBox.shrink(),
                          items: const [
                            DropdownMenuItem(value: LocalModelType.chatGguf, child: Text('💬 Chat LLM', style: TextStyle(fontSize: 11))),
                            DropdownMenuItem(value: LocalModelType.uncensoredGguf, child: Text('🔥 Uncensored', style: TextStyle(fontSize: 11))),
                            DropdownMenuItem(value: LocalModelType.imageModel, child: Text('🎨 Image Diffusion', style: TextStyle(fontSize: 11))),
                            DropdownMenuItem(value: LocalModelType.videoModel, child: Text('🎬 Video Diffusion', style: TextStyle(fontSize: 11))),
                            DropdownMenuItem(value: LocalModelType.audioModel, child: Text('🎙️ Audio & Speech', style: TextStyle(fontSize: 11))),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              notifier.setModelType(model.id, val);
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Chat Specific Settings
                    if (model.type == LocalModelType.chatGguf || model.type == LocalModelType.uncensoredGguf) ...[
                      Row(
                        children: [
                          Text('Context: ${model.contextSize} tokens', style: TextStyle(fontSize: 11, color: tokens.textSecondary)),
                          const Spacer(),
                          DropdownButton<int>(
                            value: model.contextSize,
                            isDense: true,
                            dropdownColor: Theme.of(context).colorScheme.surface,
                            underline: const SizedBox.shrink(),
                            items: const [
                              DropdownMenuItem(value: 1024, child: Text('1K')),
                              DropdownMenuItem(value: 2048, child: Text('2K')),
                              DropdownMenuItem(value: 4096, child: Text('4K')),
                              DropdownMenuItem(value: 8192, child: Text('8K')),
                            ],
                            onChanged: (val) {
                              if (val != null) notifier.updateModelConfig(model.id, contextSize: val);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text('Threads: ${model.threads}', style: TextStyle(fontSize: 11, color: tokens.textSecondary)),
                          const Spacer(),
                          DropdownButton<int>(
                            value: model.threads,
                            isDense: true,
                            dropdownColor: Theme.of(context).colorScheme.surface,
                            underline: const SizedBox.shrink(),
                            items: const [
                              DropdownMenuItem(value: 2, child: Text('2 Cores')),
                              DropdownMenuItem(value: 4, child: Text('4 Cores')),
                              DropdownMenuItem(value: 6, child: Text('6 Cores')),
                              DropdownMenuItem(value: 8, child: Text('8 Cores')),
                            ],
                            onChanged: (val) {
                              if (val != null) notifier.updateModelConfig(model.id, threads: val);
                            },
                          ),
                        ],
                      ),
                    ],

                    // Image / Video Specific Settings
                    if (model.type == LocalModelType.imageModel || model.type == LocalModelType.videoModel) ...[
                      Row(
                        children: [
                          Text('Sampling Steps: ${model.steps}', style: TextStyle(fontSize: 11, color: tokens.textSecondary)),
                          const Spacer(),
                          DropdownButton<int>(
                            value: model.steps,
                            isDense: true,
                            dropdownColor: Theme.of(context).colorScheme.surface,
                            underline: const SizedBox.shrink(),
                            items: const [
                              DropdownMenuItem(value: 10, child: Text('10 (Fast)')),
                              DropdownMenuItem(value: 20, child: Text('20 (Balanced)')),
                              DropdownMenuItem(value: 30, child: Text('30 (High)')),
                              DropdownMenuItem(value: 50, child: Text('50 (Ultra)')),
                            ],
                            onChanged: (val) {
                              if (val != null) notifier.updateImageParams(model.id, steps: val);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text('Aspect Ratio:', style: TextStyle(fontSize: 11, color: tokens.textSecondary)),
                          const Spacer(),
                          DropdownButton<String>(
                            value: model.aspectRatio,
                            isDense: true,
                            dropdownColor: Theme.of(context).colorScheme.surface,
                            underline: const SizedBox.shrink(),
                            items: const [
                              DropdownMenuItem(value: '1:1', child: Text('1:1 Square')),
                              DropdownMenuItem(value: '16:9', child: Text('16:9 Landscape')),
                              DropdownMenuItem(value: '9:16', child: Text('9:16 Portrait')),
                            ],
                            onChanged: (val) {
                              if (val != null) notifier.updateImageParams(model.id, aspectRatio: val);
                            },
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text('Hardware Requirement:', style: TextStyle(fontSize: 10.5, color: tokens.textSecondary)),
                        const Spacer(),
                        Text(
                          model.type == LocalModelType.videoModel
                              ? '8GB RAM · Vulkan'
                              : (model.type == LocalModelType.audioModel
                                  ? '4GB RAM · Any'
                                  : '4GB RAM · CPU/GPU'),
                          style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: tokens.accent),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),
                    // Remove Model Button
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        icon: const Icon(AppIcons.trash, size: 13, color: Colors.redAccent),
                        label: const Text('Remove Model', style: TextStyle(fontSize: 11, color: Colors.redAccent)),
                        onPressed: () {
                          notifier.deleteModel(model.id);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTag(
    String text,
    GlassTokens tokens, {
    Color? color,
    Color? bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
      decoration: BoxDecoration(
        color: bgColor ?? tokens.glassBorder.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w600,
          color: color ?? tokens.textSecondary,
        ),
      ),
    );
  }
}
