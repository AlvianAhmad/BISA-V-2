import 'dart:math';

class KodeKelasHelper {
  static String generate() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rand = Random();

    String random(int len) =>
        List.generate(len, (_) => chars[rand.nextInt(chars.length)]).join();

    return random(6); // contoh: A9K2PZ
  }
}
