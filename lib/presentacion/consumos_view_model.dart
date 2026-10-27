// PRESENTACIÓN — ViewModel con ChangeNotifier (patrón Observer).
// Es el dueño del estado compartido. No dibuja y no sabe quién lo entrega
// a las pantallas: la variante A y la variante B usan esta misma clase.

// Importa ChangeNotifier (viene con Flutter, sin paquetes extra ni widgets).
import 'package:flutter/foundation.dart';

// Importa el contrato del repositorio (no la implementación concreta).
import '../datos/consumo_repository.dart';
// Importa Consumo y la regla validarLitros.
import '../dominio/consumo.dart';
// Importa las constantes y reglas de la meta.
import '../dominio/meta.dart';

// ViewModel: extiende ChangeNotifier para poder avisar cuando cambia el estado.
class ConsumosViewModel extends ChangeNotifier {
  // Recibe el repositorio desde fuera (inyección de dependencias).
  ConsumosViewModel(this._repositorio);

  // Repositorio con el que se guardan y leen los consumos.
  final ConsumoRepository _repositorio;

  // Estado compartido: lo ven Registro, Historial y Meta.
  List<Consumo> consumos = [];
  // Mensaje de error de validación (null si no hay error).
  String? error;
  // true mientras se está guardando (la vista desactiva el botón).
  bool guardando = false;
  // Meta semanal en litros; se cambia con subirMeta y bajarMeta.
  double meta = metaInicial;

  // Estado derivado: se calcula a partir de consumos, no se guarda.
  double get total => consumos.fold<double>(0, (suma, c) => suma + c.litros);
  // Estado derivado: fracción de la meta usada, entre 0 y 1.
  double get avance => avanceDeMeta(total: total, meta: meta);
  // Estado derivado: true solo si el total rebasa la meta.
  bool get metaSuperada => total > meta;

  // Trae lo que ya tenía el repositorio (la fuente de verdad) y avisa.
  Future<void> cargar() async {
    consumos = await _repositorio.todos();
    notifyListeners();
  }

  // Acción que llama la vista al tocar "Guardar"; devuelve true si se guardó.
  Future<bool> guardar(String laboratorio, String litrosTexto) async {
    // Quita espacios, cambia coma por punto y convierte a double (null si no es número).
    final litros = double.tryParse(litrosTexto.trim().replaceAll(',', '.'));
    // Aplica la regla del dominio; motivo trae el mensaje de error o null.
    final motivo = validarLitros(litros);
    // Si la regla encontró un problema, se muestra el error y no se guarda.
    if (motivo != null) {
      error = motivo;
      notifyListeners();
      return false;
    }

    // Avisa "estoy guardando" y limpia el error anterior.
    guardando = true;
    error = null;
    notifyListeners();

    // Guarda en el repositorio; litros! afirma que ya no es null.
    await _repositorio.guardar(
      Consumo(laboratorio: laboratorio, litros: litros!),
    );
    // Vuelve a leer la lista completa desde la fuente de verdad.
    consumos = await _repositorio.todos();

    // Avisa "ya terminé": Historial y Meta se redibujan.
    guardando = false;
    notifyListeners();
    return true;
  }

  // Sube la meta un paso y avisa.
  void subirMeta() {
    meta = ajustarMeta(meta, pasoMeta);
    notifyListeners();
  }

  // Baja la meta un paso (sin pasar de metaMinima) y avisa.
  void bajarMeta() {
    meta = ajustarMeta(meta, -pasoMeta);
    notifyListeners();
  }
}
