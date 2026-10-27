// Variante A — ChangeNotifier puro:
//   flutter run -t lib/main_change_notifier.dart

import 'package:flutter/material.dart';

import 'datos/memoria_consumo_repository.dart';
import 'variantes/a_change_notifier.dart';

// Aquí, y solo aquí, se elige la fuente de datos.
void main() {
  runApp(AppChangeNotifier(repositorio: MemoriaConsumoRepository()));
}
