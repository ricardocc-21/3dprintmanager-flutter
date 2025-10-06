import 'package:flutter/material.dart';
import 'package:print_manager/db/DatabaseHelper.dart';
import 'package:print_manager/models/filamento.dart';
import 'add_edit_filamento_screen.dart';
import '../core/app_colors.dart';

class FilamentosScreen extends StatefulWidget {
  const FilamentosScreen({super.key});

  @override
  State<FilamentosScreen> createState() => _FilamentosScreenState();
}

class _FilamentosScreenState extends State<FilamentosScreen> {
  List<Filamento> filamentos = [];

  @override
  void initState() {
    super.initState();
    _loadFilamentos();
  }

  Future<void> _loadFilamentos() async {
    final data = await DatabaseHelper.instance.getFilamentos();
    setState(() {
      filamentos = data;
    });
  }

  Future<void> _deleteFilamento(String id) async {
    await DatabaseHelper.instance.deleteFilamento(id);
    _loadFilamentos();
  }

  void _goToAddFilamento([Filamento? filamento]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddEditFilamentoScreen(filamento: filamento)),
    );
    if (result != null) {
      await DatabaseHelper.instance.insertFilamento(result);
      _loadFilamentos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: filamentos.isEmpty
          ? const Center(child: Text("No hay filamentos registrados"))
          : ListView.builder(
        itemCount: filamentos.length,
        itemBuilder: (context, index) {
          final f = filamentos[index];
          return Card(
            margin: const EdgeInsets.all(8),
            elevation: 4,
            child: ListTile(
              title: Text("${f.marca} - ${f.color}"),
              subtitle: Text("Precio: €${f.precio.toStringAsFixed(2)} - Restante: ${f.restante}g"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _goToAddFilamento(f),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteFilamento(f.id),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _goToAddFilamento(),
        child: const Icon(Icons.add),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}
