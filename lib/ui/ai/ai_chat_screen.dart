import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sasacation/core/apptheme.dart';
import 'package:sasacation/data/model/ai_model.dart';
import 'package:sasacation/viewmodel/ai/ai_bloc.dart';

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
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sasa', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('AI Travel Assistant', style: TextStyle(fontSize: 11, color: Colors.grey)),
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
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.auto_awesome, size: 40, color: AppTheme.primaryColor),
          ),
          const SizedBox(height: 16),
          const Text('Halo! Saya Sasa 👋',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            'AI travel assistant kamu untuk menjelajahi Lombok. Tanya apa saja!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          ...suggestions.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  onTap: () => _sendMessage(s.substring(2)),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(12),
                      color: AppTheme.primaryColor.withOpacity(0.04),
                    ),
                    child: Text(s, style: const TextStyle(fontSize: 14)),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.of(context).viewInsets.bottom + 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
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
                hintText: 'Tanya tentang wisata Lombok...',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          BlocBuilder<AiBloc, AiState>(
            builder: (context, state) {
              final isLoading = state is AiChatState && state.isLoading;
              return CircleAvatar(
                backgroundColor: AppTheme.primaryColor,
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : IconButton(
                        icon: const Icon(Icons.send, color: Colors.white, size: 20),
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
  const _ChatBubble({required this.content, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser ? AppTheme.primaryColor : Colors.grey.shade100,
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
            color: isUser ? Colors.white : Colors.black87,
            fontSize: 14,
            height: 1.4,
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
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, size: 18, color: Colors.red.shade400),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message,
                style: TextStyle(color: Colors.red.shade700, fontSize: 13)),
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
          color: Colors.grey.shade100,
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
            Icon(Icons.auto_awesome, size: 14, color: AppTheme.primaryColor),
            const SizedBox(width: 8),
            Text('Sasa sedang mengetik...',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
