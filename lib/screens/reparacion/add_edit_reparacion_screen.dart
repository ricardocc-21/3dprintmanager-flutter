import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' show basename;
import 'package:path_provider/path_provider.dart';
import '../../core/app_colors.dart';
import '../../models/impresora.dart';
import '../../models/impresion.dart';
import '../../db/DatabaseHelper.dart';
import '../../models/reparacion.dart';

class AddEditReparacionScreen extends StatefulWidget {
  final Reparacion? impresion;

  const AddEditReparacionScreen({super.key, this.impresion});

  @override
  State<AddEditReparacionScreen> createState() => _AddEditReparacionScreenState();
}

class _AddEditReparacionScreenState extends State<AddEditReparacionScreen> {
  final _formKey = GlobalKey<FormState>();
  final nombreCtrl = TextEditingController();
  final pesoCtrl = TextEditingController();
  final tiempoCtrl = TextEditingController();
  final fechaCtrl = TextEditingController();
  final picker = ImagePicker();


  Impresora? _selectedImpresora;
  Impresora? _impresora;
  List<Impresora> _impresoras = [];
  File? _imagenSeleccionada;


  @override
  void initState() {
    super.initState();
    _loadData();

    if (widget.impresion != null) {

      final i = widget.impresion!;
       _selectedImpresora = _impresora;
      nombreCtrl.text = i.descripcion;
      pesoCtrl.text = i.precio.toString();

      fechaCtrl.text = DateFormat('dd/MM/yyyy').format(i.fecha);
    }
  }

  Future<void> _loadData() async {
    final db = DatabaseHelper.instance;
    final impresoras = await db.getImpresoras();

    Impresora? impresoraSeleccionada;

    // Si estás editando, busca los objetos correspondientes
    if (widget.impresion != null) {
      impresoraSeleccionada = impresoras.firstWhere(
            (i) => i.id.toString() == widget.impresion!.impresoraId,
        orElse: () => impresoras.isNotEmpty ? impresoras.first : null as Impresora,
      );
    }

    setState(() {
      _impresoras = impresoras;
      _selectedImpresora = impresoraSeleccionada;
    });
  }

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImpresora == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona impresora')),
      );
      return;
    }


    final nueva = Reparacion(
      id: widget.impresion?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      descripcion: nombreCtrl.text,
      impresoraId: _selectedImpresora!.id.toString(),
      precio: double.tryParse(pesoCtrl.text) ?? 0,
      fecha: fechaCtrl.text.isNotEmpty
          ? DateFormat('dd/MM/yyyy').parse(fechaCtrl.text)
          : DateTime.now()
    );

    Navigator.pop(context, nueva);
    DatabaseHelper.instance.calcularHoras(nueva.impresoraId);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.impresion == null ? 'Añadir Impresión' : 'Editar Impresión'),
        // backgroundColor: AppColors.backgroundComponent,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _guardar,
        icon: const Icon(Icons.save),
        label: const Text("Guardar"),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    "Datos de la Impresión",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(nombreCtrl, 'Nombre', Icons.title,true),
                  _buildDropdownImpresora(true),
                  _buildNumberField(pesoCtrl, 'Peso (g)', Icons.scale,false),
                  _buildNumberField(tiempoCtrl, 'Tiempo (min)', Icons.timer,false),
                  _buildDateField(false),
                  const SizedBox(height: 20),
                  Column(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          final imagePath = await takePicture();
                          if (imagePath != null) {
                            setState(() {
                              _imagenSeleccionada = File(imagePath);
                            });
                          }
                        },
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Tomar Foto'),
                      ),
                      const SizedBox(height: 16),
                      if (_imagenSeleccionada != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _imagenSeleccionada!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownImpresora(bool require) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<Impresora>(
        value: _selectedImpresora,
        items: _impresoras.map((i) {
          return DropdownMenuItem(
            value: i,
            child: Text(i.marca),
          );
        }).toList(),
        onChanged: (value) => setState(() => _selectedImpresora = value),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.print, color: AppColors.secondary),
          labelText: 'Impresora',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (value) =>
        value == null ? 'Selecciona una impresora' : null,
      ),
    );
  }


  Widget _buildNumberField(TextEditingController ctrl, String label, IconData icon, bool require) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: ctrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        validator: (value) {
          if (require && value!.isEmpty) return 'Campo requerido';
          if (value!.isNotEmpty && double.tryParse(value) == null) return 'Debe ser un número';
          return null;
        },
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppColors.secondary),
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String label, IconData icon, bool require) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: ctrl,
        validator: (value) {
          if ( require && (value == null || value.isEmpty)) return 'Campo requerido';
          return null;
        },
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppColors.secondary),
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildDateField(bool require) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: fechaCtrl,
        readOnly: true,
        validator: (value) {
          if (value == null && require) return 'Selecciona la fecha';
          return null;
        },
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.calendar_today, color: AppColors.secondary),
          labelText: 'Fecha',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onTap: () async {
          final DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
            locale: const Locale('es', 'ES'),
          );
          if (pickedDate != null) {
            fechaCtrl.text = DateFormat('dd/MM/yyyy').format(pickedDate);
          }
        },
      ),
    );
  }

  Future<String?> takePicture() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image == null) return null; // el usuario canceló

    // Guarda la imagen en almacenamiento local permanente
    final Directory appDir = await getApplicationDocumentsDirectory();
    final String fileName = basename(image.path);
    final String savedPath = '${appDir.path}/$fileName';
    final File newImage = await File(image.path).copy(savedPath);

    return newImage.path; // devuelves la ruta local del archivo
  }
}
