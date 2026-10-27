// DOMINIO — reglas de la meta semanal, en Dart puro.

// Meta con la que arranca la semana, en litros.
const metaInicial = 100.0;
// Cuánto sube o baja la meta con cada botón.
const pasoMeta = 10.0;
// La meta nunca puede quedar por debajo de este valor.
const metaMinima = 10.0;

// Regla: aplica el cambio a la meta sin bajar de metaMinima.
double ajustarMeta(double meta, double cambio) {
  // Suma el cambio (positivo sube, negativo baja).
  final nueva = meta + cambio;
  // Si quedó por debajo del mínimo, se queda en el mínimo.
  return nueva < metaMinima ? metaMinima : nueva;
}

// Regla: fracción de la meta ya usada, siempre entre 0 y 1.
double avanceDeMeta({required double total, required double meta}) {
  // clamp recorta el resultado; toDouble porque clamp devuelve num.
  return (total / meta).clamp(0, 1).toDouble();
}
