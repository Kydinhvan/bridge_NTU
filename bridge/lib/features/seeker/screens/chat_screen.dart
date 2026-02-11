import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/conversation_modes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/responsive.dart';
import '../../../models/chat_message.dart';
import '../../../shared/services/firebase_service.dart';

final _messagesProvider = StateProvider<List<ChatMessage>>((ref) => []);
final _modeProvider = StateProvider<ConversationMode>((ref) => ConversationMode.vent);

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _matchId = const Uuid().v4();
  // Mock: current user is seeker
  final _userId = 'seeker_001';

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();

    final mode = ref.read(_modeProvider);
    final msg = ChatMessage(
      id: const Uuid().v4(),
      senderId: _userId,
      text: text,
      mode: mode.name,
      isAiScaffold: false,
      createdAt: DateTime.now(),
    );

    ref.read(_messagesProvider.notifier).update((msgs) => [...msgs, msg]);
    await FirebaseService.instance.sendMessage(_matchId, msg);
    _scrollToBottom();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(_messagesProvider);
    final mode = ref.watch(_modeProvider);

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.warmBrown),
          onPressed: () => context.go('/seeker/home'),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your helper', style: AppTypography.heading2Sans),
            Text('Anonymous · ${mode.label} mode',
                style: AppTypography.captionSans.copyWith(color: AppColors.warmBrown)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded, color: AppColors.amber),
            onPressed: () => context.go('/seeker/impact'),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: _ModeSelector(
            selected: mode,
            onSelect: (m) => ref.read(_modeProvider.notifier).state = m,
          ),
        ),
      ),
      body: Responsive.centeredCard(
        context,
        Column(
          children: [
            Expanded(
              child: messages.isEmpty
                  ? _EmptyState(mode: mode)
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      itemCount: messages.length,
                      itemBuilder: (_, i) => _MessageBubble(
                        message: messages[i],
                        isMe: messages[i].senderId == _userId,
                      ),
                    ),
            ),
            _InputBar(controller: _controller, onSend: _send),
          ],
        ),
      ),
    );
  }
}

class _ModeSelector extends StatelessWidget {
  final ConversationMode selected;
  final void Function(ConversationMode) onSelect;
  const _ModeSelector({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: ConversationMode.values.map((mode) {
          final isSelected = mode == selected;
          return GestureDetector(
            onTap: () => onSelect(mode),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.amber : AppColors.amber.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(mode.label, style: AppTypography.labelSans.copyWith(
                color: isSelected ? AppColors.cream : AppColors.amber,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              )),
            ),
          );
        }).toList(),
      ),
    );
  }
}

IconData _modeIcon(ConversationMode mode) {
  switch (mode) {
    case ConversationMode.vent:    return Icons.water_drop_rounded;
    case ConversationMode.reflect: return Icons.wb_twilight_rounded;
    case ConversationMode.clarity: return Icons.explore_rounded;
    case ConversationMode.growth:  return Icons.spa_rounded;
  }
}

class _EmptyState extends StatelessWidget {
  final ConversationMode mode;
  const _EmptyState({required this.mode});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_modeIcon(mode), size: 48, color: AppColors.amber.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(mode.description,
                style: AppTypography.bodySerif.copyWith(fontSize: 18),
                textAlign: TextAlign.center),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  const _MessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Align(
            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: constraints.maxWidth * 0.75,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: isMe ? AppColors.amber : Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: Radius.circular(isMe ? 20 : 4),
                    bottomRight: Radius.circular(isMe ? 4 : 20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.warmBrown.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  message.text,
                  style: AppTypography.bodySerif.copyWith(
                    fontSize: 17,
                    color: isMe ? AppColors.cream : AppColors.charcoal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  const _InputBar({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      decoration: BoxDecoration(
        color: AppColors.cream,
        boxShadow: [
          BoxShadow(
            color: AppColors.warmBrown.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              minLines: 1,
              maxLines: 4,
              style: AppTypography.bodySans.copyWith(fontSize: 17),
              decoration: InputDecoration(
                hintText: 'Say something...',
                hintStyle: AppTypography.bodySans.copyWith(
                  color: AppColors.warmBrown.withValues(alpha: 0.35),
                ),
                filled: true,
                fillColor: AppColors.warmBrown.withValues(alpha: 0.06),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              ),
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onSend,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.amber,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.arrow_upward_rounded, color: AppColors.cream),
            ),
          ),
        ],
      ),
    );
  }
}
