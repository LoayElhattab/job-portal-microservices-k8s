import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // Required for kIsWeb

import 'app_config.dart';

class EnvLoader {
  static Future<void> load() async {
    try {
      if (kIsWeb) {
        final response = await Dio().get('/env.json');

        final data = response.data is String
            ? jsonDecode(response.data)
            : response.data;

        AppConfig().baseUrl = data['gatewayUrl'] ?? AppConfig().baseUrl;
        AppConfig().environment =
            data['ENVIRONMENT'] ?? AppConfig().environment;
        print('🌐 Web Config Loaded.');
      } else {
        const gatewayUrl = String.fromEnvironment('gatewayUrl');
        const env = String.fromEnvironment('ENVIRONMENT');

        if (gatewayUrl.isNotEmpty) AppConfig().baseUrl = gatewayUrl;
        if (env.isNotEmpty) AppConfig().environment = env;
        print('📱 Mobile Config Loaded.');
      }

      print(
        '✅ Environment: ${AppConfig().environment} | Gateway: ${AppConfig().baseUrl}',
      );
    } catch (e) {
      print('⚠️ Failed to load config. Using fallback defaults. Error: $e');
    }
  }
}
