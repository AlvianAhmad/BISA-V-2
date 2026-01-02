// ignore_for_file: deprecated_member_use, unnecessary_import
import 'dart:ui';
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
  final FocusNode _focus = FocusNode();

  late final LexaService lexa;
  final List<_ChatMessage> messages = [];
  bool isTyping = false;

  bool _showJump = false;

  static const Color _primary = Color(0xFF0E2E72);
  static const Color _primary2 = Color(0xFF1B3C9E);
  static const Color _bg = Color(0xFFF5F6FA);
  static const Color _textDark = Color(0xFF1A2552);
  static const Color _muted = Color(0xFF6F7AA6);

  @override
  void initState() {
    super.initState();

    lexa = LexaService(GroqService(), FirestoreHelper());

    messages.add(
      _ChatMessage(
        text:
            "Halo 👋 Aku **LEXA**, asisten akademikmu.\n\n"
            "Aku bisa bantu:\n"
            "📚 Materi\n"
            "📝 Tugas\n"
            "📅 Jadwal\n"
            "🏫 Kelas\n\n"
            "Coba tanya: *\"Ada tugas apa untuk kelas Pemrograman Web?\"*",
        isUser: false,
        createdAt: DateTime.now(),
      ),
    );

    _scroll.addListener(() {
      if (!_scroll.hasClients) return;
      final max = _scroll.position.maxScrollExtent;
      final cur = _scroll.offset;
      final show = (max - cur) > 280; // jauh dari bawah
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

    try {
      final reply = await lexa.reply(text);
      if (!mounted) return;

      setState(() {
        messages.add(
          _ChatMessage(text: reply, isUser: false, createdAt: DateTime.now()),
        );
        isTyping = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        messages.add(
          _ChatMessage(
            text: 'Maaf, terjadi kesalahan 😥',
            isUser: false,
            createdAt: DateTime.now(),
          ),
        );
        isTyping = false;
      });
    }

    _scrollDown();
  }

  void _scrollDown({bool instant = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      final target = _scroll.position.maxScrollExtent + 160;
      if (instant) {
        _scroll.jumpTo(target);
      } else {
        _scroll.animateTo(
          target,
          duration: const Duration(milliseconds: 360),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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

          // ===== CONTENT =====
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
                    final showDate = prev == null
                        ? true
                        : !_isSameDay(prev.createdAt, msg.createdAt);

                    return Column(
                      children: [
                        if (showDate) _DatePill(date: msg.createdAt),
                        _ChatBubble(message: msg, grouped: grouped),
                      ],
                    );
                  },
                ),
              ),

              if (isTyping) const _TypingRow(),

              _InputDock(
                controller: _controller,
                focusNode: _focus,
                enabled: !isTyping,
                onSend: _sendMessage,
              ),
            ],
          ),

          // ===== JUMP TO BOTTOM =====
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

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

/// ===================== BACKGROUND =====================

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
        child: CustomPaint(painter: _PatternPainter()),
      ),
    );
  }
}

class _PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.06);

    // pola bulatan halus
    for (double y = -40; y < size.height + 40; y += 70) {
      for (double x = -40; x < size.width + 40; x += 70) {
        canvas.drawCircle(Offset(x + (y % 140 == 0 ? 18 : 0), y), 10, paint);
      }
    }

    // blob kiri atas
    final blob = Paint()..color = Colors.white.withOpacity(0.07);
    canvas.drawCircle(const Offset(-60, 120), 160, blob);

    // blob kanan atas
    canvas.drawCircle(Offset(size.width + 70, 40), 190, blob);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// ===================== APP BAR =====================

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
      automaticallyImplyLeading: true,
      foregroundColor: Colors.white,
      title: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.10),
              border: Border.all(color: Colors.white.withOpacity(0.18)),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.white24,
                  child: Icon(
                    Icons.smart_toy_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.3,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 11.5,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      centerTitle: true,
    );
  }
}

/// ===================== DATE PILL =====================

class _DatePill extends StatelessWidget {
  final DateTime date;
  const _DatePill({required this.date});

  String _label(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dd = DateTime(d.year, d.month, d.day);
    final diff = dd.difference(today).inDays;

    if (diff == 0) return 'Hari ini';
    if (diff == -1) return 'Kemarin';
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.black.withOpacity(0.06)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Text(
            _label(date),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: Colors.black.withOpacity(0.55),
            ),
          ),
        ),
      ),
    );
  }
}

/// ===================== CHAT BUBBLE (WITH TAIL) =====================

class _ChatBubble extends StatelessWidget {
  final _ChatMessage message;
  final bool grouped;

  const _ChatBubble({required this.message, required this.grouped});

  static const Color _primary = Color(0xFF0E2E72);
  static const Color _primary2 = Color(0xFF1B3C9E);
  static const Color _textDark = Color(0xFF1A2552);
  static const Color _muted = Color(0xFF6F7AA6);

  String _time(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    final bubble = Stack(
      children: [
        Container(
          margin: EdgeInsets.only(
            left: isUser ? 40 : 0,
            right: isUser ? 0 : 40,
          ),
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
          decoration: BoxDecoration(
            gradient: isUser
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_primary2, _primary],
                  )
                : null,
            color: isUser ? null : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20),
              topRight: const Radius.circular(20),
              bottomLeft: Radius.circular(isUser ? 20 : 8),
              bottomRight: Radius.circular(isUser ? 8 : 20),
            ),
            border: isUser
                ? null
                : Border.all(color: Colors.black.withOpacity(0.06)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message.text,
                style: TextStyle(
                  color: isUser ? Colors.white : _textDark,
                  fontSize: 14.3,
                  height: 1.45,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  _time(message.createdAt),
                  style: TextStyle(
                    color: isUser ? Colors.white70 : _muted,
                    fontSize: 11.2,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Tail (hanya kalau bukan grouped biar rapi)
        if (!grouped)
          Positioned(
            left: isUser ? null : 6,
            right: isUser ? 6 : null,
            bottom: 10,
            child: CustomPaint(
              painter: _BubbleTailPainter(
                color: isUser ? _primary : Colors.white,
                isUser: isUser,
                border: !isUser,
              ),
              size: const Size(12, 12),
            ),
          ),
      ],
    );

    return Padding(
      padding: EdgeInsets.only(top: grouped ? 6 : 12, bottom: 2),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser && !grouped) ...[
            const CircleAvatar(
              radius: 16,
              backgroundColor: _primary,
              child: Icon(
                Icons.smart_toy_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
          ] else if (!isUser && grouped) ...[
            const SizedBox(width: 40),
          ],
          Flexible(child: bubble),
          if (isUser && !grouped) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.black.withOpacity(0.12),
              child: const Icon(
                Icons.person_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BubbleTailPainter extends CustomPainter {
  final Color color;
  final bool isUser;
  final bool border;

  _BubbleTailPainter({
    required this.color,
    required this.isUser,
    required this.border,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color;

    final path = Path();
    if (isUser) {
      path.moveTo(size.width, 0);
      path.lineTo(0, size.height * 0.55);
      path.lineTo(size.width, size.height);
    } else {
      path.moveTo(0, 0);
      path.lineTo(size.width, size.height * 0.55);
      path.lineTo(0, size.height);
    }
    path.close();

    canvas.drawPath(path, p);

    if (border) {
      final stroke = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.black.withOpacity(0.06);
      canvas.drawPath(path, stroke);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// ===================== TYPING ROW =====================

class _TypingRow extends StatelessWidget {
  const _TypingRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 16,
            backgroundColor: Color(0xFF0E2E72),
            child: Icon(Icons.smart_toy_rounded, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.black.withOpacity(0.06)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const _Dots(),
          ),
        ],
      ),
    );
  }
}

class _Dots extends StatefulWidget {
  const _Dots();

  @override
  State<_Dots> createState() => _DotsState();
}

class _DotsState extends State<_Dots> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        final t = _c.value;
        final active = (t * 3).floor() % 3;

        Widget dot(bool on) => AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: on ? 8 : 7,
          height: on ? 8 : 7,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: on
                ? const Color(0xFF1B3C9E)
                : Colors.black.withOpacity(0.16),
            shape: BoxShape.circle,
          ),
        );

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [dot(active == 0), dot(active == 1), dot(active == 2)],
        );
      },
    );
  }
}

/// ===================== INPUT DOCK (FLOATING) =====================

class _InputDock extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool enabled;
  final VoidCallback onSend;

  const _InputDock({
    required this.controller,
    required this.focusNode,
    required this.enabled,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final canSend = enabled && controller.text.trim().isNotEmpty;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.92),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: Colors.black.withOpacity(0.06)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
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
                      onChanged: (_) => (context as Element).markNeedsBuild(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    decoration: BoxDecoration(
                      gradient: canSend
                          ? const LinearGradient(
                              colors: [Color(0xFF1B3C9E), Color(0xFF0E2E72)],
                            )
                          : null,
                      color: canSend ? null : Colors.black.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: IconButton(
                      onPressed: canSend ? onSend : null,
                      icon: Icon(
                        Icons.send_rounded,
                        color: canSend ? Colors.white : Colors.black26,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ===================== JUMP TO BOTTOM =====================

class _JumpToBottom extends StatelessWidget {
  final VoidCallback onTap;
  const _JumpToBottom({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.black.withOpacity(0.06)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(Icons.arrow_downward_rounded, size: 20),
        ),
      ),
    );
  }
}

/// ===================== MODEL =====================

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
