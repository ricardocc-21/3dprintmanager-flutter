

class Reparacion {
  final String id;
  final String impresoraId;  // solo guardamos el ID
  final String descripcion;
  final double precio;
  final DateTime fecha;


  Reparacion({
    required this.id,
    required this.impresoraId,
    required this.descripcion,
    required this.precio,
    required this.fecha,
  });

  // Crear desde JSON de la DB
  factory Reparacion.fromJson(Map<String, dynamic> json) {
    return Reparacion(
      id: json['id'],
      impresoraId: json['impresoraId'],
      descripcion: json['descripcion'],
      precio: (json['precio'] as num).toDouble(),
      fecha: DateTime.parse(json['fecha']),
    );
  }

  // Convertir a JSON para insertar/actualizar en DB
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'impresoraId': impresoraId,
      'descripcion': descripcion,
      'precio': precio,
      'fecha': fecha.toIso8601String()
    };
  }
}
