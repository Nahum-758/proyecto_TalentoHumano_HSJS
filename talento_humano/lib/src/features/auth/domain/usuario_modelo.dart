class UsuarioModelo {
  final String id;
  final String nombre;
  final String correo;
  final String rol; // 'admin' o 'empleado'
  final String puesto;
  final DateTime fechaIngreso;

  UsuarioModelo({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.rol,
    required this.puesto,
    required this.fechaIngreso,
  });

  factory UsuarioModelo.fromMap(String id, Map<String, dynamic> data) {
    final rawFecha = data['fecha_ingreso'];
    DateTime fecha;
    if (rawFecha is DateTime) {
      fecha = rawFecha;
    } else if (rawFecha is String) {
      fecha = DateTime.tryParse(rawFecha) ?? DateTime.now();
    } else {
      fecha = DateTime.now();
    }

    return UsuarioModelo(
      id: id,
      nombre: (data['nombre'] ?? '').toString(),
      correo: (data['correo'] ?? '').toString(),
      rol: (data['rol'] ?? 'empleado').toString(),
      puesto: (data['puesto'] ?? '').toString(),
      fechaIngreso: fecha,
    );
  }
}