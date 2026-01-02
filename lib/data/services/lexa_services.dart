import 'gemini_service.dart';
import '../firestore_helper.dart';

class LexaService {
  final GroqService llm;
  final FirestoreHelper db;

  LexaService(this.llm, this.db);

  static const String _systemPrompt = '''
Kamu adalah LEXA, asisten akademik untuk aplikasi LMS kampus.

Gaya komunikasi:
- Bahasa Indonesia, ramah, profesional, dan tidak bertele-tele.
- Kalau user menyapa (halo/hai/hi/pagi/dll), balas: "Halo, saya LEXA, asisten akademikmu. Ada yang bisa saya bantu?"
- Jika user bertanya random (di luar akademik), jawab dengan benar dan netral.
- Jika pertanyaan butuh data kampus (kelas/jadwal/tugas/materi/absensi), gunakan DATA yang diberikan.
- Jangan mengarang data di luar DATA.
- Jika data tidak ada, bilang jujur dan sarankan langkah berikutnya (misalnya cek menu Kelas/Tugas atau tanya admin).

Batasan:
- Jangan bahas game/halu (misalnya Halo game, Cortana, dll) kecuali user memang membahas itu secara eksplisit.
- Jika user bertanya hal sensitif/medis/hukum, jawab aman dan sarankan sumber profesional bila perlu.
''';

  Future<String> reply(String userMessage) async {
    final raw = userMessage.trim();
    if (raw.isEmpty) return 'Tulis pertanyaan dulu ya 😊';

    final msg = raw.toLowerCase();

    // ===== GREETING =====
    if (_isGreetingOnly(msg)) {
      return 'Halo 👋 Saya LEXA, asisten akademikmu. Ada yang bisa saya bantu?';
    }

    // ===== INTENT (akademik) =====
    final wantsKelas = _containsAny(msg, [
      'kelas',
      'matkul',
      'mata kuliah',
      'kode kelas',
    ]);
    final wantsJadwal = _containsAny(msg, [
      'jadwal',
      'schedule',
      'jam',
      'hari',
    ]);
    final wantsTugas = _containsAny(msg, [
      'tugas',
      'assignment',
      'pr',
      'deadline',
      'due',
    ]);
    final wantsMateri = _containsAny(msg, [
      'materi',
      'modul',
      'bahan',
      'file',
      'ppt',
      'pdf',
    ]);
    final wantsAbsensi = _containsAny(msg, [
      'absen',
      'absensi',
      'kehadiran',
      'hadir',
    ]);

    // Prioritas biasanya: tugas > absensi > jadwal > materi > kelas
    if (wantsTugas) return _handleTugas(raw);
    if (wantsAbsensi) return _handleAbsensi(raw);
    if (wantsJadwal) return _handleJadwal(raw);
    if (wantsMateri) return _handleMateri(raw);
    if (wantsKelas) return _handleKelas(raw);

    // ===== RANDOM / GENERAL QUESTION =====
    // Tetap dijawab benar, tapi persona LEXA tetap dijaga lewat system prompt.
    return llm.generateReply(
      _wrapPrompt(
        userQuestion: raw,
        instruction: '''
Jawab pertanyaan user dengan benar dan jelas.
Kalau pertanyaannya di luar akademik, jawab singkat dan netral.
Kalau user butuh bantuan akademik, arahkan dengan contoh pertanyaan yang bisa ditanyakan ke LEXA.
''',
      ),
    );
  }

  // ================== HANDLERS ==================

  Future<String> _handleKelas(String question) async {
    final kelas = await db.getKelas();
    if (kelas.isEmpty) {
      return 'Saat ini belum ada data kelas yang tersedia. Coba cek lagi nanti ya.';
    }

    return llm.generateReply(
      _wrapPrompt(
        userQuestion: question,
        dataBlock: 'DATA KELAS:\n${kelas.join(', ')}',
        instruction: '''
Tampilkan daftar kelas secara rapi (bullet/nomor).
Kalau user menyebut nama kelas tertentu, sebutkan apakah ada atau tidak.
''',
      ),
    );
  }

  Future<String> _handleJadwal(String question) async {
    final jadwal = await db.getJadwal();
    final data = jadwal.toString().trim();

    if (data.isEmpty || data == '[]' || data == '{}') {
      return 'Belum ada jadwal yang tersimpan untuk saat ini.';
    }

    return llm.generateReply(
      _wrapPrompt(
        userQuestion: question,
        dataBlock: 'DATA JADWAL:\n$data',
        instruction: '''
Rangkum jadwal dengan rapi.
Format yang disarankan:
- Hari:
  - Jam — Mata kuliah (Kelas) — Dosen (jika ada)
Jika ada data yang kosong, jangan mengarang.
''',
      ),
    );
  }

  Future<String> _handleTugas(String question) async {
    final tugas = await db.getTugas();
    final data = tugas.toString().trim();

    if (data.isEmpty || data == '[]' || data == '{}') {
      return 'Belum ada tugas yang tersedia saat ini.';
    }

    return llm.generateReply(
      _wrapPrompt(
        userQuestion: question,
        dataBlock: 'DATA TUGAS:\n$data',
        instruction: '''
Buat daftar tugas ringkas.
Jika ada deadline, tampilkan.
Jika ada kelas, kelompokkan per kelas.
Jangan menambahkan deadline/kelas yang tidak ada di data.
''',
      ),
    );
  }

  Future<String> _handleMateri(String question) async {
    final materi = await db.getMateri();
    final data = materi.toString().trim();

    if (data.isEmpty || data == '[]' || data == '{}') {
      return 'Belum ada materi yang tersedia saat ini.';
    }

    return llm.generateReply(
      _wrapPrompt(
        userQuestion: question,
        dataBlock: 'DATA MATERI:\n$data',
        instruction: '''
Jelaskan materi yang tersedia dengan rapi.
Jika ada kelas, kelompokkan per kelas.
Jika ada fileUrl/fileType, sebutkan secara singkat.
''',
      ),
    );
  }

  Future<String> _handleAbsensi(String question) async {
    return 'Untuk absensi, coba buka menu Absensi di aplikasi ya 😊';
  }

  // ================== PROMPT WRAPPER ==================

  String _wrapPrompt({
    required String userQuestion,
    String? dataBlock,
    String? instruction,
  }) {
    return '''
$_systemPrompt

${dataBlock != null ? '$dataBlock\n' : ''}

INSTRUKSI TAMBAHAN:
${instruction ?? 'Jawab pertanyaan user dengan bantuan data di atas jika ada.'}

PERTANYAAN USER:
$userQuestion
''';
  }

  // ================== UTIL ==================

  bool _containsAny(String msg, List<String> keys) {
    for (final k in keys) {
      if (msg.contains(k)) return true;
    }
    return false;
  }

  /// Greeting yang "murni" (biar kalau user nulis "halo ada tugas?" tetap masuk intent tugas)
  bool _isGreetingOnly(String msg) {
    final cleaned = msg
        .replaceAll(RegExp(r'[^\w\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    const greetings = [
      'halo',
      'hai',
      'hi',
      'hey',
      'pagi',
      'siang',
      'sore',
      'malam',
      'assalamualaikum',
      'permisi',
    ];

    // kalau isi pesan cuma greeting + optional "lexa"
    final tokens = cleaned.split(' ').where((e) => e.isNotEmpty).toList();
    if (tokens.isEmpty) return false;

    // hapus "lexa" biar "halo lexa" dianggap greeting
    final filtered = tokens.where((t) => t != 'lexa').toList();
    if (filtered.isEmpty) return true;

    // harus semua token adalah greeting
    return filtered.every((t) => greetings.contains(t));
  }
}
