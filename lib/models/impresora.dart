import 'package:print_manager/db/DatabaseHelper.dart';

import 'impresion.dart';

class Impresora {
  final String id;
  final String marca;
  final String modelo;
  final double precio;
  final String descripcion;
  final DateTime fechaCompra;
  double horasUso;
  String imagen;

  Impresora({
    required this.id,
    required this.marca,
    required this.modelo,
    required this.precio,
    required this.descripcion,
    required this.fechaCompra,
    required this.horasUso,
    required this.imagen
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
      imagen: json['imagen'],
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
      'imagen': imagen,
    };
  }


  Future<String> getFechaUltimaImpresion() async {
    final DateTime fechaActual = DateTime.now();
    final Impresion impresion = await DatabaseHelper.instance.getUltimaImpresion(this);
    final DateTime fechaImpresion = impresion.fecha;
    final Duration diferencia = fechaActual.difference(fechaImpresion);
    final int dias = diferencia.inDays;
    final int horas = diferencia.inHours % 24;
    final int minutos = diferencia.inMinutes % 60;
    final int segundos = diferencia.inSeconds % 60;

    if (dias > 0) {
      return '$dias días';
    } else if (horas > 0) {
      return '$horas horas y $minutos minutos';
    } else if (minutos > 0) {
      return '$minutos minutos y $segundos segundos';
    } else {
      return '$segundos segundos';
    }
  }

}

