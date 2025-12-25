import 'gemini_service.dart';
import '../firestore_helper.dart';

class LexaService {
  final GroqService gemini;
  final FirestoreHelper db;

  LexaService(this.gemini, this.db);

  Future<String> reply(String userMessage) async {
    final msg = userMessage.toLowerCase();

    // ===== INTENT DETECTION =====
    if (msg.contains('kelas')) {
      final kelas = await db.getKelas();
      return gemini.generateReply('''
Berikut daftar kelas:
${kelas.join(', ')}

Jawab dengan bahasa ramah seperti asisten kampus.
''');
    }

    if (msg.contains('jadwal')) {
      final jadwal = await db.getJadwal();
      return gemini.generateReply('''
Data jadwal:
$jadwal

Tolong rangkum jadwal dengan rapi dan mudah dipahami.
''');
    }

    if (msg.contains('tugas')) {
      final tugas = await db.getTugas();
      return gemini.generateReply('''
Data tugas:
$tugas

Jawabkan daftar tugas dan deadline secara ringkas.
''');
    }

    if (msg.contains('materi')) {
      final materi = await db.getMateri();
      return gemini.generateReply('''
Data materi:
$materi

Tolong jelaskan materi yang tersedia.
''');
    }

    // ===== DEFAULT =====
    return gemini.generateReply(userMessage);
  }
}
