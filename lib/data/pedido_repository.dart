import 'dart:math';
import 'package:sqflite/sqflite.dart';
import '../models/pedido.dart';
import 'database_helper.dart';

class PedidoRepository {
  Future<List<Pedido>> listar({String? busqueda, String? estado}) async {
    final db = await DatabaseHelper.instance.database;
    final where = <String>[]; final args = <Object?>[];
    if (busqueda != null && busqueda.trim().isNotEmpty) {
      where.add('(cliente LIKE ? OR prendas LIKE ? OR telefono LIKE ? OR codigo LIKE ?)');
      final q = '%${busqueda.trim()}%'; args.addAll([q, q, q, q]);
    }
    if (estado != null && estado != 'Todos') { where.add('estado_pedido = ?'); args.add(estado); }
    final rows = await db.query('pedidos', where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args.isEmpty ? null : args, orderBy: 'fecha_entrega ASC, id DESC');
    return rows.map(Pedido.fromMap).toList();
  }

  Future<Pedido?> buscarPorCodigo(String codigo) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query('pedidos', where: 'codigo = ?', whereArgs: [codigo.toUpperCase().trim()], limit: 1);
    return rows.isEmpty ? null : Pedido.fromMap(rows.first);
  }

  String _generarCodigo() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    return List.generate(6, (_) => chars[random.nextInt(chars.length)]).join();
  }

  Future<Pedido> crear(Pedido pedido) async {
    final db = await DatabaseHelper.instance.database;
    for (var intento = 0; intento < 20; intento++) {
      final codigo = _generarCodigo();
      final existe = await db.query('pedidos', columns: ['id'], where: 'codigo = ?', whereArgs: [codigo], limit: 1);
      if (existe.isNotEmpty) continue;
      final map = pedido.toMap()..remove('id')..['codigo'] = codigo;
      try {
        final id = await db.insert('pedidos', map, conflictAlgorithm: ConflictAlgorithm.abort);
        return Pedido.fromMap({...map, 'id': id});
      } on DatabaseException { if (intento == 19) rethrow; }
    }
    throw StateError('No se pudo generar un código único.');
  }

  Future<void> actualizar(Pedido pedido) async {
    final db = await DatabaseHelper.instance.database;
    await db.update('pedidos', pedido.toMap()..remove('codigo'), where: 'id = ?', whereArgs: [pedido.id]);
  }
  Future<void> eliminar(int id) async { final db = await DatabaseHelper.instance.database; await db.delete('pedidos', where: 'id = ?', whereArgs: [id]); }
  Future<void> actualizarEstados(int id, {String? estadoPedido, String? estadoPago}) async {
    final db = await DatabaseHelper.instance.database; final valores = <String, Object?>{};
    if (estadoPedido != null) valores['estado_pedido'] = estadoPedido;
    if (estadoPago != null) valores['estado_pago'] = estadoPago;
    if (valores.isNotEmpty) await db.update('pedidos', valores, where: 'id = ?', whereArgs: [id]);
  }
}
