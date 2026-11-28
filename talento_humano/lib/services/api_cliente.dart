import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

typedef JsonMap = Map<String, dynamic>;

class ApiCliente {
  final String baseUrl;

  ApiCliente({required this.baseUrl});

  Uri _uri(String ruta) {
    final limpia = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final rutaLimpia = ruta.startsWith('/') ? ruta : '/$ruta';
    return Uri.parse('$limpia$rutaLimpia');
  }

  JsonMap _procesarRespuesta(http.Response res) {
    final texto = res.body.isNotEmpty ? res.body : '{}';
    final decoded = jsonDecode(texto);
    final data = decoded is JsonMap
        ? decoded
        : JsonMap.from({'data': decoded});

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return data;
    }

    throw Exception(data['error'] ?? 'Error HTTP ${res.statusCode}');
  }

  Future<bool> verificarSalud() async {
    try {
      final res = await http
          .get(_uri('/health'))
          .timeout(const Duration(seconds: 8));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<JsonMap> login({
    required String correo,
    String? password,
  }) async {
    final payload = JsonMap.from({
      'correo': correo.trim(),
    });
    if (password != null && password.isNotEmpty) {
      payload['password'] = password;
    }

    final res = await http.post(
      _uri('/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    return _procesarRespuesta(res);
  }

  Future<JsonMap> obtenerEstado() async {
    final res = await http.get(_uri('/estado'));
    return _procesarRespuesta(res);
  }

  Future<JsonMap> crearEmpleado({
    required String nombre,
    String puesto = 'Operativo',
    String? fechaIngreso,
    String? correo,
    String? password,
    int vecesVacacionesAnio = 2,
    int diasPorPeriodoVacaciones = 6,
    String? vigenciaVacaciones,
    int permisosAnualesDerecho = 3,
  }) async {
    final payload = JsonMap.from({
      'nombre': nombre.trim(),
      'puesto': puesto.trim(),
      'vecesVacacionesAnio': vecesVacacionesAnio,
      'diasPorPeriodoVacaciones': diasPorPeriodoVacaciones,
      'permisosAnualesDerecho': permisosAnualesDerecho,
    });
    if (fechaIngreso != null && fechaIngreso.isNotEmpty) {
      payload['fechaIngreso'] = fechaIngreso;
    }
    if (correo != null && correo.trim().isNotEmpty) {
      payload['correo'] = correo.trim();
    }
    if (password != null && password.isNotEmpty) {
      payload['password'] = password;
    }
    if (vigenciaVacaciones != null && vigenciaVacaciones.isNotEmpty) {
      payload['vigenciaVacaciones'] = vigenciaVacaciones;
    }

    final res = await http.post(
      _uri('/empleados'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    return _procesarRespuesta(res);
  }

  Future<JsonMap> editarEmpleado({
    required String empleadoId,
    String? nombre,
    String? puesto,
    String? fechaIngreso,
    int? vecesVacacionesAnio,
    int? diasPorPeriodoVacaciones,
    String? vigenciaVacaciones,
    int? permisosAnualesDerecho,
    bool? activo,
  }) async {
    final payload = JsonMap.from({});
    if (nombre != null) payload['nombre'] = nombre.trim();
    if (puesto != null) payload['puesto'] = puesto.trim();
    if (fechaIngreso != null) payload['fechaIngreso'] = fechaIngreso;
    if (vecesVacacionesAnio != null) {
      payload['vecesVacacionesAnio'] = vecesVacacionesAnio;
    }
    if (diasPorPeriodoVacaciones != null) {
      payload['diasPorPeriodoVacaciones'] = diasPorPeriodoVacaciones;
    }
    if (vigenciaVacaciones != null) {
      payload['vigenciaVacaciones'] = vigenciaVacaciones;
    }
    if (permisosAnualesDerecho != null) {
      payload['permisosAnualesDerecho'] = permisosAnualesDerecho;
    }
    if (activo != null) payload['activo'] = activo;

    final res = await http.patch(
      _uri('/empleados/$empleadoId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    return _procesarRespuesta(res);
  }

  Future<JsonMap> darDeBajaEmpleado({
    required String empleadoId,
    String? motivoBaja,
  }) async {
    final payload = JsonMap.from({});
    if (motivoBaja != null && motivoBaja.trim().isNotEmpty) {
      payload['motivoBaja'] = motivoBaja.trim();
    }

    final res = await http.post(
      _uri('/empleados/$empleadoId/baja'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    return _procesarRespuesta(res);
  }

  Future<JsonMap> actualizarVacaciones({
    required String empleadoId,
    required int vecesAlAnio,
    required int diasPorPeriodo,
    required String vigencia,
  }) async {
    final res = await http.patch(
      _uri('/empleados/$empleadoId/vacaciones'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'vecesAlAnio': vecesAlAnio,
        'diasPorPeriodo': diasPorPeriodo,
        'vigencia': vigencia,
      }),
    );
    return _procesarRespuesta(res);
  }

  Future<JsonMap> crearSolicitud({
    required String idEmpleado,
    required String tipo,
    required String motivo,
    required int diasSolicitados,
  }) async {
    final res = await http.post(
      _uri('/solicitudes'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'idEmpleado': idEmpleado,
        'tipo': tipo,
        'motivo': motivo,
        'diasSolicitados': diasSolicitados,
      }),
    );
    return _procesarRespuesta(res);
  }

  Future<JsonMap> responderSolicitud({
    required String solicitudId,
    required bool autorizar,
    String? fechaInicio,
    String? fechaFin,
  }) async {
    final payload = JsonMap.from({
      'autorizar': autorizar,
    });
    if (fechaInicio != null) {
      payload['fechaInicio'] = fechaInicio;
    }
    if (fechaFin != null) {
      payload['fechaFin'] = fechaFin;
    }

    final res = await http.post(
      _uri('/solicitudes/$solicitudId/responder'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    return _procesarRespuesta(res);
  }

  Future<JsonMap> crearIncidencia({
    required String nombreEmpleado,
    required String tipo,
    required String titulo,
    required String descripcion,
  }) async {
    final res = await http.post(
      _uri('/incidencias'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nombreEmpleado': nombreEmpleado,
        'tipo': tipo,
        'titulo': titulo,
        'descripcion': descripcion,
      }),
    );
    return _procesarRespuesta(res);
  }

  // ---------------------------------------------------------------------------
  // Entidades del diagrama: departamentos, puestos, notificaciones,
  // calendario laboral y reportes.
  // ---------------------------------------------------------------------------

  static const Map<String, String> _json = {'Content-Type': 'application/json'};

  Future<JsonMap> _get(String ruta, [Map<String, String>? query]) async {
    final uri = query == null || query.isEmpty
        ? _uri(ruta)
        : _uri(ruta).replace(queryParameters: query);
    return _procesarRespuesta(await http.get(uri));
  }

  Future<JsonMap> _post(String ruta, [JsonMap? body]) async =>
      _procesarRespuesta(
        await http.post(_uri(ruta), headers: _json, body: jsonEncode(body ?? {})),
      );

  Future<JsonMap> _patch(String ruta, [JsonMap? body]) async =>
      _procesarRespuesta(
        await http.patch(_uri(ruta), headers: _json, body: jsonEncode(body ?? {})),
      );

  Future<JsonMap> _delete(String ruta) async =>
      _procesarRespuesta(await http.delete(_uri(ruta)));

  Future<JsonMap> listarDepartamentos() => _get('/departamentos');
  Future<JsonMap> crearDepartamento(String nombre) =>
      _post('/departamentos', {'nombre': nombre});
  Future<JsonMap> renombrarDepartamento(String id, String nombre) =>
      _patch('/departamentos/$id', {'nombre': nombre});
  Future<JsonMap> eliminarDepartamento(String id) =>
      _delete('/departamentos/$id');

  Future<JsonMap> listarPuestos() => _get('/puestos');
  Future<JsonMap> crearPuesto(String nombre) =>
      _post('/puestos', {'nombre': nombre});
  Future<JsonMap> renombrarPuesto(String id, String nombre) =>
      _patch('/puestos/$id', {'nombre': nombre});
  Future<JsonMap> eliminarPuesto(String id) => _delete('/puestos/$id');

  /// [idEmpleado] null = notificaciones de RH.
  Future<JsonMap> listarNotificaciones({
    String? idEmpleado,
    bool soloNoLeidas = false,
  }) =>
      _get('/notificaciones', {
        'idEmpleado': ?idEmpleado,
        if (soloNoLeidas) 'soloNoLeidas': 'true',
      });
  Future<JsonMap> marcarNotificacionLeida(String id) =>
      _patch('/notificaciones/$id/leida');

  Future<JsonMap> listarCalendario({int? anio}) =>
      _get('/calendario', {if (anio != null) 'anio': '$anio'});
  Future<JsonMap> agregarDiaCalendario({
    required DateTime fecha,
    required String descripcion,
    bool esFestivo = true,
  }) =>
      _post('/calendario', {
        'fecha': fecha.toIso8601String(),
        'descripcion': descripcion,
        'esFestivo': esFestivo,
      });
  Future<JsonMap> eliminarDiaCalendario(String idDia) =>
      _delete('/calendario/$idDia');
  Future<JsonMap> cargarFestivosOficiales(int anio) =>
      _post('/calendario/festivos-oficiales/$anio');
  Future<JsonMap> diasHabiles(DateTime inicio, DateTime fin) =>
      _get('/calendario/dias-habiles', {
        'inicio': inicio.toIso8601String(),
        'fin': fin.toIso8601String(),
      });

  Future<JsonMap> listarReportes() => _get('/reportes');
  Future<JsonMap> obtenerReporte(String id) => _get('/reportes/$id');

  /// [tipoReporte]: PLANTILLA | BAJAS | SOLICITUDES | VACACIONES | INCIDENCIAS
  Future<JsonMap> generarReporte({
    required String tipoReporte,
    DateTime? desde,
    DateTime? hasta,
    String? idDepartamento,
  }) =>
      _post('/reportes', {
        'tipoReporte': tipoReporte,
        if (desde != null) 'desde': desde.toIso8601String(),
        if (hasta != null) 'hasta': hasta.toIso8601String(),
        'idDepartamento': ?idDepartamento,
      });
}
