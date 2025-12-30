import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
          "temperature": 0.7,
          "max_tokens": 512,
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
