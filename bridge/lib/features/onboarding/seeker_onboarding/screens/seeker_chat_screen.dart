import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/services/ai_chat_service.dart';
import '../../../../shared/services/firebase_service.dart';
import '../../../../shared/widgets/ai_chat_bubble.dart';

class SeekerChatScreen extends ConsumerStatefulWidget {
  const SeekerChatScreen({super.key});

  @override
  ConsumerState<SeekerChatScreen> createState() => _SeekerChatScreenState();
}

class _SeekerChatScreenState extends ConsumerState<SeekerChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<Map<String, String>> _history = [];
  bool _loading = false;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _sendAi();
  }

  Future<void> _sendAi() async {
    setState(() => _loading = true);
    final reply = await AiChatService.instance.seekerChat(_history);
    _history.add({'role': 'assistant', 'content': reply});
    setState(() => _loading = false);
    _scrollToBottom();

    // After 4 AI turns, profile is ready
    if (_history.where((m) => m['role'] == 'assistant').length >= 4) {
      setState(() => _done = true);
    }
  }

  Future<void> _sendUser() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _loading) return;
    _controller.clear();
    _history.add({'role': 'user', 'content': text});
    setState(() {});
    _scrollToBottom();
    await _sendAi();
  }

  Future<void> _proceed() async {
    final ventText = _history
        .where((m) => m['role'] == 'user')
        .map((m) => m['content']!)
        .join(' ');
    // Extract profile in background — result stored server-side via FastAPI
    await AiChatService.instance.extractSeekerProfile(ventText);
    final uid = await FirebaseService.instance.getCurrentUserId() ?? '';
    await FirebaseService.instance.createVent(seekerId: uid, audioUrl: '');
    if (!mounted) return;
    context.go('/seeker/vent');
  }

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

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.warmBrown.withValues(alpha: 0.15),
              child: const Icon(Icons.hub_rounded, size: 16, color: AppColors.warmBrown),
            ),
            const SizedBox(width: 10),
            Text('Bridge', style: AppTypography.heading2Sans.copyWith(
              color: AppColors.warmBrown,
            )),
          ],
        ),
      ),
      body: Responsive.centeredCard(
        context,
        Column(
          children: [
            Expanded(
              child: ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                itemCount: _history.length + (_loading ? 1 : 0),
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, i) {
                  if (i == _history.length) {
                    // Typing indicator
                    return AiChatBubble(
                      text: '...',
                      role: BubbleRole.ai,
                      animate: false,
                    );
                  }
                  final msg = _history[i];
                  return AiChatBubble(
                    text: msg['content']!,
                    role: msg['role'] == 'assistant' ? BubbleRole.ai : BubbleRole.user,
                  );
                },
              ),
            ),

            if (_done)
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 64,
                  child: ElevatedButton(
                    onPressed: _proceed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.amber,
                      foregroundColor: AppColors.cream,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: Text("Let's find your person",
                        style: AppTypography.heading2Sans.copyWith(color: AppColors.cream)),
                  ),
                ),
              )
            else
              _InputBar(controller: _controller, onSend: _sendUser, loading: _loading),
          ],
        ),
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool loading;

  const _InputBar({
    required this.controller,
    required this.onSend,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      decoration: BoxDecoration(
        color: AppColors.cream,
        boxShadow: [
          BoxShadow(
            color: AppColors.warmBrown.withValues(alpha: 0.08),
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
              style: AppTypography.bodySerif.copyWith(fontSize: 18),
              decoration: InputDecoration(
                hintText: 'Type here...',
                hintStyle: AppTypography.bodySerif.copyWith(
                  color: AppColors.warmBrown.withValues(alpha: 0.4),
                  fontSize: 18,
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
            onTap: loading ? null : onSend,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: loading ? AppColors.amber.withValues(alpha: 0.4) : AppColors.amber,
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
