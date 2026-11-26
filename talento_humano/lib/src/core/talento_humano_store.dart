import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  final String nombre;
  final String puesto;
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
    required this.nombre,
    required this.puesto,
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
  }) : vigenciaVacaciones =
            vigenciaVacaciones ?? TalentoHumanoStore.finCicloAnual();

  int get aniosCumplidos {
    final hoy = DateTime.now();
    int anios = hoy.year - fechaIngreso.year;
    if (hoy.month < fechaIngreso.month ||
        (hoy.month == fechaIngreso.month && hoy.day < fechaIngreso.day)) {
      anios--;
    }
    return anios < 0 ? 0 : anios;
  }

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

  Map<String, dynamic> toMap() => {
        'id': id,
        'nombre': nombre,
        'puesto': puesto,
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

    return Empleado(
      id: (map['id'] ?? '').toString(),
      nombre: (map['nombre'] ?? '').toString(),
      puesto: (map['puesto'] ?? 'Operativo').toString(),
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
      activo: map['activo'] is bool
          ? map['activo'] as bool
          : (map['activo']?.toString().toLowerCase() != 'false'),
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

  final List<Empleado> _empleados = [];
  final List<UsuarioCuenta> _usuarios = [];
  final List<SolicitudPermiso> _solicitudes = [];
  final List<RegistroIncidencia> _incidencias = [];

  String? _empleadoActualId;
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

  Empleado? get empleadoActual {
    if (_empleadoActualId == null) {
      return empleadosActivos.isNotEmpty ? empleadosActivos.first : null;
    }
    return buscarEmpleadoPorId(_empleadoActualId!);
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
    String f(DateTime d) =>
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    return '${f(ini)} al ${f(fin)}';
  }

  bool get _supabaseActivo {
    try {
      Supabase.instance.client;
      return true;
    } catch (_) {
      return false;
    }
  }

  Empleado? buscarEmpleadoPorId(String id) {
    for (final e in _empleados) {
      if (e.id == id) return e;
    }
    return null;
  }

  UsuarioCuenta? buscarUsuarioPorEmpleadoId(String empleadoId) {
    for (final u in _usuarios) {
      if (u.empleadoId == empleadoId) return u;
    }
    return null;
  }

  void establecerSesionEmpleado(String? empleadoId, {String rol = 'empleado'}) {
    _empleadoActualId = empleadoId;
    _rolActual = rol;
    notifyListeners();
  }

  void cerrarSesion() {
    _empleadoActualId = null;
    _rolActual = null;
    notifyListeners();
  }

  Future<void> cargarLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawEmp = prefs.getString(_kEmpleadosKey);
      final rawUsr = prefs.getString(_kUsuariosKey);
      final rawSol = prefs.getString(_kSolicitudesKey);
      final rawInc = prefs.getString(_kIncidenciasKey);

      if (rawEmp != null) {
        final list = jsonDecode(rawEmp) as List<dynamic>;
        _empleados
          ..clear()
          ..addAll(
            list.map((e) => Empleado.fromMap(Map<String, dynamic>.from(e))),
          );
      }
      if (rawUsr != null) {
        final list = jsonDecode(rawUsr) as List<dynamic>;
        _usuarios
          ..clear()
          ..addAll(
            list.map(
              (u) => UsuarioCuenta.fromMap(Map<String, dynamic>.from(u)),
            ),
          );
      }
      if (rawSol != null) {
        final list = jsonDecode(rawSol) as List<dynamic>;
        _solicitudes
          ..clear()
          ..addAll(
            list.map(
              (s) => SolicitudPermiso.fromMap(Map<String, dynamic>.from(s)),
            ),
          );
      }
      if (rawInc != null) {
        final list = jsonDecode(rawInc) as List<dynamic>;
        _incidencias
          ..clear()
          ..addAll(
            list.map(
              (i) => RegistroIncidencia.fromMap(Map<String, dynamic>.from(i)),
            ),
          );
      }
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _guardarLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _kEmpleadosKey,
        jsonEncode(_empleados.map((e) => e.toMap()).toList()),
      );
      await prefs.setString(
        _kUsuariosKey,
        jsonEncode(_usuarios.map((u) => u.toMap()).toList()),
      );
      await prefs.setString(
        _kSolicitudesKey,
        jsonEncode(_solicitudes.map((s) => s.toMap()).toList()),
      );
      await prefs.setString(
        _kIncidenciasKey,
        jsonEncode(_incidencias.map((i) => i.toMap()).toList()),
      );
    } catch (_) {}
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
      final client = Supabase.instance.client;

      final empRes = await client.from('empleados').select();
      _empleados
        ..clear()
        ..addAll(
          (empRes as List<dynamic>).map(
            (e) => Empleado.fromMap(Map<String, dynamic>.from(e)),
          ),
        );

      final usrRes = await client.from('usuarios').select();
      _usuarios
        ..clear()
        ..addAll(
          (usrRes as List<dynamic>).map(
            (u) => UsuarioCuenta.fromMap(Map<String, dynamic>.from(u)),
          ),
        );

      final solRes = await client.from('solicitudes').select();
      _solicitudes
        ..clear()
        ..addAll(
          (solRes as List<dynamic>).map(
            (s) => SolicitudPermiso.fromMap(Map<String, dynamic>.from(s)),
          ),
        );

      final incRes = await client.from('incidencias').select();
      _incidencias
        ..clear()
        ..addAll(
          (incRes as List<dynamic>).map(
            (i) => RegistroIncidencia.fromMap(Map<String, dynamic>.from(i)),
          ),
        );

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
    _rolActual = encontrado.rol;
    notifyListeners();
    return encontrado.rol;
  }

  Future<void> guardarEmpleado(
    Empleado emp, {
    String? correo,
    String? password,
    String rol = 'empleado',
  }) async {
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
        id: uIdx >= 0
            ? _usuarios[uIdx].id
            : 'usr_${DateTime.now().millisecondsSinceEpoch}',
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

    if (_supabaseActivo) {
      try {
        await Supabase.instance.client.from('empleados').upsert(emp.toMap());
        if (cuenta != null) {
          await Supabase.instance.client
              .from('usuarios')
              .upsert(cuenta.toMap());
        }
      } catch (_) {}
    }
  }

  Future<void> darDeBajaEmpleado(String id, {String motivo = ''}) async {
    final idx = _empleados.indexWhere((e) => e.id == id);
    if (idx == -1) return;
    final actual = _empleados[idx];
    final baja = Empleado(
      id: actual.id,
      nombre: actual.nombre,
      puesto: actual.puesto,
      fechaIngreso: actual.fechaIngreso,
      fechaNacimiento: actual.fechaNacimiento,
      vecesVacacionesAnio: actual.vecesVacacionesAnio,
      diasPorPeriodoVacaciones: actual.diasPorPeriodoVacaciones,
      diasVacacionesUsados: actual.diasVacacionesUsados,
      vigenciaVacaciones: actual.vigenciaVacaciones,
      permisosEntradaTardeTotal: actual.permisosEntradaTardeTotal,
      permisosEntradaTardeUsados: actual.permisosEntradaTardeUsados,
      permisosSalidaAntesTotal: actual.permisosSalidaAntesTotal,
      permisosSalidaAntesUsados: actual.permisosSalidaAntesUsados,
      faltasConGoceTotal: actual.faltasConGoceTotal,
      faltasConGoceUsados: actual.faltasConGoceUsados,
      faltasSinGoceTotal: actual.faltasSinGoceTotal,
      faltasSinGoceUsados: actual.faltasSinGoceUsados,
      diaCumpleanosTotal: actual.diaCumpleanosTotal,
      diaCumpleanosUsados: actual.diaCumpleanosUsados,
      fallecimientoPrimeraLineaTotal: actual.fallecimientoPrimeraLineaTotal,
      fallecimientoPrimeraLineaUsados: actual.fallecimientoPrimeraLineaUsados,
      activo: false,
      fechaBaja: DateTime.now(),
      motivoBaja: motivo,
    );
    await guardarEmpleado(baja);
  }

  Future<void> reactivarEmpleado(String id) async {
    final idx = _empleados.indexWhere((e) => e.id == id);
    if (idx == -1) return;
    final actual = _empleados[idx];
    final reactivado = Empleado(
      id: actual.id,
      nombre: actual.nombre,
      puesto: actual.puesto,
      fechaIngreso: actual.fechaIngreso,
      fechaNacimiento: actual.fechaNacimiento,
      vecesVacacionesAnio: actual.vecesVacacionesAnio,
      diasPorPeriodoVacaciones: actual.diasPorPeriodoVacaciones,
      diasVacacionesUsados: actual.diasVacacionesUsados,
      vigenciaVacaciones: actual.vigenciaVacaciones,
      permisosEntradaTardeTotal: actual.permisosEntradaTardeTotal,
      permisosEntradaTardeUsados: actual.permisosEntradaTardeUsados,
      permisosSalidaAntesTotal: actual.permisosSalidaAntesTotal,
      permisosSalidaAntesUsados: actual.permisosSalidaAntesUsados,
      faltasConGoceTotal: actual.faltasConGoceTotal,
      faltasConGoceUsados: actual.faltasConGoceUsados,
      faltasSinGoceTotal: actual.faltasSinGoceTotal,
      faltasSinGoceUsados: actual.faltasSinGoceUsados,
      diaCumpleanosTotal: actual.diaCumpleanosTotal,
      diaCumpleanosUsados: actual.diaCumpleanosUsados,
      fallecimientoPrimeraLineaTotal: actual.fallecimientoPrimeraLineaTotal,
      fallecimientoPrimeraLineaUsados: actual.fallecimientoPrimeraLineaUsados,
      activo: true,
      fechaBaja: null,
      motivoBaja: '',
    );
    await guardarEmpleado(reactivado);
  }

  Future<void> crearSolicitud(SolicitudPermiso solicitud) async {
    _solicitudes.insert(0, solicitud);
    notifyListeners();
    await _guardarLocal();

    if (_supabaseActivo) {
      try {
        await Supabase.instance.client
            .from('solicitudes')
            .insert(solicitud.toMap());
      } catch (_) {}
    }
  }

  Future<void> actualizarEstatusSolicitud(
    String id,
    String nuevoEstatus, {
    DateTime? fechaAutorizadaInicio,
    DateTime? fechaAutorizadaFin,
  }) async {
    final idx = _solicitudes.indexWhere((s) => s.id == id);
    if (idx == -1) return;
    final actual = _solicitudes[idx];

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

    if (_supabaseActivo) {
      try {
        await Supabase.instance.client
            .from('solicitudes')
            .update(actualizada.toMap())
            .eq('id', id);
      } catch (_) {}
    }
  }

  Future<void> _descontarSaldoPorSolicitud(SolicitudPermiso sol) async {
    final emp = buscarEmpleadoPorId(sol.idEmpleado);
    if (emp == null) return;
    final tipoLower = sol.tipo.toLowerCase();
    final cant = sol.diasSolicitados;

    int vacUsados = emp.diasVacacionesUsados;
    int tardeUsados = emp.permisosEntradaTardeUsados;
    int salidaUsados = emp.permisosSalidaAntesUsados;
    int conGoceUsados = emp.faltasConGoceUsados;
    int sinGoceUsados = emp.faltasSinGoceUsados;
    int cumpleUsados = emp.diaCumpleanosUsados;
    int lutoUsados = emp.fallecimientoPrimeraLineaUsados;

    if (tipoLower.contains('vacacion')) {
      vacUsados += cant;
    } else if (tipoLower.contains('entrada tarde')) {
      tardeUsados += cant;
    } else if (tipoLower.contains('salida antes')) {
      salidaUsados += cant;
    } else if (tipoLower.contains('con goce')) {
      conGoceUsados += cant;
    } else if (tipoLower.contains('sin goce')) {
      sinGoceUsados += cant;
    } else if (tipoLower.contains('cumple')) {
      cumpleUsados += cant;
    } else if (tipoLower.contains('fallecimiento')) {
      lutoUsados += cant;
    }

    final actualizado = Empleado(
      id: emp.id,
      nombre: emp.nombre,
      puesto: emp.puesto,
      fechaIngreso: emp.fechaIngreso,
      fechaNacimiento: emp.fechaNacimiento,
      vecesVacacionesAnio: emp.vecesVacacionesAnio,
      diasPorPeriodoVacaciones: emp.diasPorPeriodoVacaciones,
      diasVacacionesUsados: vacUsados,
      vigenciaVacaciones: emp.vigenciaVacaciones,
      permisosEntradaTardeTotal: emp.permisosEntradaTardeTotal,
      permisosEntradaTardeUsados: tardeUsados,
      permisosSalidaAntesTotal: emp.permisosSalidaAntesTotal,
      permisosSalidaAntesUsados: salidaUsados,
      faltasConGoceTotal: emp.faltasConGoceTotal,
      faltasConGoceUsados: conGoceUsados,
      faltasSinGoceTotal: emp.faltasSinGoceTotal,
      faltasSinGoceUsados: sinGoceUsados,
      diaCumpleanosTotal: emp.diaCumpleanosTotal,
      diaCumpleanosUsados: cumpleUsados,
      fallecimientoPrimeraLineaTotal: emp.fallecimientoPrimeraLineaTotal,
      fallecimientoPrimeraLineaUsados: lutoUsados,
      activo: emp.activo,
      fechaBaja: emp.fechaBaja,
      motivoBaja: emp.motivoBaja,
    );

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

    if (_supabaseActivo) {
      try {
        await Supabase.instance.client
            .from('solicitudes')
            .update({'estatus': 'CANCELADA'})
            .eq('id', id);
      } catch (_) {}
    }
  }

  Future<void> eliminarSolicitud(String id) async {
    _solicitudes.removeWhere((s) => s.id == id);
    notifyListeners();
    await _guardarLocal();

    if (_supabaseActivo) {
      try {
        await Supabase.instance.client
            .from('solicitudes')
            .delete()
            .eq('id', id);
      } catch (_) {}
    }
  }

  Future<void> agregarIncidencia(RegistroIncidencia incidencia) async {
    _incidencias.insert(0, incidencia);
    notifyListeners();
    await _guardarLocal();

    if (_supabaseActivo) {
      try {
        await Supabase.instance.client
            .from('incidencias')
            .insert(incidencia.toMap());
      } catch (_) {}
    }
  }

  Future<void> eliminarIncidencia(String id) async {
    _incidencias.removeWhere((i) => i.id == id);
    notifyListeners();
    await _guardarLocal();

    if (_supabaseActivo) {
      try {
        await Supabase.instance.client
            .from('incidencias')
            .delete()
            .eq('id', id);
      } catch (_) {}
    }
  }

  Future<void> reiniciarSaldosCicloAnual() async {
    final nuevaVigencia = finCicloAnual();
    for (int i = 0; i < _empleados.length; i++) {
      final emp = _empleados[i];
      _empleados[i] = Empleado(
        id: emp.id,
        nombre: emp.nombre,
        puesto: emp.puesto,
        fechaIngreso: emp.fechaIngreso,
        fechaNacimiento: emp.fechaNacimiento,
        vecesVacacionesAnio: emp.vecesVacacionesAnio,
        diasPorPeriodoVacaciones: emp.diasPorPeriodoVacaciones,
        diasVacacionesUsados: 0,
        vigenciaVacaciones: nuevaVigencia,
        permisosEntradaTardeTotal: emp.permisosEntradaTardeTotal,
        permisosEntradaTardeUsados: 0,
        permisosSalidaAntesTotal: emp.permisosSalidaAntesTotal,
        permisosSalidaAntesUsados: 0,
        faltasConGoceTotal: emp.faltasConGoceTotal,
        faltasConGoceUsados: 0,
        faltasSinGoceTotal: emp.faltasSinGoceTotal,
        faltasSinGoceUsados: 0,
        diaCumpleanosTotal: emp.diaCumpleanosTotal,
        diaCumpleanosUsados: 0,
        fallecimientoPrimeraLineaTotal: emp.fallecimientoPrimeraLineaTotal,
        fallecimientoPrimeraLineaUsados: 0,
        activo: emp.activo,
        fechaBaja: emp.fechaBaja,
        motivoBaja: emp.motivoBaja,
      );
    }
    notifyListeners();
    await _guardarLocal();

    if (_supabaseActivo) {
      try {
        for (final emp in _empleados) {
          await Supabase.instance.client.from('empleados').upsert(emp.toMap());
        }
      } catch (_) {}
    }
  }
}