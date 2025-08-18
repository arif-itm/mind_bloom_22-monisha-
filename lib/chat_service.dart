import 'dart:convert';
import 'package:http/http.dart' as http;

/// Simple AI chat service using OpenAI-compatible Chat Completions API.
/// Replace BASE_URL and MODEL if you're using a different provider.
class ChatService {
  static const String _apiKey = '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'; // TODO: replace safely
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';
  static const String _model = 'gpt-4o-mini'; // lightweight, good quality

  /// Sends the full conversation (system + history + user) and returns assistant text.
  static Future<String> send(List<Map<String, String>> messages) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': _model,
        'temperature': 0.8,
        'messages': messages,
      }),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      final text = data['choices']?[0]?['message']?['content'] ?? '';
      return text.toString().trim();
    } else {
      throw Exception(
        'AI request failed (${response.statusCode}): ${response.body}',
      );
    }
  }
}