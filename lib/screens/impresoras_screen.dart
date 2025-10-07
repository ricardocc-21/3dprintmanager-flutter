import 'package:flutter/material.dart';
import 'package:print_manager/core/app_colors.dart';
import 'package:print_manager/db/DatabaseHelper.dart';
import 'package:print_manager/models/impresora.dart';



class ImpresorasScreen extends StatefulWidget {
  const ImpresorasScreen({super.key});

  @override
  State<ImpresorasScreen> createState() => _ImpresorasScreenState();
}

class _ImpresorasScreenState extends State<ImpresorasScreen> {
  List<Impresora> impresoras = [];

  @override
  void initState() {
    super.initState();
    _loadImpresoras();
  }

  Future<void> _loadImpresoras() async {
    final data = await DatabaseHelper.instance.getImpresoras();
    setState(() {
      impresoras = data;
    });
  }

  Future<void> _addOrEditImpresora({Impresora? impresora}) async {
    final TextEditingController marcaCtrl =
    TextEditingController(text: impresora?.marca ?? '');
    final TextEditingController modeloCtrl =
    TextEditingController(text: impresora?.modelo ?? '');
    final TextEditingController precioCtrl =
    TextEditingController(text: impresora?.precio.toString() ?? '');
    final TextEditingController descripcionCtrl =
    TextEditingController(text: impresora?.descripcion ?? '');

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(impresora == null ? "Añadir impresora" : "Editar impresora"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: marcaCtrl, decoration: const InputDecoration(labelText: "Marca")),
              TextField(controller: modeloCtrl, decoration: const InputDecoration(labelText: "Modelo")),
              TextField(controller: precioCtrl, decoration: const InputDecoration(labelText: "Precio"), keyboardType: TextInputType.number),
              TextField(controller: descripcionCtrl, decoration: const InputDecoration(labelText: "Descripción")),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              final nueva = Impresora(
                id: impresora?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                marca: marcaCtrl.text,
                modelo: modeloCtrl.text,
                precio: double.tryParse(precioCtrl.text) ?? 0,
                descripcion: descripcionCtrl.text,
                fechaCompra: impresora?.fechaCompra ?? DateTime.now(),
                horasUso: impresora?.horasUso ?? 0,
              );
              await DatabaseHelper.instance.insertImpresora(nueva);
              Navigator.pop(context);
              _loadImpresoras();
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteImpresora(String id) async {
    await DatabaseHelper.instance.deleteImpresora(id);
    _loadImpresoras();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: impresoras.isEmpty
          ? const Center(child: Text("No hay impresoras registradas"))
          : ListView.builder(
        itemCount: impresoras.length,
        itemBuilder: (context, index) {
          final imp = impresoras[index];
          return Card(
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 3,
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/ender3.png',
                  height: 160,
                  width: 140,
                  fit: BoxFit.cover,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${imp.marca} ${imp.modelo}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert),
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _addOrEditImpresora(); // tu método
                                } else if (value == 'delete') {
                                  _deleteImpresora(imp.id); // tu método
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
                        const SizedBox(height: 8),
                        Text('Horas totales: ${imp.horasUso}', style: TextStyle(color: Colors.grey[700], fontSize: 16)),
                        const SizedBox(height: 4),
                        Text('Última impresión: 05/10/2025', style: TextStyle(color: Colors.grey[700], fontSize: 16)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.access_time, color: Colors.blue, size: 20),
                            const SizedBox(width: 6),
                            Text('En uso', style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.w600)),
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
        onPressed: () => _addOrEditImpresora(),
        backgroundColor: AppColors.secondary,
        shape: const CircleBorder(), // asegura que sea circular
        mini: false,
        child: const Icon(Icons.add, size: 32), // si quieres un botón más pequeño, pon true
      )
    );
  }
}
