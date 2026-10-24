# Gestión de Lavandería — Flutter

Aplicación Flutter Android con dos accesos separados: **cliente** y **administrador**. La navegación GPS continúa siendo solo una interfaz de preparación para la segunda unidad.

## Funciones
- **Cliente:** ingresa el código de 6 caracteres que recibió al entregar su ropa y consulta estado, peso, pago y fecha de entrega.
- **Administrador:** requiere un PIN de acceso de 6 dígitos para registrar pedidos, editar/eliminar pedidos, cambiar estado, consultar pagos y ver montos pendientes/cobrados.
- Código único automático de pedido: 6 caracteres entre `A-Z` y `0-9`, por ejemplo `A7K2P9`.
- Registro de kilos y tarifa por kilo. El total se calcula automáticamente como `kilos × tarifa por kilo`.
- Confirmación en ventana flotante antes de cambiar estado del pedido o del pago.
- Persistencia SQLite, búsqueda por cliente/prenda/teléfono/código, filtros y actualización al regresar de pantallas.
- Migración automática de la base de datos anterior para añadir código, kilos y tarifa.
- Pantalla de navegación GPS como placeholder, sin activar GPS ni mapas.

## PIN administrador
El PIN inicial del proyecto es **864210**. Está definido en `lib/screens/portal_screen.dart`, dentro de `AccesoAdminScreen.pinAdministrador`. Cámbialo antes de instalar o distribuir la app. Este PIN local sirve como control básico de acceso, no como autenticación segura para un sistema publicado.

## Ejecutar
1. Instala Flutter y configura un emulador o conecta un teléfono Android.
2. Abre la carpeta `lavanderia_flutter` en VS Code.
3. Ejecuta:
```bash
flutter pub get
flutter analyze
flutter run
```
4. Para generar el APK:
```bash
flutter build apk --release
```
Ruta habitual: `build/app/outputs/flutter-apk/app-release.apk`.

## Notas
- Los datos permanecen en el dispositivo donde se registran. Esta versión no sincroniza entre distintos teléfonos.
- El código de consulta no es una contraseña personal; se recomienda entregar un código distinto por pedido y no publicar datos sensibles del cliente.
- La compilación debe comprobarse en el equipo que tenga Flutter y Android SDK instalados.
