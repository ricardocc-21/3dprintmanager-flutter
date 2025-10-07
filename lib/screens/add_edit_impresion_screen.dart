import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/app_colors.dart';
import '../models/impresora.dart';
import '../models/filamento.dart';
import '../models/impresion.dart';
import '../db/DatabaseHelper.dart';

class AddEditImpresionScreen extends StatefulWidget {
  final Impresion? impresion;

  const AddEditImpresionScreen({super.key, this.impresion});

  @override
  State<AddEditImpresionScreen> createState() => _AddEditImpresionScreenState();
}

class _AddEditImpresionScreenState extends State<AddEditImpresionScreen> {
  final _formKey = GlobalKey<FormState>();
  final nombreCtrl = TextEditingController();
  final pesoCtrl = TextEditingController();
  final tiempoCtrl = TextEditingController();
  final fechaCtrl = TextEditingController();

  Impresora? _selectedImpresora;
  Filamento? _selectedFilamento;
  Impresora? _impresora;
  Filamento? _filamento;
  List<Impresora> _impresoras = [];
  List<Filamento> _filamentos = [];

  @override
  void initState() {
    super.initState();
    _loadData();

    if (widget.impresion != null) {

      final i = widget.impresion!;
       _selectedImpresora = _impresora;
       _selectedFilamento = _filamento;
      nombreCtrl.text = i.nombre;
      pesoCtrl.text = i.peso.toString();
      tiempoCtrl.text = i.tiempo.inMinutes.toString();
      fechaCtrl.text = DateFormat('dd/MM/yyyy').format(i.fecha);
    }
  }

  Future<void> _loadData() async {
    final db = DatabaseHelper.instance;
    final impresoras = await db.getImpresoras();
    final filamentos = await db.getFilamentos();

    Impresora? impresoraSeleccionada;
    Filamento? filamentoSeleccionado;

    // Si estás editando, busca los objetos correspondientes
    if (widget.impresion != null) {
      impresoraSeleccionada = impresoras.firstWhere(
            (i) => i.id.toString() == widget.impresion!.impresoraId,
        orElse: () => impresoras.isNotEmpty ? impresoras.first : null as Impresora,
      );
      filamentoSeleccionado = filamentos.firstWhere(
            (f) => f.id.toString() == widget.impresion!.filamentoId,
        orElse: () => filamentos.isNotEmpty ? filamentos.first : null as Filamento,
      );
    }

    setState(() {
      _impresoras = impresoras;
      _filamentos = filamentos;
      _selectedImpresora = impresoraSeleccionada;
      _selectedFilamento = filamentoSeleccionado;
    });
  }

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImpresora == null || _selectedFilamento == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona impresora y filamento')),
      );
      return;
    }

    final nueva = Impresion(
      id: widget.impresion?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      nombre: nombreCtrl.text,
      impresoraId: _selectedImpresora!.id.toString(),
      filamentoId: _selectedFilamento!.id.toString(),
      peso: double.tryParse(pesoCtrl.text) ?? 0,
      tiempo: Duration(minutes: int.tryParse(tiempoCtrl.text) ?? 0),
      fecha: fechaCtrl.text.isNotEmpty
          ? DateFormat('dd/MM/yyyy').parse(fechaCtrl.text)
          : DateTime.now(),
    );

    Navigator.pop(context, nueva);
    DatabaseHelper.instance.calcularUsado(nueva.filamentoId);
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
                  _buildTextField(nombreCtrl, 'Nombre', Icons.title),
                  _buildDropdownImpresora(),
                  _buildDropdownFilamento(),
                  _buildNumberField(pesoCtrl, 'Peso (g)', Icons.scale),
                  _buildNumberField(tiempoCtrl, 'Tiempo (min)', Icons.timer),
                  _buildDateField(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownImpresora() {
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
        validator: (value) => value == null ? 'Selecciona una impresora' : null,
      ),
    );
  }

  Widget _buildDropdownFilamento() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<Filamento>(
        value: _selectedFilamento,
        items: _filamentos.map((f) {
          return DropdownMenuItem(
            value: f,
            child: Text("${f.marca} (${f.material})"),
          );
        }).toList(),
        onChanged: (value) => setState(() => _selectedFilamento = value),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.science, color: AppColors.secondary),
          labelText: 'Filamento',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (value) => value == null ? 'Selecciona un filamento' : null,
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

  Widget _buildTextField(TextEditingController ctrl, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: ctrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
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

  Widget _buildDateField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: fechaCtrl,
        readOnly: true,
        validator: (value) {
          if (value == null || value.isEmpty) return 'Selecciona la fecha';
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
}
