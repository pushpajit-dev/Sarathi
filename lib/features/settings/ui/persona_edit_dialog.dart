import 'package:sarathi/core/localization/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sarathi/core/db/app_database.dart' show Persona;
import 'package:sarathi/shared/widgets/app_icons.dart';
import 'package:sarathi/features/conversations/application/conversations_controller.dart';

class PersonaEditDialog extends ConsumerStatefulWidget {
  const PersonaEditDialog({super.key, this.persona});

  final Persona? persona;

  static Future<void> show(BuildContext context, {Persona? persona}) {
    return showDialog(
      context: context,
      builder: (_) => PersonaEditDialog(persona: persona),
    );
  }

  @override
  ConsumerState<PersonaEditDialog> createState() => _PersonaEditDialogState();
}

class _PersonaEditDialogState extends ConsumerState<PersonaEditDialog> {
  final _nameController = TextEditingController();
  final _iconController = TextEditingController();
  final _promptController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.persona != null) {
      _nameController.text = widget.persona!.name;
      _iconController.text = widget.persona!.icon;
      _promptController.text = widget.persona!.systemPrompt;
    } else {
      _iconController.text = '🤖';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _iconController.dispose();
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final prompt = _promptController.text.trim();
    if (name.isEmpty || prompt.isEmpty) return;

    await ref.read(personaActionsProvider).save(
          id: widget.persona?.id,
          name: name,
          systemPrompt: prompt,
          icon: _iconController.text.trim().isEmpty
              ? '🤖'
              : _iconController.text.trim(),
        );

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.persona == null ? ref.t('newPersona') : ref.t('editPersona')),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 50,
                  child: TextField(
                    controller: _iconController,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13.5),
                    decoration: const InputDecoration(
                      labelText: 'Icon',
                      border: OutlineInputBorder(),
                      hintStyle: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    style: const TextStyle(fontSize: 13.5),
                    decoration: InputDecoration(
                      labelText: ref.t('personaName'),
                      hintText: 'e.g. Python Expert',
                      border: const OutlineInputBorder(),
                      hintStyle: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _promptController,
              minLines: 3,
              maxLines: 6,
              style: const TextStyle(fontSize: 13.5),
              decoration: InputDecoration(
                labelText: ref.t('systemPrompt'),
                hintText: 'You are an expert engineer...',
                border: const OutlineInputBorder(),
                hintStyle: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(ref.t('cancel')),
        ),
        FilledButton.icon(
          icon: const Icon(AppIcons.save, size: 16),
          label: Text(ref.t('save')),
          onPressed: _save,
        ),
      ],
    );
  }
}
