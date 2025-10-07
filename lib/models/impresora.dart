class Impresora {
  final String id;
  final String marca;
  final String modelo;
  final double precio;
  final String descripcion;
  final DateTime fechaCompra;
  double horasUso;

  Impresora({
    required this.id,
    required this.marca,
    required this.modelo,
    required this.precio,
    required this.descripcion,
    required this.fechaCompra,
    required this.horasUso,
  });

  factory Impresora.fromJson(Map<String, dynamic> json) {
    return Impresora(
      id: json['id'],
      marca: json['marca'],
      modelo: json['modelo'],
      precio: json['precio'],
      descripcion: json['descripcion'],
      fechaCompra: DateTime.parse(json['fecha_compra']),
      horasUso: json['horas_uso'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'marca': marca,
      'modelo': modelo,
      'precio': precio,
      'descripcion': descripcion,
      'fecha_compra': fechaCompra.toIso8601String(), // Guardamos como String
      'horas_uso': horasUso,
    };
  }
}
