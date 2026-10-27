// VARIANTE A — ChangeNotifier puro (viene con Flutter).
//
// Cableado: el ViewModel se crea una vez y se pasa por constructor a cada
// pantalla. Cada pantalla lo escucha con ListenableBuilder.
// Costo: con muchas pantallas anidadas hay que pasarlo de mano en mano.

import 'package:flutter/material.dart';

import '../datos/consumo_repository.dart';
import '../presentacion/consumos_view_model.dart';
import '../presentacion/vistas.dart';

// Raíz de la variante A: es la dueña del ViewModel.
class AppChangeNotifier extends StatefulWidget {
  const AppChangeNotifier({super.key, required this.repositorio});

  // Fuente de datos que se elige en main.
  final ConsumoRepository repositorio;

  @override
  State<AppChangeNotifier> createState() => _AppChangeNotifierState();
}

class _AppChangeNotifierState extends State<AppChangeNotifier> {
  // Un solo ViewModel para las tres pantallas.
  late final ConsumosViewModel _vm;

  @override
  void initState() {
    super.initState();
    // Se crea una vez y trae lo que ya tenía el repositorio.
    _vm = ConsumosViewModel(widget.repositorio)..cargar();
  }

  @override
  void dispose() {
    // Quien crea el ViewModel lo libera.
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoTrack · ChangeNotifier',
      home: TresPantallas(
        titulo: 'A · ChangeNotifier',
        registro: RegistroCN(vm: _vm),
        historial: HistorialCN(vm: _vm),
        meta: MetaCN(vm: _vm),
      ),
    );
  }
}

// Adaptador de Registro: recibe el vm por constructor y lo escucha.
class RegistroCN extends StatelessWidget {
  const RegistroCN({super.key, required this.vm});

  final ConsumosViewModel vm;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) => FormularioRegistro(
        alGuardar: vm.guardar,
        error: vm.error,
        guardando: vm.guardando,
      ),
    );
  }
}

// Adaptador de Historial.
class HistorialCN extends StatelessWidget {
  const HistorialCN({super.key, required this.vm});

  final ConsumosViewModel vm;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) =>
          ListaHistorial(consumos: vm.consumos, total: vm.total),
    );
  }
}

// Adaptador de Meta.
class MetaCN extends StatelessWidget {
  const MetaCN({super.key, required this.vm});

  final ConsumosViewModel vm;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) => PanelMeta(
        total: vm.total,
        meta: vm.meta,
        avance: vm.avance,
        superada: vm.metaSuperada,
        alSubir: vm.subirMeta,
        alBajar: vm.bajarMeta,
      ),
    );
  }
}
