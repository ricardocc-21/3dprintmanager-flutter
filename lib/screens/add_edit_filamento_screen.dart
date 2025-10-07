import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/app_colors.dart';
import '../models/filamento.dart';

class AddEditFilamentoScreen extends StatefulWidget {
  final Filamento? filamento;

  const AddEditFilamentoScreen({super.key, this.filamento});

  @override
  State<AddEditFilamentoScreen> createState() => _AddEditFilamentoScreenState();
}

class _AddEditFilamentoScreenState extends State<AddEditFilamentoScreen> {
  final _formKey = GlobalKey<FormState>();
  final marcaCtrl = TextEditingController();
  final materialCtrl = TextEditingController();
  final colorCtrl = TextEditingController();
  final pesoCtrl = TextEditingController();
  final precioCtrl = TextEditingController();
  final diametroCtrl = TextEditingController();
  final enlaceCompraCtrl = TextEditingController();
  final enlaceImagenCtrl = TextEditingController();
  final fechaCompraCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.filamento != null) {
      final f = widget.filamento!;
      marcaCtrl.text = f.marca;
      materialCtrl.text = f.material;
      colorCtrl.text = f.color;
      pesoCtrl.text = f.peso.toString();
      precioCtrl.text = f.precio.toString();
      diametroCtrl.text = f.diametro.toString();
      enlaceCompraCtrl.text = f.enlace_compra;
      enlaceImagenCtrl.text = f.enlace_imagen;
      fechaCompraCtrl.text = DateFormat('dd/MM/yyyy').format(f.fecha_compra);
    }
  }

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;

    final nueva = Filamento(
      id: widget.filamento?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      marca: marcaCtrl.text,
      material: materialCtrl.text,
      color: colorCtrl.text,
      peso: double.tryParse(pesoCtrl.text) ?? 0,
      precio: double.tryParse(precioCtrl.text) ?? 0,
      diametro: double.tryParse(diametroCtrl.text) ?? 0,
      disponible: 1,
      enlace_compra: enlaceCompraCtrl.text,
      enlace_imagen: enlaceImagenCtrl.text,
      fecha_compra: fechaCompraCtrl.text.isNotEmpty
          ? DateFormat('dd/MM/yyyy').parse(fechaCompraCtrl.text)
          : DateTime.now(),
      descripcion: widget.filamento?.descripcion ?? '',
      usado: widget.filamento?.usado ?? 0,
      restante: widget.filamento?.restante ?? 0,
      porcentaje_usado: widget.filamento?.porcentaje_usado ?? 0,
      precio_kg: (double.tryParse(precioCtrl.text) ?? 0) /
          ((double.tryParse(pesoCtrl.text) ?? 1) / 1000),
    );

    Navigator.pop(context, nueva);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.filamento == null ? 'Añadir Filamento' : 'Editar Filamento'),
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
                    "Datos del Filamento",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(marcaCtrl, 'Marca', Icons.factory),
                  _buildTextField(materialCtrl, 'Material', Icons.science),
                  _buildTextField(colorCtrl, 'Color', Icons.color_lens),
                  _buildNumberField(pesoCtrl, 'Peso (g)', Icons.scale),
                  _buildNumberField(precioCtrl, 'Precio (€)', Icons.euro),
                  _buildNumberField(diametroCtrl, 'Diámetro (mm)', Icons.circle),
                  _buildTextField(enlaceCompraCtrl, 'Enlace de compra', Icons.link),
                  _buildTextField(enlaceImagenCtrl, 'Enlace de imagen', Icons.image_outlined),
                  _buildDateField(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: ctrl,
        validator: (value) {
          if (value == null || value.isEmpty) return 'Campo requerido';
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

  Widget _buildNumberField(TextEditingController ctrl, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: ctrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        validator: (value) {
          if (value == null || value.isEmpty) return 'Campo requerido';
          if (double.tryParse(value) == null) return 'Debe ser un número';
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

  Widget _buildDateField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: fechaCompraCtrl,
        readOnly: true,
        validator: (value) {
          if (value == null || value.isEmpty) return 'Selecciona la fecha';
          return null;
        },
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.calendar_today, color: Colors.deepOrange),
          labelText: 'Fecha de compra',
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
            fechaCompraCtrl.text = DateFormat('dd/MM/yyyy').format(pickedDate);
          }
        },
      ),
    );
  }
}
