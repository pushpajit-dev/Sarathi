import '../../../core/db/app_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../conversations/application/conversations_controller.dart';
import 'chat_screen.dart';

/// Root screen: manages conversation sync + chat surface.
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key, this.conversationId});

  final String? conversationId;

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  @override
  void initState() {
    super.initState();
    _syncConversation();
  }

  @override
  void didUpdateWidget(HomeShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.conversationId != widget.conversationId) {
      _syncConversation();
    }
  }

  void _syncConversation() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      if (widget.conversationId != null) {
        ref.read(currentConversationIdProvider.notifier).state =
            widget.conversationId;
      } else {
        final currentId = ref.read(currentConversationIdProvider);
        if (currentId == null) {
          final all = await ref.read(appDatabaseProvider).conversationsDao.getAll();
          if (all.isNotEmpty && mounted) {
            ref.read(currentConversationIdProvider.notifier).state = all.first.id;
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Return ChatScreen directly to prevent nested Scaffolds and bottom margin inset conflicts.
    return const ChatScreen();
  }
}
