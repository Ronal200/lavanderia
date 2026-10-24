import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/pedido_repository.dart';
import '../models/pedido.dart';
import '../utils/constantes.dart';
import 'formulario_pedido_screen.dart';
import 'detalle_pedido_screen.dart';
import 'lista_pedidos_screen.dart';
import 'ubicacion_screen.dart';
import 'pagos_screen.dart';

class InicioAdminScreen extends StatefulWidget {
  const InicioAdminScreen({super.key});
  @override
  State<InicioAdminScreen> createState() => _InicioAdminScreenState();
}

class _InicioAdminScreenState extends State<InicioAdminScreen> {
  final _repo = PedidoRepository();
  late Future<List<Pedido>> _future;

  @override
  void initState() {
    super.initState();
    _future = _repo.listar();
  }

  void _recargar() { if (mounted) setState(() => _future = _repo.listar()); }

  Future<void> _nuevoPedido() async {
    final resultado = await Navigator.push(context, MaterialPageRoute(
      builder: (_) => const FormularioPedidoScreen(),
    ));
    if (!mounted) return;
    _recargar();
    if (resultado is Pedido && resultado.codigo.isNotEmpty) {
      await showDialog<void>(context: context, builder: (ctx) => AlertDialog(
        title: const Text('Pedido registrado'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Entrega este código al cliente. Lo necesitará para consultar el estado de su ropa.'),
          const SizedBox(height: 16),
          SelectableText(resultado.codigo, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, letterSpacing: 5, color: kVerde)),
          const SizedBox(height: 8), const Text('Código de 6 caracteres', style: TextStyle(color: Colors.black54)),
        ]),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Entendido'))],
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(children: [
          Icon(Icons.local_laundry_service, color: kVerde),
          SizedBox(width: 10),
          Text('Lavandería'),
        ]),
        actions: [
          IconButton(tooltip: 'Cerrar sesión', icon: const Icon(Icons.logout), onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false)),
          IconButton(
            tooltip: 'Cómo llegar',
            icon: const Icon(Icons.location_on_outlined),
            onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const UbicacionScreen())),
          ),
        ],
      ),
      body: FutureBuilder<List<Pedido>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _MensajeEstado(
              icono: Icons.error_outline,
              titulo: 'No se pudieron cargar los pedidos',
              detalle: 'Comprueba el almacenamiento e inténtalo nuevamente.',
              accion: TextButton(onPressed: _recargar, child: const Text('Reintentar')),
            );
          }
          final pedidos = snapshot.data ?? [];
          final pendientes = pedidos.where((p) => p.estadoPago == estadosPago[0]).length;
          final listos = pedidos.where((p) => p.estadoPedido == 'Listo').length;
          return RefreshIndicator(
            onRefresh: () async => _recargar(),
            child: ListView(
              padding: const EdgeInsets.all(kEspacioMd),
              children: [
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF176B50), Color(0xFF38A77B)]),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('¡Bienvenido!', style: TextStyle(color: Colors.white70, fontSize: 15)),
                      SizedBox(height: 6),
                      Text('Tu lavandería,\nbajo control.', style: TextStyle(color: Colors.white, fontSize: 27, fontWeight: FontWeight.bold)),
                      SizedBox(height: 12),
                      Text('Organiza pedidos, entregas y pagos desde un solo lugar.',
                        style: TextStyle(color: Colors.white, height: 1.4)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(children: [
                  Expanded(child: _Indicador(titulo: 'Pedidos', valor: '${pedidos.length}', icono: Icons.receipt_long, color: Colors.blue)),
                  const SizedBox(width: 10),
                  Expanded(child: _Indicador(titulo: 'Listos', valor: '$listos', icono: Icons.check_circle_outline, color: kVerde)),
                  const SizedBox(width: 10),
                  Expanded(child: _Indicador(titulo: 'Por cobrar', valor: '$pendientes', icono: Icons.payments_outlined, color: Colors.orange)),
                ]),
                const SizedBox(height: 14),
                Card(child: ListTile(leading: const CircleAvatar(child: Icon(Icons.payments_outlined)), title: const Text('Control de pagos'), subtitle: const Text('Revisa montos pagados y pendientes'), trailing: const Icon(Icons.chevron_right), onTap: () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => const PagosScreen())); if (mounted) _recargar(); })),
                const SizedBox(height: 10),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('Pedidos recientes', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
                  TextButton(onPressed: () async {
                    await Navigator.push(context, MaterialPageRoute(builder: (_) => const ListaPedidosScreen()));
                    if (mounted) _recargar();
                  }, child: const Text('Ver todos')),
                ]),
                if (pedidos.isEmpty)
                  _MensajeEstado(
                    icono: Icons.local_laundry_service_outlined,
                    titulo: 'Aún no hay pedidos',
                    detalle: 'Registra el primer pedido para comenzar a organizar tu lavandería.',
                    accion: FilledButton.icon(onPressed: _nuevoPedido, icon: const Icon(Icons.add), label: const Text('Registrar pedido')),
                  )
                else
                  ...pedidos.take(4).map((p) => _TarjetaPedido(
                    pedido: p,
                    onTap: () async {
                      await Navigator.push(context, MaterialPageRoute(builder: (_) => DetallePedidoScreen(pedido: p)));
                      if (mounted) _recargar();
                    },
                  )),
                const SizedBox(height: 18),
                Card(
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.map_outlined)),
                    title: const Text('¿Cómo llegar a la lavandería?'),
                    subtitle: const Text('La navegación GPS estará disponible en la segunda unidad.'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UbicacionScreen())),
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _nuevoPedido,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo pedido'),
      ),
    );
  }
}

class _Indicador extends StatelessWidget {
  final String titulo, valor;
  final IconData icono;
  final Color color;
  const _Indicador({required this.titulo, required this.valor, required this.icono, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
    child: Column(children: [
      Icon(icono, color: color),
      const SizedBox(height: 8),
      Text(valor, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      Text(titulo, style: const TextStyle(fontSize: 11), textAlign: TextAlign.center),
    ]),
  );
}

class _TarjetaPedido extends StatelessWidget {
  final Pedido pedido;
  final VoidCallback onTap;
  const _TarjetaPedido({required this.pedido, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final fecha = DateFormat('dd/MM/yyyy').format(pedido.fechaEntrega);
    final pagado = pedido.estadoPago == 'Pagado';
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(backgroundColor: const Color(0xFFE2F4EB),
          child: Icon(Icons.local_laundry_service, color: kVerde)),
        title: Text(pedido.cliente, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${pedido.prendas} · ${pedido.kilos.toStringAsFixed(2)} kg', maxLines: 1, overflow: TextOverflow.ellipsis),
            Text('Código: ${pedido.codigo}', style: const TextStyle(fontWeight: FontWeight.w600, letterSpacing: 1.5)),
            const SizedBox(height: 5),
            Text('Entrega: $fecha'),
            const SizedBox(height: 7),
            Wrap(spacing: 6, children: [
              _ChipEstado(texto: pedido.estadoPedido),
              _ChipEstado(texto: pedido.estadoPago, color: pagado ? kVerde : Colors.deepOrange),
            ]),
          ]),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _ChipEstado extends StatelessWidget {
  final String texto;
  final Color? color;
  const _ChipEstado({required this.texto, this.color});
  @override
  Widget build(BuildContext context) {
    final c = color ?? (texto == 'Listo' || texto == 'Entregado' ? kVerde : Colors.blueGrey);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(color: c.withValues(alpha: .11), borderRadius: BorderRadius.circular(30)),
      child: Text(texto, style: TextStyle(color: c, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

class _MensajeEstado extends StatelessWidget {
  final IconData icono;
  final String titulo, detalle;
  final Widget? accion;
  const _MensajeEstado({required this.icono, required this.titulo, required this.detalle, this.accion});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    margin: const EdgeInsets.symmetric(vertical: 16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
    child: Column(children: [
      Icon(icono, size: 44, color: kVerde),
      const SizedBox(height: 12),
      Text(titulo, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
      const SizedBox(height: 8),
      Text(detalle, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54)),
      if (accion != null) ...[const SizedBox(height: 14), accion!],
    ]),
  );
}
