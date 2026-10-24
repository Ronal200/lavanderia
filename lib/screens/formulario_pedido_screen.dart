import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/pedido_repository.dart';
import '../models/pedido.dart';
import '../utils/constantes.dart';
import '../utils/validadores.dart';

class FormularioPedidoScreen extends StatefulWidget {
  final Pedido? pedido;
  const FormularioPedidoScreen({super.key, this.pedido});
  @override
  State<FormularioPedidoScreen> createState() => _FormularioPedidoScreenState();
}

class _FormularioPedidoScreenState extends State<FormularioPedidoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cliente = TextEditingController();
  final _telefono = TextEditingController();
  final _prendas = TextEditingController();
  final _cantidad = TextEditingController(text: '1');
  final _precio = TextEditingController();
  final _kilos = TextEditingController(text: '1');
  final _precioKilo = TextEditingController(text: '8');
  final _observaciones = TextEditingController();
  final _repo = PedidoRepository();
  DateTime _recepcion = DateTime.now();
  DateTime _entrega = DateTime.now().add(const Duration(days: 2));
  String _estadoPedido = 'Recibido';
  String _estadoPago = 'Pago pendiente';
  bool _enviando = false;

  @override
  void initState() {
    super.initState();
    final p = widget.pedido;
    if (p != null) {
      _cliente.text = p.cliente; _telefono.text = p.telefono; _prendas.text = p.prendas;
      _cantidad.text = '${p.cantidad}'; _precio.text = p.precio.toStringAsFixed(2);
      _kilos.text = p.kilos.toString(); _precioKilo.text = p.precioPorKilo.toStringAsFixed(2);
      _observaciones.text = p.observaciones; _recepcion = p.fechaRecepcion;
      _entrega = p.fechaEntrega; _estadoPedido = p.estadoPedido; _estadoPago = p.estadoPago;
    } else { _actualizarTotal(); }
  }

  @override
  void dispose() {
    _cliente.dispose(); _telefono.dispose(); _prendas.dispose(); _cantidad.dispose();
    _precio.dispose(); _kilos.dispose(); _precioKilo.dispose(); _observaciones.dispose(); super.dispose();
  }

  Future<void> _elegirFecha(bool esEntrega) async {
    final inicial = esEntrega ? _entrega : _recepcion;
    final fecha = await showDatePicker(
      context: context,
      initialDate: inicial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: esEntrega ? 'Fecha de entrega' : 'Fecha de recepción',
    );
    if (fecha == null || !mounted) return;
    setState(() {
      if (esEntrega) _entrega = fecha; else _recepcion = fecha;
    });
  }

  void _actualizarTotal() {
    final kilos = double.tryParse(_kilos.text.replaceAll(',', '.')) ?? 0;
    final tarifa = double.tryParse(_precioKilo.text.replaceAll(',', '.')) ?? 0;
    _precio.text = (kilos * tarifa).toStringAsFixed(2);
  }

  Future<void> _guardar() async {
    if (_enviando || !_formKey.currentState!.validate()) return;
    if (_entrega.isBefore(DateTime(_recepcion.year, _recepcion.month, _recepcion.day))) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('La entrega no puede ser anterior a la recepción.')));
      return;
    }
    setState(() => _enviando = true);
    try {
      final p = Pedido(
        id: widget.pedido?.id,
        cliente: _cliente.text.trim(),
        telefono: _telefono.text.trim(),
        prendas: _prendas.text.trim(),
        cantidad: int.parse(_cantidad.text),
        kilos: double.parse(_kilos.text.replaceAll(',', '.')),
        precioPorKilo: double.parse(_precioKilo.text.replaceAll(',', '.')),
        fechaRecepcion: _recepcion,
        fechaEntrega: _entrega,
        precio: double.parse(_precio.text.replaceAll(',', '.')),
        estadoPedido: _estadoPedido,
        estadoPago: _estadoPago,
        observaciones: _observaciones.text.trim(),
      );
      Pedido? creado;
      if (widget.pedido == null) {
        creado = await _repo.crear(p);
      } else {
        await _repo.actualizar(p);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(widget.pedido == null ? 'Pedido registrado.' : 'Pedido actualizado.')));
      Navigator.pop(context, creado ?? true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se pudo guardar el pedido. Inténtalo nuevamente.')));
      debugPrint('Error guardando pedido: $e');
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formato = DateFormat('dd/MM/yyyy');
    return Scaffold(
      appBar: AppBar(title: Text(widget.pedido == null ? 'Registrar pedido' : 'Editar pedido')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Datos del cliente', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
            TextFormField(controller: _cliente, textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Nombre del cliente *', prefixIcon: Icon(Icons.person_outline)),
              validator: Validadores.cliente),
            const SizedBox(height: 12),
            TextFormField(controller: _telefono, keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Teléfono *', prefixIcon: Icon(Icons.phone_outlined)),
              validator: Validadores.telefono),
            const SizedBox(height: 22),
            const Text('Detalle de las prendas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
            TextFormField(controller: _prendas, maxLength: 200,
              decoration: const InputDecoration(labelText: 'Prendas (ej. 2 camisas, 1 pantalón) *', prefixIcon: Icon(Icons.checkroom_outlined)),
              validator: Validadores.prendas),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: TextFormField(controller: _cantidad, keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Cantidad de prendas *'), validator: Validadores.cantidad)),
              const SizedBox(width: 12),
              Expanded(child: TextFormField(controller: _kilos, keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Peso en kilos *'),
                onChanged: (_) => _actualizarTotal(),
                validator: (v) { final n = double.tryParse((v ?? '').replaceAll(',', '.')); return n == null || n <= 0 ? 'Ingresa kilos mayores a 0' : null; })),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: TextFormField(controller: _precioKilo, keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Tarifa por kilo (S/) *'),
                validator: (v) { final n = double.tryParse((v ?? '').replaceAll(',', '.')); return n == null || n < 0 ? 'Tarifa no válida' : null; },
                onChanged: (_) => _actualizarTotal())),
              const SizedBox(width: 12),
              Expanded(child: TextFormField(controller: _precio, readOnly: true,
                decoration: const InputDecoration(labelText: 'Total calculado (S/)'))),
            ]),
            const SizedBox(height: 22),
            const Text('Fechas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _FilaFecha(titulo: 'Fecha de recepción', fecha: formato.format(_recepcion), onTap: () => _elegirFecha(false)),
            _FilaFecha(titulo: 'Fecha de entrega', fecha: formato.format(_entrega), onTap: () => _elegirFecha(true)),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _estadoPedido,
              decoration: const InputDecoration(labelText: 'Estado del pedido', prefixIcon: Icon(Icons.local_laundry_service_outlined)),
              items: estadosPedido.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) { if (v != null) setState(() => _estadoPedido = v); },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _estadoPago,
              decoration: const InputDecoration(labelText: 'Estado del pago', prefixIcon: Icon(Icons.payments_outlined)),
              items: estadosPago.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) { if (v != null) setState(() => _estadoPago = v); },
            ),
            const SizedBox(height: 12),
            TextFormField(controller: _observaciones, maxLines: 3, maxLength: 300,
              decoration: const InputDecoration(labelText: 'Observaciones (opcional)', alignLabelWithHint: true),
              validator: (v) => (v?.length ?? 0) > 300 ? 'Máximo 300 caracteres.' : null),
            const SizedBox(height: 24),
            SizedBox(height: 52, child: FilledButton.icon(
              onPressed: _enviando ? null : _guardar,
              icon: _enviando ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.save_outlined),
              label: Text(_enviando ? 'Guardando...' : 'Guardar pedido'),
            )),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _FilaFecha extends StatelessWidget {
  final String titulo, fecha;
  final VoidCallback onTap;
  const _FilaFecha({required this.titulo, required this.fecha, required this.onTap});
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: const Icon(Icons.calendar_month_outlined, color: kVerde),
      title: Text(titulo),
      subtitle: Text(fecha, style: const TextStyle(fontWeight: FontWeight.bold)),
      trailing: const Icon(Icons.edit_calendar_outlined),
      onTap: onTap,
    ),
  );
}
