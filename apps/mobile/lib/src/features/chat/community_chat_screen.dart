import 'package:flutter/material.dart';

import '../../core/utils/formatters.dart';
import '../../models/chat_models.dart';

class CommunityChatScreen extends StatefulWidget {
  const CommunityChatScreen({
    super.key,
    required this.onLoadMessages,
    required this.onSendMessage,
  });

  final Future<List<CommunityChatMessage>> Function() onLoadMessages;
  final Future<List<CommunityChatMessage>> Function(String body) onSendMessage;

  @override
  State<CommunityChatScreen> createState() => _CommunityChatScreenState();
}

class _CommunityChatScreenState extends State<CommunityChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  List<CommunityChatMessage> _messages = const [];
  bool _isLoading = true;
  bool _isSending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF7),
      appBar: AppBar(
        title: const Text('Chat general'),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFF8EFE4),
                  Color(0xFFFFFBF7),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Espacio abierto para comentar tránsitos, sensaciones y preguntas breves del día.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF5E676E),
                        height: 1.4,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Mantén cada mensaje claro y corto para que la conversación sea fácil de seguir.',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: const Color(0xFF7C675B),
                      ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildBody(context),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      minLines: 1,
                      maxLines: 4,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        hintText: 'Escribe un mensaje para la comunidad',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  FilledButton(
                    onPressed: _isSending ? null : _send,
                    child: _isSending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Enviar'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null && _messages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _error!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF8B2C1F),
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        itemCount: _messages.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final item = _messages[index];
          return _MessageBubble(item: item);
        },
      ),
    );
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final messages = await widget.onLoadMessages();
      if (!mounted) {
        return;
      }
      setState(() {
        _messages = messages;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = error.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _send() async {
    final body = _messageController.text.trim();
    if (body.isEmpty) {
      return;
    }

    setState(() {
      _isSending = true;
      _error = null;
    });

    try {
      final messages = await widget.onSendMessage(body);
      if (!mounted) {
        return;
      }
      _messageController.clear();
      setState(() {
        _messages = messages;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.item,
  });

  final CommunityChatMessage item;

  @override
  Widget build(BuildContext context) {
    final isGuide = item.authorRole == 'guide';
    final accent = isGuide ? const Color(0xFF5C3B52) : const Color(0xFF4A6A60);
    final background =
        isGuide ? const Color(0xFFF8EFF6) : const Color(0xFFF0F7F3);

    return Container(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accent.withValues(alpha: 0.14)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.authorName,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: accent,
                      ),
                ),
              ),
              Text(
                formatSchedule(item.createdAt),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: const Color(0xFF7C675B),
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.body,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.4,
                  color: const Color(0xFF3B3432),
                ),
          ),
        ],
      ),
    );
  }
}
