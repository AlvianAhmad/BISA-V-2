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
          _ChatMessage(
            text: 'Maaf, LEXA sedang mengalami gangguan 😥',
            isUser: false,
          ),
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
      backgroundColor: const Color(0xFFF2F3F7),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(child: _buildChatList()),
          if (isTyping) const _TypingIndicator(),
          _buildInput(),
        ],
      ),
    );
  }

  // ================= APP BAR =================
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      centerTitle: true,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0E2E72), Color(0xFF1E4DB7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          CircleAvatar(
            radius: 14,
            backgroundColor: Colors.white,
            child: Icon(Icons.smart_toy, color: Color(0xFF0E2E72), size: 18),
          ),
          SizedBox(width: 8),
          Text('LEXA AI', style: TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ================= CHAT LIST =================
  Widget _buildChatList() {
    return ListView.builder(
      controller: _scroll,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      itemCount: messages.length,
      itemBuilder: (_, i) => _ChatBubble(message: messages[i]),
    );
  }

  // ================= INPUT =================
  Widget _buildInput() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(blurRadius: 12, color: Colors.black.withOpacity(0.08)),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F3F6),
                  borderRadius: BorderRadius.circular(30),
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
            const SizedBox(width: 10),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF0E2E72), Color(0xFF1E4DB7)],
                  ),
                ),
                child: const Icon(Icons.send, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= CHAT BUBBLE =================

class _ChatBubble extends StatelessWidget {
  final _ChatMessage message;
  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 320),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: isUser
                ? const LinearGradient(
                    colors: [Color(0xFF0E2E72), Color(0xFF1E4DB7)],
                  )
                : null,
            color: isUser ? null : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: isUser
                  ? const Radius.circular(18)
                  : const Radius.circular(4),
              bottomRight: isUser
                  ? const Radius.circular(4)
                  : const Radius.circular(18),
            ),
            boxShadow: [
              BoxShadow(blurRadius: 8, color: Colors.black.withOpacity(0.06)),
            ],
          ),
          child: Text(
            message.text,
            style: TextStyle(
              color: isUser ? Colors.white : Colors.black87,
              height: 1.45,
            ),
          ),
        ),
      ),
    );
  }
}

// ================= TYPING =================

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
