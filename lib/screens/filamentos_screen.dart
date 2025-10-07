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
      MaterialPageRoute(
        builder: (_) => AddEditFilamentoScreen(filamento: filamento),
      ),
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
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      if (!f.enlace_imagen.isEmpty)
                      Image.network(
                        f.enlace_imagen,
                        height: 140,
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${f.marca} ${f.color}',
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
                                        _goToAddFilamento(f); // tu metodo
                                      } else if (value == 'delete') {
                                        _deleteFilamento(f.id); // tu metodo
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.edit,
                                              color: Colors.blue,
                                            ),
                                            SizedBox(width: 8),
                                            Text('Editar'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
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
                              Text(
                                f.material.toUpperCase(),
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${f.precio_kg}€/kg',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Disponible: ${f.restante}g',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 12),
                              LinearProgressIndicator(
                                value: (100 - f.porcentaje_usado)/ 100,
                                // Convierte a 0–1
                                minHeight: 10,
                                backgroundColor: Colors.grey[300],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  100 - f.porcentaje_usado > 60
                                      ? Colors.green
                                      : 100 - f.porcentaje_usado < 25
                                      ? Colors.red
                                      : Colors.orange,
                                ),
                                borderRadius: BorderRadius.circular(10),
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
        onPressed: () => _goToAddFilamento(),
        backgroundColor: AppColors.secondary,
        shape: const CircleBorder(),
        // asegura que sea circular
        mini: false,
        child: const Icon(
          Icons.add,
          size: 32,
        ), // si quieres un botón más pequeño, pon true
      ),
    );
  }
}
