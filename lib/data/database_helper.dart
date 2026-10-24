import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    final folder = await getDatabasesPath();
    _database = await openDatabase(p.join(folder, 'gestion_lavanderia.db'), version: 2,
      onCreate: (db, version) async {
        await db.execute('''CREATE TABLE pedidos (
          id INTEGER PRIMARY KEY AUTOINCREMENT, codigo TEXT NOT NULL UNIQUE,
          cliente TEXT NOT NULL, telefono TEXT NOT NULL, prendas TEXT NOT NULL,
          cantidad INTEGER NOT NULL CHECK(cantidad > 0), kilos REAL NOT NULL DEFAULT 0,
          precio_por_kilo REAL NOT NULL DEFAULT 0, fecha_recepcion TEXT NOT NULL,
          fecha_entrega TEXT NOT NULL, precio REAL NOT NULL CHECK(precio >= 0),
          estado_pedido TEXT NOT NULL, estado_pago TEXT NOT NULL, observaciones TEXT NOT NULL DEFAULT '')''');
        await db.execute('CREATE INDEX idx_pedidos_entrega ON pedidos(fecha_entrega)');
        await db.execute('CREATE INDEX idx_pedidos_estado ON pedidos(estado_pedido)');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute("ALTER TABLE pedidos ADD COLUMN codigo TEXT NOT NULL DEFAULT ''");
          await db.execute('ALTER TABLE pedidos ADD COLUMN kilos REAL NOT NULL DEFAULT 0');
          await db.execute('ALTER TABLE pedidos ADD COLUMN precio_por_kilo REAL NOT NULL DEFAULT 0');
          final rows = await db.query('pedidos', columns: ['id']);
          for (final row in rows) {
            final id = row['id'] as int;
            await db.update('pedidos', {'codigo': 'LEG${id.toString().padLeft(3, '0')}'}, where: 'id = ?', whereArgs: [id]);
          }
          await db.execute('CREATE UNIQUE INDEX idx_pedidos_codigo ON pedidos(codigo)');
        }
      });
    return _database!;
  }
}
