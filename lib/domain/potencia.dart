/// 1 kW equivale a 1,35962 CV métricos (caballos de vapor, DIN).
const double _kwACvFactor = 1.35962;

/// Convierte kilovatios a CV para mostrar, redondeando al entero más
/// cercano. La potencia se guarda siempre en kW; el CV es solo de
/// presentación y nunca se persiste, para que no puedan desincronizarse.
int kwACv(int kw) => (kw * _kwACvFactor).round();
