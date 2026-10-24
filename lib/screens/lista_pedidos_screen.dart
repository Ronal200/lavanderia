import 'package:flutter/material.dart';
import '../data/pedido_repository.dart';
import '../models/pedido.dart';
import '../utils/constantes.dart';
import 'formulario_pedido_screen.dart';
import 'detalle_pedido_screen.dart';

class ListaPedidosScreen extends StatefulWidget {
  const ListaPedidosScreen({super.key});
  @override
  State<ListaPedidosScreen> createState() => _ListaPedidosScreenState();
}

class _ListaPedidosScreenState extends State<ListaPedidosScreen> {
  final _repo = PedidoRepository();
  final _busqueda = TextEditingController();
  String _estado = 'Todos';
  late Future<List<Pedido>> _future;

  @override
  void initState() { super.initState(); _future = _repo.listar(); }
  @override
  void dispose() { _busqueda.dispose(); super.dispose(); }

  void _cargar() => setState(() => _future = _repo.listar(busqueda: _busqueda.text, estado: _estado));

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Todos los pedidos')),
    body: Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: TextField(
          controller: _busqueda,
          onChanged: (_) => _cargar(),
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search), hintText: 'Buscar cliente, prenda o teléfono',
          ),
        ),
      ),
      SizedBox(height: 52, child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        children: ['Todos', ...estadosPedido].map((e) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: ChoiceChip(label: Text(e), selected: _estado == e,
            onSelected: (_) { setState(() => _estado = e); _cargar(); }),
        )).toList(),
      )),
      Expanded(child: FutureBuilder<List<Pedido>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snap.hasError) return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.error_outline, size: 42), const Text('Error al cargar los pedidos'),
            TextButton(onPressed: _cargar, child: const Text('Reintentar')),
          ]));
          final lista = snap.data ?? [];
          if (lista.isEmpty) return Center(child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.inbox_outlined, size: 56, color: kVerde),
              const SizedBox(height: 12),
              const Text('No hay pedidos que mostrar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const Text('Prueba otra búsqueda o registra un pedido nuevo.', textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton.icon(onPressed: () async {
                await Navigator.push(context, MaterialPageRoute(builder: (_) => const FormularioPedidoScreen()));
                if (mounted) _cargar();
              }, icon: const Icon(Icons.add), label: const Text('Nuevo pedido')),
            ]),
          ));
          return RefreshIndicator(
            onRefresh: () async => _cargar(),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 90),
              itemCount: lista.length,
              itemBuilder: (context, i) => Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.local_laundry_service)),
                  title: Text(lista[i].cliente),
                  subtitle: Text('Código ${lista[i].codigo} · ${lista[i].kilos.toStringAsFixed(2)} kg\n${lista[i].estadoPedido} · ${lista[i].estadoPago}'),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    await Navigator.push(context, MaterialPageRoute(builder: (_) => DetallePedidoScreen(pedido: lista[i])));
                    if (mounted) _cargar();
                  },
                ),
              ),
            ),
          );
        },
      )),
    ]),
    floatingActionButton: FloatingActionButton(
      onPressed: () async {
        await Navigator.push(context, MaterialPageRoute(builder: (_) => const FormularioPedidoScreen()));
        if (mounted) _cargar();
      },
      child: const Icon(Icons.add),
    ),
  );
}
