import 'package:flutter/material.dart';
import '../../../../data/services/gemini_service.dart';
import '../../../../data/services/lexa_services.dart';
import '../../../../data/firestore_helper.dart';

class LexaChatPage extends StatefulWidget {
  const LexaChatPage({super.key});

  @override
  State<LexaChatPage> createState() => _LexaChatPageState();
}

class _LexaChatPageState extends State<LexaChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();

  late final LexaService lexa;

  final List<_ChatMessage> messages = [];
  bool isTyping = false;

  @override
  void initState() {
    super.initState();

    lexa = LexaService(GroqService(), FirestoreHelper());

    messages.add(
      _ChatMessage(
        text:
            'Halo 👋 Aku **LEXA**, asisten akademik kamu.\n\n'
            'Aku bisa bantu:\n'
            '📅 Jadwal\n'
            '🏫 Kelas\n'
            '📝 Tugas\n'
            '📚 Materi',
        isUser: false,
      ),
    );
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      messages.add(_ChatMessage(text: text, isUser: true));
      isTyping = true;
    });

    _controller.clear();
    _scrollToBottom();

    try {
      final reply = await lexa.reply(text);

      setState(() {
        messages.add(_ChatMessage(text: reply, isUser: false));
      });
    } catch (_) {
      setState(() {
        messages.add(
          _ChatMessage(text: 'LEXA sedang bermasalah 😥', isUser: false),
        );
      });
    }

    setState(() => isTyping = false);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        elevation: 0,
        title: const Text('LEXA'),
        centerTitle: true,
        backgroundColor: const Color(0xFF0E2E72),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                return _ChatBubble(message: msg);
              },
            ),
          ),

          if (isTyping) const _TypingIndicator(),

          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildInput() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F3F6),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _controller,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                  decoration: const InputDecoration(
                    hintText: 'Tanya LEXA...',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: const Color(0xFF0E2E72),
              child: IconButton(
                icon: const Icon(Icons.send_rounded, color: Colors.white),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= UI COMPONENT =================

class _ChatBubble extends StatelessWidget {
  final _ChatMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isUser) _avatarBot(),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isUser ? const Color(0xFF0E2E72) : Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: isUser ? Colors.white : Colors.black87,
                  height: 1.4,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (isUser) _avatarUser(),
        ],
      ),
    );
  }

  Widget _avatarBot() {
    return const CircleAvatar(
      radius: 18,
      backgroundColor: Color(0xFF0E2E72),
      child: Icon(Icons.smart_toy_rounded, color: Colors.white),
    );
  }

  Widget _avatarUser() {
    return const CircleAvatar(
      radius: 18,
      backgroundColor: Colors.grey,
      child: Icon(Icons.person, color: Colors.white),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Row(
        children: const [
          CircleAvatar(
            radius: 14,
            backgroundColor: Color(0xFF0E2E72),
            child: Icon(Icons.smart_toy, size: 16, color: Colors.white),
          ),
          SizedBox(width: 8),
          Text(
            'LEXA sedang mengetik...',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// ================= MODEL =================

class _ChatMessage {
  final String text;
  final bool isUser;

  _ChatMessage({required this.text, required this.isUser});
}
