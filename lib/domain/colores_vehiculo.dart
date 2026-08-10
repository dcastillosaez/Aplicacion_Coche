/// Paleta de colores habituales de carrocería.
///
/// Se guarda el nombre y el tono. El nombre es editable después de elegir
/// de la paleta: la gente llama a su coche "azul mystery" o "gris quantum",
/// no "azul" a secas, y esos nombres comerciales no caben en una lista.
///
/// El tono se guarda como entero ARGB para que la capa de datos no dependa
/// de Flutter. La interfaz lo convierte a Color donde lo necesita.
library;

class ColorVehiculo {
  final String nombre;

  /// Valor ARGB, del estilo 0xFFRRGGBB.
  final int valor;

  const ColorVehiculo(this.nombre, this.valor);
}

/// Ordenados como se leen en una paleta: primero los acromáticos, que son
/// la gran mayoría del parque, y luego los cromáticos.
const List<ColorVehiculo> coloresVehiculo = [
  ColorVehiculo('Blanco', 0xFFF4F4F2),
  ColorVehiculo('Negro', 0xFF17191C),
  ColorVehiculo('Gris', 0xFF7E8488),
  ColorVehiculo('Gris antracita', 0xFF3B4045),
  ColorVehiculo('Plata', 0xFFC5C8CA),
  ColorVehiculo('Beige', 0xFFC9B99C),
  ColorVehiculo('Marrón', 0xFF6B4A30),
  ColorVehiculo('Rojo', 0xFFB32B23),
  ColorVehiculo('Burdeos', 0xFF5E1F2A),
  ColorVehiculo('Naranja', 0xFFD2691E),
  ColorVehiculo('Amarillo', 0xFFE3B01B),
  ColorVehiculo('Verde', 0xFF1F6B45),
  ColorVehiculo('Verde oliva', 0xFF5A6540),
  ColorVehiculo('Azul claro', 0xFF6E9BD1),
  ColorVehiculo('Azul', 0xFF1F4E9C),
  ColorVehiculo('Azul marino', 0xFF17294E),
  ColorVehiculo('Morado', 0xFF5B3A7E),
  ColorVehiculo('Dorado', 0xFFB39A5F),
];
