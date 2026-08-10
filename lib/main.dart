import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'data/photo_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PhotoStorage.inicializar();
  runApp(const ProviderScope(child: CarCareApp()));
}
