import 'package:flutter/material.dart';
import 'package:talento_humano/src/core/hospital_theme.dart';
import 'package:talento_humano/src/core/talento_humano_store.dart';
import 'package:talento_humano/src/features/dashboard/presentacion/admin_catalogos.dart';
import 'package:talento_humano/src/features/dashboard/presentacion/admin_reportes.dart';
import 'package:talento_humano/src/features/dashboard/presentacion/notificaciones_boton.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _indiceActual = 0;

  // Búsqueda y filtros en Solicitudes
  final TextEditingController _busquedaSolicitudesCtrl = TextEditingController();
  String _filtroEstatusSolicitud =
      'TODOS'; // TODOS | PENDIENTE | AUTORIZADA | RECHAZADA | CANCELADA
  String _filtroTipoSolicitud = 'TODOS'; // TODOS | VACACIONES | PERMISOS

  // Búsqueda y filtros en Empleados
  final TextEditingController _busquedaEmpleadosCtrl = TextEditingController();
  String _filtroEstadoEmpleado = 'ACTIVOS'; // ACTIVOS | BAJAS | TODOS

  // Selector de colaborador en el apartado Tabulador
  String? _empleadoIdTabulador;

  @override
  void dispose() {
    _busquedaSolicitudesCtrl.dispose();
    _busquedaEmpleadosCtrl.dispose();
    super.dispose();
  }

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
      firstDate: DateTime(1950),
      lastDate: DateTime(2035),
    );
    if (elegida != null) {
      setModalState(() => onSeleccionada(elegida));
    }
  }

  /// Campos de número de empleado, departamento y puesto para los diálogos.
  List<Widget> _camposOrganizacion({
    required StateSetter setModalState,
    required TextEditingController numeroCtrl,
    required TextEditingController puestoCtrl,
    required String? departamentoId,
    required String? puestoId,
    required ValueChanged<String?> onDepartamento,
    required ValueChanged<String?> onPuesto,
  }) {
    final store = TalentoHumanoStore.instance;
    final deptos = store.departamentos;
    final puestos = store.puestos;
    final deptoValido =
        deptos.any((d) => d.id == departamentoId) ? departamentoId : null;
    final puestoValido =
        puestos.any((p) => p.id == puestoId) ? puestoId : null;

    return [
      TextField(
        controller: numeroCtrl,
        decoration: InputDecoration(
          labelText: 'Número de empleado',
          helperText: 'Vacío = se asigna ${store.siguienteNumeroEmpleado()}',
          border: const OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 10),
      DropdownButtonFormField<String?>(
        initialValue: deptoValido,
        decoration: const InputDecoration(
          labelText: 'Departamento',
          border: OutlineInputBorder(),
        ),
        items: [
          const DropdownMenuItem<String?>(
            value: null,
            child: Text('Sin departamento'),
          ),
          ...deptos.map(
            (d) => DropdownMenuItem<String?>(value: d.id, child: Text(d.nombre)),
          ),
        ],
        onChanged: (v) => setModalState(() => onDepartamento(v)),
      ),
      const SizedBox(height: 10),
      if (puestos.isNotEmpty)
        DropdownButtonFormField<String?>(
          initialValue: puestoValido,
          decoration: const InputDecoration(
            labelText: 'Puesto (catálogo)',
            border: OutlineInputBorder(),
          ),
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text('Otro (texto libre)'),
            ),
            ...puestos.map(
              (p) => DropdownMenuItem<String?>(value: p.id, child: Text(p.nombre)),
            ),
          ],
          onChanged: (v) => setModalState(() {
            onPuesto(v);
            if (v != null) {
              puestoCtrl.text = store.buscarPuesto(v)?.nombre ?? puestoCtrl.text;
            }
          }),
        ),
      if (puestos.isEmpty || puestoValido == null) ...[
        if (puestos.isNotEmpty) const SizedBox(height: 10),
        TextField(
          controller: puestoCtrl,
          decoration: const InputDecoration(
            labelText: 'Puesto',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    ];
  }

  Future<void> _dialogoAgregarEmpleado() async {
    final nombreCtrl = TextEditingController();
    final puestoCtrl = TextEditingController(text: 'Operativo');
    final numeroCtrl = TextEditingController();
    String? departamentoId;
    String? puestoId;
    final correoCtrl = TextEditingController();
    final passCtrl = TextEditingController(text: '1234');
    String rolSeleccionado = 'empleado';
    int vecesVac = 2;
    int diasPeriodo = 6;
    DateTime fechaIngreso = DateTime.now();
    DateTime? fechaNacimiento;

    final guardar = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          title: const Text('Alta de colaborador'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nombreCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nombre completo',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                ..._camposOrganizacion(
                  setModalState: setModalState,
                  numeroCtrl: numeroCtrl,
                  puestoCtrl: puestoCtrl,
                  departamentoId: departamentoId,
                  puestoId: puestoId,
                  onDepartamento: (v) => departamentoId = v,
                  onPuesto: (v) => puestoId = v,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: rolSeleccionado,
                  decoration: const InputDecoration(
                    labelText: 'Rol en el sistema',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'empleado',
                      child: Text('Empleado'),
                    ),
                    DropdownMenuItem(
                      value: 'admin',
                      child: Text('Administrador'),
                    ),
                  ],
                  onChanged: (v) {
                    if (v != null) {
                      setModalState(() => rolSeleccionado = v);
                    }
                  },
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () => _seleccionarFecha(
                    dialogContext: ctx,
                    setModalState: setModalState,
                    inicial: fechaIngreso,
                    onSeleccionada: (d) => fechaIngreso = d,
                  ),
                  child: Text('Fecha ingreso: ${_fmtFecha(fechaIngreso)}'),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () => _seleccionarFecha(
                    dialogContext: ctx,
                    setModalState: setModalState,
                    inicial: fechaNacimiento ?? DateTime(1995, 1, 1),
                    onSeleccionada: (d) => fechaNacimiento = d,
                  ),
                  child: Text(
                    'Fecha nacimiento: ${_fmtFecha(fechaNacimiento)}',
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: vecesVac.toString(),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Periodos vac./año',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (v) =>
                            vecesVac = int.tryParse(v.trim()) ?? vecesVac,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        initialValue: diasPeriodo.toString(),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Días x periodo',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (v) => diasPeriodo =
                            int.tryParse(v.trim()) ?? diasPeriodo,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: correoCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Correo de acceso (requerido para login)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: passCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña inicial',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );

    if (guardar == true && nombreCtrl.text.trim().isNotEmpty && mounted) {
      final emp = Empleado(
        id: 'emp_${DateTime.now().millisecondsSinceEpoch}',
        numeroEmpleado: numeroCtrl.text.trim(),
        departamentoId: departamentoId,
        puestoId: puestoId,
        nombre: nombreCtrl.text.trim(),
        puesto: puestoCtrl.text.trim().isEmpty
            ? 'Operativo'
            : puestoCtrl.text.trim(),
        fechaIngreso: fechaIngreso,
        fechaNacimiento: fechaNacimiento,
        vecesVacacionesAnio: vecesVac < 1 ? 1 : vecesVac,
        diasPorPeriodoVacaciones: diasPeriodo < 1 ? 1 : diasPeriodo,
        vigenciaVacaciones: TalentoHumanoStore.finCicloAnual(),
        activo: true,
      );

      await TalentoHumanoStore.instance.guardarEmpleado(
        emp,
        correo: correoCtrl.text.trim(),
        password: passCtrl.text,
        rol: rolSeleccionado,
      );
    }
  }

  Future<void> _dialogoEditarEmpleado(Empleado emp) async {
    final store = TalentoHumanoStore.instance;
    final usrActual = store.buscarUsuarioPorEmpleadoId(emp.id);

    final nombreCtrl = TextEditingController(text: emp.nombre);
    final puestoCtrl = TextEditingController(text: emp.puesto);
    final numeroCtrl = TextEditingController(text: emp.numeroEmpleado);
    String? departamentoId = emp.departamentoId;
    String? puestoId = emp.puestoId;
    EstadoLaboral estadoLaboral = emp.estadoLaboral;
    final correoCtrl = TextEditingController(text: usrActual?.correo ?? '');
    final passCtrl = TextEditingController(text: usrActual?.password ?? '');
    String rolSeleccionado = usrActual?.rol ?? 'empleado';

    final vacUsadosCtrl =
        TextEditingController(text: emp.diasVacacionesUsados.toString());
    final vecesVacCtrl =
        TextEditingController(text: emp.vecesVacacionesAnio.toString());
    final diasPeriodoCtrl =
        TextEditingController(text: emp.diasPorPeriodoVacaciones.toString());
    final tardeTotCtrl =
        TextEditingController(text: emp.permisosEntradaTardeTotal.toString());
    final tardeUsaCtrl =
        TextEditingController(text: emp.permisosEntradaTardeUsados.toString());
    final salidaTotCtrl =
        TextEditingController(text: emp.permisosSalidaAntesTotal.toString());
    final salidaUsaCtrl =
        TextEditingController(text: emp.permisosSalidaAntesUsados.toString());
    final conGoceTotCtrl =
        TextEditingController(text: emp.faltasConGoceTotal.toString());
    final conGoceUsaCtrl =
        TextEditingController(text: emp.faltasConGoceUsados.toString());
    final sinGoceTotCtrl =
        TextEditingController(text: emp.faltasSinGoceTotal.toString());
    final sinGoceUsaCtrl =
        TextEditingController(text: emp.faltasSinGoceUsados.toString());
    final cumpleTotCtrl =
        TextEditingController(text: emp.diaCumpleanosTotal.toString());
    final cumpleUsaCtrl =
        TextEditingController(text: emp.diaCumpleanosUsados.toString());
    final lutoTotCtrl = TextEditingController(
      text: emp.fallecimientoPrimeraLineaTotal.toString(),
    );
    final lutoUsaCtrl = TextEditingController(
      text: emp.fallecimientoPrimeraLineaUsados.toString(),
    );

    DateTime ingreso = emp.fechaIngreso;
    DateTime? nacimiento = emp.fechaNacimiento;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          title: Text('Editar: ${emp.nombre}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nombreCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                ..._camposOrganizacion(
                  setModalState: setModalState,
                  numeroCtrl: numeroCtrl,
                  puestoCtrl: puestoCtrl,
                  departamentoId: departamentoId,
                  puestoId: puestoId,
                  onDepartamento: (v) => departamentoId = v,
                  onPuesto: (v) => puestoId = v,
                ),
                if (emp.activo) ...[
                  const SizedBox(height: 10),
                  DropdownButtonFormField<EstadoLaboral>(
                    initialValue: estadoLaboral,
                    decoration: const InputDecoration(
                      labelText: 'Estado laboral',
                      border: OutlineInputBorder(),
                    ),
                    items: EstadoLaboral.values
                        .where((e) => e != EstadoLaboral.baja)
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text(e.etiqueta),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setModalState(() => estadoLaboral = v);
                    },
                  ),
                ],
                const SizedBox(height: 10),
                TextField(
                  controller: correoCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Correo de acceso',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: passCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue:
                      rolSeleccionado == 'admin' ? 'admin' : 'empleado',
                  decoration: const InputDecoration(
                    labelText: 'Rol',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'empleado',
                      child: Text('Empleado'),
                    ),
                    DropdownMenuItem(
                      value: 'admin',
                      child: Text('Administrador'),
                    ),
                  ],
                  onChanged: (v) {
                    if (v != null) {
                      setModalState(() => rolSeleccionado = v);
                    }
                  },
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () => _seleccionarFecha(
                    dialogContext: ctx,
                    setModalState: setModalState,
                    inicial: ingreso,
                    onSeleccionada: (d) => ingreso = d,
                  ),
                  child: Text('Ingreso: ${_fmtFecha(ingreso)}'),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () => _seleccionarFecha(
                    dialogContext: ctx,
                    setModalState: setModalState,
                    inicial: nacimiento ?? DateTime(1995, 1, 1),
                    onSeleccionada: (d) => nacimiento = d,
                  ),
                  child: Text('Nacimiento: ${_fmtFecha(nacimiento)}'),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: vecesVacCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Veces vac./año',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: diasPeriodoCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Días x periodo',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: vacUsadosCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Días vacaciones usados',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: tardeTotCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Ent. tarde total',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: tardeUsaCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Ent. tarde usados',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: salidaTotCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Sal. antes total',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: salidaUsaCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Sal. antes usados',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: conGoceTotCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Faltas c/goce tot.',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: conGoceUsaCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Faltas c/goce us.',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: sinGoceTotCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Faltas s/goce tot.',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: sinGoceUsaCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Faltas s/goce us.',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: cumpleTotCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Cumpleaños tot.',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: cumpleUsaCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Cumpleaños us.',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: lutoTotCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: '1a línea tot.',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: lutoUsaCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: '1a línea us.',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Guardar cambios'),
            ),
          ],
        ),
      ),
    );

    if (ok == true && mounted) {
      int n(TextEditingController c, int actual) =>
          int.tryParse(c.text.trim()) ?? actual;

      final editado = emp.copyWith(
        numeroEmpleado: numeroCtrl.text.trim(),
        departamentoId: departamentoId,
        puestoId: puestoId,
        estadoLaboral: emp.activo ? estadoLaboral : null,
        nombre: nombreCtrl.text.trim().isEmpty
            ? emp.nombre
            : nombreCtrl.text.trim(),
        puesto: puestoCtrl.text.trim().isEmpty
            ? emp.puesto
            : puestoCtrl.text.trim(),
        fechaIngreso: ingreso,
        fechaNacimiento: nacimiento,
        vecesVacacionesAnio: n(vecesVacCtrl, emp.vecesVacacionesAnio),
        diasPorPeriodoVacaciones:
            n(diasPeriodoCtrl, emp.diasPorPeriodoVacaciones),
        diasVacacionesUsados: n(vacUsadosCtrl, emp.diasVacacionesUsados),
        permisosEntradaTardeTotal:
            n(tardeTotCtrl, emp.permisosEntradaTardeTotal),
        permisosEntradaTardeUsados:
            n(tardeUsaCtrl, emp.permisosEntradaTardeUsados),
        permisosSalidaAntesTotal:
            n(salidaTotCtrl, emp.permisosSalidaAntesTotal),
        permisosSalidaAntesUsados:
            n(salidaUsaCtrl, emp.permisosSalidaAntesUsados),
        faltasConGoceTotal: n(conGoceTotCtrl, emp.faltasConGoceTotal),
        faltasConGoceUsados: n(conGoceUsaCtrl, emp.faltasConGoceUsados),
        faltasSinGoceTotal: n(sinGoceTotCtrl, emp.faltasSinGoceTotal),
        faltasSinGoceUsados: n(sinGoceUsaCtrl, emp.faltasSinGoceUsados),
        diaCumpleanosTotal: n(cumpleTotCtrl, emp.diaCumpleanosTotal),
        diaCumpleanosUsados: n(cumpleUsaCtrl, emp.diaCumpleanosUsados),
        fallecimientoPrimeraLineaTotal:
            n(lutoTotCtrl, emp.fallecimientoPrimeraLineaTotal),
        fallecimientoPrimeraLineaUsados:
            n(lutoUsaCtrl, emp.fallecimientoPrimeraLineaUsados),
      );

      if (editado.estadoLaboral != emp.estadoLaboral) {
        await store.enviarNotificacion(
          idEmpleado: emp.id,
          mensaje:
              'Tu estado laboral cambió a: ${editado.estadoLaboral.etiqueta}.',
        );
      }

      await store.guardarEmpleado(
        editado,
        correo: correoCtrl.text.trim(),
        password: passCtrl.text.trim().isEmpty ? null : passCtrl.text.trim(),
        rol: rolSeleccionado,
      );
    }
  }

  Future<void> _dialogoBajaEmpleado(Empleado emp) async {
    final motivoCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Dar de baja a ${emp.nombre}'),
        content: TextField(
          controller: motivoCtrl,
          decoration: const InputDecoration(
            labelText: 'Motivo de baja',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirmar baja'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      await TalentoHumanoStore.instance.darDeBajaEmpleado(
        emp.id,
        motivo: motivoCtrl.text.trim(),
      );
    }
  }

  Future<void> _dialogoNuevaIncidencia() async {
    final store = TalentoHumanoStore.instance;
    final activos = store.empleadosActivos;
    String empleadoNombre =
        activos.isNotEmpty ? activos.first.nombre : 'Colaborador';
    String tipo = 'Reconocimiento';
    final tituloCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          title: const Text('Registrar reconocimiento o sanción'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (activos.isNotEmpty)
                  DropdownButtonFormField<String>(
                    initialValue: empleadoNombre,
                    decoration: const InputDecoration(
                      labelText: 'Colaborador',
                      border: OutlineInputBorder(),
                    ),
                    items: activos
                        .map(
                          (e) => DropdownMenuItem<String>(
                            value: e.nombre,
                            child: Text(e.nombre),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setModalState(() => empleadoNombre = v);
                      }
                    },
                  ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: tipo,
                  decoration: const InputDecoration(
                    labelText: 'Tipo',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Reconocimiento',
                      child: Text('Reconocimiento'),
                    ),
                    DropdownMenuItem(
                      value: 'Sanción',
                      child: Text('Sanción'),
                    ),
                  ],
                  onChanged: (v) {
                    if (v != null) {
                      setModalState(() => tipo = v);
                    }
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: tituloCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Título',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );

    if (ok == true && tituloCtrl.text.trim().isNotEmpty && mounted) {
      await store.agregarIncidencia(
        RegistroIncidencia(
          id: 'inc_${DateTime.now().millisecondsSinceEpoch}',
          nombreEmpleado: empleadoNombre,
          tipo: tipo,
          titulo: tituloCtrl.text.trim(),
          descripcion: descCtrl.text.trim(),
        ),
      );
    }
  }

  Future<void> _confirmarEliminarSolicitudAdmin(SolicitudPermiso s) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar solicitud'),
        content: Text(
          '¿Deseas eliminar la solicitud de ${s.nombreEmpleado} (${s.tipo})?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      await TalentoHumanoStore.instance.eliminarSolicitud(s.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solicitud eliminada.')),
      );
    }
  }

  Future<void> _confirmarEliminarIncidencia(RegistroIncidencia inc) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar incidencia'),
        content: Text(
          '¿Deseas eliminar "${inc.titulo}" de ${inc.nombreEmpleado}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      await TalentoHumanoStore.instance.eliminarIncidencia(inc.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Incidencia eliminada.')),
      );
    }
  }

  Widget _buildApartadoTabulador(TalentoHumanoStore store) {
    final colaboradores = store.empleadosActivos;
    Empleado? seleccionado;
    if (colaboradores.isNotEmpty) {
      seleccionado = colaboradores.firstWhere(
        (e) => e.id == _empleadoIdTabulador,
        orElse: () => colaboradores.first,
      );
    }

    final anios = seleccionado?.aniosCumplidos ?? 0;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Consulta por colaborador',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Selecciona un empleado para resaltar su rango de antigüedad',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 10),
                if (colaboradores.isEmpty)
                  const Text('No hay colaboradores activos registrados.')
                else
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: seleccionado?.id,
                    decoration: const InputDecoration(
                      labelText: 'Colaborador',
                      border: OutlineInputBorder(),
                    ),
                    items: colaboradores
                        .map(
                          (e) => DropdownMenuItem<String>(
                            value: e.id,
                            child: Text(
                              '${e.nombre} (${e.antiguedadTexto})',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      setState(() => _empleadoIdTabulador = v);
                    },
                  ),
                if (seleccionado != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    'Ingreso: ${_fmtFecha(seleccionado.fechaIngreso)} • Antigüedad: ${seleccionado.antiguedadTexto}',
                  ),
                  Text(
                    anios < 1
                        ? 'Por tabulador: aún no cumple 1 año (0 días)'
                        : 'Por tabulador: ${seleccionado.diasVacacionesPorTabulador} días (Disp. actuales: ${seleccionado.diasVacacionesDisponibles})',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: HospitalBranding.azulMarino,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tabulador de vacaciones según antigüedad',
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
                      final esActual = seleccionado != null &&
                          anios >= fila.minAnios &&
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

  @override
  Widget build(BuildContext context) {
    final store = TalentoHumanoStore.instance;

    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        Widget cuerpo;
        switch (_indiceActual) {
          case 0:
            cuerpo = _buildSolicitudes(store);
            break;
          case 1:
            cuerpo = _buildEmpleados(store);
            break;
          case 2:
            cuerpo = _buildApartadoTabulador(store);
            break;
          case 3:
            cuerpo = _buildIncidenciasYConfig(store);
            break;
          case 4:
            cuerpo = const AdminCatalogosView();
            break;
          default:
            cuerpo = const AdminReportesView();
            break;
        }

        return Scaffold(
          appBar: AppBar(
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${HospitalBranding.nombre} - Admin',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  '“${HospitalBranding.lema}”',
                  style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
                ),
              ],
            ),
            actions: [
              const NotificacionesBoton(idEmpleado: null),
              IconButton(
                tooltip: 'Sincronizar con Supabase',
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
          floatingActionButton: _indiceActual == 1
              ? FloatingActionButton.extended(
                  onPressed: _dialogoAgregarEmpleado,
                  icon: const Icon(Icons.person_add),
                  label: const Text('Nuevo empleado'),
                )
              : _indiceActual == 3
                  ? FloatingActionButton.extended(
                      onPressed: _dialogoNuevaIncidencia,
                      icon: const Icon(Icons.add),
                      label: const Text('Registrar'),
                    )
                  : null,
          body: Column(
            children: [
              if (store.ultimoError != null)
                MaterialBanner(
                  backgroundColor: Colors.red.shade50,
                  content: Text(
                    store.ultimoError!,
                    style: TextStyle(
                      color: Colors.red.shade900,
                      fontSize: 12,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => store.sincronizarDesdeSupabase(),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              Expanded(child: cuerpo),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _indiceActual,
            onDestinationSelected: (i) => setState(() => _indiceActual = i),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.fact_check_outlined),
                selectedIcon: Icon(Icons.fact_check),
                label: 'Solicitudes',
              ),
              NavigationDestination(
                icon: Icon(Icons.people_outline),
                selectedIcon: Icon(Icons.people),
                label: 'Empleados',
              ),
              NavigationDestination(
                icon: Icon(Icons.table_chart_outlined),
                selectedIcon: Icon(Icons.table_chart),
                label: 'Tabulador',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: 'Incidencias',
              ),
              NavigationDestination(
                icon: Icon(Icons.apartment_outlined),
                selectedIcon: Icon(Icons.apartment),
                label: 'Catálogos',
              ),
              NavigationDestination(
                icon: Icon(Icons.summarize_outlined),
                selectedIcon: Icon(Icons.summarize),
                label: 'Reportes',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSolicitudes(TalentoHumanoStore store) {
    final query = _busquedaSolicitudesCtrl.text.trim().toLowerCase();

    final solicitudesFiltradas = store.solicitudes.where((s) {
      if (_filtroEstatusSolicitud != 'TODOS' &&
          s.estatus != _filtroEstatusSolicitud) {
        return false;
      }
      final esVac = s.tipo.toLowerCase().contains('vacacion');
      if (_filtroTipoSolicitud == 'VACACIONES' && !esVac) return false;
      if (_filtroTipoSolicitud == 'PERMISOS' && esVac) return false;

      if (query.isNotEmpty) {
        final matchNombre = s.nombreEmpleado.toLowerCase().contains(query);
        final matchTipo = s.tipo.toLowerCase().contains(query);
        final matchMotivo = s.motivo.toLowerCase().contains(query);
        if (!matchNombre && !matchTipo && !matchMotivo) return false;
      }
      return true;
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          controller: _busquedaSolicitudesCtrl,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            labelText: 'Buscar usuario, tipo o motivo',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _busquedaSolicitudesCtrl.text.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _busquedaSolicitudesCtrl.clear();
                      setState(() {});
                    },
                  ),
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            ChoiceChip(
              label: const Text('Todos'),
              selected: _filtroEstatusSolicitud == 'TODOS',
              onSelected: (_) =>
                  setState(() => _filtroEstatusSolicitud = 'TODOS'),
            ),
            ChoiceChip(
              label: const Text('Pendientes'),
              selected: _filtroEstatusSolicitud == 'PENDIENTE',
              onSelected: (_) =>
                  setState(() => _filtroEstatusSolicitud = 'PENDIENTE'),
            ),
            ChoiceChip(
              label: const Text('Autorizadas'),
              selected: _filtroEstatusSolicitud == 'AUTORIZADA',
              onSelected: (_) =>
                  setState(() => _filtroEstatusSolicitud = 'AUTORIZADA'),
            ),
            ChoiceChip(
              label: const Text('Rechazadas'),
              selected: _filtroEstatusSolicitud == 'RECHAZADA',
              onSelected: (_) =>
                  setState(() => _filtroEstatusSolicitud = 'RECHAZADA'),
            ),
            ChoiceChip(
              label: const Text('Canceladas'),
              selected: _filtroEstatusSolicitud == 'CANCELADA',
              onSelected: (_) =>
                  setState(() => _filtroEstatusSolicitud = 'CANCELADA'),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            ChoiceChip(
              label: const Text('Todo tipo'),
              selected: _filtroTipoSolicitud == 'TODOS',
              onSelected: (_) =>
                  setState(() => _filtroTipoSolicitud = 'TODOS'),
            ),
            ChoiceChip(
              label: const Text('Vacaciones'),
              selected: _filtroTipoSolicitud == 'VACACIONES',
              onSelected: (_) =>
                  setState(() => _filtroTipoSolicitud = 'VACACIONES'),
            ),
            ChoiceChip(
              label: const Text('Permisos/Faltas'),
              selected: _filtroTipoSolicitud == 'PERMISOS',
              onSelected: (_) =>
                  setState(() => _filtroTipoSolicitud = 'PERMISOS'),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (solicitudesFiltradas.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'No hay solicitudes que coincidan con la búsqueda o filtro.',
              ),
            ),
          )
        else
          ...solicitudesFiltradas.map((s) {
            final pendiente = s.estatus == 'PENDIENTE';
            final emp = store.buscarEmpleadoPorId(s.idEmpleado);
            final esVac = s.tipo.toLowerCase().contains('vacacion');
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${s.nombreEmpleado} • ${s.tipo}',
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
                    if (emp != null && esVac)
                      Text(
                        'Antigüedad: ${emp.antiguedadTexto} | Tabulador: ${emp.diasVacacionesPorTabulador} días | Disp.: ${emp.diasVacacionesDisponibles}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: HospitalBranding.azulMarino,
                        ),
                      ),
                    Text('Días solicitados: ${s.diasSolicitados}'),
                    Text(
                      'Fechas: ${_fmtFecha(s.fechaInicio)} al ${_fmtFecha(s.fechaFin)}',
                    ),
                    if (s.motivo.isNotEmpty) Text('Motivo: ${s.motivo}'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        if (pendiente) ...[
                          FilledButton.icon(
                            onPressed: () async {
                              final error =
                                  await store.actualizarEstatusSolicitud(
                                s.id,
                                'AUTORIZADA',
                                fechaAutorizadaInicio: s.fechaInicio,
                                fechaAutorizadaFin: s.fechaFin,
                              );
                              if (error != null && mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(error)),
                                );
                              }
                            },
                            icon: const Icon(Icons.check),
                            label: const Text('Autorizar'),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => store.actualizarEstatusSolicitud(
                              s.id,
                              'RECHAZADA',
                            ),
                            icon: const Icon(Icons.close),
                            label: const Text('Rechazar'),
                          ),
                        ],
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red.shade700,
                          ),
                          onPressed: () => _confirmarEliminarSolicitudAdmin(s),
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Eliminar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildEmpleados(TalentoHumanoStore store) {
    final query = _busquedaEmpleadosCtrl.text.trim().toLowerCase();

    final baseLista = _filtroEstadoEmpleado == 'BAJAS'
        ? store.empleadosBaja
        : _filtroEstadoEmpleado == 'TODOS'
            ? [
                ...store.empleadosActivos,
                ...store.empleadosBaja,
              ]
            : store.empleadosActivos;

    final lista = query.isEmpty
        ? baseLista
        : baseLista.where((e) {
            final matchNombre = e.nombre.toLowerCase().contains(query);
            final matchPuesto = e.puesto.toLowerCase().contains(query);
            final matchNumero =
                e.numeroEmpleado.toLowerCase().contains(query);
            final matchDepto = store
                .nombreDepartamento(e.departamentoId)
                .toLowerCase()
                .contains(query);
            return matchNombre || matchPuesto || matchNumero || matchDepto;
          }).toList();

    final tituloLista = _filtroEstadoEmpleado == 'BAJAS'
        ? 'Colaboradores dados de baja (${lista.length})'
        : _filtroEstadoEmpleado == 'TODOS'
            ? 'Todos los colaboradores (${lista.length})'
            : 'Colaboradores activos (${lista.length})';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          controller: _busquedaEmpleadosCtrl,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            labelText: 'Buscar por nombre, número, puesto o departamento',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _busquedaEmpleadosCtrl.text.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _busquedaEmpleadosCtrl.clear();
                      setState(() {});
                    },
                  ),
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            ChoiceChip(
              label: const Text('Activos'),
              selected: _filtroEstadoEmpleado == 'ACTIVOS',
              onSelected: (_) =>
                  setState(() => _filtroEstadoEmpleado = 'ACTIVOS'),
            ),
            ChoiceChip(
              label: const Text('Bajas'),
              selected: _filtroEstadoEmpleado == 'BAJAS',
              onSelected: (_) =>
                  setState(() => _filtroEstadoEmpleado = 'BAJAS'),
            ),
            ChoiceChip(
              label: const Text('Todos'),
              selected: _filtroEstadoEmpleado == 'TODOS',
              onSelected: (_) =>
                  setState(() => _filtroEstadoEmpleado = 'TODOS'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          tituloLista,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 10),
        if (lista.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'No hay colaboradores que coincidan con la búsqueda o filtro.',
              ),
            ),
          )
        else
          ...lista.map(
            (e) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                title: Text(
                  e.activo
                      ? '${e.numeroEmpleado.isEmpty ? '' : '${e.numeroEmpleado} · '}${e.nombre} (${e.puesto})'
                      : '${e.nombre} • BAJA',
                ),
                subtitle: Text(
                  '${store.nombreDepartamento(e.departamentoId)} | Estado: ${e.estadoLaboral.etiqueta}\nAntigüedad: ${e.antiguedadTexto} | Vacaciones disp.: ${e.diasVacacionesDisponibles}\nIngreso: ${_fmtFecha(e.fechaIngreso)} | Nac.: ${_fmtFecha(e.fechaNacimiento)}',
                ),
                isThreeLine: true,
                trailing: PopupMenuButton<String>(
                  onSelected: (accion) async {
                    if (accion == 'editar') {
                      await _dialogoEditarEmpleado(e);
                    } else if (accion == 'baja') {
                      await _dialogoBajaEmpleado(e);
                    } else if (accion == 'reactivar') {
                      await store.reactivarEmpleado(e.id);
                    }
                  },
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(
                      value: 'editar',
                      child: Text('Editar datos y saldos'),
                    ),
                    if (e.activo)
                      const PopupMenuItem(
                        value: 'baja',
                        child: Text('Dar de baja'),
                      )
                    else
                      const PopupMenuItem(
                        value: 'reactivar',
                        child: Text('Reactivar colaborador'),
                      ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildIncidenciasYConfig(TalentoHumanoStore store) {
    final incidencias = store.incidencias;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ciclo anual de permisos y vacaciones: ${store.cicloAnualTexto}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  icon: const Icon(Icons.autorenew),
                  label: const Text('Renovar saldos del ciclo anual'),
                  onPressed: () async {
                    await store.reiniciarSaldosCicloAnual();
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Saldos del ciclo renovados.'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Reconocimientos y sanciones registrados',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (incidencias.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Aún no hay incidencias ni reconocimientos.'),
            ),
          )
        else
          ...incidencias.map(
            (inc) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text('${inc.tipo}: ${inc.titulo}'),
                subtitle: Text(
                  '${inc.nombreEmpleado} • ${inc.descripcion}\nFecha: ${_fmtFecha(inc.fecha)}',
                ),
                trailing: IconButton(
                  tooltip: 'Eliminar',
                  icon: Icon(
                    Icons.delete_outline,
                    color: Colors.red.shade700,
                  ),
                  onPressed: () => _confirmarEliminarIncidencia(inc),
                ),
              ),
            ),
          ),
      ],
    );
  }
}