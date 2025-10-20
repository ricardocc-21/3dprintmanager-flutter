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
  String fechaUltimaImpresion = '';

  @override
  void initState() {
    super.initState();
    _loadReparaciones();
  }

  Future<void> _loadReparaciones() async {
    final data = await DatabaseHelper.instance.getReparacionesImpresora(
      widget.impresora,
    );
    double _coste = 0;
    data.forEach((reparacion) {
      _coste += reparacion.precio;
    });
    String _fecha = await widget.impresora.getFechaUltimaImpresion();

    setState(() {
      reparaciones = data;
      costeTotal = _coste;
      fechaUltimaImpresion =_fecha;
    });
  }

  Future<void> _addOrEditReparacion({Reparacion? reparacion}) async {
    final formatoFecha = DateFormat('dd/MM/yyyy');

    final TextEditingController descripcionCtrl = TextEditingController(
      text: reparacion?.descripcion ?? '',
    );
    final TextEditingController precioCtrl = TextEditingController(
      text: reparacion?.precio.toString() ?? '',
    );
    final TextEditingController fechaCtrl = TextEditingController(
      // 👇 Si hay fecha, la formatea; si no, usa la actual.
      text: reparacion?.fecha != null
          ? formatoFecha.format(reparacion!.fecha)
          : formatoFecha.format(DateTime.now()),
    );

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          reparacion == null ? "Añadir reparación" : "Editar reparación",
        ),
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
                id:
                    reparacion?.id ??
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Horas de uso: ${(widget.impresora.horasUso / 60).toInt()}h',
                      ),
                      const SizedBox(height: 4),
                      Text('Última impresión: $fechaUltimaImpresion'),
                      const SizedBox(height: 4),
                      Text(
                        'Coste total: ${widget.impresora.precio + costeTotal}€',
                      ),
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
                shrinkWrap: true,
                // ✅ necesario dentro de SingleChildScrollView
                physics: const NeverScrollableScrollPhysics(),
                // evita doble scroll
                itemBuilder: (context, index) {
                  final rep = reparaciones[index];
                  return Dismissible(
                    key: ValueKey(rep.id),
                    // cada elemento debe tener una key única
                    direction: DismissDirection.endToStart,
                    // solo permite swipe a la derecha
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    confirmDismiss: (direction) async {
                      // Mostrar diálogo de confirmación
                      final bool? confirm = await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Confirmar eliminación'),
                          content: const Text(
                            '¿Seguro que quieres eliminar esta reparación?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              // cancelar
                              child: const Text('Cancelar'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              // confirmar
                              child: const Text('Eliminar'),
                            ),
                          ],
                        ),
                      );

                      return confirm ??
                          false; // si el usuario cierra el diálogo sin elegir, no se elimina
                    },
                    onDismissed: (direction) async {
                      // Acción al deslizar (eliminar)
                      _deleteReparacion(rep.id);
                      // await DatabaseHelper.instance.deleteReparacion(rep.id);
                      // setState(() {
                      //   reparaciones.removeAt(index); // actualiza la lista
                      // });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Reparación eliminada')),
                      );
                    },
                    child: InkWell(
                      onTap: () => _addOrEditReparacion(reparacion: rep),
                      child: Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),

                        child: ListTile(
                          leading: const Icon(Icons.build, color: Colors.blue),
                          title: Text(rep.descripcion),
                          subtitle: Text(
                            // 👈 fecha en formato dd/MM/yyyy
                            DateFormat('dd/MM/yyyy').format(rep.fecha),
                            style: const TextStyle(color: Colors.grey),
                          ),
                          trailing: Text(
                            '${rep.precio.toStringAsFixed(2)}€',
                            style: const TextStyle(
                              fontSize: 20, // 👈 grande
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ),
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
