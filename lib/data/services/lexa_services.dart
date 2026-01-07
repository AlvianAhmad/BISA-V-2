import 'qroq_service.dart';
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

  // ================== CHAT BIASA ==================

  Future<String> reply(String userMessage) async {
    final raw = userMessage.trim();
    if (raw.isEmpty) return 'Tulis pertanyaan dulu ya 😊';

    final msg = raw.toLowerCase();

    // ===== GREETING =====
    if (_isGreetingOnly(msg)) {
      return 'Halo 👋 Saya LEXA, asisten akademikmu. Ada yang bisa saya bantu?';
    }

    // ===== INTENT =====
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

    if (wantsTugas) return _handleTugas(raw);
    if (wantsAbsensi) return _handleAbsensi(raw);
    if (wantsJadwal) return _handleJadwal(raw);
    if (wantsMateri) return _handleMateri(raw);
    if (wantsKelas) return _handleKelas(raw);

    // ===== RANDOM / GENERAL =====
    return llm.generateReply(
      _wrapPrompt(
        userQuestion: raw,
        instruction: '''
Jawab pertanyaan user dengan benar dan jelas.
Kalau pertanyaannya di luar akademik, jawab singkat dan netral.
Kalau user butuh bantuan akademik, arahkan dengan contoh pertanyaan ke LEXA.
''',
      ),
    );
  }

  // ================== CHAT DENGAN FILE ==================
  // (INI YANG DITAMBAHKAN – FIX ERROR KAMU)

  Future<String> replyWithFile({
    required String question,
    required String fileContent,
  }) async {
    final q = question.trim();
    final content = fileContent.trim();

    if (q.isEmpty) {
      return 'Tulis pertanyaan tentang file tersebut ya 😊';
    }

    if (content.isEmpty) {
      return 'Maaf, isi file tidak dapat dibaca atau kosong.';
    }

    // Batas aman token
    final safeContent = content.length > 6000
        ? content.substring(0, 6000)
        : content;

    return llm.generateReply('''
$_systemPrompt

KONTEKS FILE:
$safeContent

INSTRUKSI:
- Jawab pertanyaan user BERDASARKAN isi file
- Jangan mengarang jika tidak ada di file
- Jika diminta ringkasan, buat ringkasan
- Jika informasi tidak ditemukan, katakan dengan jujur

PERTANYAAN USER:
$q
''');
  }

  // ================== HANDLERS ==================

  Future<String> _handleKelas(String question) async {
    final kelas = await db.getKelas();
    if (kelas.isEmpty) {
      return 'Saat ini belum ada data kelas yang tersedia.';
    }

    return llm.generateReply(
      _wrapPrompt(
        userQuestion: question,
        dataBlock: 'DATA KELAS:\n${kelas.join(', ')}',
        instruction: '''
Tampilkan daftar kelas secara rapi.
Jika user menyebut nama kelas tertentu, jelaskan apakah ada atau tidak.
''',
      ),
    );
  }

  Future<String> _handleJadwal(String question) async {
    final jadwal = await db.getJadwal();
    final data = jadwal.toString().trim();

    if (data.isEmpty || data == '[]' || data == '{}') {
      return 'Belum ada jadwal yang tersimpan.';
    }

    return llm.generateReply(
      _wrapPrompt(
        userQuestion: question,
        dataBlock: 'DATA JADWAL:\n$data',
        instruction: '''
Rangkum jadwal dengan rapi.
Jangan mengarang data.
''',
      ),
    );
  }

  Future<String> _handleTugas(String question) async {
    final tugas = await db.getTugas();
    final data = tugas.toString().trim();

    if (data.isEmpty || data == '[]' || data == '{}') {
      return 'Belum ada tugas saat ini.';
    }

    return llm.generateReply(
      _wrapPrompt(
        userQuestion: question,
        dataBlock: 'DATA TUGAS:\n$data',
        instruction: '''
Buat daftar tugas ringkas.
Tampilkan deadline jika ada.
''',
      ),
    );
  }

  Future<String> _handleMateri(String question) async {
    final materi = await db.getMateri();
    final data = materi.toString().trim();

    if (data.isEmpty || data == '[]' || data == '{}') {
      return 'Belum ada materi tersedia.';
    }

    return llm.generateReply(
      _wrapPrompt(
        userQuestion: question,
        dataBlock: 'DATA MATERI:\n$data',
        instruction: '''
Jelaskan materi yang tersedia dengan rapi.
''',
      ),
    );
  }

  Future<String> _handleAbsensi(String question) async {
    return 'Untuk absensi, silakan buka menu Absensi di aplikasi 😊';
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

    final tokens = cleaned.split(' ').where((e) => e.isNotEmpty).toList();
    if (tokens.isEmpty) return false;

    final filtered = tokens.where((t) => t != 'lexa').toList();
    if (filtered.isEmpty) return true;

    return filtered.every((t) => greetings.contains(t));
  }
}
