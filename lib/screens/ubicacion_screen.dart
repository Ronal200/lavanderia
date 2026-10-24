import 'package:flutter/material.dart';
import '../utils/constantes.dart';

class UbicacionScreen extends StatelessWidget {
  const UbicacionScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Cómo llegar')),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      Container(
        height: 220,
        decoration: BoxDecoration(
          color: const Color(0xFFE6F1EA),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFC8DED0)),
        ),
        child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.map_outlined, size: 76, color: kVerde),
          SizedBox(height: 12),
          Text('Mapa de la lavandería', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          Text('Interfaz preparada para la segunda unidad'),
        ]),
      ),
      const SizedBox(height: 22),
      const Text('Encuentra nuestra lavandería', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      const Text('En la segunda unidad se integrará el GPS para mostrar la ubicación de la lavandería y orientar al usuario hasta el establecimiento.'),
      const SizedBox(height: 18),
      const _Pendiente(icono: Icons.my_location, texto: 'Obtener ubicación actual del usuario'),
      const _Pendiente(icono: Icons.pin_drop_outlined, texto: 'Configurar las coordenadas de la lavandería'),
      const _Pendiente(icono: Icons.route_outlined, texto: 'Mostrar mapa y ruta para llegar'),
      const _Pendiente(icono: Icons.security_outlined, texto: 'Solicitar permisos de ubicación y manejar su denegación'),
      const SizedBox(height: 20),
      FilledButton.icon(
        onPressed: null,
        icon: const Icon(Icons.lock_clock_outlined),
        label: const Text('GPS pendiente para la segunda unidad'),
      ),
    ]),
  );
}

class _Pendiente extends StatelessWidget {
  final IconData icono;
  final String texto;
  const _Pendiente({required this.icono, required this.texto});
  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: const Icon(Icons.radio_button_unchecked, color: kVerde),
    title: Text(texto),
    trailing: const Icon(Icons.schedule, color: Colors.orange),
  );
}
