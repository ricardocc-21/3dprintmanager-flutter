import 'package:path/path.dart';
import 'package:print_manager/models/filamento.dart';
import 'package:print_manager/models/impresion.dart';
import 'package:print_manager/models/impresora.dart';
import 'package:print_manager/models/reparacion.dart';
import 'package:sqflite/sqflite.dart';



class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('3dPrintManager.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }
  // Cerrar DB
  Future close() async {
    final db = await instance.database;
    db.close();
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE impresoras (
        id TEXT PRIMARY KEY,
        marca TEXT NOT NULL,
        modelo TEXT NOT NULL,
        precio REAL NULL,
        descripcion TEXT,
        fecha_compra TEXT NOT NULL,
        horas_uso REAL DEFAULT 0,
        imagen TEXT NOT NULL
      )
      ''');
    await db.execute('''
      CREATE TABLE filamentos (
        id TEXT PRIMARY KEY,
        marca TEXT NOT NULL,
        material TEXT NULL,
        color TEXT NULL,
        peso REAL NULL,
        precio DECIMAL(6,2) NULL,
        precio_kg DECIMAL(6,2) NULL,
        diametro DECIMAL(4,2) NULL,
        descripcion TEXT,
        fecha_compra TEXT NULL,
        enlace_compra TEXT,
        enlace_imagen TEXT,
        usado REAL DEFAULT 0,
        restante REAL DEFAULT 0,
        disponible REAL DEFAULT 0,
        porcentaje_usado REAL DEFAULT 0
      )
      ''');
    await db.execute('''
      CREATE TABLE impresiones (
        id TEXT PRIMARY KEY,
        nombre TEXT NOT NULL,
        impresoraId TEXT NOT NULL,
        filamentoId TEXT NOT NULL,
        peso DECIMAL(6,2) NOT NULL,
        tiempo REAL NOT NULL,
        fecha DATE NOT NULL,
        imagen TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE reparaciones (
        id TEXT PRIMARY KEY,
        impresoraId TEXT NOT NULL,
        descripcion TEXT NULL,
        precio DECIMAL(6,2) NOT NULL,
        fecha DATE NOT NULL
        )
    ''');
    // Impresora
    await db.execute('''
      INSERT INTO impresoras (id, marca, modelo, precio, descripcion, fecha_compra,imagen) VALUES ('1', 'Creality','Ender 3 V2 Neo',200,'Description','2025-10-07 15:42:30.123456','assets/images/ender3.png')
    ''');
    // Filamento
    await db.execute('''
      INSERT INTO filamentos (id, marca, material, color, peso, precio, precio_kg, diametro, descripcion, fecha_compra, enlace_compra, enlace_imagen) VALUES (1, 'eSUN', 'PLA', 'Azul', 1000, 10, 1, 1, 'descripcion', '2025-10-07 15:42:30.123456', 'asdc', 'imagen1.jpg')
    ''');
    // Impresion
    // await db.execute('''
    //   INSERT INTO impresiones (id, nombre, impresoraId, filamentoId, peso, tiempo, fecha, imagen) VALUES (1, 'Impresion 1', 1, 1, 100, 60, '2023-01-01', 'imagen1.jpg')
    // ''');
  }
/***    IMPRESORAS    ***/
  // Insertar impresora
  // Future<void> insertImpresora(Impresora impresora) async {
  //   final db = await instance.database;
  //   await db.insert(
  //     'impresoras',
  //     impresora.toJson(),
  //     conflictAlgorithm: ConflictAlgorithm.replace,
  //   );
  // }
  Future<void> insertImpresora(Impresora impresora) async {
    final db = await instance.database;

    final existing = await db.query(
      'impresoras',
      where: 'id = ?',
      whereArgs: [impresora.id],
    );

    if (existing.isNotEmpty) {
      // 🔹 Ya existe → actualiza
      await db.update(
        'impresoras',
        impresora.toJson(),
        where: 'id = ?',
        whereArgs: [impresora.id],
      );
    } else {
      // 🔹 No existe → inserta
      await db.insert('impresoras', impresora.toJson());
    }
  }



  // Obtener todas las impresoras
  Future<List<Impresora>> getImpresoras() async {
    final db = await instance.database;
    final result = await db.query('impresoras');
    return result.map((json) => Impresora.fromJson(json)).toList();
  }

  Future<Impresora?> getImpresora(String id) async {
    final db = await instance.database;
    final result = await db.query('impresoras', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return Impresora.fromJson(result.first);
    }
    return null;
  }


  // Eliminar una impresora
  Future<int> deleteImpresora(String id) async {
    final db = await instance.database;
    return await
    db.delete(
        'impresoras',
        where: 'id = ?',
        whereArgs: [id],
      );
  }

  Future<void> calcularHoras(String impresoraId) async {
    final db = await instance.database;
    final impresora = await getImpresora(impresoraId);
    final result = await db.rawQuery(
      'SELECT SUM(tiempo) as totalTiempo FROM impresiones WHERE impresoraId = ?',
      [impresora?.id],
    );

    final total = (result.first['totalTiempo'] as num?)?.toDouble() ?? 0.0;

    impresora?.horasUso = total;
    insertImpresora(impresora!);
  }

  /***    IMPRESIONES    ***/

  // Insertar impresion
  // Future<int> insertImpresion(Impresion impresion) async {
  //   try {
  //     final db = await instance.database;
  //     return await db.insert('impresiones', impresion.toJson(),conflictAlgorithm: ConflictAlgorithm.rollback);
  //   } catch (e, stackTrace) {
  //     print('❌ Error al insertar impresión: $e');
  //     print(stackTrace); // opcional, muestra la línea exacta del fallo
  //     return 0;
  //   }
  // }

  Future<void> insertImpresion(Impresion impresion) async {
    final db = await instance.database;

    final existing = await db.query(
      'impresiones',
      where: 'id = ?',
      whereArgs: [impresion.id],
    );

    if (existing.isNotEmpty) {
      // 🔹 Ya existe → actualiza
      await db.update(
        'impresiones',
        impresion.toJson(),
        where: 'id = ?',
        whereArgs: [impresion.id],
      );
    } else {
      // 🔹 No existe → inserta
      await db.insert('impresiones', impresion.toJson());
    }
  }

  // Obtener una impresion
  Future<Impresion?> getImpresion(String id) async {
    final db = await instance.database;

    final result = await db.query(
      'impresiones',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return Impresion.fromJson(result.first);
    } else {
      return null;
    }
  }


  // Obtener todas las impresiones
  Future<List<Impresion>> getImpresiones() async {
    final db = await instance.database;
    final result = await db.query('impresiones');
    return result.map((json) => Impresion.fromJson(json)).toList();
  }

  // Eliminar una impresion
  Future<int> deleteImpresion(String id) async {
    final db = await instance.database;
    return await db.delete(
      'impresiones',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /***    FILAMENTOS    ***/

  // Insertar filamento
  // Future<void> insertFilamento(Filamento filamento) async {
  //   final db = await instance.database;
  //   await db.insert(
  //     'filamentos',
  //     filamento.toJson(),
  //     conflictAlgorithm: ConflictAlgorithm.replace,
  //   );
  // }

  Future<void> insertFilamento(Filamento filamento) async {
    final db = await instance.database;

    final existing = await db.query(
      'filamentos',
      where: 'id = ?',
      whereArgs: [filamento.id],
    );

    if (existing.isNotEmpty) {
      // 🔹 Ya existe → actualiza
      await db.update(
        'filamentos',
        filamento.toJson(),
        where: 'id = ?',
        whereArgs: [filamento.id],
      );
    } else {
      // 🔹 No existe → inserta
      await db.insert('filamentos', filamento.toJson());
    }
  }


  // Obtener todos los filamentos
  Future<List<Filamento>> getFilamentos() async {
    final db = await instance.database;
    final result = await db.query('filamentos');
    return result.map((json) => Filamento.fromJson(json)).toList();
  }

  // Obtener un filamento
  Future<Filamento?> getFilamento(String id) async {
    final db = await instance.database;
    final result = await db.query('filamentos', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return Filamento.fromJson(result.first);
    }
    return null;
  }


  // Eliminar un filamento
  Future<int> deleteFilamento(String id) async {
    final db = await instance.database;
    return await db.delete(
      'filamentos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> calcularUsado(String filamentoId) async {
    final db = await instance.database;
    final filamento = await getFilamento(filamentoId);
    final result = await db.rawQuery(
      'SELECT SUM(peso) as totalPeso FROM impresiones WHERE filamentoId = ?',
      [filamento?.id],
    );

    final total = (result.first['totalPeso'] as num?)?.toDouble() ?? 0.0;

    filamento?.usado = total;
    filamento?.restante = filamento.peso - total;
    filamento?.porcentaje_usado = (total / filamento.peso) * 100;
    insertFilamento(filamento!);
  }


  /***    REPARACIONES    ***/
  // Insertar o actualizar filamento
  Future<void> insertReparacion(Reparacion reparacion) async {
    final db = await instance.database;

    final existing = await db.query(
      'reparaciones',
      where: 'id = ?',
      whereArgs: [reparacion.id],
    );

    if (existing.isNotEmpty) {
      // 🔹 Ya existe → actualiza
      await db.update(
        'reparaciones',
        reparacion.toJson(),
        where: 'id = ?',
        whereArgs: [reparacion.id],
      );
    } else {
      // 🔹 No existe → inserta
      await db.insert('reparaciones', reparacion.toJson());
    }
  }


  // Obtener todas las reparaciones
  Future<List<Reparacion>> getReparaciones() async {
    final db = await instance.database;
    final result = await db.query('reparaciones');
    return result.map((json) => Reparacion.fromJson(json)).toList();
  }

  // Obtener todas las reparaciones de una impresora
  Future<List<Reparacion>> getReparacionesImpresora(Impresora impresora) async {
    final db = await instance.database;
    final result = await db.query(
      'reparaciones',
      where: 'impresoraId = ?',
      whereArgs: [impresora.id],
    );
    return result.map((json) => Reparacion.fromJson(json)).toList();
  }


  // Obtener un filamento
  Future<Reparacion?> getReparacion(String id) async {
    final db = await instance.database;
    final result = await db.query('reparaciones', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return Reparacion.fromJson(result.first);
    }
    return null;
  }


  // Eliminar un filamento
  Future<int> deleteReparacion(String id) async {
    final db = await instance.database;
    return await db.delete(
      'reparaciones',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

}
