import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:print_manager/models/filamento.dart';
import 'app_colors.dart';

class Commons{


  static Widget buildTextField(TextEditingController ctrl, String label, IconData icon, bool require, String valorInicial) {
    if (valorInicial != "") {
      ctrl.text = valorInicial;
    }
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

  static Widget buildNumberField(TextEditingController ctrl, String label, IconData icon, bool require,double? valorInicial) {
    if (valorInicial != null && valorInicial != 0) {
      ctrl.text = valorInicial.toString();
    }
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

  static Widget buildDateField(BuildContext context,TextEditingController ctrl, String label,bool require) {
    if (ctrl.text.isEmpty) {
       ctrl.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: ctrl,
        readOnly: true,
        validator: (value) {
          if (value == null && require) return 'Selecciona la fecha';
          return null;
        },
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.calendar_today, color: AppColors.secondary),
          labelText: label,
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
            ctrl.text = DateFormat('dd/MM/yyyy').format(pickedDate);
          }
        },
      ),
    );
  }


  static Future<String?> takePicture() async {
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