import 'package:flutter/material.dart';
import 'package:talento_humano/src/core/hospital_theme.dart';
import 'package:talento_humano/src/core/talento_humano_store.dart';
import 'package:talento_humano/src/features/dashboard/presentacion/notificaciones_boton.dart';

class EmployeeDashboard extends StatefulWidget {
  const EmployeeDashboard({super.key});

  @override
  State<EmployeeDashboard> createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends State<EmployeeDashboard> {
  int _indiceActual = 0;

  static const List<String> _tiposPermiso = [
    'Entrada tarde',
    'Salida antes',
    'Falta con goce',
    'Falta sin goce',
    'Día de cumpleaños',
    'Fallecimiento de primera línea',
  ];

  bool _esFallecimiento(String tipo) =>
      tipo.toLowerCase().contains('fallecimiento');

  String _fmtFecha(DateTime? fecha) {
    if (fecha == null) return 'No especificada';
    final d = fecha.day.toString().padLeft(2, '0');
    final m = fecha.month.toString().padLeft(2, '0');
    return '$d/$m/${fecha.year}';
  }

  Future<void> _seleccionarFecha({
    required BuildContext dialogContext,
    required StateSetter setModalState,
    required DateTime inicial,
    required ValueChanged<DateTime> onSeleccionada,
  }) async {
    final elegida = await showDatePicker(
      context: dialogContext,
      initialDate: inicial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (elegida != null) {
      setModalState(() => onSeleccionada(elegida));
    }
  }

  Future<void> _abrirFormularioSolicitud({
    required String tipoInicial,
    required bool esVacacion,
  }) async {
    final store = TalentoHumanoStore.instance;
    final emp = store.empleadoActual;
    if (emp == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay un colaborador activo vinculado a esta sesión.'),
        ),
      );
      return;
    }

    if (esVacacion) {
      if (emp.aniosCumplidos < 1) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Aún no cumples 1 año de antigüedad para solicitar vacaciones.',
            ),
          ),
        );
        return;
      }
      if (emp.diasVacacionesDisponibles <= 0) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No tienes días de vacaciones disponibles.'),
          ),
        );
        return;
      }
    }

    String tipoSeleccionado = esVacacion
        ? 'Vacaciones'
        : (tipoInicial.isNotEmpty ? tipoInicial : _tiposPermiso.first);
    final motivoController = TextEditingController();
    final diasController = TextEditingController(text: '1');
    DateTime fechaInicio = DateTime.now();
    DateTime fechaFin = DateTime.now();
    String? errorDias;

    final solicitudCreada = await showDialog<SolicitudPermiso>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final tipoEfectivo = esVacacion ? 'Vacaciones' : tipoSeleccionado;
          final esFallec = _esFallecimiento(tipoEfectivo);
          final int maxPermitido = emp.saldoDisponiblePara(tipoEfectivo);

          String etiquetaCantidad =
              'Cantidad (días o eventos) (Disp: $maxPermitido)';
          if (esVacacion) {
            etiquetaCantidad =
                'Días solicitados (Disp: ${emp.diasVacacionesDisponibles})';
          } else if (esFallec) {
            etiquetaCantidad =
                'Días solicitados (Máx. 3 | Disp: ${emp.fallecimientoPrimeraLineaDisponibles})';
          }

          return AlertDialog(
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            title: Text(
              esVacacion
                  ? 'Solicitar vacaciones'
                  : 'Solicitar permiso o falta',
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!esVacacion) ...[
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: _tiposPermiso.contains(tipoSeleccionado)
                            ? tipoSeleccionado
                            : _tiposPermiso.first,
                        decoration: const InputDecoration(
                          labelText: 'Tipo de permiso o falta',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                        items: _tiposPermiso
                            .map(
                              (t) => DropdownMenuItem<String>(
                                value: t,
                                child: Text(
                                  t,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          if (v != null) {
                            setModalState(() {
                              tipoSeleccionado = v;
                              errorDias = null;
                              if (_esFallecimiento(v)) {
                                final actual =
                                    int.tryParse(diasController.text.trim()) ??
                                        1;
                                if (actual > 3) {
                                  diasController.text = '3';
                                }
                              }
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                    ],
                    TextField(
                      controller: diasController,
                      keyboardType: TextInputType.number,
                      onChanged: (_) {
                        if (errorDias != null) {
                          setModalState(() => errorDias = null);
                        }
                      },
                      decoration: InputDecoration(
                        labelText: etiquetaCantidad,
                        errorText: errorDias,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 12,
                              ),
                            ),
                            onPressed: () => _seleccionarFecha(
                              dialogContext: ctx,
                              setModalState: setModalState,
                              inicial: fechaInicio,
                              onSeleccionada: (d) {
                                fechaInicio = d;
                                if (fechaFin.isBefore(fechaInicio)) {
                                  fechaFin = d;
                                }
                              },
                            ),
                            child: Text(
                              'Inicio: ${_fmtFecha(fechaInicio)}',
                              maxLines: 1,
                              softWrap: false,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 12,
                              ),
                            ),
                            onPressed: () => _seleccionarFecha(
                              dialogContext: ctx,
                              setModalState: setModalState,
                              inicial: fechaFin,
                              onSeleccionada: (d) => fechaFin = d,
                            ),
                            child: Text(
                              'Fin: ${_fmtFecha(fechaFin)}',
                              maxLines: 1,
                              softWrap: false,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Builder(
                      builder: (_) {
                        final habiles = TalentoHumanoStore
                            .instance.calendarioLaboral
                            .diasHabilesEntre(fechaInicio, fechaFin);
                        return Text(
                          'Días hábiles en el rango: $habiles '
                          '(sin fines de semana ni festivos)',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: motivoController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Motivo u observaciones',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () {
                  final parsed = int.tryParse(diasController.text.trim());
                  if (parsed == null || parsed < 1) {
                    setModalState(
                      () => errorDias =
                          'Ingresa una cantidad válida de al menos 1.',
                    );
                    return;
                  }
                  if (esFallec && parsed > 3) {
                    setModalState(
                      () => errorDias =
                          'Por fallecimiento se permiten máximo 3 días.',
                    );
                    return;
                  }
                  if (parsed > maxPermitido) {
                    setModalState(
                      () => errorDias = maxPermitido <= 0
                          ? 'No tienes días disponibles para este concepto.'
                          : 'Máximo disponible: $maxPermitido día(s).',
                    );
                    return;
                  }

                  Navigator.pop(
                    ctx,
                    SolicitudPermiso(
                      id: 'sol_${DateTime.now().millisecondsSinceEpoch}',
                      idEmpleado: emp.id,
                      nombreEmpleado: emp.nombre,
                      tipo: tipoEfectivo,
                      motivo: motivoController.text.trim(),
                      diasSolicitados: parsed,
                      fechaInicio: fechaInicio,
                      fechaFin: fechaFin,
                    ),
                  );
                },
                child: const Text('Enviar'),
              ),
            ],
          );
        },
      ),
    );

    if (solicitudCreada == null) return;

    await store.crearSolicitud(solicitudCreada);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Solicitud enviada a Talento Humano.')),
    );
  }

  Future<void> _confirmarAccionSolicitud({
    required SolicitudPermiso solicitud,
    required bool esEliminar,
  }) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(esEliminar ? 'Eliminar solicitud' : 'Cancelar solicitud'),
        content: Text(
          esEliminar
              ? '¿Seguro que deseas eliminar esta solicitud de ${solicitud.tipo}?'
              : '¿Seguro que deseas cancelar esta solicitud de ${solicitud.tipo}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(esEliminar ? 'Eliminar' : 'Cancelar solicitud'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;
    final store = TalentoHumanoStore.instance;
    if (esEliminar) {
      await store.eliminarSolicitud(solicitud.id);
    } else {
      await store.cancelarSolicitud(solicitud.id);
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          esEliminar ? 'Solicitud eliminada.' : 'Solicitud cancelada.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = TalentoHumanoStore.instance;

    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final emp = store.empleadoActual;
        final misSolicitudes = emp == null
            ? <SolicitudPermiso>[]
            : store.solicitudes
                .where((s) => s.idEmpleado == emp.id)
                .toList();
        final misIncidencias = emp == null
            ? <RegistroIncidencia>[]
            : store.incidencias
                .where((i) => i.nombreEmpleado == emp.nombre)
                .toList();

        return Scaffold(
          appBar: AppBar(
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  HospitalBranding.nombre,
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  '“${HospitalBranding.lema}”',
                  style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
                ),
              ],
            ),
            actions: [
              if (emp != null) NotificacionesBoton(idEmpleado: emp.id),
              IconButton(
                tooltip: 'Sincronizar',
                icon: store.cargando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.sync),
                onPressed: store.cargando
                    ? null
                    : () => store.sincronizarDesdeSupabase(),
              ),
              IconButton(
                tooltip: 'Cerrar sesión',
                icon: const Icon(Icons.logout),
                onPressed: () {
                  store.cerrarSesion();
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
            ],
          ),
          body: _indiceActual == 0
              ? _buildInicio(emp, store)
              : _indiceActual == 1
                  ? _buildVacaciones(emp)
                  : _buildMisSolicitudes(misSolicitudes, misIncidencias),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _indiceActual,
            onDestinationSelected: (i) => setState(() => _indiceActual = i),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Inicio',
              ),
              NavigationDestination(
                icon: Icon(Icons.beach_access_outlined),
                selectedIcon: Icon(Icons.beach_access),
                label: 'Vacaciones',
              ),
              NavigationDestination(
                icon: Icon(Icons.assignment_outlined),
                selectedIcon: Icon(Icons.assignment),
                label: 'Solicitudes',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInicio(Empleado? emp, TalentoHumanoStore store) {
    if (emp == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'No hay información de colaborador disponible en esta sesión.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  emp.nombre,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: HospitalBranding.azulMarino,
                  ),
                ),
                const SizedBox(height: 6),
                if (emp.numeroEmpleado.isNotEmpty)
                  Text('No. de empleado: ${emp.numeroEmpleado}'),
                Text('Puesto: ${emp.puesto}'),
                Text(
                  'Departamento: ${store.nombreDepartamento(emp.departamentoId)}',
                ),
                Text('Estado laboral: ${emp.estadoLaboral.etiqueta}'),
                Text('Antigüedad: ${emp.antiguedadTexto}'),
                Text('Fecha de ingreso: ${_fmtFecha(emp.fechaIngreso)}'),
                Text(
                  'Fecha de nacimiento: ${_fmtFecha(emp.fechaNacimiento)}',
                ),
                const SizedBox(height: 8),
                Text(
                  'Ciclo anual vigente: ${store.cicloAnualTexto}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                icon: const Icon(Icons.beach_access),
                label: const Text('Pedir vacaciones'),
                onPressed: () => _abrirFormularioSolicitud(
                  tipoInicial: 'Vacaciones',
                  esVacacion: true,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.event_available),
                label: const Text('Pedir permiso'),
                onPressed: () => _abrirFormularioSolicitud(
                  tipoInicial: 'Entrada tarde',
                  esVacacion: false,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'Saldos anuales disponibles en este ciclo',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _saldoTile(
          'Vacaciones disponibles',
          '${emp.diasVacacionesDisponibles} / ${emp.diasVacacionesTotales} días',
        ),
        _saldoTile(
          'Permisos entrada tarde',
          '${emp.permisosEntradaTardeDisponibles} / ${emp.permisosEntradaTardeTotal}',
        ),
        _saldoTile(
          'Permisos salida antes',
          '${emp.permisosSalidaAntesDisponibles} / ${emp.permisosSalidaAntesTotal}',
        ),
        _saldoTile(
          'Faltas con goce',
          '${emp.faltasConGoceDisponibles} / ${emp.faltasConGoceTotal}',
        ),
        _saldoTile(
          'Faltas sin goce',
          '${emp.faltasSinGoceDisponibles} / ${emp.faltasSinGoceTotal}',
        ),
        _saldoTile(
          'Día de cumpleaños',
          '${emp.diaCumpleanosDisponibles} / ${emp.diaCumpleanosTotal}',
        ),
        _saldoTile(
          'Fallecimiento de primera línea',
          '${emp.fallecimientoPrimeraLineaDisponibles} / ${emp.fallecimientoPrimeraLineaTotal}',
        ),
        ..._proximosFestivos(store),
      ],
    );
  }

  List<Widget> _proximosFestivos(TalentoHumanoStore store) {
    final hoy = DateTime.now();
    final inicioHoy = DateTime(hoy.year, hoy.month, hoy.day);
    final proximos = store.diasCalendario
        .where((d) => d.esFestivo && !d.fecha.isBefore(inicioHoy))
        .take(5)
        .toList();
    if (proximos.isEmpty) return const [];
    return [
      const SizedBox(height: 16),
      const Text(
        'Próximos días festivos',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      ...proximos.map(
        (d) => Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.celebration),
            title: Text(d.descripcion),
            trailing: Text(_fmtFecha(d.fecha)),
          ),
        ),
      ),
    ];
  }

  Widget _saldoTile(String titulo, String valor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(titulo),
        trailing: Text(
          valor,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: HospitalBranding.azulMarino,
          ),
        ),
      ),
    );
  }

  Widget _buildVacaciones(Empleado? emp) {
    if (emp == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('Sin datos de vacaciones disponibles.'),
        ),
      );
    }

    final anios = emp.aniosCumplidos;
    final sugeridos = emp.diasVacacionesPorTabulador;
    final textoSugerencia = anios < 1
        ? 'Aún no cumples 1 año de antigüedad (0 días por tabulador)'
        : '$sugeridos días por antigüedad ($anios ${anios == 1 ? 'año' : 'años'})';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Resumen de vacaciones',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Antigüedad: ${emp.antiguedadTexto}'),
                Text(
                  'Cálculo automático por antigüedad: $textoSugerencia',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: HospitalBranding.azulMarino,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Periodos asignados: ${emp.vecesVacacionesAnio} x ${emp.diasPorPeriodoVacaciones} días = ${emp.diasVacacionesTotales} días',
                ),
                Text('Días usados: ${emp.diasVacacionesUsados}'),
                Text('Días restantes: ${emp.diasVacacionesDisponibles}'),
                Text('Vigencia del ciclo: ${_fmtFecha(emp.vigenciaVacaciones)}'),
                const SizedBox(height: 14),
                FilledButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Nueva solicitud de vacaciones'),
                  onPressed: () => _abrirFormularioSolicitud(
                    tipoInicial: 'Vacaciones',
                    esVacacion: true,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tabulador de días según antigüedad',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Referencia del formato institucional HSJS',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 10),
                Table(
                  border: TableBorder.all(color: Colors.black26),
                  columnWidths: const {
                    0: FlexColumnWidth(1.3),
                    1: FlexColumnWidth(1),
                  },
                  children: [
                    TableRow(
                      decoration: BoxDecoration(
                        color: HospitalBranding.azulMarino
                            .withValues(alpha: 0.12),
                      ),
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(8),
                          child: Text(
                            'Años de antigüedad',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8),
                          child: Text(
                            'Días que corresponden',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    ...kTabuladorVacacionesHsjs.map((fila) {
                      final esActual = anios >= fila.minAnios &&
                          anios <= fila.maxAnios &&
                          anios >= 1;
                      return TableRow(
                        decoration: esActual
                            ? BoxDecoration(
                                color: HospitalBranding.azulMarino
                                    .withValues(alpha: 0.18),
                              )
                            : null,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              esActual
                                  ? '${fila.rangoLabel} (Actual)'
                                  : fila.rangoLabel,
                              style: TextStyle(
                                fontWeight: esActual
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              '${fila.dias} días',
                              style: TextStyle(
                                fontWeight: esActual
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMisSolicitudes(
    List<SolicitudPermiso> misSolicitudes,
    List<RegistroIncidencia> misIncidencias,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Mis solicitudes',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (misSolicitudes.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Aún no tienes solicitudes registradas.'),
            ),
          )
        else
          ...misSolicitudes.map((s) {
            final pendiente = s.estatus == 'PENDIENTE';
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${s.tipo} (${s.diasSolicitados} día(s))',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        Chip(label: Text(s.estatus)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      s.motivo.isEmpty ? 'Sin motivo' : s.motivo,
                    ),
                    Text(
                      'Inicio: ${_fmtFecha(s.fechaInicio)} - Fin: ${_fmtFecha(s.fechaFin)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (pendiente) ...[
                          OutlinedButton.icon(
                            onPressed: () => _confirmarAccionSolicitud(
                              solicitud: s,
                              esEliminar: false,
                            ),
                            icon: const Icon(Icons.cancel_outlined, size: 18),
                            label: const Text('Cancelar'),
                          ),
                          const SizedBox(width: 8),
                        ],
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red.shade700,
                          ),
                          onPressed: () => _confirmarAccionSolicitud(
                            solicitud: s,
                            esEliminar: true,
                          ),
                          icon: const Icon(Icons.delete_outline, size: 18),
                          label: const Text('Eliminar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        const SizedBox(height: 16),
        const Text(
          'Reconocimientos y notas',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (misIncidencias.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Sin registros de incidencias o reconocimientos.'),
            ),
          )
        else
          ...misIncidencias.map(
            (inc) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text('${inc.tipo}: ${inc.titulo}'),
                subtitle: Text(
                  '${inc.descripcion}\nFecha: ${_fmtFecha(inc.fecha)}',
                ),
              ),
            ),
          ),
      ],
    );
  }
}