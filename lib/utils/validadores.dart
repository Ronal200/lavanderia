class Validadores {
  static String? requerido(String? valor, String campo) {
    if (valor == null || valor.trim().isEmpty) return 'Ingrese $campo.';
    return null;
  }

  static String? cliente(String? valor) {
    final base = requerido(valor, 'el nombre del cliente');
    if (base != null) return base;
    if (valor!.trim().length < 3) return 'El nombre debe tener al menos 3 caracteres.';
    if (valor.trim().length > 80) return 'El nombre no debe superar 80 caracteres.';
    return null;
  }

  static String? telefono(String? valor) {
    final base = requerido(valor, 'el teléfono');
    if (base != null) return base;
    final limpio = valor!.replaceAll(RegExp(r'[\s+\-()]'), '');
    if (!RegExp(r'^\d{7,15}$').hasMatch(limpio)) {
      return 'Ingrese un teléfono válido (7 a 15 dígitos).';
    }
    return null;
  }

  static String? cantidad(String? valor) {
    final n = int.tryParse(valor ?? '');
    if (n == null || n < 1 || n > 500) return 'La cantidad debe estar entre 1 y 500.';
    return null;
  }

  static String? precio(String? valor) {
    final n = double.tryParse((valor ?? '').replaceAll(',', '.'));
    if (n == null || n < 0 || n > 100000) return 'Ingrese un precio válido mayor o igual a S/ 0.';
    return null;
  }

  static String? prendas(String? valor) {
    final base = requerido(valor, 'las prendas');
    if (base != null) return base;
    if (valor!.trim().length > 200) return 'Describa las prendas en máximo 200 caracteres.';
    return null;
  }
}
