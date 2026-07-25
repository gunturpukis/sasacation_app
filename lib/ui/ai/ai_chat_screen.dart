import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sasacation/core/apptheme.dart';
import 'package:sasacation/data/model/ai_model.dart';
import 'package:sasacation/ui/ai/agent_trip_plan_result_screen.dart';
import 'package:sasacation/viewmodel/ai/ai_bloc.dart';
 
/// AiChatScreen — restyle mengikuti mockup `sasa_ai_chatbot`.
///
/// PERUBAHAN WARNA PENTING (bukan sekadar reskin token):
/// SEBELUM: bubble USER = teal (primaryColor), bubble ASSISTANT = abu-abu.
/// SEKARANG (sesuai mockup): bubble ASSISTANT = teal (brand-forward),
/// bubble USER = abu-abu netral. Ini pola yang disengaja di mockup —
/// jawaban Sasa yang ditonjolkan warnanya, bukan pesan user.
///
/// CATATAN: tombol "+" (attach) di sebelah kiri input bar pada mockup
/// SENGAJA tidak saya tambahkan — tidak ada fitur attach/upload apa pun di
/// balik AiRepository saat ini, menambah tombol itu cuma akan jadi UI mati.
 
class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});
 
  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}
 
class _AiChatScreenState extends State<AiChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
 
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
 
  void _sendMessage(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    _controller.clear();
    context.read<AiBloc>().add(AiChatMessageSent(content: trimmed));
    _scrollToBottom();
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppTheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy_outlined, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Sasa AI', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('TRAVEL ASSISTANT',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.primary)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset chat',
            onPressed: () => context.read<AiBloc>().add(AiChatCleared()),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<AiBloc, AiState>(
              listener: (context, state) {
                if (state is AiChatState) _scrollToBottom();
              },
              builder: (context, state) {
                if (state is AiInitial) {
                  return _buildWelcome(context);
                }
                if (state is AiChatState) {
                  final itemCount = state.messages.length +
                      (state.isLoading ? 1 : 0) +
                      (state.error != null ? 1 : 0);
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: itemCount,
                    itemBuilder: (context, index) {
                      if (index == state.messages.length && state.isLoading) {
                        return const _TypingIndicator();
                      }
                      if (state.error != null &&
                          index == state.messages.length + (state.isLoading ? 1 : 0)) {
                        return _ErrorBubble(
                          message: state.error!,
                          onRetry: () {
                            final lastUser = state.messages.lastWhere(
                              (m) => m.isUser,
                              orElse: () => ChatMessage.user(''),
                            );
                            if (lastUser.content.isNotEmpty) {
                              context.read<AiBloc>().add(AiChatMessageSent(content: lastUser.content));
                            }
                          },
                        );
                      }
                      final msg = state.messages[index];
                      return _ChatBubble(
                        content: msg.content,
                        isUser: msg.isUser,
                        tripPlan: msg.tripPlan,
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }
 
  Widget _buildWelcome(BuildContext context) {
    final suggestions = [
      '🏖️ Rekomendasikan pantai terbaik di Lombok',
      '🏨 Hotel dengan kolam renang di bawah \$200',
      '🍢 Kuliner khas Lombok yang wajib dicoba',
      '🏔️ Cara mendaki Gunung Rinjani',
    ];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.smart_toy_outlined, size: 40, color: AppTheme.primary),
          ),
          const SizedBox(height: 16),
          Text('Halo! Saya Sasa 👋', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'AI travel assistant kamu untuk menjelajahi Lombok. Tanya apa saja!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ...suggestions.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  onTap: () => _sendMessage(s.substring(2)),
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                      color: AppTheme.surfaceContainerLow,
                    ),
                    child: Text(s, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.onSurface)),
                  ),
                ),
              )),
        ],
      ),
    );
  }
 
  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).viewInsets.bottom + 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        border: Border(top: BorderSide(color: AppTheme.outlineVariant.withOpacity(0.3))),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: _sendMessage,
              decoration: InputDecoration(
                hintText: 'Ask Sasa anything...',
                filled: true,
                fillColor: AppTheme.surfaceContainerLow,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          BlocBuilder<AiBloc, AiState>(
            builder: (context, state) {
              final isLoading = state is AiChatState && state.isLoading;
              return CircleAvatar(
                backgroundColor: AppTheme.secondaryContainer,
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : IconButton(
                        icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                        onPressed: () => _sendMessage(_controller.text),
                      ),
              );
            },
          ),
        ],
      ),
    );
  }
 
  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
 
class _ChatBubble extends StatelessWidget {
  final String content;
  final bool isUser;
  final TripPlan? tripPlan;
  const _ChatBubble({required this.content, required this.isUser, this.tripPlan});
 
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              // SEBELUM: isUser -> teal, !isUser -> abu-abu.
              // SEKARANG (sesuai mockup): dibalik — balasan Sasa yang teal.
              color: isUser ? AppTheme.surfaceContainerLow : AppTheme.primaryContainer,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(isUser ? 18 : 4),
                bottomRight: Radius.circular(isUser ? 4 : 18),
              ),
            ),
            child: Text(
              content,
              style: TextStyle(
                color: isUser ? AppTheme.onSurface : Colors.white,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ),
        // Kartu ini HANYA muncul kalau backend mendeteksi intent trip-planning
        // dan menjalankan Agent Workflow untuk balasan ini (lihat
        // ChatMessage.tripPlan di ai_model.dart). Balasan chat biasa tidak
        // akan pernah menampilkan kartu ini.
        if (tripPlan != null) _TripPlanCard(plan: tripPlan!),
      ],
    );
  }
}
 
class _TripPlanCard extends StatelessWidget {
  final TripPlan plan;
  const _TripPlanCard({required this.plan});
 
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AgentTripPlanResultScreen(plan: plan)),
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(color: AppTheme.primary.withOpacity(0.25)),
            boxShadow: AppTheme.softCardShadow,
          ),
          child: Row(
            children: [
              Icon(Icons.map_outlined, color: AppTheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(plan.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text('${plan.days.length} hari • \$${plan.totalEstimatedCost.toStringAsFixed(0)}',
                        style: TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppTheme.outline),
            ],
          ),
        ),
      ),
    );
  }
}
 
class _ErrorBubble extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorBubble({required this.message, required this.onRetry});
 
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.errorContainer,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 18, color: AppTheme.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message, style: const TextStyle(color: AppTheme.onErrorContainer, fontSize: 13)),
          ),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 0)),
            child: const Text('Coba Lagi', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
 
class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();
 
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.primaryContainer,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomRight: Radius.circular(18),
            bottomLeft: Radius.circular(4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            const SizedBox(width: 8),
            const Text('Sasa sedang mengetik...', style: TextStyle(color: Colors.white, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
 