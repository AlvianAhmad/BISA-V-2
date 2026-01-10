import 'dart:convert';
import 'package:http/http.dart' as http;

class GroqService {
  static const String _apiKey =
      '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';
  static const String _endpoint =
      'https://api.groq.com/openai/v1/chat/completions';

  Future<String> generateReply(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          "model": "llama-3.1-8b-instant",
          "messages": [
            {"role": "user", "content": prompt},
          ],
          "temperature": 0.6,
          "max_tokens": 700,
        }),
      );

      if (response.statusCode != 200) {
        return 'LEXA sedang bermasalah (${response.statusCode})';
      }

      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'];
    } catch (e) {
      return 'LEXA error: $e';
    }
  }
}
