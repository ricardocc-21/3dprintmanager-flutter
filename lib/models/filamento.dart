class Filamento {
  final String id;
  final String marca;
  final String material;
  final String color;
  final double peso;
  final double precio;
  final double precio_kg;
  final double diametro;
  final String descripcion;
  final DateTime fecha_compra;
  final String enlace_compra;
  final String enlace_imagen;
  double usado;
  double restante;
  int disponible;
  double porcentaje_usado;


  Filamento({
    required this.id,
    required this.marca,
    required this.material,
    required this.color,
    required this.peso,
    required this.precio,
    required this.precio_kg,
    required this.diametro,
    required this.descripcion,
    required this.fecha_compra,
    required this.enlace_compra,
    required this.enlace_imagen,
    required this.usado,
    required this.restante,
    required this.disponible,
    required this.porcentaje_usado,
  });

  factory Filamento.fromJson(Map<String, dynamic> json) {
    return Filamento(
      id: json['id'],
      marca: json['marca'],
      material: json['material'],
      color: json['color'],
      peso: json['peso'],
      precio: (json['precio'] as num?)?.toDouble() ?? 0.0,
      precio_kg: (json['precio_kg'] as num?)?.toDouble() ?? 0.0,
      diametro: (json['diametro'] as num?)?.toDouble() ?? 0.0,
      descripcion: json['descripcion'],
      fecha_compra: DateTime.parse(json['fecha_compra']),
      enlace_compra: json['enlace_compra'],
      enlace_imagen: json['enlace_imagen'],
      usado: json['usado'],
      restante: json['restante'],
      disponible: json['disponible'],
      porcentaje_usado: (json['porcentaje_usado'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'marca': marca,
      'material': material,
      'color': color,
      'peso': peso,
      'precio': precio,
      'precio_kg': precio_kg,
      'diametro': diametro,
      'descripcion': descripcion,
      'fecha_compra': fecha_compra.toIso8601String(), // Guardamos como String
      'enlace_compra': enlace_compra,
      'enlace_imagen': enlace_imagen,
      'usado': usado,
      'restante': restante,
      'disponible': disponible,
      'porcentaje_usado': porcentaje_usado,
    };
  }
}
