import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' show basename;
import 'package:path_provider/path_provider.dart';
import 'package:print_manager/core/app_colors.dart';
import 'package:print_manager/db/DatabaseHelper.dart';
import 'package:print_manager/models/impresora.dart';


class AddEditImpresoraScreen extends StatefulWidget {
  final Impresora? impresora;

  const AddEditImpresoraScreen({super.key, this.impresora});

  @override
  State<AddEditImpresoraScreen> createState() => _AddEditImpresoraScreenState();
}

class _AddEditImpresoraScreenState extends State<AddEditImpresoraScreen> {
  final _formKey = GlobalKey<FormState>();
  final marcaCtrl = TextEditingController();
  final modeloCtrl = TextEditingController();
  final precioCtrl = TextEditingController();
  final descripcionCtrl = TextEditingController();
  final fechaCtrl = TextEditingController();
  final horasUsoCtrl = TextEditingController();
  final pesoCtrl = TextEditingController();
  final tiempoCtrl = TextEditingController();
  final picker = ImagePicker();

  File? _imagenSeleccionada;


  @override
  void initState() {
    super.initState();
    // _loadData();

    if (widget.impresora != null) {

      final i = widget.impresora!;
      marcaCtrl.text = i.marca;
      modeloCtrl.text = i.modelo;
      precioCtrl.text = i.precio.toString();
      descripcionCtrl.text = i.descripcion;
      fechaCtrl.text = DateFormat('dd/MM/yyyy').format(i.fechaCompra);
    }
    if (widget.impresora != null && widget.impresora!.imagen.isNotEmpty) {
      _imagenSeleccionada = File(widget.impresora!.imagen);
    }
  }

  // Future<void> _loadData() async {
  //   final db = DatabaseHelper.instance;
  //   final impresoras = await db.getImpresoras();
  //   final filamentos = await db.getFilamentos();
  //
  //   Impresora? impresoraSeleccionada;
  //   Filamento? filamentoSeleccionado;
  //
  //   // Si estás editando, busca los objetos correspondientes
  //   if (widget.impresora != null) {
  //     impresoraSeleccionada = impresoras.firstWhere(
  //           (i) => i.id.toString() == widget.impresora!.impresoraId,
  //       orElse: () => impresoras.isNotEmpty ? impresoras.first : null as Impresora,
  //     );
  //     filamentoSeleccionado = filamentos.firstWhere(
  //           (f) => f.id.toString() == widget.impresora!.filamentoId,
  //       orElse: () => filamentos.isNotEmpty ? filamentos.first : null as Filamento,
  //     );
  //   }
  //
  //   setState(() {
  //     _impresoras = impresoras;
  //     _filamentos = filamentos;
  //     _selectedImpresora = impresoraSeleccionada;
  //     _selectedFilamento = filamentoSeleccionado;
  //   });
  // }

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;

    final imagenPath = _imagenSeleccionada?.path ?? widget.impresora?.imagen ?? '';


    final nueva = Impresora(
      id: widget.impresora?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      marca: marcaCtrl.text,
      modelo: modeloCtrl.text,
      precio: double.tryParse(precioCtrl.text) ?? 0,
      descripcion: descripcionCtrl.text,
      horasUso: double.tryParse(horasUsoCtrl.text) ?? 0,
      fechaCompra: fechaCtrl.text.isNotEmpty
          ? DateFormat('dd/MM/yyyy').parse(fechaCtrl.text)
          : DateTime.now(),
      imagen: imagenPath,
    );

    Navigator.pop(context, nueva);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.impresora == null ? 'Añadir Impresora' : 'Editar Impresora'),
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
                    "Datos de la Impresora",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(marcaCtrl, 'Marca', Icons.title,true),
                  _buildTextField(modeloCtrl, 'Modelo', Icons.title,true),
                  _buildNumberField(precioCtrl, 'Precio', Icons.euro,false),
                  _buildTextField(descripcionCtrl, 'Descripción', Icons.description,false),
                  _buildNumberField(horasUsoCtrl, 'Horas de uso', Icons.timer,false),
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
    if (fechaCtrl.text.isEmpty) {
      fechaCtrl.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
    }

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
