import 'package:flutter/material.dart';
import '../data/pedido_repository.dart';
import '../models/pedido.dart';
import '../utils/constantes.dart';

class PagosScreen extends StatefulWidget { const PagosScreen({super.key}); @override State<PagosScreen> createState() => _PagosScreenState(); }
class _PagosScreenState extends State<PagosScreen> {
  final _repo = PedidoRepository(); late Future<List<Pedido>> _future;
  @override void initState() { super.initState(); _future = _repo.listar(); }
  Future<void> _recargar() async { setState(() => _future = _repo.listar()); await _future; }
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Control de pagos')),
    body: FutureBuilder<List<Pedido>>(future: _future, builder: (context, snap) {
      if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
      if (snap.hasError) return Center(child: TextButton(onPressed: () => setState(() => _future = _repo.listar()), child: const Text('Error al cargar. Reintentar')));
      final pedidos = snap.data ?? []; final pendientes = pedidos.where((p) => p.estadoPago != 'Pagado').toList();
      final pagados = pedidos.where((p) => p.estadoPago == 'Pagado').toList();
      final deuda = pendientes.fold<double>(0, (s, p) => s + p.precio);
      final cobrado = pagados.fold<double>(0, (s, p) => s + p.precio);
      return RefreshIndicator(onRefresh: _recargar, child: ListView(padding: const EdgeInsets.all(16), children: [
        Row(children: [Expanded(child: _resumen('Por cobrar', deuda, Colors.deepOrange)), const SizedBox(width: 10), Expanded(child: _resumen('Pagado', cobrado, kVerde))]),
        const SizedBox(height: 22), const Text('Pagos pendientes', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
        if (pendientes.isEmpty) const Padding(padding: EdgeInsets.all(16), child: Text('No hay pagos pendientes.')),
        ...pendientes.map((p) => Card(child: ListTile(leading: const Icon(Icons.pending_actions, color: Colors.deepOrange), title: Text(p.cliente), subtitle: Text('Código ${p.codigo} · ${p.kilos.toStringAsFixed(2)} kg'), trailing: Text('S/ ${p.precio.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold))))),
        const SizedBox(height: 16), const Text('Pagos registrados', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
        if (pagados.isEmpty) const Padding(padding: EdgeInsets.all(16), child: Text('Aún no hay pagos registrados.')),
        ...pagados.map((p) => Card(child: ListTile(leading: const Icon(Icons.check_circle, color: kVerde), title: Text(p.cliente), subtitle: Text('Código ${p.codigo}'), trailing: Text('S/ ${p.precio.toStringAsFixed(2)}')))),
        const SizedBox(height: 60),
      ]));
    }));
  Widget _resumen(String titulo, double monto, Color color) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: color.withValues(alpha: .10), borderRadius: BorderRadius.circular(18)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(titulo), const SizedBox(height: 8), Text('S/ ${monto.toStringAsFixed(2)}', style: TextStyle(fontSize: 21, color: color, fontWeight: FontWeight.bold))]));
}
