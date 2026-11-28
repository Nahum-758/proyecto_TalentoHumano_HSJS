// Modelos del diagrama de clases que faltaban en la app:
// Departamento, Puesto, Notificacion, AdministradorRH, CalendarioLaboral,
// Reporte y el enum EstadoLaboral.

DateTime? _fechaOpcional(dynamic v) =>
    v == null ? null : DateTime.tryParse(v.toString());

DateTime _fecha(dynamic v, [DateTime? fallback]) =>
    _fechaOpcional(v) ?? fallback ?? DateTime.now();

bool _bool(dynamic v, [bool fallback = false]) {
  if (v == null) return fallback;
  if (v is bool) return v;
  final t = v.toString().toLowerCase();
  return t == 'true' || t == '1' || t == 't';
}

String _soloFecha(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// Estado laboral del empleado (atributo `estadoLaboral` del diagrama).
enum EstadoLaboral {
  activo('ACTIVO', 'Activo'),
  vacaciones('VACACIONES', 'De vacaciones'),
  incapacidad('INCAPACIDAD', 'Incapacidad'),
  suspendido('SUSPENDIDO', 'Suspendido'),
  baja('BAJA', 'Baja');

  final String clave;
  final String etiqueta;
  const EstadoLaboral(this.clave, this.etiqueta);

  static EstadoLaboral desdeClave(String? clave, {bool activo = true}) {
    final c = (clave ?? '').trim().toUpperCase();
    for (final e in EstadoLaboral.values) {
      if (e.clave == c) return e;
    }
    return activo ? EstadoLaboral.activo : EstadoLaboral.baja;
  }
}

/// Departamento — agrupa 0..* empleados.
class Departamento {
  final String id;
  final String nombre;

  const Departamento({required this.id, required this.nombre});

  Map<String, dynamic> toMap() => {'id': id, 'nombre': nombre};

  factory Departamento.fromMap(Map<String, dynamic> m) => Departamento(
        id: (m['id'] ?? '').toString(),
        nombre: (m['nombre'] ?? '').toString(),
      );
}

/// Puesto — define 0..* empleados.
class Puesto {
  final String id;
  final String nombre;

  const Puesto({required this.id, required this.nombre});

  Map<String, dynamic> toMap() => {'id': id, 'nombre': nombre};

  factory Puesto.fromMap(Map<String, dynamic> m) => Puesto(
        id: (m['id'] ?? '').toString(),
        nombre: (m['nombre'] ?? '').toString(),
      );
}

/// Notificación — un empleado (o administrador) recibe 0..* notificaciones.
class Notificacion {
  final String id;

  /// Empleado destinatario. Si es null, la notificación es para RH (admins).
  final String? idEmpleado;
  final String mensaje;
  final DateTime fechaEnvio;
  final bool leida;

  Notificacion({
    required this.id,
    this.idEmpleado,
    required this.mensaje,
    DateTime? fechaEnvio,
    this.leida = false,
  }) : fechaEnvio = fechaEnvio ?? DateTime.now();

  bool get esParaRH => idEmpleado == null || idEmpleado!.isEmpty;

  Notificacion marcarLeida() => Notificacion(
        id: id,
        idEmpleado: idEmpleado,
        mensaje: mensaje,
        fechaEnvio: fechaEnvio,
        leida: true,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'id_empleado': idEmpleado,
        'mensaje': mensaje,
        'fecha_envio': fechaEnvio.toIso8601String(),
        'leida': leida,
      };

  factory Notificacion.fromMap(Map<String, dynamic> m) => Notificacion(
        id: (m['id'] ?? '').toString(),
        idEmpleado: m['id_empleado']?.toString(),
        mensaje: (m['mensaje'] ?? '').toString(),
        fechaEnvio: _fecha(m['fecha_envio']),
        leida: _bool(m['leida']),
      );
}

/// Administrador de RH — gestiona empleados, autoriza solicitudes,
/// registra incidencias y genera reportes.
class AdministradorRH {
  final String id;
  final String nombre;
  final String area;

  const AdministradorRH({
    required this.id,
    required this.nombre,
    this.area = 'Recursos Humanos',
  });
}

/// Día del calendario laboral (festivos / inhábiles).
class DiaCalendario {
  final String id;
  final DateTime fecha;
  final String descripcion;
  final bool esFestivo;

  DiaCalendario({
    required this.id,
    required DateTime fecha,
    required this.descripcion,
    this.esFestivo = true,
  }) : fecha = DateTime(fecha.year, fecha.month, fecha.day);

  Map<String, dynamic> toMap() => {
        'id': id,
        'fecha': _soloFecha(fecha),
        'descripcion': descripcion,
        'es_festivo': esFestivo,
      };

  factory DiaCalendario.fromMap(Map<String, dynamic> m) => DiaCalendario(
        id: (m['id'] ?? '').toString(),
        fecha: _fecha(m['fecha']),
        descripcion: (m['descripcion'] ?? '').toString(),
        esFestivo: _bool(m['es_festivo'], true),
      );
}

/// Calendario laboral: sabe qué días son hábiles.
class CalendarioLaboral {
  final List<DiaCalendario> dias;

  const CalendarioLaboral(this.dias);

  bool esFestivo(DateTime fecha) => dias.any(
        (d) =>
            d.esFestivo &&
            d.fecha.year == fecha.year &&
            d.fecha.month == fecha.month &&
            d.fecha.day == fecha.day,
      );

  bool esDiaHabil(DateTime fecha) =>
      fecha.weekday != DateTime.saturday &&
      fecha.weekday != DateTime.sunday &&
      !esFestivo(fecha);

  /// Días hábiles entre [inicio] y [fin], ambos incluidos.
  int diasHabilesEntre(DateTime inicio, DateTime fin) {
    var d = DateTime(inicio.year, inicio.month, inicio.day);
    final f = DateTime(fin.year, fin.month, fin.day);
    var total = 0;
    while (!d.isAfter(f)) {
      if (esDiaHabil(d)) total++;
      d = DateTime(d.year, d.month, d.day + 1);
    }
    return total;
  }
}

/// Reporte generado por un administrador de RH.
class Reporte {
  final String id;
  final String tipoReporte;
  final DateTime fechaGeneracion;
  final String descripcion;
  final String parametros;

  /// Id del AdministradorRH que lo generó.
  final String? generadoPor;

  Reporte({
    required this.id,
    required this.tipoReporte,
    DateTime? fechaGeneracion,
    required this.descripcion,
    this.parametros = '',
    this.generadoPor,
  }) : fechaGeneracion = fechaGeneracion ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'tipo_reporte': tipoReporte,
        'fecha_generacion': fechaGeneracion.toIso8601String(),
        'descripcion': descripcion,
        'parametros': parametros,
        'generado_por': generadoPor,
      };

  factory Reporte.fromMap(Map<String, dynamic> m) => Reporte(
        id: (m['id'] ?? '').toString(),
        tipoReporte: (m['tipo_reporte'] ?? '').toString(),
        fechaGeneracion: _fecha(m['fecha_generacion']),
        descripcion: (m['descripcion'] ?? '').toString(),
        parametros: (m['parametros'] ?? '').toString(),
        generadoPor: m['generado_por']?.toString(),
      );
}

/// Tipos de reporte que puede generar RH.
class TiposReporte {
  static const plantilla = 'Plantilla activa';
  static const bajas = 'Bajas';
  static const solicitudes = 'Solicitudes';
  static const vacaciones = 'Saldos de vacaciones';
  static const incidencias = 'Incidencias';

  static const todos = [plantilla, bajas, solicitudes, vacaciones, incidencias];
}
