import 'dart:convert';

import 'filamento.dart';
import 'impresora.dart';

class Impresion {
  final String id;
  final String nombre;
  final String impresora;
  final String filamento;
  final double peso;
  final Duration tiempo;
  final DateTime fecha;


  Impresion({
    required this.id,
    required this.nombre,
    required this.impresora,
    required this.filamento,
    required this.peso,
    required this.tiempo,
    required this.fecha,
  });

  factory Impresion.fromJson(Map<String, dynamic> json) {
    // si tienes los objetos anidados
    Impresora? impresora;
    Filamento? filamento;

    final impresoraData = json['impresora'];
    if (impresoraData != null) {
      impresora = impresoraData is String
          ? Impresora.fromJson(jsonDecode(impresoraData))
          : Impresora.fromJson(impresoraData);
    }

    final filamentoData = json['filamento'];
    if (filamentoData != null) {
      filamento = filamentoData is String
          ? Filamento.fromJson(jsonDecode(filamentoData))
          : Filamento.fromJson(filamentoData);
    }

    return Impresion(
      id: json['id'],
      nombre: (json['nombre'] as String).isNotEmpty ? json['nombre'] : '',
      impresora: json['impresora'], // 👈 ahora tomas solo el id
      filamento: json['filamento'], // 👈 idem
      peso: (json['peso'] as num).toDouble(),
      tiempo: Duration(seconds: json['tiempo']),
      fecha: DateTime.parse(json['fecha']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'impresora': impresora,
      'filamento': filamento,
      'peso': peso,
      'tiempo': tiempo.inSeconds,
      'fecha': fecha.toIso8601String(),
    };
  }
}
