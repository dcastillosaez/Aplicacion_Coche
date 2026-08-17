import 'package:car_care/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('claro y oscuro se resuelven a su ThemeMode', () {
    expect(AppTheme.modoDesdeTema('claro'), ThemeMode.light);
    expect(AppTheme.modoDesdeTema('oscuro'), ThemeMode.dark);
  });

  test('automatico y cualquier otro valor se resuelven a system', () {
    expect(AppTheme.modoDesdeTema('automatico'), ThemeMode.system);
    expect(AppTheme.modoDesdeTema(null), ThemeMode.system);
    expect(AppTheme.modoDesdeTema('valor-desconocido'), ThemeMode.system);
  });
}
