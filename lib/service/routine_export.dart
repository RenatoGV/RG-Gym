import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rg_gym/models/routine.dart';
import 'package:share_plus/share_plus.dart';

class RoutineExport {
  static Future<void> exportRoutines(List<Routine> routines) async {
    final json = jsonEncode(
      routines.map((routine) => routine.toJson()).toList()
    );

    final directory = await getTemporaryDirectory();

    final file = File('${directory.path}/rg_gym_routines.json');

    await file.writeAsString(json);

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Rutinas de RG Gym'
    );
  }

  static Future<List<Routine>?> importRoutines() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: true,
    );

    if (result == null) {
      return null;
    }

    final file = result.files.first;

    String json;

    if (file.bytes != null) {
      json = utf8.decode(file.bytes!);
    } else if (file.path != null) {
      json = await File(file.path!).readAsString();
    } else {
      throw Exception('No se pudo leer el archivo');
    }

    final decoded = jsonDecode(json);

    if (decoded is! List) {
      throw Exception('El archivo no contiene una lista de rutinas válida');
    }

    return decoded
        .map(
          (json) => Routine.fromJson(
            Map<String, dynamic>.from(json),
          ),
        )
        .toList();
  }
}