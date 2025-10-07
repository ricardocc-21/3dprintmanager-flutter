import 'filamento.dart';
import 'impresora.dart';

class Impresion {
  final String id;
  final String nombre;
  final String impresoraId;  // solo guardamos el ID
  final String filamentoId;  // solo guardamos el ID
  final double peso;
  final Duration tiempo;
  final DateTime fecha;
  String imagen;

  // Opcional: objetos completos solo si los quieres cargar
  Impresora? impresora;
  Filamento? filamento;

  Impresion({
    required this.id,
    required this.nombre,
    required this.impresoraId,
    required this.filamentoId,
    required this.peso,
    required this.tiempo,
    required this.fecha,
    required this.imagen,

    this.impresora,
    this.filamento,
  });

  // Crear desde JSON de la DB
  factory Impresion.fromJson(Map<String, dynamic> json) {
    return Impresion(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      impresoraId: json['impresoraId'],
      filamentoId: json['filamentoId'],
      peso: (json['peso'] as num).toDouble(),
      tiempo: Duration(minutes: (json['tiempo'] as num).toInt()),
      fecha: DateTime.parse(json['fecha']),
      imagen: json['imagen'] ?? '',
    );
  }

  // Convertir a JSON para insertar/actualizar en DB
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'impresoraId': impresoraId,
      'filamentoId': filamentoId,
      'peso': peso,
      'tiempo': tiempo.inMinutes,
      'fecha': fecha.toIso8601String(),
      'imagen': imagen,
    };
  }
}
