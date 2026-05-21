import 'package:flutter_test/flutter_test.dart';
import 'package:jobportal_app/config/app_config.dart';

void main() {
  test('should be a singleton', () {
    final instance1 = AppConfig();
    final instance2 = AppConfig();
    expect(instance1, same(instance2));
  });

  test('should have default values', () {
    final config = AppConfig();
    expect(config.baseUrl, 'http://localhost:3100/api/v1');
    expect(config.environment, 'development');
  });
}
