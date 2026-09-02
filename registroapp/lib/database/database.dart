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
              correo TEXT
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
                CREATE TABLE IF NOT EXISTS ordenes ( 
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

  static Future<int> eliminarOrden(int id) async {
    final db = await database;

    // Buscar la orden antes de eliminarla
    final ordenes = await db.query(
      'ordenes',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (ordenes.isEmpty) {
      return 0;
    }

    // Obtener el cliente asociado a la orden (compatible con cliente_id y clienteid)
    final ordenData = ordenes.first;
    final clienteId = ordenData['cliente_id'] ?? ordenData['clienteid'];

    // Eliminar la orden
    final resultado = await db.delete(
      'ordenes',
      where: 'id = ?',
      whereArgs: [id],
    );

    // Verificar si el cliente tiene otras órdenes asociadas
    if (clienteId != null) {
      List<Map<String, dynamic>> otrasOrdenes = [];
      try {
        otrasOrdenes = await db.query(
          'ordenes',
          where: 'cliente_id = ?',
          whereArgs: [clienteId],
        );
      } catch (_) {
        otrasOrdenes = await db.query(
          'ordenes',
          where: 'clienteid = ?',
          whereArgs: [clienteId],
        );
      }

      // Si ya no tiene otras órdenes, eliminar también al cliente
      if (otrasOrdenes.isEmpty) {
        await db.delete(
          'clientes',
          where: 'id = ?',
          whereArgs: [clienteId],
        );
      }
    }

    return resultado;
  }
  static Future<int> eliminarCliente(int id) async {
    final db = await database;

    return await db.delete(
      'clientes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /*static Future<int> eliminarOrden(int id) async {
    final db = await database;

    return await db.delete(
      'ordenes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }*/

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

    try {
      return await db.rawQuery('''
        SELECT ordenes.*, 
               clientes.nombre AS cliente_nombre, 
               clientes.telefono AS cliente_telefono, 
               clientes.correo AS cliente_correo
        FROM ordenes
        LEFT JOIN clientes ON ordenes.cliente_id = clientes.id
        ORDER BY ordenes.id DESC
      ''');
    } catch (_) {
      try {
        return await db.rawQuery('''
          SELECT ordenes.*, 
                 clientes.nombre AS cliente_nombre, 
                 clientes.telefono AS cliente_telefono, 
                 clientes.correo AS cliente_correo
          FROM ordenes
          LEFT JOIN clientes ON ordenes.clienteid = clientes.id
          ORDER BY ordenes.id DESC
        ''');
      } catch (_) {
        final ordenesRaw = await db.query('ordenes', orderBy: 'id DESC');
        final clientesRaw = await db.query('clientes');
        final Map<int, Map<String, dynamic>> clienteMap = {
          for (var c in clientesRaw) (c['id'] as int): c
        };

        return ordenesRaw.map((ord) {
          final cId = (ord['cliente_id'] ?? ord['clienteid']) as int?;
          final c = cId != null ? clienteMap[cId] : null;
          final mut = Map<String, dynamic>.from(ord);
          if (c != null) {
            mut['cliente_nombre'] = c['nombre'];
            mut['cliente_telefono'] = c['telefono'];
            mut['cliente_correo'] = c['correo'];
          }
          return mut;
        }).toList();
      }
    }
  }

  // Obtener una orden por su ID
  static Future<Map<String, dynamic>?> obtenerOrden(
    int id,
  ) async {
    final db = await database;

    try {
      final resultado = await db.rawQuery('''
        SELECT ordenes.*, 
               clientes.nombre AS cliente_nombre, 
               clientes.telefono AS cliente_telefono, 
               clientes.correo AS cliente_correo
        FROM ordenes
        LEFT JOIN clientes ON ordenes.cliente_id = clientes.id
        WHERE ordenes.id = ?
        LIMIT 1
      ''', [id]);

      if (resultado.isNotEmpty) return resultado.first;
    } catch (_) {
      try {
        final resultado = await db.rawQuery('''
          SELECT ordenes.*, 
                 clientes.nombre AS cliente_nombre, 
                 clientes.telefono AS cliente_telefono, 
                 clientes.correo AS cliente_correo
          FROM ordenes
          LEFT JOIN clientes ON ordenes.clienteid = clientes.id
          WHERE ordenes.id = ?
          LIMIT 1
        ''', [id]);

        if (resultado.isNotEmpty) return resultado.first;
      } catch (_) {
        final resultado = await db.query(
          'ordenes',
          where: 'id = ?',
          whereArgs: [id],
          limit: 1,
        );

        if (resultado.isEmpty) return null;

        final ord = Map<String, dynamic>.from(resultado.first);
        final cId = (ord['cliente_id'] ?? ord['clienteid']) as int?;
        if (cId != null) {
          final cRes = await db.query('clientes', where: 'id = ?', whereArgs: [cId], limit: 1);
          if (cRes.isNotEmpty) {
            ord['cliente_nombre'] = cRes.first['nombre'];
            ord['cliente_telefono'] = cRes.first['telefono'];
            ord['cliente_correo'] = cRes.first['correo'];
          }
        }
        return ord;
      }
    }

    return null;
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

  static Future<int> contarClientes() async {
  final db = await database;

  final resultado = await db.rawQuery(
    'SELECT COUNT(*) FROM clientes',
  );

return resultado.first.values.first as int? ?? 0;
}

static Future<int> contarOrdenes() async {
  final db = await database;

  final resultado = await db.rawQuery(
    'SELECT COUNT(*) FROM ordenes',
  );

return resultado.first.values.first as int? ?? 0;
}

  static Future<int> contarOrdenesPorEstado(
    String estado,
  ) async {
    final db = await database;

    final resultado = await db.rawQuery(
      'SELECT COUNT(*) FROM ordenes WHERE estado = ?',
      [estado],
    );

    return resultado.first.values.first as int? ?? 0;
  }

  // Generar siguiente folio consecutivo por año (ejemplo: ORD-2026-0001)
  static Future<String> generarSiguienteFolio() async {
    final db = await database;
    final anioActual = DateTime.now().year;
    final prefijo = 'ORD-$anioActual-';

    final resultado = await db.query(
      'ordenes',
      columns: ['folio'],
      where: 'folio LIKE ?',
      whereArgs: ['$prefijo%'],
    );

    int maxNumero = 0;
    for (final fila in resultado) {
      final folio = fila['folio'] as String?;
      if (folio != null && folio.startsWith(prefijo)) {
        final numeroStr = folio.substring(prefijo.length);
        final numero = int.tryParse(numeroStr);
        if (numero != null && numero > maxNumero) {
          maxNumero = numero;
        }
      }
    }

    final siguienteNumero = maxNumero + 1;
    final numeroFormateado = siguienteNumero.toString().padLeft(4, '0');
    return '$prefijo$numeroFormateado';
  }
}