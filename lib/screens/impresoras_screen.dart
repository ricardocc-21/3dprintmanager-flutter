import 'package:flutter/material.dart';
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
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: Text("${imp.marca} ${imp.modelo}"),
              subtitle:Text('${(imp.horasUso/60).toStringAsFixed(1)}h'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _addOrEditImpresora(impresora: imp),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteImpresora(imp.id),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditImpresora(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
