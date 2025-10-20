import 'dart:io';

import 'package:flutter/material.dart';
import 'package:print_manager/db/DatabaseHelper.dart';
import 'package:print_manager/models/impresion.dart';
import '../../core/app_colors.dart';
import '../../models/filamento.dart';
import 'add_edit_impresion_screen.dart';

class ImpresionesScreen extends StatefulWidget {
  const ImpresionesScreen({super.key});

  @override
  State<ImpresionesScreen> createState() => _ImpresionesScreenState();
}

class _ImpresionesScreenState extends State<ImpresionesScreen> {
  List<Impresion> impresiones = [];
  List<Filamento> filamentos = [];

  @override
  void initState() {
    super.initState();
    _loadImpresiones();
  }

  Future<void> _loadImpresiones() async {
    final _impresiones = await DatabaseHelper.instance.getImpresiones();
    final _filamentos = await DatabaseHelper.instance.getFilamentos();

    setState(() {
      impresiones = _impresiones;
      filamentos = _filamentos;
    });
  }

  Future<void> _deleteImpresion(String id) async {
    await DatabaseHelper.instance.deleteFilamento(id);
    _loadImpresiones();
  }

  void _goToAddImpresion([Impresion? impresion]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddEditImpresionScreen(impresion: impresion)),
    );
    if (result != null) {
      await DatabaseHelper.instance.insertImpresion(result);
      _loadImpresiones();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: impresiones.isEmpty
          ? const Center(child: Text("No hay impresiones registradas"))
          : ListView.builder(
        itemCount: impresiones.length,
        itemBuilder: (context, index) {
          final i = impresiones[index];
          final f = filamentos.firstWhere((f) => f.id == i.filamentoId);
          return Card(
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 3,
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (i.imagen.isNotEmpty)
                Image.file(
                  File(i.imagen),
                  height: 150,
                  width: 150,
                  fit: BoxFit.cover,
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0,top:4.0,right:4.0,bottom: 4.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child:
                              Text(
                                i.nombre,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.clip,
                                maxLines: 1,
                              ),
                            ),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert),
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _goToAddImpresion(i); // tu metodo
                                } else if (value == 'delete') {
                                  _deleteImpresion(i.id); // tu metodo
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, color: Colors.blue),
                                      SizedBox(width: 8),
                                      Text('Editar'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text('Eliminar'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Text('${f.color} (${f.marca})', style: TextStyle(color: Colors.grey[700], fontSize: 16)),
                        const SizedBox(height: 8),
                            Text('${(i.peso/1000 * f.precio_kg).toStringAsFixed(2)}€', style: TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),

                        Row(
                          children: [
                            const Icon(Icons.access_time, color: Colors.blue, size: 20),
                            const SizedBox(width: 6),
                            Text('${i.tiempo.inMinutes} min', style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.w600)),
                            const SizedBox(width: 6),
                            const Icon(Icons.scale, color: Colors.blue, size: 20),
                            Text('${i.peso} g', style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _goToAddImpresion(),
          backgroundColor: AppColors.secondary,
          shape: const CircleBorder(), // asegura que sea circular
          mini: false,
          child: const Icon(Icons.add, size: 32), // si quieres un botón más pequeño, pon true
        )
    );
  }
}
