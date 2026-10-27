// DATOS — implementación en memoria (los consumos se pierden al cerrar la app).
// Solo los main*.dart la importan: ahí se elige la fuente de datos.

// Importa el contrato que se cumple.
import 'consumo_repository.dart';
// Importa la entidad Consumo.
import '../dominio/consumo.dart';

// Estado persistido: esta lista es la fuente de verdad de los consumos.
class MemoriaConsumoRepository implements ConsumoRepository {
  // Lista privada donde realmente viven los datos.
  final List<Consumo> _consumos = [];

  // Cumple el contrato: agrega el consumo a la lista interna.
  @override
  Future<void> guardar(Consumo consumo) async => _consumos.add(consumo);

  // Cumple el contrato: copia que no se puede modificar, para que nadie altere la fuente por fuera.
  @override
  Future<List<Consumo>> todos() async => List.unmodifiable(_consumos);
}
