import 'package:flutter/material.dart';
import 'package:print_manager/db/DatabaseHelper.dart';
import 'package:print_manager/models/filamento.dart';
import 'add_edit_filamento_screen.dart';
import '../../core/app_colors.dart';

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

  void _marcarDisponible(Filamento filamento) async {
    filamento.disponible == 1 ? filamento.disponible = 0 : filamento.disponible = 1;
    await DatabaseHelper.instance.insertFilamento(filamento);
    _loadFilamentos();
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
                return Opacity(
                  opacity: f.disponible == 0 ? 0.5 : 1.0, // 50% transparente si no disponible
                  child: Card(
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
                        Expanded(
                          flex: 1,
                          child: Image.network(
                            f.enlace_imagen,
                            fit: BoxFit.cover,
                            color: f.disponible == 0 ? Colors.grey : null, // atenuar la imagen
                            colorBlendMode: f.disponible == 0 ? BlendMode.saturation : null,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${f.marca} ${f.color}',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: f.disponible == 0 ? Colors.grey : Colors.black,
                                        ),
                                        overflow: TextOverflow.clip,
                                        maxLines: 1,
                                      ),
                                    ),
                                    PopupMenuButton<String>(
                                      icon: const Icon(Icons.more_vert),
                                      onSelected: (value) {
                                        if (value == 'disponible') {
                                          _marcarDisponible(f);
                                        } else if (value == 'edit') {
                                          _goToAddFilamento(f);
                                        } else if (value == 'delete') {
                                          _deleteFilamento(f.id);
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        PopupMenuItem(
                                          value: 'disponible',
                                          child: Row(
                                            children: [

                                              if (f.disponible == 0)
                                                const Icon(Icons.check_circle, color: Colors.green)
                                              else
                                                const Icon(Icons.close_rounded, color: Colors.red),

                                              const SizedBox(width: 8),
                                              Text(f.disponible == 0 ? 'Disponible' : 'No disponible'),
                                            ],
                                          ),
                                        ),
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
                                const SizedBox(height: 6),
                                Text(
                                  f.material.toUpperCase(),
                                  style: TextStyle(
                                    color: f.disponible == 0 ? Colors.grey : Colors.grey[700],
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${f.precio_kg}€/kg',
                                  style: TextStyle(
                                    color: f.disponible == 0 ? Colors.grey : Colors.grey[700],
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Disponible: ${f.restante}g',
                                  style: TextStyle(
                                    color: f.disponible == 0 ? Colors.grey : Colors.grey[700],
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                LinearProgressIndicator(
                                  value: (100 - f.porcentaje_usado) / 100,
                                  minHeight: 10,
                                  backgroundColor: Colors.grey[300],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    f.disponible == 0
                                        ? Colors.grey
                                        : 100 - f.porcentaje_usado > 60
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
