// ignore: unnecessary_import
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../data/services/gemini_service.dart';
import '../../../../data/services/lexa_services.dart';
import '../../../../data/firestore_helper.dart';

class LexaChatPage
    extends
        StatefulWidget {
  const LexaChatPage({
    super.key,
  });

  @override
  State<
    LexaChatPage
  >
  createState() => _LexaChatPageState();
}

class _LexaChatPageState
    extends
        State<
          LexaChatPage
        > {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();

  late final LexaService lexa;
  final List<
    _ChatMessage
  >
  messages = [];
  bool isTyping = false;

  @override
  void initState() {
    super.initState();

    lexa = LexaService(
      GroqService(),
      FirestoreHelper(),
    );

    messages.add(
      _ChatMessage(
        text:
            "Halo 👋 Aku **LEXA**, asisten akademikmu.\n\n"
            "Aku bisa bantu:\n"
            "📚 Materi\n"
            "📝 Tugas\n"
            "📅 Jadwal\n"
            "🏫 Kelas",
        isUser: false,
      ),
    );
  }

  Future<
    void
  >
  _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(
      () {
        messages.add(
          _ChatMessage(
            text: text,
            isUser: true,
          ),
        );
        isTyping = true;
      },
    );

    _controller.clear();
    _scrollDown();

    try {
      final reply = await lexa.reply(
        text,
      );
      setState(
        () {
          messages.add(
            _ChatMessage(
              text: reply,
              isUser: false,
            ),
          );
        },
      );
    } catch (
      _
    ) {
      messages.add(
        _ChatMessage(
          text: 'Maaf, terjadi kesalahan 😥',
          isUser: false,
        ),
      );
    }

    isTyping = false;
    _scrollDown();
  }

  void _scrollDown() {
    Future.delayed(
      const Duration(
        milliseconds: 200,
      ),
      () {
        if (_scroll.hasClients) {
          _scroll.animateTo(
            _scroll.position.maxScrollExtent,
            duration: const Duration(
              milliseconds: 300,
            ),
            curve: Curves.easeOut,
          );
        }
      },
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFF5F6FA,
      ),
      appBar: AppBar(
        backgroundColor: const Color(
          0xFF0E2E72,
        ),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'LEXA',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              itemCount: messages.length,
              itemBuilder:
                  (
                    _,
                    i,
                  ) => _ChatBubble(
                    message: messages[i],
                  ),
            ),
          ),

          if (isTyping) const _TypingIndicator(),

          _InputBar(
            controller: _controller,
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }
}

/// ===================== CHAT BUBBLE =====================

class _ChatBubble
    extends
        StatelessWidget {
  final _ChatMessage message;
  const _ChatBubble({
    required this.message,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 6,
      ),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) _botAvatar(),
          const SizedBox(
            width: 8,
          ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(
                14,
              ),
              decoration: BoxDecoration(
                gradient: isUser
                    ? const LinearGradient(
                        colors: [
                          Color(
                            0xFF1B3C9E,
                          ),
                          Color(
                            0xFF0E2E72,
                          ),
                        ],
                      )
                    : null,
                color: isUser
                    ? null
                    : Colors.white,
                borderRadius: BorderRadius.circular(
                  20,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(
                      0.05,
                    ),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: isUser
                      ? Colors.white
                      : Colors.black87,
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 8,
          ),
          if (isUser) _userAvatar(),
        ],
      ),
    );
  }

  Widget _botAvatar() {
    return const CircleAvatar(
      radius: 18,
      backgroundColor: Color(
        0xFF0E2E72,
      ),
      child: Icon(
        Icons.smart_toy_rounded,
        color: Colors.white,
      ),
    );
  }

  Widget _userAvatar() {
    return const CircleAvatar(
      radius: 18,
      backgroundColor: Colors.grey,
      child: Icon(
        Icons.person,
        color: Colors.white,
      ),
    );
  }
}

/// ===================== INPUT BAR =====================

class _InputBar
    extends
        StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _InputBar({
    required this.controller,
    required this.onSend,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          12,
          8,
          12,
          12,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(
                0.08,
              ),
              blurRadius: 12,
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: const Color(
                    0xFFF1F3F6,
                  ),
                  borderRadius: BorderRadius.circular(
                    24,
                  ),
                ),
                child: TextField(
                  controller: controller,
                  maxLines: 4,
                  minLines: 1,
                  decoration: const InputDecoration(
                    hintText: 'Tulis pesan...',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 8,
            ),
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(
                0xFF0E2E72,
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                ),
                onPressed: onSend,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ===================== TYPING =====================

class _TypingIndicator
    extends
        StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16,
        bottom: 8,
      ),
      child: Row(
        children: const [
          CircleAvatar(
            radius: 14,
            backgroundColor: Color(
              0xFF0E2E72,
            ),
            child: Icon(
              Icons.smart_toy,
              size: 16,
              color: Colors.white,
            ),
          ),
          SizedBox(
            width: 8,
          ),
          Text(
            'LEXA sedang mengetik...',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

/// ===================== MODEL =====================

class _ChatMessage {
  final String text;
  final bool isUser;

  _ChatMessage({
    required this.text,
    required this.isUser,
  });
}
