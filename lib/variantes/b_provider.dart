// VARIANTE B — provider.
//
// Cableado: ChangeNotifierProvider cuelga el MISMO ConsumosViewModel en el
// árbol. Cada pantalla lo pide con context.watch (para mostrar) y
// context.read (para actuar), sin recibirlo por constructor.
// Lo que no cambia: ConsumosViewModel, ConsumoRepository y las vistas.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../datos/consumo_repository.dart';
import '../presentacion/consumos_view_model.dart';
import '../presentacion/vistas.dart';

// Raíz de la variante B: el provider crea, entrega y libera el ViewModel.
class AppProvider extends StatelessWidget {
  const AppProvider({super.key, required this.repositorio});

  // Fuente de datos que se elige en main.
  final ConsumoRepository repositorio;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // Se crea una vez y trae lo que ya tenía el repositorio.
      create: (_) => ConsumosViewModel(repositorio)..cargar(),
      child: const MaterialApp(
        title: 'EcoTrack · provider',
        home: TresPantallas(
          titulo: 'B · provider',
          registro: RegistroProvider(),
          historial: HistorialProvider(),
          meta: MetaProvider(),
        ),
      ),
    );
  }
}

// Adaptador de Registro: pide el ViewModel al árbol.
class RegistroProvider extends StatelessWidget {
  const RegistroProvider({super.key});

  @override
  Widget build(BuildContext context) {
    // watch: se redibuja cuando el ViewModel avisa.
    final vm = context.watch<ConsumosViewModel>();
    return FormularioRegistro(
      // read: dentro del callback solo se actúa, no se escucha.
      alGuardar: (laboratorio, litros) =>
          context.read<ConsumosViewModel>().guardar(laboratorio, litros),
      error: vm.error,
      guardando: vm.guardando,
    );
  }
}

// Adaptador de Historial.
class HistorialProvider extends StatelessWidget {
  const HistorialProvider({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ConsumosViewModel>();
    return ListaHistorial(consumos: vm.consumos, total: vm.total);
  }
}

// Adaptador de Meta.
class MetaProvider extends StatelessWidget {
  const MetaProvider({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ConsumosViewModel>();
    return PanelMeta(
      total: vm.total,
      meta: vm.meta,
      avance: vm.avance,
      superada: vm.metaSuperada,
      alSubir: () => context.read<ConsumosViewModel>().subirMeta(),
      alBajar: () => context.read<ConsumosViewModel>().bajarMeta(),
    );
  }
}
