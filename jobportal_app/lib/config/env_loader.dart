import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'app_config.dart';

class EnvLoader {
  static Future<void> load() async {
    try {
      final origin = html.window.location.origin;
      final response = await html.HttpRequest.getString('$origin/env.json');
      final data = jsonDecode(response);

      AppConfig().baseUrl = data['API_GATEWAY_URL'] ?? AppConfig().baseUrl;
      AppConfig().environment = data['ENVIRONMENT'] ?? AppConfig().environment;

      print(
        '✅ Environment: ${AppConfig().environment} | Gateway: ${AppConfig().baseUrl}',
      );
    } catch (e) {
      print('⚠️ Failed to load env.json. Using fallback defaults. Error: $e');
    }
  }
}
