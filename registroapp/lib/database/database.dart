import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    sqfliteFfiInit();

    databaseFactory = databaseFactoryFfi;

    final dbPath = await databaseFactory.getDatabasesPath();
    final path = '$dbPath/registroapp.db';

    return await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 2,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE clientes (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              nombre TEXT NOT NULL,
              telefono TEXT NOT NULL UNIQUE,
              correo TEXT,
            )
          ''');
          await db.execute('''
          CREATE TABLE ordenes(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            folio TEXT NOT NULL UNIQUE,
            cliente_id INTEGER NOT NULL,
            fecha TEXT NOT NULL,
            equipo TEXT,
            problema TEXT,
            estado TEXT NOT NULL,
            diagnostico TEXT,
            observaciones TEXT,
            FOREIGN KEY (cliente_id) REFERENCES clientes (id)
             )
        ''');
        },

        onUpgrade: (db, oldVersion, newVersion) async { 
            if (oldVersion < 2) { 
                await db.execute(''' 
                CREATE TABLE ordenes ( 
                id INTEGER PRIMARY KEY AUTOINCREMENT, 
                folio TEXT NOT NULL UNIQUE, 
                cliente_id INTEGER NOT NULL, 
                fecha TEXT NOT NULL, 
                equipo TEXT, 
                problema TEXT, 
                estado TEXT NOT NULL, 
                diagnostico TEXT, 
                observaciones TEXT, 
                FOREIGN KEY (cliente_id) REFERENCES clientes (id) 
                ) 
            ''');
            }
        },
      ),
    );
  }

  static Future<List<Map<String, dynamic>>> obtenerClientes() async {
    final db = await database;

    return await db.query(
      'clientes',
      orderBy: 'nombre ASC',
    );
  }

  static Future<int> insertarCliente(
    Map<String, dynamic> cliente,
  ) async {
    final db = await database;

    return await db.insert(
      'clientes',
      cliente,
    );
  }

  static Future<int> actualizarCliente(
    int id,
    Map<String, dynamic> cliente,
  ) async {
    final db = await database;

    return await db.update(
      'clientes',
      cliente,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> eliminarCliente(int id) async {
    final db = await database;

    return await db.delete(
      'clientes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> eliminarOrden(int id) async {
    final db = await database;

    return await db.delete(
      'ordenes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<bool> existeTelefono(
    String telefono, {
    int? excluirId,
  }) async {
    final db = await database;

    String where = 'telefono = ?';
    List<dynamic> argumentos = [telefono];

    if (excluirId != null) {
      where += ' AND id != ?';
      argumentos.add(excluirId);
    }

    final resultado = await db.query(
      'clientes',
      where: where,
      whereArgs: argumentos,
      limit: 1,
    );

    return resultado.isNotEmpty;
  }

  // Obtener todas las órdenes
  static Future<List<Map<String, dynamic>>> obtenerOrdenes() async {
    final db = await database;

    return await db.query(
      'ordenes',
      orderBy: 'id DESC',
    );
  }

  // Obtener una orden por su ID
  static Future<Map<String, dynamic>?> obtenerOrden(
    int id,
  ) async {
    final db = await database;

    final resultado = await db.query(
      'ordenes',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (resultado.isEmpty) {
      return null;
    }

    return resultado.first;
  }

  // Insertar una orden
  static Future<int> insertarOrden(
    Map<String, dynamic> orden,
  ) async {
    final db = await database;

    return await db.insert(
      'ordenes',
      orden,
    );
  }

  // Actualizar una orden
  static Future<int> actualizarOrden(
    int id,
    Map<String, dynamic> orden,
  ) async {
    final db = await database;

    return await db.update(
      'ordenes',
      orden,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

}