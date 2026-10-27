// PRESENTACIÓN — widgets "tontos", compartidos por las dos variantes.
// Reciben datos y callbacks. No conocen el ViewModel, ni datos/, ni quién
// los cablea: así lo único que cambia entre A y B es el cableado.

// Importa los widgets de Material Design.
import 'package:flutter/material.dart';

// Importa Consumo y la lista laboratoriosUtez.
import '../dominio/consumo.dart';

// Formulario para capturar un consumo; Stateful porque guarda estado efímero.
class FormularioRegistro extends StatefulWidget {
  // Constructor: todo lo que necesita llega desde fuera.
  const FormularioRegistro({
    super.key,
    required this.alGuardar,
    required this.error,
    required this.guardando,
  });

  // Callback que recibe laboratorio y litros (como texto) y responde si se guardó.
  final Future<bool> Function(String laboratorio, String litros) alGuardar;
  // Error actual o null.
  final String? error;
  // true mientras se guarda.
  final bool guardando;

  @override
  State<FormularioRegistro> createState() => _FormularioRegistroState();
}

// Estado efímero del formulario: solo le importa a esta pantalla.
class _FormularioRegistroState extends State<FormularioRegistro> {
  // Controlador del campo de litros.
  final _litros = TextEditingController();
  // Laboratorio elegido; inicia con el primero de la lista.
  String _laboratorio = laboratoriosUtez.first;

  @override
  void dispose() {
    // Libera el controlador para no dejar memoria ocupada.
    _litros.dispose();
    super.dispose();
  }

  // Lógica del botón "Guardar".
  Future<void> _guardar() async {
    // Pide al gestor que guarde y espera el resultado.
    final ok = await widget.alGuardar(_laboratorio, _litros.text);
    // Si no se guardó o la pantalla ya no existe, no hace nada más.
    if (!ok || !mounted) return;
    _litros.clear();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Consumo guardado')));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Selector de laboratorio: el cambio es estado efímero (setState).
        DropdownButtonFormField<String>(
          initialValue: _laboratorio,
          decoration: const InputDecoration(labelText: 'Laboratorio'),
          items: [
            for (final lab in laboratoriosUtez)
              DropdownMenuItem(value: lab, child: Text(lab)),
          ],
          onChanged: (lab) => setState(() => _laboratorio = lab!),
        ),
        // Campo de litros; la clave la usan las pruebas.
        TextField(
          key: const Key('litros'),
          controller: _litros,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          // El error llega del ViewModel (regla del dominio).
          decoration: InputDecoration(
            labelText: 'Litros',
            errorText: widget.error,
          ),
        ),
        const SizedBox(height: 16),
        // null desactiva el botón mientras se guarda.
        FilledButton(
          onPressed: widget.guardando ? null : _guardar,
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}

// Lista de consumos con el total que le pasan; no guarda nada propio.
class ListaHistorial extends StatelessWidget {
  const ListaHistorial({super.key, required this.consumos, required this.total});

  // Consumos que llegan del gestor de estado.
  final List<Consumo> consumos;
  // Total ya calculado por el ViewModel (estado derivado).
  final double total;

  @override
  Widget build(BuildContext context) {
    if (consumos.isEmpty) {
      return const Center(child: Text('Sin consumos'));
    }
    return ListView(
      children: [
        ListTile(
          title: Text('Total: ${total.toStringAsFixed(1)} L'),
          tileColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        for (final c in consumos)
          ListTile(
            leading: const Icon(Icons.water_drop),
            title: Text('${c.litros} L'),
            subtitle: Text(c.laboratorio),
          ),
      ],
    );
  }
}

// Pantalla de la meta semanal: muestra el avance y ofrece subir o bajar la meta.
class PanelMeta extends StatelessWidget {
  const PanelMeta({
    super.key,
    required this.total,
    required this.meta,
    required this.avance,
    required this.superada,
    required this.alSubir,
    required this.alBajar,
  });

  // Litros usados en la semana.
  final double total;
  // Meta actual en litros.
  final double meta;
  // Fracción usada, entre 0 y 1.
  final double avance;
  // true si el total ya rebasó la meta.
  final bool superada;
  // Acción del botón "+".
  final VoidCallback alSubir;
  // Acción del botón "−".
  final VoidCallback alBajar;

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Usado: ${total.toStringAsFixed(1)} de ${meta.toStringAsFixed(1)} L',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: avance,
          color: superada ? colores.error : colores.primary,
        ),
        const SizedBox(height: 12),
        // Aviso que cambia según el estado derivado metaSuperada.
        Text(
          superada ? 'Te pasaste de la meta' : 'Dentro de la meta',
          style: TextStyle(color: superada ? colores.error : colores.primary),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton.outlined(
              key: const Key('bajarMeta'),
              onPressed: alBajar,
              icon: const Icon(Icons.remove),
            ),
            const SizedBox(width: 24),
            IconButton.outlined(
              key: const Key('subirMeta'),
              onPressed: alSubir,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ],
    );
  }
}

/// Tres pestañas: Registro, Historial y Meta. Es el escenario del criterio
/// "Dato compartido": lo que se guarda en una debe verse en las otras.
class TresPantallas extends StatefulWidget {
  const TresPantallas({
    super.key,
    required this.titulo,
    required this.registro,
    required this.historial,
    required this.meta,
  });

  // Título de la AppBar (nombre de la variante).
  final String titulo;
  // Vistas ya cableadas a su gestor de estado.
  final Widget registro;
  final Widget historial;
  final Widget meta;

  @override
  State<TresPantallas> createState() => _TresPantallasState();
}

// Estado efímero: qué pestaña está activa.
class _TresPantallasState extends State<TresPantallas> {
  int _indice = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.titulo)),
      // IndexedStack mantiene montadas las tres vistas y solo muestra una.
      body: IndexedStack(
        index: _indice,
        children: [widget.registro, widget.historial, widget.meta],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indice,
        onDestinationSelected: (i) => setState(() => _indice = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.add), label: 'Registro'),
          NavigationDestination(icon: Icon(Icons.history), label: 'Historial'),
          NavigationDestination(icon: Icon(Icons.flag), label: 'Meta'),
        ],
      ),
    );
  }
}
