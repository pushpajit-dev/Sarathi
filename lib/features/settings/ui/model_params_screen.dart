import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sarathi/app/theme/glass_tokens.dart';
import 'package:sarathi/core/storage/prefs_provider.dart';
import 'package:sarathi/shared/widgets/app_icons.dart';
import 'package:sarathi/shared/widgets/glass_button.dart';

/// Settings screen for model generation parameters.
/// Organizes technical details inside clean collapsible dropdown organizer cells.
class ModelParamsScreen extends ConsumerStatefulWidget {
  const ModelParamsScreen({super.key});

  @override
  ConsumerState<ModelParamsScreen> createState() => _ModelParamsScreenState();
}

class _ModelParamsScreenState extends ConsumerState<ModelParamsScreen> {
  double _temperature = 0.7;
  double _topP = 1.0;
  int _maxTokens = 4096;
  double _freqPenalty = 0.0;
  double _presencePenalty = 0.0;
  final _systemPromptController = TextEditingController();

  // Collapsible Organizer Cell states
  bool _samplingExpanded = true;
  bool _tokenLimitExpanded = false;
  bool _penaltiesExpanded = false;
  bool _systemPromptExpanded = false;

  @override
  void initState() {
    super.initState();
    final prefs = ref.read(sharedPreferencesProvider);
    _temperature = prefs.getDouble('gen_temperature') ?? 0.7;
    _topP = prefs.getDouble('gen_top_p') ?? 1.0;
    _maxTokens = prefs.getInt('gen_max_tokens') ?? 4096;
    _freqPenalty = prefs.getDouble('gen_freq_penalty') ?? 0.0;
    _presencePenalty = prefs.getDouble('gen_presence_penalty') ?? 0.0;
    _systemPromptController.text = prefs.getString('gen_system_prompt') ?? '';
  }

  @override
  void dispose() {
    _systemPromptController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    HapticFeedback.mediumImpact();
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setDouble('gen_temperature', _temperature);
    await prefs.setDouble('gen_top_p', _topP);
    await prefs.setInt('gen_max_tokens', _maxTokens);
    await prefs.setDouble('gen_freq_penalty', _freqPenalty);
    await prefs.setDouble('gen_presence_penalty', _presencePenalty);
    await prefs.setString('gen_system_prompt', _systemPromptController.text.trim());

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Model configuration saved successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.glass;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Model Tuning & Parameters',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Cell 1: Creativity & Sampling
          _buildOrganizerCell(
            title: 'Creativity & Sampling',
            summary: 'Temp: ${_temperature.toStringAsFixed(2)} · Top-P: ${_topP.toStringAsFixed(2)}',
            icon: AppIcons.sparkles,
            isExpanded: _samplingExpanded,
            onToggle: () => setState(() => _samplingExpanded = !_samplingExpanded),
            tokens: tokens,
            child: Column(
              children: [
                _SliderTile(
                  title: 'Temperature (${_temperature.toStringAsFixed(2)})',
                  subtitle: 'Controls randomness. Lower = precise logic, Higher = creative writing.',
                  value: _temperature,
                  min: 0.0,
                  max: 2.0,
                  divisions: 40,
                  onChanged: (v) => setState(() => _temperature = v),
                ),
                _SliderTile(
                  title: 'Top P Nucleus (${_topP.toStringAsFixed(2)})',
                  subtitle: 'Cumulative probability sampling threshold.',
                  value: _topP,
                  min: 0.0,
                  max: 1.0,
                  divisions: 20,
                  onChanged: (v) => setState(() => _topP = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Cell 2: Token Limits
          _buildOrganizerCell(
            title: 'Output Length & Tokens',
            summary: 'Max Limit: $_maxTokens tokens',
            icon: AppIcons.layers,
            isExpanded: _tokenLimitExpanded,
            onToggle: () => setState(() => _tokenLimitExpanded = !_tokenLimitExpanded),
            tokens: tokens,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildTokenPresetPill('2K', 2048, tokens),
                    const SizedBox(width: 8),
                    _buildTokenPresetPill('4K (Default)', 4096, tokens),
                    const SizedBox(width: 8),
                    _buildTokenPresetPill('8K', 8192, tokens),
                    const SizedBox(width: 8),
                    _buildTokenPresetPill('16K', 16384, tokens),
                  ],
                ),
                const SizedBox(height: 10),
                _SliderTile(
                  title: 'Max Output Tokens ($_maxTokens)',
                  subtitle: 'Maximum number of tokens to generate per turn.',
                  value: _maxTokens.toDouble(),
                  min: 512,
                  max: 16384,
                  divisions: 31,
                  onChanged: (v) => setState(() => _maxTokens = v.toInt()),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Cell 3: Penalties
          _buildOrganizerCell(
            title: 'Repetition & Topic Penalties',
            summary: 'Freq: ${_freqPenalty.toStringAsFixed(2)} · Presence: ${_presencePenalty.toStringAsFixed(2)}',
            icon: AppIcons.sliders,
            isExpanded: _penaltiesExpanded,
            onToggle: () => setState(() => _penaltiesExpanded = !_penaltiesExpanded),
            tokens: tokens,
            child: Column(
              children: [
                _SliderTile(
                  title: 'Frequency Penalty (${_freqPenalty.toStringAsFixed(2)})',
                  subtitle: 'Decreases likelihood of repeating verbatim phrases.',
                  value: _freqPenalty,
                  min: -2.0,
                  max: 2.0,
                  divisions: 40,
                  onChanged: (v) => setState(() => _freqPenalty = v),
                ),
                _SliderTile(
                  title: 'Presence Penalty (${_presencePenalty.toStringAsFixed(2)})',
                  subtitle: 'Encourages the model to introduce new topics.',
                  value: _presencePenalty,
                  min: -2.0,
                  max: 2.0,
                  divisions: 40,
                  onChanged: (v) => setState(() => _presencePenalty = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Cell 4: System Prompt Override
          _buildOrganizerCell(
            title: 'Global System Instructions',
            summary: _systemPromptController.text.trim().isNotEmpty
                ? 'Active (${_systemPromptController.text.trim().length} chars)'
                : 'Default (none)',
            icon: AppIcons.bot,
            isExpanded: _systemPromptExpanded,
            onToggle: () => setState(() => _systemPromptExpanded = !_systemPromptExpanded),
            tokens: tokens,
            child: TextField(
              controller: _systemPromptController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Global System Prompt (optional)',
                hintText: 'Custom instructions prepended to all conversation turns...',
                filled: true,
                fillColor: tokens.glassColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(tokens.radiusSm),
                  borderSide: BorderSide(color: tokens.glassBorder),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(height: 20),

          GlassButton(
            label: 'Save Configuration',
            expanded: true,
            onPressed: _save,
          ),
        ],
      ),
    );
  }

  Widget _buildOrganizerCell({
    required String title,
    required String summary,
    required IconData icon,
    required bool isExpanded,
    required VoidCallback onToggle,
    required GlassTokens tokens,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: tokens.glassColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tokens.glassBorder.withValues(alpha: 0.6), width: 0.8),
        boxShadow: tokens.softShadow,
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              onToggle();
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: tokens.accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 16, color: tokens.accent),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          summary,
                          style: TextStyle(fontSize: 11, color: tokens.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                    color: tokens.textSecondary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(14),
              child: child,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTokenPresetPill(String label, int tokensVal, GlassTokens tokens) {
    final isSelected = _maxTokens == tokensVal;
    return Expanded(
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _maxTokens = tokensVal);
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? tokens.accent.withValues(alpha: 0.25) : tokens.glassBorder.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? tokens.accent : Colors.transparent,
              width: 0.8,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? tokens.accent : tokens.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _SliderTile extends StatelessWidget {
  const _SliderTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = context.glass;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: tokens.glassBorder.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(fontSize: 10.5, color: tokens.textSecondary),
          ),
          Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            activeColor: tokens.accent,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
