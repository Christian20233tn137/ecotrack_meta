// EcoTrack Meta — la misma app con dos cableados de estado.
//
//   flutter run                                 -> B · provider
//   flutter run -t lib/main_change_notifier.dart -> A · ChangeNotifier
//
// dominio/, datos/, el ViewModel y las vistas son iguales en las dos.
// Lo único que cambia está en lib/variantes/.

import 'package:flutter/material.dart';

import 'datos/memoria_consumo_repository.dart';
import 'variantes/b_provider.dart';

// Aquí, y solo aquí, se elige la fuente de datos.
void main() {
  runApp(AppProvider(repositorio: MemoriaConsumoRepository()));
}
