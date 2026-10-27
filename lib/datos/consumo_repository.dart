// DATOS — contrato del repositorio. No conoce Flutter ni pantallas.
// Criterio "Sustitución": el resto de la app solo conoce este contrato.

// Importa la entidad Consumo del dominio.
import '../dominio/consumo.dart';

// Contrato (interfaz): qué se puede hacer con los consumos, no cómo.
abstract class ConsumoRepository {
  // Guarda un consumo; es asíncrono porque una fuente real tardaría (red, disco).
  Future<void> guardar(Consumo consumo);

  // Devuelve todos los consumos guardados.
  Future<List<Consumo>> todos();
}
