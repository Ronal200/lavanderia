class Pedido {
  final int? id;
  final String codigo;
  final String cliente;
  final String telefono;
  final String prendas;
  final int cantidad;
  final double kilos;
  final double precioPorKilo;
  final DateTime fechaRecepcion;
  final DateTime fechaEntrega;
  final double precio;
  final String estadoPedido;
  final String estadoPago;
  final String observaciones;

  const Pedido({this.id, this.codigo = '', required this.cliente, required this.telefono,
    required this.prendas, required this.cantidad, this.kilos = 0, this.precioPorKilo = 0,
    required this.fechaRecepcion, required this.fechaEntrega, required this.precio,
    required this.estadoPedido, required this.estadoPago, this.observaciones = ''});

  Map<String, Object?> toMap() => {'id': id, 'codigo': codigo, 'cliente': cliente,
    'telefono': telefono, 'prendas': prendas, 'cantidad': cantidad, 'kilos': kilos,
    'precio_por_kilo': precioPorKilo, 'fecha_recepcion': fechaRecepcion.toIso8601String(),
    'fecha_entrega': fechaEntrega.toIso8601String(), 'precio': precio,
    'estado_pedido': estadoPedido, 'estado_pago': estadoPago, 'observaciones': observaciones};

  factory Pedido.fromMap(Map<String, Object?> map) => Pedido(
    id: map['id'] as int, codigo: (map['codigo'] as String?) ?? '',
    cliente: map['cliente'] as String, telefono: map['telefono'] as String,
    prendas: map['prendas'] as String, cantidad: map['cantidad'] as int,
    kilos: (map['kilos'] as num?)?.toDouble() ?? 0,
    precioPorKilo: (map['precio_por_kilo'] as num?)?.toDouble() ?? 0,
    fechaRecepcion: DateTime.parse(map['fecha_recepcion'] as String),
    fechaEntrega: DateTime.parse(map['fecha_entrega'] as String),
    precio: (map['precio'] as num).toDouble(), estadoPedido: map['estado_pedido'] as String,
    estadoPago: map['estado_pago'] as String, observaciones: (map['observaciones'] as String?) ?? '');

  Pedido copyWith({String? estadoPedido, String? estadoPago}) => Pedido(
    id: id, codigo: codigo, cliente: cliente, telefono: telefono, prendas: prendas,
    cantidad: cantidad, kilos: kilos, precioPorKilo: precioPorKilo,
    fechaRecepcion: fechaRecepcion, fechaEntrega: fechaEntrega, precio: precio,
    estadoPedido: estadoPedido ?? this.estadoPedido, estadoPago: estadoPago ?? this.estadoPago,
    observaciones: observaciones);
}
