import 'package:flutter/material.dart';
import 'package:gestion_lavanderia/screens/inicio_screen.dart';
import '../data/pedido_repository.dart';
import '../models/pedido.dart';
import '../utils/constantes.dart';

class PortalScreen extends StatelessWidget {
  const PortalScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Lavandería')),
    body: Center(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: Column(
      mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.local_laundry_service, size: 72, color: kVerde),
        const SizedBox(height: 12), const Text('Bienvenido a tu lavandería', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        const SizedBox(height: 8), const Text('Consulta el estado de tu ropa o ingresa al área de administración.', textAlign: TextAlign.center),
        const SizedBox(height: 28), SizedBox(width: double.infinity, child: FilledButton.icon(
          icon: const Icon(Icons.person_search), label: const Text('Consultar mi pedido'),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ConsultaPedidoScreen())))),
        const SizedBox(height: 12), SizedBox(width: double.infinity, child: OutlinedButton.icon(
          icon: const Icon(Icons.admin_panel_settings_outlined), label: const Text('Acceso de administrador'),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AccesoAdminScreen())))),
      ],
    ))),
  );
}

class AccesoAdminScreen extends StatefulWidget {
  const AccesoAdminScreen({super.key});
  @override State<AccesoAdminScreen> createState() => _AccesoAdminScreenState();
}
class _AccesoAdminScreenState extends State<AccesoAdminScreen> {
  final _pin = TextEditingController(); String? _error;
  // Cambia este PIN antes de distribuir la aplicación.
  static const String pinAdministrador = '864210';
  @override void dispose() { _pin.dispose(); super.dispose(); }
  void _entrar() {
    if (_pin.text.trim() == pinAdministrador) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) =>  InicioAdminScreen()));
    } else { setState(() => _error = 'Código incorrecto. Inténtalo nuevamente.'); }
  }
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Acceso administrador')),
    body: Center(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.lock_outline, size: 64, color: kVerde), const SizedBox(height: 16),
      const Text('Área privada', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      const Text('Ingresa el código de administrador de 6 dígitos.'), const SizedBox(height: 20),
      TextField(controller: _pin, obscureText: true, keyboardType: TextInputType.number, maxLength: 6,
        decoration: InputDecoration(labelText: 'Código administrador', errorText: _error, prefixIcon: const Icon(Icons.password)),
        onSubmitted: (_) => _entrar()), const SizedBox(height: 8),
      SizedBox(width: double.infinity, child: FilledButton(onPressed: _entrar, child: const Text('Ingresar'))),
    ]))));
}

class ConsultaPedidoScreen extends StatefulWidget {
  const ConsultaPedidoScreen({super.key});
  @override State<ConsultaPedidoScreen> createState() => _ConsultaPedidoScreenState();
}
class _ConsultaPedidoScreenState extends State<ConsultaPedidoScreen> {
  final _codigo = TextEditingController(); final _repo = PedidoRepository();
  Pedido? _pedido; bool _buscando = false; String? _error;
  @override void dispose() { _codigo.dispose(); super.dispose(); }
  Future<void> _consultar() async {
    if (_codigo.text.trim().length != 6) { setState(() { _pedido = null; _error = 'Ingresa el código de 6 caracteres que recibiste.'; }); return; }
    setState(() { _buscando = true; _error = null; _pedido = null; });
    try {
      final pedido = await _repo.buscarPorCodigo(_codigo.text);
      if (!mounted) return;
      setState(() { _pedido = pedido; if (pedido == null) _error = 'No encontramos un pedido con ese código.'; });
    } catch (_) { if (mounted) setState(() => _error = 'No se pudo consultar. Inténtalo nuevamente.'); }
    finally { if (mounted) setState(() => _buscando = false); }
  }
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Consultar mi pedido')),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      const Icon(Icons.qr_code_2, size: 60, color: kVerde),
      const Text('Código de tu ropa', style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
      const SizedBox(height: 8), const Text('Escribe el código de 6 letras mayúsculas o números que te entregaron al recibir tu ropa.', textAlign: TextAlign.center),
      const SizedBox(height: 20), TextField(controller: _codigo, textCapitalization: TextCapitalization.characters,
        maxLength: 6, textAlign: TextAlign.center, style: const TextStyle(fontSize: 24, letterSpacing: 5, fontWeight: FontWeight.bold),
        decoration: const InputDecoration(hintText: 'A1B2C3', prefixIcon: Icon(Icons.key)),
        onChanged: (v) => _codigo.value = _codigo.value.copyWith(text: v.toUpperCase(), selection: TextSelection.collapsed(offset: v.length))),
      FilledButton.icon(onPressed: _buscando ? null : _consultar, icon: const Icon(Icons.search), label: Text(_buscando ? 'Consultando...' : 'Consultar estado')),
      if (_error != null) ...[const SizedBox(height: 16), Text(_error!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center)],
      if (_pedido != null) ...[
        const SizedBox(height: 22), Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Estado de tu pedido', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12), Text('Código: ${_pedido!.codigo}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2)),
          const Divider(height: 24), _dato('Cliente', _pedido!.cliente), _dato('Prendas', _pedido!.prendas),
          _dato('Peso recibido', '${_pedido!.kilos.toStringAsFixed(2)} kg'), _dato('Estado', _pedido!.estadoPedido),
          _dato('Pago', _pedido!.estadoPago), _dato('Total', 'S/ ${_pedido!.precio.toStringAsFixed(2)}'),
          _dato('Entrega estimada', '${_pedido!.fechaEntrega.day.toString().padLeft(2, '0')}/${_pedido!.fechaEntrega.month.toString().padLeft(2, '0')}/${_pedido!.fechaEntrega.year}'),
        ]))),
      ],
    ]));
  Widget _dato(String t, String v) => Padding(padding: const EdgeInsets.symmetric(vertical: 5), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [SizedBox(width: 125, child: Text(t, style: const TextStyle(color: Colors.black54))), Expanded(child: Text(v, style: const TextStyle(fontWeight: FontWeight.w600)))]));
}
