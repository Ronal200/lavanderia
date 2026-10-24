import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/pedido_repository.dart';
import '../models/pedido.dart';
import '../utils/constantes.dart';
import 'formulario_pedido_screen.dart';

class DetallePedidoScreen extends StatefulWidget {
  final Pedido pedido;
  const DetallePedidoScreen({super.key, required this.pedido});
  @override
  State<DetallePedidoScreen> createState() => _DetallePedidoScreenState();
}

class _DetallePedidoScreenState extends State<DetallePedidoScreen> {
  final _repo = PedidoRepository();
  late Pedido _pedido;
  bool _actualizando = false;
  @override
  void initState() { super.initState(); _pedido = widget.pedido; }

  Future<void> _editar() async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => FormularioPedidoScreen(pedido: _pedido)));
    if (!mounted) return;
    final lista = await _repo.listar();
    final actualizado = lista.where((p) => p.id == _pedido.id);
    if (!mounted) return;
    if (actualizado.isNotEmpty) setState(() => _pedido = actualizado.first);
  }

  Future<void> _cambiarEstado({String? pedido, String? pago}) async {
    if (_actualizando) return;
    final nuevo = pedido ?? pago ?? '';
    final tipo = pedido != null ? 'estado del pedido' : 'estado del pago';
    final confirmar = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Confirmar cambio'),
      content: Text('¿Estás seguro de cambiar $tipo a «$nuevo»?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('No')),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sí, cambiar')),
      ],
    ));
    if (confirmar != true) { if (mounted) setState(() {}); return; }
    if (!mounted) return;
    setState(() => _actualizando = true);
    try {
      await _repo.actualizarEstados(_pedido.id!, estadoPedido: pedido, estadoPago: pago);
      if (!mounted) return;
      setState(() => _pedido = _pedido.copyWith(estadoPedido: pedido, estadoPago: pago));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Estado actualizado.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se pudo actualizar el estado.')));
    } finally {
      if (mounted) setState(() => _actualizando = false);
    }
  }

  Future<void> _eliminar() async {
    final ok = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Eliminar pedido'),
      content: const Text('¿Seguro que deseas eliminar este pedido? Esta acción no se puede deshacer.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar')),
      ],
    ));
    if (ok != true || !mounted) return;
    await _repo.eliminar(_pedido.id!);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final f = DateFormat('dd/MM/yyyy');
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del pedido'), actions: [
        IconButton(onPressed: _editar, tooltip: 'Editar', icon: const Icon(Icons.edit_outlined)),
        IconButton(onPressed: _eliminar, tooltip: 'Eliminar', icon: const Icon(Icons.delete_outline)),
      ]),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(color: const Color(0xFFE2F4EB), borderRadius: BorderRadius.circular(22)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.local_laundry_service, size: 36, color: kVerde),
            const SizedBox(height: 12),
            Text(_pedido.cliente, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text('Pedido #${_pedido.id} · ${_pedido.telefono}'),
            const SizedBox(height: 8),
            const Text('Código para el cliente', style: TextStyle(color: Colors.black54)),
            SelectableText(_pedido.codigo, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 4, color: kVerde)),
            const SizedBox(height: 14),
            Text('S/ ${_pedido.precio.toStringAsFixed(2)}', style: const TextStyle(fontSize: 26, color: kVerde, fontWeight: FontWeight.bold)),
          ]),
        ),
        const SizedBox(height: 18),
        _Seccion(titulo: 'Información del pedido', children: [
          _Dato(icono: Icons.checkroom_outlined, titulo: 'Prendas', valor: _pedido.prendas),
          _Dato(icono: Icons.numbers, titulo: 'Cantidad', valor: '${_pedido.cantidad} prenda(s)'),
          _Dato(icono: Icons.scale_outlined, titulo: 'Peso', valor: '${_pedido.kilos.toStringAsFixed(2)} kg'),
          _Dato(icono: Icons.price_change_outlined, titulo: 'Tarifa por kilo', valor: 'S/ ${_pedido.precioPorKilo.toStringAsFixed(2)}'),
          _Dato(icono: Icons.calendar_today_outlined, titulo: 'Recepción', valor: f.format(_pedido.fechaRecepcion)),
          _Dato(icono: Icons.event_available_outlined, titulo: 'Fecha de entrega', valor: f.format(_pedido.fechaEntrega)),
          if (_pedido.observaciones.isNotEmpty) _Dato(icono: Icons.notes, titulo: 'Observaciones', valor: _pedido.observaciones),
        ]),
        const SizedBox(height: 16),
        _Seccion(titulo: 'Estado del pedido', children: [
          DropdownButtonFormField<String>(
            value: _pedido.estadoPedido,
            decoration: const InputDecoration(labelText: 'Cambiar estado'),
            items: estadosPedido.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: _actualizando ? null : (v) { if (v != null) _cambiarEstado(pedido: v); },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _pedido.estadoPago,
            decoration: const InputDecoration(labelText: 'Estado de pago'),
            items: estadosPago.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: _actualizando ? null : (v) { if (v != null) _cambiarEstado(pago: v); },
          ),
          if (_actualizando) const Padding(padding: EdgeInsets.all(8), child: LinearProgressIndicator()),
        ]),
        const SizedBox(height: 24),
        OutlinedButton.icon(onPressed: _editar, icon: const Icon(Icons.edit_outlined), label: const Text('Editar información')),
        const SizedBox(height: 24),
      ]),
    );
  }
}

class _Seccion extends StatelessWidget {
  final String titulo;
  final List<Widget> children;
  const _Seccion({required this.titulo, required this.children});
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(padding: const EdgeInsets.all(16), child: Column(
      crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(titulo, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12), ...children,
      ],
    )),
  );
}

class _Dato extends StatelessWidget {
  final IconData icono;
  final String titulo, valor;
  const _Dato({required this.icono, required this.titulo, required this.valor});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 13),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icono, size: 20, color: kVerde), const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(titulo, style: const TextStyle(color: Colors.black54, fontSize: 12)),
        const SizedBox(height: 3), Text(valor, style: const TextStyle(fontWeight: FontWeight.w500)),
      ])),
    ]),
  );
}
