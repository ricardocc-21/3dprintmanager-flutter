import 'package:path/path.dart';
import 'package:print_manager/models/filamento.dart';
import 'package:print_manager/models/impresion.dart';
import 'package:print_manager/models/impresora.dart';
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
        precio REAL NOT NULL,
        descripcion TEXT,
        fecha_compra TEXT NOT NULL,
        horas_uso REAL NOT NULL
      )
      ''');
    await db.execute('''
      
      CREATE TABLE filamentos (
        id TEXT PRIMARY KEY,
        marca TEXT NOT NULL,
        material TEXT NOT NULL,
        color TEXT NOT NULL,
        peso REAL NOT NULL,
        precio DECIMAL(6,2) NOT NULL,
        precio_kg DECIMAL(6,2) NOT NULL,
        diametro DECIMAL(4,2) NOT NULL,
        descripcion TEXT,
        fecha_compra TEXT NOT NULL,
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
        impresora TEXT NOT NULL,
        filamento TEXT NOT NULL,
        peso DECIMAL(6,2) NOT NULL,
        tiempo REAL NOT NULL,
        fecha DATE NOT NULL
      )
    ''');
  }
/***    IMPRESORAS    ***/
  // Insertar impresora
  Future<void> insertImpresora(Impresora impresora) async {
    final db = await instance.database;
    await db.insert(
      'impresoras',
      impresora.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Obtener todas las impresoras
  Future<List<Impresora>> getImpresoras() async {
    final db = await instance.database;
    final result = await db.query('impresoras');
    return result.map((json) => Impresora.fromJson(json)).toList();
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

  /***    IMPRESIONES    ***/

  // Insertar impresion
  Future<void> insertImpresion(Impresion impresion) async {
    final db = await instance.database;
    await db.insert(
      'impresiones',
      impresion.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

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
  Future<void> insertFilamento(Filamento filamento) async {
    final db = await instance.database;
    await db.insert(
      'filamentos',
      filamento.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Obtener todas las impresion
  Future<List<Filamento>> getFilamentos() async {
    final db = await instance.database;
    final result = await db.query('filamentos');
    return result.map((json) => Filamento.fromJson(json)).toList();
  }

  // Eliminar una impresion
  Future<int> deleteFilamento(String id) async {
    final db = await instance.database;
    return await db.delete(
      'filamentos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }


}
