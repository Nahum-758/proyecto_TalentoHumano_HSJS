import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:talento_humano/src/core/modelos_rh.dart';

export 'package:talento_humano/src/core/modelos_rh.dart';

class RangoTabuladorVacaciones {
  final int minAnios;
  final int maxAnios;
  final String rangoLabel;
  final int dias;

  const RangoTabuladorVacaciones({
    required this.minAnios,
    required this.maxAnios,
    required this.rangoLabel,
    required this.dias,
  });
}

const List<RangoTabuladorVacaciones> kTabuladorVacacionesHsjs = [
  RangoTabuladorVacaciones(
    minAnios: 1,
    maxAnios: 1,
    rangoLabel: '1 año',
    dias: 12,
  ),
  RangoTabuladorVacaciones(
    minAnios: 2,
    maxAnios: 2,
    rangoLabel: '2 años',
    dias: 14,
  ),
  RangoTabuladorVacaciones(
    minAnios: 3,
    maxAnios: 3,
    rangoLabel: '3 años',
    dias: 16,
  ),
  RangoTabuladorVacaciones(
    minAnios: 4,
    maxAnios: 4,
    rangoLabel: '4 años',
    dias: 18,
  ),
  RangoTabuladorVacaciones(
    minAnios: 5,
    maxAnios: 5,
    rangoLabel: '5 años',
    dias: 20,
  ),
  RangoTabuladorVacaciones(
    minAnios: 6,
    maxAnios: 10,
    rangoLabel: '6 a 10 años',
    dias: 22,
  ),
  RangoTabuladorVacaciones(
    minAnios: 11,
    maxAnios: 15,
    rangoLabel: '11 a 15 años',
    dias: 24,
  ),
  RangoTabuladorVacaciones(
    minAnios: 16,
    maxAnios: 20,
    rangoLabel: '16 a 20 años',
    dias: 26,
  ),
  RangoTabuladorVacaciones(
    minAnios: 21,
    maxAnios: 25,
    rangoLabel: '21 a 25 años',
    dias: 28,
  ),
  RangoTabuladorVacaciones(
    minAnios: 26,
    maxAnios: 30,
    rangoLabel: '26 a 30 años',
    dias: 30,
  ),
  RangoTabuladorVacaciones(
    minAnios: 31,
    maxAnios: 99,
    rangoLabel: '31 años o más',
    dias: 32,
  ),
];

class UsuarioCuenta {
  final String id;
  final String correo;
  final String password;
  final String rol; // 'admin' o 'empleado'
  final String? empleadoId;

  const UsuarioCuenta({
    required this.id,
    required this.correo,
    required this.password,
    required this.rol,
    this.empleadoId,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'correo': correo,
        'password': password,
        'rol': rol,
        'empleado_id': empleadoId,
      };

  factory UsuarioCuenta.fromMap(Map<String, dynamic> map) => UsuarioCuenta(
        id: (map['id'] ?? '').toString(),
        correo: (map['correo'] ?? '').toString(),
        password: (map['password'] ?? '').toString(),
        rol: (map['rol'] ?? 'empleado').toString(),
        empleadoId: map['empleado_id']?.toString(),
      );
}

class Empleado {
  final String id;
  final String numeroEmpleado;
  final String nombre;
  final String puesto;
  final String? puestoId;
  final String? departamentoId;
  final EstadoLaboral estadoLaboral;
  final DateTime fechaIngreso;
  final DateTime? fechaNacimiento;
  final int vecesVacacionesAnio;
  final int diasPorPeriodoVacaciones;
  final int diasVacacionesUsados;
  final DateTime vigenciaVacaciones;

  final int permisosEntradaTardeTotal;
  final int permisosEntradaTardeUsados;
  final int permisosSalidaAntesTotal;
  final int permisosSalidaAntesUsados;
  final int faltasConGoceTotal;
  final int faltasConGoceUsados;
  final int faltasSinGoceTotal;
  final int faltasSinGoceUsados;
  final int diaCumpleanosTotal;
  final int diaCumpleanosUsados;
  final int fallecimientoPrimeraLineaTotal;
  final int fallecimientoPrimeraLineaUsados;

  final bool activo;
  final DateTime? fechaBaja;
  final String motivoBaja;

  Empleado({
    required this.id,
    this.numeroEmpleado = '',
    required this.nombre,
    required this.puesto,
    this.puestoId,
    this.departamentoId,
    EstadoLaboral? estadoLaboral,
    required this.fechaIngreso,
    this.fechaNacimiento,
    this.vecesVacacionesAnio = 2,
    this.diasPorPeriodoVacaciones = 6,
    this.diasVacacionesUsados = 0,
    DateTime? vigenciaVacaciones,
    this.permisosEntradaTardeTotal = 4,
    this.permisosEntradaTardeUsados = 0,
    this.permisosSalidaAntesTotal = 4,
    this.permisosSalidaAntesUsados = 0,
    this.faltasConGoceTotal = 4,
    this.faltasConGoceUsados = 0,
    this.faltasSinGoceTotal = 4,
    this.faltasSinGoceUsados = 0,
    this.diaCumpleanosTotal = 1,
    this.diaCumpleanosUsados = 0,
    this.fallecimientoPrimeraLineaTotal = 3,
    this.fallecimientoPrimeraLineaUsados = 0,
    this.activo = true,
    this.fechaBaja,
    this.motivoBaja = '',
  })  : vigenciaVacaciones =
            vigenciaVacaciones ?? TalentoHumanoStore.finCicloAnual(),
        estadoLaboral = !activo
            ? EstadoLaboral.baja
            : (estadoLaboral == null || estadoLaboral == EstadoLaboral.baja)
                ? EstadoLaboral.activo
                : estadoLaboral;

  static const Object _sinCambio = Object();

  Empleado copyWith({
    String? numeroEmpleado,
    String? nombre,
    String? puesto,
    Object? puestoId = _sinCambio,
    Object? departamentoId = _sinCambio,
    EstadoLaboral? estadoLaboral,
    DateTime? fechaIngreso,
    Object? fechaNacimiento = _sinCambio,
    int? vecesVacacionesAnio,
    int? diasPorPeriodoVacaciones,
    int? diasVacacionesUsados,
    DateTime? vigenciaVacaciones,
    int? permisosEntradaTardeTotal,
    int? permisosEntradaTardeUsados,
    int? permisosSalidaAntesTotal,
    int? permisosSalidaAntesUsados,
    int? faltasConGoceTotal,
    int? faltasConGoceUsados,
    int? faltasSinGoceTotal,
    int? faltasSinGoceUsados,
    int? diaCumpleanosTotal,
    int? diaCumpleanosUsados,
    int? fallecimientoPrimeraLineaTotal,
    int? fallecimientoPrimeraLineaUsados,
    bool? activo,
    Object? fechaBaja = _sinCambio,
    String? motivoBaja,
  }) {
    return Empleado(
      id: id,
      numeroEmpleado: numeroEmpleado ?? this.numeroEmpleado,
      nombre: nombre ?? this.nombre,
      puesto: puesto ?? this.puesto,
      puestoId: identical(puestoId, _sinCambio)
          ? this.puestoId
          : puestoId as String?,
      departamentoId: identical(departamentoId, _sinCambio)
          ? this.departamentoId
          : departamentoId as String?,
      estadoLaboral: estadoLaboral ?? this.estadoLaboral,
      fechaIngreso: fechaIngreso ?? this.fechaIngreso,
      fechaNacimiento: identical(fechaNacimiento, _sinCambio)
          ? this.fechaNacimiento
          : fechaNacimiento as DateTime?,
      vecesVacacionesAnio: vecesVacacionesAnio ?? this.vecesVacacionesAnio,
      diasPorPeriodoVacaciones:
          diasPorPeriodoVacaciones ?? this.diasPorPeriodoVacaciones,
      diasVacacionesUsados: diasVacacionesUsados ?? this.diasVacacionesUsados,
      vigenciaVacaciones: vigenciaVacaciones ?? this.vigenciaVacaciones,
      permisosEntradaTardeTotal:
          permisosEntradaTardeTotal ?? this.permisosEntradaTardeTotal,
      permisosEntradaTardeUsados:
          permisosEntradaTardeUsados ?? this.permisosEntradaTardeUsados,
      permisosSalidaAntesTotal:
          permisosSalidaAntesTotal ?? this.permisosSalidaAntesTotal,
      permisosSalidaAntesUsados:
          permisosSalidaAntesUsados ?? this.permisosSalidaAntesUsados,
      faltasConGoceTotal: faltasConGoceTotal ?? this.faltasConGoceTotal,
      faltasConGoceUsados: faltasConGoceUsados ?? this.faltasConGoceUsados,
      faltasSinGoceTotal: faltasSinGoceTotal ?? this.faltasSinGoceTotal,
      faltasSinGoceUsados: faltasSinGoceUsados ?? this.faltasSinGoceUsados,
      diaCumpleanosTotal: diaCumpleanosTotal ?? this.diaCumpleanosTotal,
      diaCumpleanosUsados: diaCumpleanosUsados ?? this.diaCumpleanosUsados,
      fallecimientoPrimeraLineaTotal:
          fallecimientoPrimeraLineaTotal ?? this.fallecimientoPrimeraLineaTotal,
      fallecimientoPrimeraLineaUsados: fallecimientoPrimeraLineaUsados ??
          this.fallecimientoPrimeraLineaUsados,
      activo: activo ?? this.activo,
      fechaBaja:
          identical(fechaBaja, _sinCambio) ? this.fechaBaja : fechaBaja as DateTime?,
      motivoBaja: motivoBaja ?? this.motivoBaja,
    );
  }

  /// Saldo disponible para un tipo de solicitud (vacaciones o permiso).
  int saldoDisponiblePara(String tipo) {
    final t = tipo.toLowerCase();
    if (t.contains('vacacion')) return diasVacacionesDisponibles;
    if (t.contains('entrada tarde')) return permisosEntradaTardeDisponibles;
    if (t.contains('salida antes')) return permisosSalidaAntesDisponibles;
    if (t.contains('con goce')) return faltasConGoceDisponibles;
    if (t.contains('sin goce')) return faltasSinGoceDisponibles;
    if (t.contains('cumple')) return diaCumpleanosDisponibles;
    if (t.contains('fallecimiento')) {
      final d = fallecimientoPrimeraLineaDisponibles;
      return d < 3 ? d : 3;
    }
    return 0;
  }

  /// Años completos de antigüedad (método `calcularAntiguedad()` del diagrama).
  int calcularAntiguedad([DateTime? referencia]) {
    final hoy = referencia ?? DateTime.now();
    int anios = hoy.year - fechaIngreso.year;
    if (hoy.month < fechaIngreso.month ||
        (hoy.month == fechaIngreso.month && hoy.day < fechaIngreso.day)) {
      anios--;
    }
    return anios < 0 ? 0 : anios;
  }

  int get aniosCumplidos => calcularAntiguedad();

  String get antiguedadTexto {
    final hoy = DateTime.now();
    if (hoy.isBefore(fechaIngreso)) return '0 meses';
    int mesesTotales =
        (hoy.year - fechaIngreso.year) * 12 + (hoy.month - fechaIngreso.month);
    if (hoy.day < fechaIngreso.day) {
      mesesTotales--;
    }
    if (mesesTotales < 0) mesesTotales = 0;
    final anios = mesesTotales ~/ 12;
    final meses = mesesTotales % 12;
    if (anios == 0) {
      return '$meses ${meses == 1 ? 'mes' : 'meses'}';
    }
    if (meses == 0) {
      return '$anios ${anios == 1 ? 'año' : 'años'}';
    }
    return '$anios ${anios == 1 ? 'año' : 'años'} y $meses ${meses == 1 ? 'mes' : 'meses'}';
  }

  int get diasVacacionesPorTabulador {
    final anios = aniosCumplidos;
    if (anios < 1) return 0;
    for (final fila in kTabuladorVacacionesHsjs) {
      if (anios >= fila.minAnios && anios <= fila.maxAnios) {
        return fila.dias;
      }
    }
    return 32;
  }

  int get diasVacacionesTotales =>
      vecesVacacionesAnio * diasPorPeriodoVacaciones;

  int get diasVacacionesDisponibles {
    final rest = diasVacacionesTotales - diasVacacionesUsados;
    return rest < 0 ? 0 : rest;
  }

  int get permisosEntradaTardeDisponibles {
    final r = permisosEntradaTardeTotal - permisosEntradaTardeUsados;
    return r < 0 ? 0 : r;
  }

  int get permisosSalidaAntesDisponibles {
    final r = permisosSalidaAntesTotal - permisosSalidaAntesUsados;
    return r < 0 ? 0 : r;
  }

  int get faltasConGoceDisponibles {
    final r = faltasConGoceTotal - faltasConGoceUsados;
    return r < 0 ? 0 : r;
  }

  int get faltasSinGoceDisponibles {
    final r = faltasSinGoceTotal - faltasSinGoceUsados;
    return r < 0 ? 0 : r;
  }

  int get diaCumpleanosDisponibles {
    final r = diaCumpleanosTotal - diaCumpleanosUsados;
    return r < 0 ? 0 : r;
  }

  int get fallecimientoPrimeraLineaDisponibles {
    final r = fallecimientoPrimeraLineaTotal - fallecimientoPrimeraLineaUsados;
    return r < 0 ? 0 : r;
  }

  /// Columnas agregadas en la migración del diagrama de clases.
  static const columnasNuevas = [
    'numero_empleado',
    'puesto_id',
    'departamento_id',
    'estado_laboral',
  ];

  Map<String, dynamic> toMap() => {
        'id': id,
        'numero_empleado': numeroEmpleado,
        'nombre': nombre,
        'puesto': puesto,
        'puesto_id': puestoId,
        'departamento_id': departamentoId,
        'estado_laboral': estadoLaboral.clave,
        'fecha_ingreso': fechaIngreso.toIso8601String(),
        'fecha_nacimiento': fechaNacimiento?.toIso8601String(),
        'veces_vacaciones_anio': vecesVacacionesAnio,
        'dias_por_periodo_vacaciones': diasPorPeriodoVacaciones,
        'dias_vacaciones_usados': diasVacacionesUsados,
        'vigencia_vacaciones': vigenciaVacaciones.toIso8601String(),
        'permisos_entrada_tarde_total': permisosEntradaTardeTotal,
        'permisos_entrada_tarde_usados': permisosEntradaTardeUsados,
        'permisos_salida_antes_total': permisosSalidaAntesTotal,
        'permisos_salida_antes_usados': permisosSalidaAntesUsados,
        'faltas_con_goce_total': faltasConGoceTotal,
        'faltas_con_goce_usados': faltasConGoceUsados,
        'faltas_sin_goce_total': faltasSinGoceTotal,
        'faltas_sin_goce_usados': faltasSinGoceUsados,
        'dia_cumpleanos_total': diaCumpleanosTotal,
        'dia_cumpleanos_usados': diaCumpleanosUsados,
        'fallecimiento_primera_linea_total': fallecimientoPrimeraLineaTotal,
        'fallecimiento_primera_linea_usados': fallecimientoPrimeraLineaUsados,
        'activo': activo,
        'fecha_baja': fechaBaja?.toIso8601String(),
        'motivo_baja': motivoBaja,
      };

  factory Empleado.fromMap(Map<String, dynamic> map) {
    DateTime parseFecha(dynamic v, DateTime fallback) {
      if (v == null) return fallback;
      return DateTime.tryParse(v.toString()) ?? fallback;
    }

    int parseInt(dynamic v, int fallback) {
      if (v == null) return fallback;
      if (v is int) return v;
      return int.tryParse(v.toString()) ?? fallback;
    }

    final activo = map['activo'] is bool
        ? map['activo'] as bool
        : (map['activo']?.toString().toLowerCase() != 'false');

    return Empleado(
      id: (map['id'] ?? '').toString(),
      numeroEmpleado: (map['numero_empleado'] ?? '').toString(),
      nombre: (map['nombre'] ?? '').toString(),
      puesto: (map['puesto'] ?? 'Operativo').toString(),
      puestoId: map['puesto_id']?.toString(),
      departamentoId: map['departamento_id']?.toString(),
      estadoLaboral: EstadoLaboral.desdeClave(
        map['estado_laboral']?.toString(),
        activo: activo,
      ),
      fechaIngreso: parseFecha(map['fecha_ingreso'], DateTime.now()),
      fechaNacimiento: map['fecha_nacimiento'] != null
          ? DateTime.tryParse(map['fecha_nacimiento'].toString())
          : null,
      vecesVacacionesAnio: parseInt(map['veces_vacaciones_anio'], 2),
      diasPorPeriodoVacaciones: parseInt(map['dias_por_periodo_vacaciones'], 6),
      diasVacacionesUsados: parseInt(map['dias_vacaciones_usados'], 0),
      vigenciaVacaciones: parseFecha(
        map['vigencia_vacaciones'],
        TalentoHumanoStore.finCicloAnual(),
      ),
      permisosEntradaTardeTotal:
          parseInt(map['permisos_entrada_tarde_total'], 4),
      permisosEntradaTardeUsados:
          parseInt(map['permisos_entrada_tarde_usados'], 0),
      permisosSalidaAntesTotal:
          parseInt(map['permisos_salida_antes_total'], 4),
      permisosSalidaAntesUsados:
          parseInt(map['permisos_salida_antes_usados'], 0),
      faltasConGoceTotal: parseInt(map['faltas_con_goce_total'], 4),
      faltasConGoceUsados: parseInt(map['faltas_con_goce_usados'], 0),
      faltasSinGoceTotal: parseInt(map['faltas_sin_goce_total'], 4),
      faltasSinGoceUsados: parseInt(map['faltas_sin_goce_usados'], 0),
      diaCumpleanosTotal: parseInt(map['dia_cumpleanos_total'], 1),
      diaCumpleanosUsados: parseInt(map['dia_cumpleanos_usados'], 0),
      fallecimientoPrimeraLineaTotal:
          parseInt(map['fallecimiento_primera_linea_total'], 3),
      fallecimientoPrimeraLineaUsados:
          parseInt(map['fallecimiento_primera_linea_usados'], 0),
      activo: activo,
      fechaBaja: map['fecha_baja'] != null
          ? DateTime.tryParse(map['fecha_baja'].toString())
          : null,
      motivoBaja: (map['motivo_baja'] ?? '').toString(),
    );
  }
}

class SolicitudPermiso {
  final String id;
  final String idEmpleado;
  final String nombreEmpleado;
  final String tipo;
  final String motivo;
  final int diasSolicitados;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final String estatus; // PENDIENTE | AUTORIZADA | RECHAZADA | CANCELADA

  SolicitudPermiso({
    required this.id,
    required this.idEmpleado,
    required this.nombreEmpleado,
    required this.tipo,
    required this.motivo,
    this.diasSolicitados = 1,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    this.estatus = 'PENDIENTE',
  })  : fechaInicio = fechaInicio ?? DateTime.now(),
        fechaFin = fechaFin ?? (fechaInicio ?? DateTime.now());

  Map<String, dynamic> toMap() => {
        'id': id,
        'id_empleado': idEmpleado,
        'nombre_empleado': nombreEmpleado,
        'tipo': tipo,
        'motivo': motivo,
        'dias_solicitados': diasSolicitados,
        'fecha_inicio': fechaInicio.toIso8601String(),
        'fecha_fin': fechaFin.toIso8601String(),
        'estatus': estatus,
      };

  factory SolicitudPermiso.fromMap(Map<String, dynamic> map) =>
      SolicitudPermiso(
        id: (map['id'] ?? '').toString(),
        idEmpleado: (map['id_empleado'] ?? '').toString(),
        nombreEmpleado: (map['nombre_empleado'] ?? '').toString(),
        tipo: (map['tipo'] ?? '').toString(),
        motivo: (map['motivo'] ?? '').toString(),
        diasSolicitados: map['dias_solicitados'] is int
            ? map['dias_solicitados'] as int
            : int.tryParse((map['dias_solicitados'] ?? '1').toString()) ?? 1,
        fechaInicio: map['fecha_inicio'] != null
            ? (DateTime.tryParse(map['fecha_inicio'].toString()) ??
                DateTime.now())
            : DateTime.now(),
        fechaFin: map['fecha_fin'] != null
            ? (DateTime.tryParse(map['fecha_fin'].toString()) ??
                DateTime.now())
            : DateTime.now(),
        estatus: (map['estatus'] ?? 'PENDIENTE').toString(),
      );
}

class RegistroIncidencia {
  final String id;
  final String nombreEmpleado;
  final String tipo; // Reconocimiento | Sanción
  final String titulo;
  final String descripcion;
  final DateTime fecha;

  RegistroIncidencia({
    required this.id,
    required this.nombreEmpleado,
    required this.tipo,
    required this.titulo,
    required this.descripcion,
    DateTime? fecha,
  }) : fecha = fecha ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'nombre_empleado': nombreEmpleado,
        'tipo': tipo,
        'titulo': titulo,
        'descripcion': descripcion,
        'fecha': fecha.toIso8601String(),
      };

  factory RegistroIncidencia.fromMap(Map<String, dynamic> map) =>
      RegistroIncidencia(
        id: (map['id'] ?? '').toString(),
        nombreEmpleado: (map['nombre_empleado'] ?? '').toString(),
        tipo: (map['tipo'] ?? 'Reconocimiento').toString(),
        titulo: (map['titulo'] ?? '').toString(),
        descripcion: (map['descripcion'] ?? '').toString(),
        fecha: map['fecha'] != null
            ? (DateTime.tryParse(map['fecha'].toString()) ?? DateTime.now())
            : DateTime.now(),
      );
}

class TalentoHumanoStore extends ChangeNotifier {
  TalentoHumanoStore._internal();
  static final TalentoHumanoStore instance = TalentoHumanoStore._internal();

  static const String _kEmpleadosKey = 'hsjs_empleados_v1';
  static const String _kUsuariosKey = 'hsjs_usuarios_v1';
  static const String _kSolicitudesKey = 'hsjs_solicitudes_v1';
  static const String _kIncidenciasKey = 'hsjs_incidencias_v1';
  static const String _kDepartamentosKey = 'hsjs_departamentos_v1';
  static const String _kPuestosKey = 'hsjs_puestos_v1';
  static const String _kNotificacionesKey = 'hsjs_notificaciones_v1';
  static const String _kCalendarioKey = 'hsjs_calendario_v1';
  static const String _kReportesKey = 'hsjs_reportes_v1';

  final List<Empleado> _empleados = [];
  final List<UsuarioCuenta> _usuarios = [];
  final List<SolicitudPermiso> _solicitudes = [];
  final List<RegistroIncidencia> _incidencias = [];
  final List<Departamento> _departamentos = [];
  final List<Puesto> _puestos = [];
  final List<Notificacion> _notificaciones = [];
  final List<DiaCalendario> _calendario = [];
  final List<Reporte> _reportes = [];

  String? _empleadoActualId;
  String? _usuarioActualId;
  String? _rolActual;
  bool _cargando = false;
  String? _ultimoError;

  bool get cargando => _cargando;
  String? get ultimoError => _ultimoError;
  String? get rolActual => _rolActual;

  List<Empleado> get empleadosActivos =>
      _empleados.where((e) => e.activo).toList();
  List<Empleado> get empleadosBaja =>
      _empleados.where((e) => !e.activo).toList();
  List<SolicitudPermiso> get solicitudes => List.unmodifiable(_solicitudes);
  List<RegistroIncidencia> get incidencias => List.unmodifiable(_incidencias);
  List<Departamento> get departamentos => List.unmodifiable(
        [..._departamentos]..sort((a, b) => a.nombre.compareTo(b.nombre)),
      );
  List<Puesto> get puestos => List.unmodifiable(
        [..._puestos]..sort((a, b) => a.nombre.compareTo(b.nombre)),
      );
  List<DiaCalendario> get diasCalendario => List.unmodifiable(
        [..._calendario]..sort((a, b) => a.fecha.compareTo(b.fecha)),
      );
  CalendarioLaboral get calendarioLaboral => CalendarioLaboral(_calendario);
  List<Reporte> get reportes => List.unmodifiable(
        [..._reportes]
          ..sort((a, b) => b.fechaGeneracion.compareTo(a.fechaGeneracion)),
      );

  Empleado? get empleadoActual {
    if (_empleadoActualId == null) {
      return empleadosActivos.isNotEmpty ? empleadosActivos.first : null;
    }
    return buscarEmpleadoPorId(_empleadoActualId!);
  }

  /// Administrador de RH con sesión iniciada (null si el rol no es admin).
  AdministradorRH? get administradorActual {
    if (_rolActual != 'admin') return null;
    UsuarioCuenta? u;
    for (final x in _usuarios) {
      if (x.id == _usuarioActualId) u = x;
    }
    final emp =
        _empleadoActualId != null ? buscarEmpleadoPorId(_empleadoActualId!) : null;
    String? nombreDepto;
    if (emp?.departamentoId != null) {
      nombreDepto = buscarDepartamento(emp!.departamentoId!)?.nombre;
    }
    return AdministradorRH(
      id: u?.id ?? 'admin',
      nombre: emp?.nombre ?? u?.correo ?? 'Administrador',
      area: nombreDepto ?? 'Recursos Humanos',
    );
  }

  static DateTime inicioCicloAnual([DateTime? ref]) {
    final hoy = ref ?? DateTime.now();
    if (hoy.month == 12 && hoy.day >= 23) {
      return DateTime(hoy.year, 12, 23);
    }
    return DateTime(hoy.year - 1, 12, 23);
  }

  static DateTime finCicloAnual([DateTime? ref]) {
    final inicio = inicioCicloAnual(ref);
    return DateTime(inicio.year + 1, 12, 22);
  }

  String get cicloAnualTexto {
    final ini = inicioCicloAnual();
    final fin = finCicloAnual();
    return '${fmtFecha(ini)} al ${fmtFecha(fin)}';
  }

  static String fmtFecha(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  static String _nuevoId(String prefijo) =>
      '${prefijo}_${DateTime.now().microsecondsSinceEpoch}';

  bool get _supabaseActivo {
    try {
      Supabase.instance.client;
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Ejecuta una operación remota sin romper la app si Supabase falla.
  Future<void> _remoto(Future<void> Function(SupabaseClient c) op) async {
    if (!_supabaseActivo) return;
    try {
      await op(Supabase.instance.client);
    } catch (e) {
      debugPrint('Supabase: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Búsquedas
  // ---------------------------------------------------------------------------

  Empleado? buscarEmpleadoPorId(String id) {
    for (final e in _empleados) {
      if (e.id == id) return e;
    }
    return null;
  }

  Empleado? buscarEmpleadoPorNombre(String nombre) {
    final n = nombre.trim().toLowerCase();
    for (final e in _empleados) {
      if (e.nombre.trim().toLowerCase() == n) return e;
    }
    return null;
  }

  UsuarioCuenta? buscarUsuarioPorEmpleadoId(String empleadoId) {
    for (final u in _usuarios) {
      if (u.empleadoId == empleadoId) return u;
    }
    return null;
  }

  Departamento? buscarDepartamento(String id) {
    for (final d in _departamentos) {
      if (d.id == id) return d;
    }
    return null;
  }

  Puesto? buscarPuesto(String id) {
    for (final p in _puestos) {
      if (p.id == id) return p;
    }
    return null;
  }

  String nombreDepartamento(String? id) =>
      id == null ? 'Sin departamento' : (buscarDepartamento(id)?.nombre ?? 'Sin departamento');

  List<Empleado> empleadosDeDepartamento(String departamentoId) =>
      _empleados.where((e) => e.departamentoId == departamentoId).toList();

  List<Empleado> empleadosDePuesto(String puestoId) =>
      _empleados.where((e) => e.puestoId == puestoId).toList();

  /// Siguiente número de empleado consecutivo (E0001, E0002, ...).
  String siguienteNumeroEmpleado() {
    var max = 0;
    final re = RegExp(r'(\d+)$');
    for (final e in _empleados) {
      final m = re.firstMatch(e.numeroEmpleado);
      if (m != null) {
        final n = int.tryParse(m.group(1)!) ?? 0;
        if (n > max) max = n;
      }
    }
    return 'E${(max + 1).toString().padLeft(4, '0')}';
  }

  // ---------------------------------------------------------------------------
  // Sesión
  // ---------------------------------------------------------------------------

  void establecerSesionEmpleado(String? empleadoId, {String rol = 'empleado'}) {
    _empleadoActualId = empleadoId;
    _rolActual = rol;
    notifyListeners();
  }

  void cerrarSesion() {
    _empleadoActualId = null;
    _usuarioActualId = null;
    _rolActual = null;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Persistencia local y sincronización
  // ---------------------------------------------------------------------------

  void _cargarLista<T>(
    SharedPreferences prefs,
    String clave,
    List<T> destino,
    T Function(Map<String, dynamic>) fromMap,
  ) {
    final raw = prefs.getString(clave);
    if (raw == null) return;
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      destino
        ..clear()
        ..addAll(list.map((e) => fromMap(Map<String, dynamic>.from(e))));
    } catch (_) {}
  }

  Future<void> cargarLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _cargarLista(prefs, _kEmpleadosKey, _empleados, Empleado.fromMap);
      _cargarLista(prefs, _kUsuariosKey, _usuarios, UsuarioCuenta.fromMap);
      _cargarLista(
          prefs, _kSolicitudesKey, _solicitudes, SolicitudPermiso.fromMap);
      _cargarLista(
          prefs, _kIncidenciasKey, _incidencias, RegistroIncidencia.fromMap);
      _cargarLista(
          prefs, _kDepartamentosKey, _departamentos, Departamento.fromMap);
      _cargarLista(prefs, _kPuestosKey, _puestos, Puesto.fromMap);
      _cargarLista(
          prefs, _kNotificacionesKey, _notificaciones, Notificacion.fromMap);
      _cargarLista(prefs, _kCalendarioKey, _calendario, DiaCalendario.fromMap);
      _cargarLista(prefs, _kReportesKey, _reportes, Reporte.fromMap);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _guardarLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      Future<void> g(String k, Iterable<Map<String, dynamic>> v) =>
          prefs.setString(k, jsonEncode(v.toList()));
      await g(_kEmpleadosKey, _empleados.map((e) => e.toMap()));
      await g(_kUsuariosKey, _usuarios.map((u) => u.toMap()));
      await g(_kSolicitudesKey, _solicitudes.map((s) => s.toMap()));
      await g(_kIncidenciasKey, _incidencias.map((i) => i.toMap()));
      await g(_kDepartamentosKey, _departamentos.map((d) => d.toMap()));
      await g(_kPuestosKey, _puestos.map((p) => p.toMap()));
      await g(_kNotificacionesKey, _notificaciones.map((n) => n.toMap()));
      await g(_kCalendarioKey, _calendario.map((d) => d.toMap()));
      await g(_kReportesKey, _reportes.map((r) => r.toMap()));
    } catch (_) {}
  }

  /// Descarga una tabla. Si la tabla aún no existe en Supabase (migración
  /// pendiente) se conserva la copia local y no se interrumpe el resto.
  Future<void> _descargarTabla<T>(
    SupabaseClient client,
    String tabla,
    List<T> destino,
    T Function(Map<String, dynamic>) fromMap, {
    bool obligatoria = false,
  }) async {
    try {
      final res = await client.from(tabla).select();
      destino
        ..clear()
        ..addAll(
          (res as List<dynamic>)
              .map((e) => fromMap(Map<String, dynamic>.from(e))),
        );
    } catch (e) {
      if (obligatoria) rethrow;
      debugPrint('Tabla "$tabla" no disponible: $e');
    }
  }

  Future<void> sincronizarDesdeSupabase() async {
    if (_cargando) return;
    _cargando = true;
    _ultimoError = null;
    notifyListeners();

    await cargarLocal();

    if (!_supabaseActivo) {
      _cargando = false;
      notifyListeners();
      return;
    }

    try {
      final c = Supabase.instance.client;
      await _descargarTabla(c, 'empleados', _empleados, Empleado.fromMap,
          obligatoria: true);
      await _descargarTabla(c, 'usuarios', _usuarios, UsuarioCuenta.fromMap,
          obligatoria: true);
      await _descargarTabla(
          c, 'solicitudes', _solicitudes, SolicitudPermiso.fromMap,
          obligatoria: true);
      await _descargarTabla(
          c, 'incidencias', _incidencias, RegistroIncidencia.fromMap,
          obligatoria: true);
      await _descargarTabla(
          c, 'departamentos', _departamentos, Departamento.fromMap);
      await _descargarTabla(c, 'puestos', _puestos, Puesto.fromMap);
      await _descargarTabla(
          c, 'notificaciones', _notificaciones, Notificacion.fromMap);
      await _descargarTabla(
          c, 'calendario_laboral', _calendario, DiaCalendario.fromMap);
      await _descargarTabla(c, 'reportes', _reportes, Reporte.fromMap);

      await _guardarLocal();
    } catch (e) {
      _ultimoError = e.toString();
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<String> iniciarSesion({
    required String correo,
    required String password,
  }) async {
    _ultimoError = null;
    if (_usuarios.isEmpty) {
      await sincronizarDesdeSupabase();
    }

    final correoLimpio = correo.trim().toLowerCase();
    UsuarioCuenta? encontrado;
    for (final u in _usuarios) {
      if (u.correo.trim().toLowerCase() == correoLimpio) {
        encontrado = u;
        break;
      }
    }

    if (encontrado == null) {
      _ultimoError = 'Correo no registrado.';
      notifyListeners();
      return 'empleado';
    }

    if (encontrado.password != password) {
      _ultimoError = 'Contraseña incorrecta';
      notifyListeners();
      return 'empleado';
    }

    _empleadoActualId = encontrado.empleadoId;
    _usuarioActualId = encontrado.id;
    _rolActual = encontrado.rol;
    notifyListeners();
    return encontrado.rol;
  }

  // ---------------------------------------------------------------------------
  // Empleados (AdministradorRH "gestiona" Empleado)
  // ---------------------------------------------------------------------------

  Future<void> guardarEmpleado(
    Empleado emp, {
    String? correo,
    String? password,
    String rol = 'empleado',
  }) async {
    if (emp.numeroEmpleado.trim().isEmpty) {
      emp = emp.copyWith(numeroEmpleado: siguienteNumeroEmpleado());
    }
    // Mantiene sincronizado el nombre del puesto con el catálogo.
    if (emp.puestoId != null) {
      final p = buscarPuesto(emp.puestoId!);
      if (p != null && p.nombre != emp.puesto) {
        emp = emp.copyWith(puesto: p.nombre);
      }
    }

    final idx = _empleados.indexWhere((e) => e.id == emp.id);
    if (idx >= 0) {
      _empleados[idx] = emp;
    } else {
      _empleados.add(emp);
    }

    UsuarioCuenta? cuenta;
    if (correo != null && correo.trim().isNotEmpty) {
      final uIdx = _usuarios.indexWhere((u) => u.empleadoId == emp.id);
      final passFinal = (password != null && password.trim().isNotEmpty)
          ? password.trim()
          : (uIdx >= 0 ? _usuarios[uIdx].password : '1234');
      cuenta = UsuarioCuenta(
        id: uIdx >= 0 ? _usuarios[uIdx].id : _nuevoId('usr'),
        correo: correo.trim(),
        password: passFinal,
        rol: rol,
        empleadoId: emp.id,
      );
      if (uIdx >= 0) {
        _usuarios[uIdx] = cuenta;
      } else {
        _usuarios.add(cuenta);
      }
    }

    notifyListeners();
    await _guardarLocal();

    final empFinal = emp;
    final cuentaFinal = cuenta;
    await _remoto((c) async {
      await _upsertEmpleado(c, empFinal);
      if (cuentaFinal != null) {
        await c.from('usuarios').upsert(cuentaFinal.toMap());
      }
    });
  }

  /// Si la migración aún no agregó las columnas nuevas a `empleados`,
  /// reintenta sin ellas para no perder el guardado.
  Future<void> _upsertEmpleado(SupabaseClient c, Empleado emp) async {
    try {
      await c.from('empleados').upsert(emp.toMap());
    } catch (_) {
      final mapa = emp.toMap()
        ..removeWhere((k, _) => Empleado.columnasNuevas.contains(k));
      await c.from('empleados').upsert(mapa);
    }
  }

  Future<void> darDeBajaEmpleado(String id, {String motivo = ''}) async {
    final actual = buscarEmpleadoPorId(id);
    if (actual == null) return;
    await guardarEmpleado(
      actual.copyWith(
        activo: false,
        estadoLaboral: EstadoLaboral.baja,
        fechaBaja: DateTime.now(),
        motivoBaja: motivo,
      ),
    );
  }

  Future<void> reactivarEmpleado(String id) async {
    final actual = buscarEmpleadoPorId(id);
    if (actual == null) return;
    await guardarEmpleado(
      actual.copyWith(
        activo: true,
        estadoLaboral: EstadoLaboral.activo,
        fechaBaja: null,
        motivoBaja: '',
      ),
    );
  }

  Future<void> cambiarEstadoLaboral(String id, EstadoLaboral estado) async {
    final actual = buscarEmpleadoPorId(id);
    if (actual == null) return;
    if (estado == EstadoLaboral.baja) {
      await darDeBajaEmpleado(id, motivo: actual.motivoBaja);
      return;
    }
    await guardarEmpleado(
      actual.copyWith(
        estadoLaboral: estado,
        activo: true,
        fechaBaja: null,
      ),
    );
    await enviarNotificacion(
      idEmpleado: id,
      mensaje: 'Tu estado laboral cambió a: ${estado.etiqueta}.',
    );
  }

  // ---------------------------------------------------------------------------
  // Solicitudes (AdministradorRH "autoriza")
  // ---------------------------------------------------------------------------

  Future<void> crearSolicitud(SolicitudPermiso solicitud) async {
    _solicitudes.insert(0, solicitud);
    notifyListeners();
    await _guardarLocal();

    await _remoto((c) => c.from('solicitudes').insert(solicitud.toMap()));

    await enviarNotificacion(
      idEmpleado: null,
      mensaje:
          '${solicitud.nombreEmpleado} solicitó ${solicitud.tipo} (${solicitud.diasSolicitados} día(s)).',
    );
  }

  /// Devuelve un mensaje de error si no se pudo actualizar.
  Future<String?> actualizarEstatusSolicitud(
    String id,
    String nuevoEstatus, {
    DateTime? fechaAutorizadaInicio,
    DateTime? fechaAutorizadaFin,
  }) async {
    final idx = _solicitudes.indexWhere((s) => s.id == id);
    if (idx == -1) return 'Solicitud no encontrada.';
    final actual = _solicitudes[idx];

    if (actual.estatus != 'AUTORIZADA' && nuevoEstatus == 'AUTORIZADA') {
      final emp = buscarEmpleadoPorId(actual.idEmpleado);
      if (emp == null) return 'No se encontró al colaborador.';
      final disponible = emp.saldoDisponiblePara(actual.tipo);
      if (actual.diasSolicitados > disponible) {
        return 'No se puede autorizar: pidió ${actual.diasSolicitados} día(s) '
            'de ${actual.tipo} y solo tiene $disponible disponible(s).';
      }
    }

    final actualizada = SolicitudPermiso(
      id: actual.id,
      idEmpleado: actual.idEmpleado,
      nombreEmpleado: actual.nombreEmpleado,
      tipo: actual.tipo,
      motivo: actual.motivo,
      diasSolicitados: actual.diasSolicitados,
      fechaInicio: fechaAutorizadaInicio ?? actual.fechaInicio,
      fechaFin: fechaAutorizadaFin ?? actual.fechaFin,
      estatus: nuevoEstatus,
    );
    _solicitudes[idx] = actualizada;

    if (actual.estatus != 'AUTORIZADA' && nuevoEstatus == 'AUTORIZADA') {
      await _descontarSaldoPorSolicitud(actualizada);
    }

    notifyListeners();
    await _guardarLocal();

    await _remoto(
      (c) => c.from('solicitudes').update(actualizada.toMap()).eq('id', id),
    );

    if (actual.estatus != nuevoEstatus) {
      final verbo = nuevoEstatus == 'AUTORIZADA'
          ? 'fue AUTORIZADA'
          : nuevoEstatus == 'RECHAZADA'
              ? 'fue RECHAZADA'
              : 'cambió a $nuevoEstatus';
      final fechas = nuevoEstatus == 'AUTORIZADA'
          ? ' (${fmtFecha(actualizada.fechaInicio)} al ${fmtFecha(actualizada.fechaFin)})'
          : '';
      await enviarNotificacion(
        idEmpleado: actual.idEmpleado,
        mensaje: 'Tu solicitud de ${actual.tipo} $verbo$fechas.',
      );
    }
    return null;
  }

  Future<void> _descontarSaldoPorSolicitud(SolicitudPermiso sol) async {
    final emp = buscarEmpleadoPorId(sol.idEmpleado);
    if (emp == null) return;
    final tipoLower = sol.tipo.toLowerCase();
    final cant = sol.diasSolicitados;

    Empleado actualizado = emp;
    if (tipoLower.contains('vacacion')) {
      actualizado = emp.copyWith(
          diasVacacionesUsados: emp.diasVacacionesUsados + cant);
    } else if (tipoLower.contains('entrada tarde')) {
      actualizado = emp.copyWith(
          permisosEntradaTardeUsados: emp.permisosEntradaTardeUsados + cant);
    } else if (tipoLower.contains('salida antes')) {
      actualizado = emp.copyWith(
          permisosSalidaAntesUsados: emp.permisosSalidaAntesUsados + cant);
    } else if (tipoLower.contains('con goce')) {
      actualizado =
          emp.copyWith(faltasConGoceUsados: emp.faltasConGoceUsados + cant);
    } else if (tipoLower.contains('sin goce')) {
      actualizado =
          emp.copyWith(faltasSinGoceUsados: emp.faltasSinGoceUsados + cant);
    } else if (tipoLower.contains('cumple')) {
      actualizado =
          emp.copyWith(diaCumpleanosUsados: emp.diaCumpleanosUsados + cant);
    } else if (tipoLower.contains('fallecimiento')) {
      actualizado = emp.copyWith(
        fallecimientoPrimeraLineaUsados:
            emp.fallecimientoPrimeraLineaUsados + cant,
      );
    }

    await guardarEmpleado(actualizado);
  }

  Future<void> cancelarSolicitud(String id) async {
    final idx = _solicitudes.indexWhere((s) => s.id == id);
    if (idx == -1) return;
    final actual = _solicitudes[idx];
    if (actual.estatus != 'PENDIENTE') return;

    _solicitudes[idx] = SolicitudPermiso(
      id: actual.id,
      idEmpleado: actual.idEmpleado,
      nombreEmpleado: actual.nombreEmpleado,
      tipo: actual.tipo,
      motivo: actual.motivo,
      diasSolicitados: actual.diasSolicitados,
      fechaInicio: actual.fechaInicio,
      fechaFin: actual.fechaFin,
      estatus: 'CANCELADA',
    );
    notifyListeners();
    await _guardarLocal();

    await _remoto(
      (c) => c.from('solicitudes').update({'estatus': 'CANCELADA'}).eq('id', id),
    );
  }

  Future<void> eliminarSolicitud(String id) async {
    _solicitudes.removeWhere((s) => s.id == id);
    notifyListeners();
    await _guardarLocal();
    await _remoto((c) => c.from('solicitudes').delete().eq('id', id));
  }

  // ---------------------------------------------------------------------------
  // Incidencias (AdministradorRH "registra")
  // ---------------------------------------------------------------------------

  Future<void> agregarIncidencia(RegistroIncidencia incidencia) async {
    _incidencias.insert(0, incidencia);
    notifyListeners();
    await _guardarLocal();
    await _remoto((c) => c.from('incidencias').insert(incidencia.toMap()));

    final emp = buscarEmpleadoPorNombre(incidencia.nombreEmpleado);
    if (emp != null) {
      await enviarNotificacion(
        idEmpleado: emp.id,
        mensaje:
            'Se registró un(a) ${incidencia.tipo.toLowerCase()} a tu nombre: ${incidencia.titulo}.',
      );
    }
  }

  Future<void> eliminarIncidencia(String id) async {
    _incidencias.removeWhere((i) => i.id == id);
    notifyListeners();
    await _guardarLocal();
    await _remoto((c) => c.from('incidencias').delete().eq('id', id));
  }

  // ---------------------------------------------------------------------------
  // Departamentos y puestos
  // ---------------------------------------------------------------------------

  Future<void> guardarDepartamento(Departamento d) async {
    final idx = _departamentos.indexWhere((x) => x.id == d.id);
    if (idx >= 0) {
      _departamentos[idx] = d;
    } else {
      _departamentos.add(d);
    }
    notifyListeners();
    await _guardarLocal();
    await _remoto((c) => c.from('departamentos').upsert(d.toMap()));
  }

  Future<void> crearDepartamento(String nombre) =>
      guardarDepartamento(Departamento(id: _nuevoId('dep'), nombre: nombre.trim()));

  /// Devuelve un mensaje de error si no se puede eliminar.
  Future<String?> eliminarDepartamento(String id) async {
    final n = empleadosDeDepartamento(id).length;
    if (n > 0) {
      return 'No se puede eliminar: tiene $n colaborador(es) asignado(s).';
    }
    _departamentos.removeWhere((d) => d.id == id);
    notifyListeners();
    await _guardarLocal();
    await _remoto((c) => c.from('departamentos').delete().eq('id', id));
    return null;
  }

  Future<void> guardarPuesto(Puesto p) async {
    final idx = _puestos.indexWhere((x) => x.id == p.id);
    if (idx >= 0) {
      _puestos[idx] = p;
    } else {
      _puestos.add(p);
    }
    notifyListeners();
    await _guardarLocal();
    await _remoto((c) => c.from('puestos').upsert(p.toMap()));

    // Si se renombró, actualiza el texto del puesto en los empleados.
    for (final e in empleadosDePuesto(p.id)) {
      if (e.puesto != p.nombre) {
        await guardarEmpleado(e.copyWith(puesto: p.nombre));
      }
    }
  }

  Future<void> crearPuesto(String nombre) =>
      guardarPuesto(Puesto(id: _nuevoId('pue'), nombre: nombre.trim()));

  Future<String?> eliminarPuesto(String id) async {
    final n = empleadosDePuesto(id).length;
    if (n > 0) {
      return 'No se puede eliminar: tiene $n colaborador(es) asignado(s).';
    }
    _puestos.removeWhere((p) => p.id == id);
    notifyListeners();
    await _guardarLocal();
    await _remoto((c) => c.from('puestos').delete().eq('id', id));
    return null;
  }

  // ---------------------------------------------------------------------------
  // Calendario laboral
  // ---------------------------------------------------------------------------

  Future<void> guardarDiaCalendario(DiaCalendario dia) async {
    final idx = _calendario.indexWhere((x) => x.id == dia.id);
    if (idx >= 0) {
      _calendario[idx] = dia;
    } else {
      _calendario.add(dia);
    }
    notifyListeners();
    await _guardarLocal();
    await _remoto((c) => c.from('calendario_laboral').upsert(dia.toMap()));
  }

  Future<void> agregarDiaFestivo(DateTime fecha, String descripcion,
          {bool esFestivo = true}) =>
      guardarDiaCalendario(
        DiaCalendario(
          id: _nuevoId('dia'),
          fecha: fecha,
          descripcion: descripcion.trim(),
          esFestivo: esFestivo,
        ),
      );

  Future<void> eliminarDiaCalendario(String id) async {
    _calendario.removeWhere((d) => d.id == id);
    notifyListeners();
    await _guardarLocal();
    await _remoto((c) => c.from('calendario_laboral').delete().eq('id', id));
  }

  /// Carga los días de descanso obligatorio de la LFT (art. 74) del año dado
  /// que aún no estén registrados.
  Future<int> cargarFestivosOficiales(int anio) async {
    DateTime nLunes(int mes, int n) {
      var d = DateTime(anio, mes, 1);
      while (d.weekday != DateTime.monday) {
        d = DateTime(d.year, d.month, d.day + 1);
      }
      return DateTime(d.year, d.month, d.day + 7 * (n - 1));
    }

    final oficiales = <DateTime, String>{
      DateTime(anio, 1, 1): 'Año Nuevo',
      nLunes(2, 1): 'Día de la Constitución',
      nLunes(3, 3): 'Natalicio de Benito Juárez',
      DateTime(anio, 5, 1): 'Día del Trabajo',
      DateTime(anio, 9, 16): 'Día de la Independencia',
      nLunes(11, 3): 'Día de la Revolución',
      DateTime(anio, 12, 25): 'Navidad',
    };

    var agregados = 0;
    for (final entry in oficiales.entries) {
      if (calendarioLaboral.esFestivo(entry.key)) continue;
      await agregarDiaFestivo(entry.key, entry.value);
      agregados++;
    }
    return agregados;
  }

  // ---------------------------------------------------------------------------
  // Notificaciones (Empleado / AdministradorRH "recibe")
  // ---------------------------------------------------------------------------

  List<Notificacion> notificacionesDe(String? idEmpleado) {
    final lista = _notificaciones
        .where((n) => idEmpleado == null ? n.esParaRH : n.idEmpleado == idEmpleado)
        .toList()
      ..sort((a, b) => b.fechaEnvio.compareTo(a.fechaEnvio));
    return lista;
  }

  List<Notificacion> get notificacionesRH => notificacionesDe(null);

  int noLeidasDe(String? idEmpleado) =>
      notificacionesDe(idEmpleado).where((n) => !n.leida).length;

  Future<void> enviarNotificacion({
    required String? idEmpleado,
    required String mensaje,
  }) async {
    final n = Notificacion(
      id: _nuevoId('not'),
      idEmpleado: idEmpleado,
      mensaje: mensaje,
    );
    _notificaciones.insert(0, n);
    notifyListeners();
    await _guardarLocal();
    await _remoto((c) => c.from('notificaciones').insert(n.toMap()));
  }

  Future<void> marcarNotificacionLeida(String id) async {
    final idx = _notificaciones.indexWhere((n) => n.id == id);
    if (idx == -1 || _notificaciones[idx].leida) return;
    _notificaciones[idx] = _notificaciones[idx].marcarLeida();
    notifyListeners();
    await _guardarLocal();
    await _remoto(
      (c) => c.from('notificaciones').update({'leida': true}).eq('id', id),
    );
  }

  Future<void> marcarTodasLeidas(String? idEmpleado) async {
    for (final n in notificacionesDe(idEmpleado).where((n) => !n.leida)) {
      await marcarNotificacionLeida(n.id);
    }
  }

  // ---------------------------------------------------------------------------
  // Reportes (AdministradorRH "genera")
  // ---------------------------------------------------------------------------

  bool _enRango(DateTime f, DateTime? desde, DateTime? hasta) {
    final d = DateTime(f.year, f.month, f.day);
    if (desde != null &&
        d.isBefore(DateTime(desde.year, desde.month, desde.day))) {
      return false;
    }
    if (hasta != null &&
        d.isAfter(DateTime(hasta.year, hasta.month, hasta.day))) {
      return false;
    }
    return true;
  }

  /// Construye el contenido de un reporte sin guardarlo (útil para pruebas).
  String construirContenidoReporte(
    String tipo, {
    DateTime? desde,
    DateTime? hasta,
    String? departamentoId,
  }) {
    bool deDepto(Empleado e) =>
        departamentoId == null || e.departamentoId == departamentoId;
    final sb = StringBuffer();

    switch (tipo) {
      case TiposReporte.plantilla:
        final lista1 = empleadosActivos.where(deDepto).toList()
          ..sort((a, b) => a.nombre.compareTo(b.nombre));
        sb.writeln('Colaboradores activos: ${lista1.length}');
        for (final e in lista1) {
          sb.writeln(
            '• ${e.numeroEmpleado} ${e.nombre} — ${e.puesto} — '
            '${nombreDepartamento(e.departamentoId)} — '
            '${e.estadoLaboral.etiqueta} — ${e.antiguedadTexto}',
          );
        }
        break;
      case TiposReporte.bajas:
        final lista2 = empleadosBaja
            .where(deDepto)
            .where((e) => e.fechaBaja == null || _enRango(e.fechaBaja!, desde, hasta))
            .toList();
        sb.writeln('Bajas en el periodo: ${lista2.length}');
        for (final e in lista2) {
          sb.writeln(
            '• ${e.numeroEmpleado} ${e.nombre} — '
            '${e.fechaBaja == null ? 's/f' : fmtFecha(e.fechaBaja!)} — '
            '${e.motivoBaja.isEmpty ? 'Sin motivo' : e.motivoBaja}',
          );
        }
        break;
      case TiposReporte.solicitudes:
        final lista3 = _solicitudes.where((s) {
          final emp = buscarEmpleadoPorId(s.idEmpleado);
          if (departamentoId != null &&
              (emp == null || emp.departamentoId != departamentoId)) {
            return false;
          }
          return _enRango(s.fechaInicio, desde, hasta);
        }).toList();
        final porEstatus = <String, int>{};
        for (final s in lista3) {
          porEstatus[s.estatus] = (porEstatus[s.estatus] ?? 0) + 1;
        }
        sb.writeln('Solicitudes: ${lista3.length}');
        porEstatus.forEach((k, v) => sb.writeln('  $k: $v'));
        for (final s in lista3) {
          sb.writeln(
            '• ${s.nombreEmpleado} — ${s.tipo} — ${s.diasSolicitados} día(s) — '
            '${fmtFecha(s.fechaInicio)} — ${s.estatus}',
          );
        }
        break;
      case TiposReporte.vacaciones:
        final lista4 = empleadosActivos.where(deDepto).toList()
          ..sort((a, b) => a.nombre.compareTo(b.nombre));
        sb.writeln('Saldos de vacaciones (${lista4.length} colaboradores)');
        for (final e in lista4) {
          sb.writeln(
            '• ${e.nombre}: usados ${e.diasVacacionesUsados} / '
            '${e.diasVacacionesTotales}, disponibles ${e.diasVacacionesDisponibles} '
            '(tabulador: ${e.diasVacacionesPorTabulador})',
          );
        }
        break;
      case TiposReporte.incidencias:
        final lista5 = _incidencias.where((i) {
          if (departamentoId != null) {
            final emp = buscarEmpleadoPorNombre(i.nombreEmpleado);
            if (emp == null || emp.departamentoId != departamentoId) {
              return false;
            }
          }
          return _enRango(i.fecha, desde, hasta);
        }).toList();
        final rec = lista5.where((i) => i.tipo == 'Reconocimiento').length;
        sb.writeln('Incidencias: ${lista5.length} '
            '(reconocimientos: $rec, sanciones: ${lista5.length - rec})');
        for (final i in lista5) {
          sb.writeln('• ${fmtFecha(i.fecha)} — ${i.nombreEmpleado} — '
              '${i.tipo}: ${i.titulo}');
        }
        break;
      default:
        sb.writeln('Tipo de reporte no reconocido: $tipo');
    }
    return sb.toString().trimRight();
  }

  Future<Reporte> generarReporte(
    String tipo, {
    DateTime? desde,
    DateTime? hasta,
    String? departamentoId,
  }) async {
    final params = <String, dynamic>{
      if (desde != null) 'desde': desde.toIso8601String(),
      if (hasta != null) 'hasta': hasta.toIso8601String(),
      'departamento_id': ?departamentoId,
    };
    final reporte = Reporte(
      id: _nuevoId('rep'),
      tipoReporte: tipo,
      descripcion: construirContenidoReporte(
        tipo,
        desde: desde,
        hasta: hasta,
        departamentoId: departamentoId,
      ),
      parametros: jsonEncode(params),
      generadoPor: administradorActual?.id,
    );
    _reportes.insert(0, reporte);
    notifyListeners();
    await _guardarLocal();
    await _remoto((c) => c.from('reportes').insert(reporte.toMap()));
    return reporte;
  }

  Future<void> eliminarReporte(String id) async {
    _reportes.removeWhere((r) => r.id == id);
    notifyListeners();
    await _guardarLocal();
    await _remoto((c) => c.from('reportes').delete().eq('id', id));
  }

  // ---------------------------------------------------------------------------
  // Ciclo anual
  // ---------------------------------------------------------------------------

  Future<void> reiniciarSaldosCicloAnual() async {
    final nuevaVigencia = finCicloAnual();
    for (int i = 0; i < _empleados.length; i++) {
      _empleados[i] = _empleados[i].copyWith(
        diasVacacionesUsados: 0,
        vigenciaVacaciones: nuevaVigencia,
        permisosEntradaTardeUsados: 0,
        permisosSalidaAntesUsados: 0,
        faltasConGoceUsados: 0,
        faltasSinGoceUsados: 0,
        diaCumpleanosUsados: 0,
        fallecimientoPrimeraLineaUsados: 0,
      );
    }
    notifyListeners();
    await _guardarLocal();

    await _remoto((c) async {
      for (final emp in _empleados) {
        await _upsertEmpleado(c, emp);
      }
    });
  }

  /// Solo para pruebas: limpia el estado en memoria.
  @visibleForTesting
  void reiniciarParaPruebas() {
    _empleados.clear();
    _usuarios.clear();
    _solicitudes.clear();
    _incidencias.clear();
    _departamentos.clear();
    _puestos.clear();
    _notificaciones.clear();
    _calendario.clear();
    _reportes.clear();
    _empleadoActualId = null;
    _usuarioActualId = null;
    _rolActual = null;
  }
}
