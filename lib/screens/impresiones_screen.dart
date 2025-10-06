import 'package:flutter/material.dart';
import 'package:print_manager/db/DatabaseHelper.dart';
import 'package:print_manager/models/impresion.dart';
import '../core/app_colors.dart';
import 'add_edit_impresion_screen.dart';

class ImpresionesScreen extends StatefulWidget {
  const ImpresionesScreen({super.key});

  @override
  State<ImpresionesScreen> createState() => _ImpresionesScreenState();
}

class _ImpresionesScreenState extends State<ImpresionesScreen> {
  List<Impresion> impresiones = [];

  @override
  void initState() {
    super.initState();
    _loadImpresiones();
  }

  Future<void> _loadImpresiones() async {
    final data = await DatabaseHelper.instance.getImpresiones();
    setState(() {
      impresiones = data;
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
          return Card(
            margin: const EdgeInsets.all(8),
            elevation: 4,
            child: ListTile(
              title: Text("${i.nombre} - ${i.tiempo}"),
              subtitle: Text("Subtitulo"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _goToAddImpresion(i),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteImpresion(i.id.toString()),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _goToAddImpresion(),
        child: const Icon(Icons.add),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}
