// ignore_for_file: deprecated_member_use

import 'dart:ui';
import 'package:flutter/material.dart';

import '../../../../data/services/lexa_services.dart';
import '../../../../data/services/qroq_service.dart';
import '../../../../data/services/file_reader_service.dart';
import '../../../../data/firestore_helper.dart';

class LexaChatPage extends StatefulWidget {
  const LexaChatPage({super.key});

  @override
  State<LexaChatPage> createState() => _LexaChatPageState();
}

class _LexaChatPageState extends State<LexaChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final FocusNode _focus = FocusNode();

  late final LexaService lexa;
  late final FileReaderService fileReader;

  final List<_ChatMessage> messages = [];
  bool isTyping = false;
  bool _showJump = false;

  static const Color _bg = Color(0xFFF5F6FA);

  @override
  void initState() {
    super.initState();

    lexa = LexaService(GroqService(), FirestoreHelper());
    fileReader = FileReaderService();

    // 🔴 PENTING: update UI saat user mengetik
    _controller.addListener(() {
      setState(() {});
    });

    messages.add(
      _ChatMessage(
        text:
            "Halo 👋 Aku **LEXA**, asisten akademikmu.\n\n"
            "Aku bisa bantu:\n"
            "📚 Materi\n"
            "📝 Tugas\n"
            "📄 Analisis PDF\n\n"
            "Kamu juga bisa **upload file PDF/TXT** 📎",
        isUser: false,
        createdAt: DateTime.now(),
      ),
    );

    _scroll.addListener(() {
      if (!_scroll.hasClients) return;
      final show = (_scroll.position.maxScrollExtent - _scroll.offset) > 280;
      if (show != _showJump) setState(() => _showJump = show);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    _focus.dispose();
    super.dispose();
  }

  // ===================== SEND TEXT =====================

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || isTyping) return;

    setState(() {
      messages.add(
        _ChatMessage(text: text, isUser: true, createdAt: DateTime.now()),
      );
      isTyping = true;
    });

    _controller.clear();
    _scrollDown();

    final reply = await lexa.reply(text);

    if (!mounted) return;
    setState(() {
      messages.add(
        _ChatMessage(text: reply, isUser: false, createdAt: DateTime.now()),
      );
      isTyping = false;
    });

    _scrollDown();
  }

  // ===================== PICK FILE =====================

  Future<void> _pickFileAndSend() async {
    if (isTyping) return;

    final content = await fileReader.pickAndReadFile();
    if (content == null || content.trim().isEmpty) {
      return;
    }

    setState(() {
      messages.add(
        _ChatMessage(
          text: '📎 File berhasil diunggah',
          isUser: true,
          createdAt: DateTime.now(),
        ),
      );
      isTyping = true;
    });

    _scrollDown();

    final reply = await lexa.replyWithFile(
      question: 'Tolong jelaskan isi file ini',
      fileContent: content,
    );

    if (!mounted) return;
    setState(() {
      messages.add(
        _ChatMessage(text: reply, isUser: false, createdAt: DateTime.now()),
      );
      isTyping = false;
    });

    _scrollDown();
  }

  void _scrollDown({bool instant = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      final target = _scroll.position.maxScrollExtent + 160;
      instant
          ? _scroll.jumpTo(target)
          : _scroll.animateTo(
              target,
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
            );
    });
  }

  @override
  Widget build(BuildContext context) {
    final canSend = _controller.text.trim().isNotEmpty && !isTyping;

    return Scaffold(
      backgroundColor: _bg,
      extendBodyBehindAppBar: true,
      appBar: _GlassAppBar(
        title: 'LEXA',
        subtitle: isTyping ? 'Sedang mengetik…' : 'Online',
      ),
      body: Stack(
        children: [
          const _ChatBackground(),
          Column(
            children: [
              const SizedBox(height: kToolbarHeight + 16),
              Expanded(
                child: ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 120),
                  itemCount: messages.length,
                  itemBuilder: (_, i) {
                    final msg = messages[i];
                    final prev = i > 0 ? messages[i - 1] : null;
                    final grouped = prev != null && prev.isUser == msg.isUser;
                    return _ChatBubble(message: msg, grouped: grouped);
                  },
                ),
              ),
              if (isTyping) const _TypingRow(),
              _InputDock(
                controller: _controller,
                focusNode: _focus,
                enabled: !isTyping,
                canSend: canSend,
                onSend: _sendMessage,
                onPickFile: _pickFileAndSend,
              ),
            ],
          ),
          if (_showJump)
            Positioned(
              right: 16,
              bottom: 110,
              child: _JumpToBottom(onTap: () => _scrollDown()),
            ),
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////////////////////////////////
// UI COMPONENTS
////////////////////////////////////////////////////////////////////////////////

class _ChatBackground extends StatelessWidget {
  const _ChatBackground();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0E2E72), Color(0xFFF5F6FA)],
            stops: [0.0, 0.35],
          ),
        ),
      ),
    );
  }
}

class _GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String subtitle;

  const _GlassAppBar({required this.title, required this.subtitle});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: Column(
        children: [
          Text(title),
          Text(subtitle, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class _InputDock extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool enabled;
  final bool canSend;
  final VoidCallback onSend;
  final VoidCallback onPickFile;

  const _InputDock({
    required this.controller,
    required this.focusNode,
    required this.enabled,
    required this.canSend,
    required this.onSend,
    required this.onPickFile,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.attach_file_rounded),
              onPressed: enabled ? onPickFile : null,
            ),
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                enabled: enabled,
                minLines: 1,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Tulis pesan ke LEXA...',
                  border: InputBorder.none,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send_rounded),
              color: canSend ? Colors.blue : Colors.grey,
              onPressed: canSend ? onSend : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _TypingRow extends StatelessWidget {
  const _TypingRow();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(12),
      child: Text('LEXA sedang mengetik...'),
    );
  }
}

class _JumpToBottom extends StatelessWidget {
  final VoidCallback onTap;

  const _JumpToBottom({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onTap,
      child: const Icon(Icons.arrow_downward),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final _ChatMessage message;
  final bool grouped;

  const _ChatBubble({required this.message, required this.grouped});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: message.isUser ? Colors.blue : Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.isUser ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;
  final DateTime createdAt;

  _ChatMessage({
    required this.text,
    required this.isUser,
    required this.createdAt,
  });
}
