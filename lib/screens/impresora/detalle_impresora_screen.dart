import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:print_manager/core/app_colors.dart';
import 'package:print_manager/db/DatabaseHelper.dart';
import 'package:print_manager/models/impresora.dart';
import 'package:print_manager/models/reparacion.dart';


class DetalleImpresoraScreen extends StatefulWidget {
  final Impresora impresora; // 👈 guardamos el parámetro

const DetalleImpresoraScreen({super.key, required this.impresora});

  @override
  State<DetalleImpresoraScreen> createState() => _DetalleImpresoraScreenState();
}

class _DetalleImpresoraScreenState extends State<DetalleImpresoraScreen> {
  List<Reparacion> reparaciones = [];
  double costeTotal = 0;

  @override
  void initState() {
    super.initState();
    _loadReparaciones();
  }

  Future<void> _loadReparaciones() async {
    final data = await DatabaseHelper.instance.getReparacionesImpresora(widget.impresora);
    double _coste = 0;
    data.forEach((reparacion) {
      _coste += reparacion.precio;
    });

    setState(() {
      reparaciones = data;
      costeTotal = _coste;
    });
  }

  Future<void> _addOrEditReparacion({Reparacion? reparacion}) async {
    final formatoFecha = DateFormat('dd/MM/yyyy');

    final TextEditingController descripcionCtrl =
    TextEditingController(text: reparacion?.descripcion ?? '');
    final TextEditingController precioCtrl =
    TextEditingController(text: reparacion?.precio.toString() ?? '');
    final TextEditingController fechaCtrl = TextEditingController(
      // 👇 Si hay fecha, la formatea; si no, usa la actual.
      text: reparacion?.fecha != null
          ? formatoFecha.format(reparacion!.fecha)
          : formatoFecha.format(DateTime.now()),
    );

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(reparacion == null ? "Añadir reparación" : "Editar reparación"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: descripcionCtrl,
                decoration: const InputDecoration(labelText: "Descripción"),
              ),
              TextField(
                controller: precioCtrl,
                decoration: const InputDecoration(labelText: "Precio"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: fechaCtrl,
                readOnly: true, // evita escritura manual
                decoration: const InputDecoration(labelText: "Fecha"),
                onTap: () async {
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    locale: const Locale('es', 'ES'),
                  );
                  if (pickedDate != null) {
                    fechaCtrl.text = formatoFecha.format(pickedDate);
                  }
                },
              ),
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
              // ✅ Convierte la fecha del campo a DateTime
              final DateTime fechaFinal = fechaCtrl.text.isNotEmpty
                  ? formatoFecha.parse(fechaCtrl.text)
                  : DateTime.now();

              final nueva = Reparacion(
                id: reparacion?.id ??
                    DateTime.now().millisecondsSinceEpoch.toString(),
                impresoraId: widget.impresora.id,
                precio: double.tryParse(precioCtrl.text) ?? 0,
                descripcion: descripcionCtrl.text,
                fecha: fechaFinal, // 👈 se guarda como DateTime
              );

              await DatabaseHelper.instance.insertReparacion(nueva);
              Navigator.pop(context);
              _loadReparaciones();
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }



  Future<void> _deleteReparacion(String id) async {
    await DatabaseHelper.instance.deleteReparacion(id);
    _loadReparaciones();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.impresora.marca} ${widget.impresora.modelo}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🖼 Imagen de la impresora
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  widget.impresora.imagen,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 🔧 Información básica
            SizedBox(
              width: double.infinity,
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Horas de uso: ${(widget.impresora.horasUso / 60).toInt()}h'),
                      const SizedBox(height: 4),
                      Text('Última impresión: calcular'),
                      const SizedBox(height: 4),
                      Text('Coste total: ${widget.impresora.precio + costeTotal }€'),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 🧰 Título del listado de reparaciones
            const Text(
              'Reparaciones:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // 📋 Listado de reparaciones
            if (reparaciones.isEmpty)
              const Text(
                'No hay reparaciones registradas.',
                style: TextStyle(color: Colors.grey),
              )
            else
              ListView.builder(
                itemCount: reparaciones.length,
                shrinkWrap: true, // ✅ necesario dentro de SingleChildScrollView
                physics: const NeverScrollableScrollPhysics(), // evita doble scroll
                itemBuilder: (context, index) {
                  final rep = reparaciones[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      leading: const Icon(Icons.build, color: Colors.blue),
                      title: Text(rep.descripcion),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text('Fecha: ${rep.fecha}'),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _addOrEditReparacion(),
          backgroundColor: AppColors.secondary,
          shape: const CircleBorder(), // asegura que sea circular
          mini: false,
          child: const Icon(Icons.add, size: 32), // si quieres un botón más pequeño, pon true
        )
    );

  }
}
