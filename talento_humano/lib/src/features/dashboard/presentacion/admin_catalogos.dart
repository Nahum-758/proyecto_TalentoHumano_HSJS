import 'package:flutter/material.dart';
import 'package:talento_humano/src/core/talento_humano_store.dart';

/// Apartado de administración de Departamentos, Puestos y Calendario laboral.
class AdminCatalogosView extends StatelessWidget {
  const AdminCatalogosView({super.key});

  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(icon: Icon(Icons.apartment), text: 'Departamentos'),
              Tab(icon: Icon(Icons.badge_outlined), text: 'Puestos'),
              Tab(icon: Icon(Icons.event), text: 'Calendario'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _DepartamentosTab(),
                _PuestosTab(),
                _CalendarioTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Future<String?> _pedirNombre(
  BuildContext context, {
  required String titulo,
  String inicial = '',
}) async {
  final res = await showDialog<String>(
    context: context,
    builder: (_) => _DialogoNombre(titulo: titulo, inicial: inicial),
  );
  final limpio = res?.trim() ?? '';
  return limpio.isEmpty ? null : limpio;
}

/// El diálogo es dueño de su controlador y lo libera en dispose(), cuando
/// ya terminó la animación de cierre (liberarlo antes provoca el error
/// '_dependents.isEmpty').
class _DialogoNombre extends StatefulWidget {
  final String titulo;
  final String inicial;

  const _DialogoNombre({required this.titulo, required this.inicial});

  @override
  State<_DialogoNombre> createState() => _DialogoNombreState();
}

class _DialogoNombreState extends State<_DialogoNombre> {
  late final TextEditingController _ctrl =
      TextEditingController(text: widget.inicial);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.titulo),
      content: TextField(
        controller: _ctrl,
        autofocus: true,
        decoration: const InputDecoration(
          labelText: 'Nombre',
          border: OutlineInputBorder(),
        ),
        onSubmitted: (v) => Navigator.pop(context, v),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _ctrl.text),
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}

Future<bool> _confirmar(BuildContext context, String mensaje) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Confirmar'),
      content: Text(mensaje),
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
  return ok == true;
}

void _aviso(BuildContext context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
}

class _DepartamentosTab extends StatelessWidget {
  const _DepartamentosTab();

  @override
  Widget build(BuildContext context) {
    final store = TalentoHumanoStore.instance;
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final lista = store.departamentos;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Departamentos (${lista.length})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                FilledButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Nuevo'),
                  onPressed: () async {
                    final n = await _pedirNombre(
                      context,
                      titulo: 'Nuevo departamento',
                    );
                    if (n != null) await store.crearDepartamento(n);
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (lista.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Aún no hay departamentos registrados.'),
                ),
              ),
            ...lista.map((d) {
              final emps = store.empleadosDeDepartamento(d.id);
              final activos = emps.where((e) => e.activo).length;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ExpansionTile(
                  leading: const Icon(Icons.apartment),
                  title: Text(d.nombre),
                  subtitle: Text('$activos colaborador(es) activo(s)'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (accion) async {
                      if (accion == 'renombrar') {
                        final n = await _pedirNombre(
                          context,
                          titulo: 'Renombrar departamento',
                          inicial: d.nombre,
                        );
                        if (n != null) {
                          await store.guardarDepartamento(
                            Departamento(id: d.id, nombre: n),
                          );
                        }
                      } else if (accion == 'eliminar') {
                        if (!await _confirmar(
                          context,
                          '¿Eliminar el departamento "${d.nombre}"?',
                        )) {
                          return;
                        }
                        final err = await store.eliminarDepartamento(d.id);
                        if (err != null && context.mounted) {
                          _aviso(context, err);
                        }
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'renombrar',
                        child: Text('Renombrar'),
                      ),
                      PopupMenuItem(
                        value: 'eliminar',
                        child: Text('Eliminar'),
                      ),
                    ],
                  ),
                  children: emps.isEmpty
                      ? const [
                          ListTile(title: Text('Sin colaboradores asignados.')),
                        ]
                      : emps
                          .map(
                            (e) => ListTile(
                              dense: true,
                              title: Text(e.nombre),
                              subtitle: Text(
                                '${e.numeroEmpleado} • ${e.puesto} • ${e.estadoLaboral.etiqueta}',
                              ),
                            ),
                          )
                          .toList(),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}

class _PuestosTab extends StatelessWidget {
  const _PuestosTab();

  @override
  Widget build(BuildContext context) {
    final store = TalentoHumanoStore.instance;
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final lista = store.puestos;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Puestos (${lista.length})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                FilledButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Nuevo'),
                  onPressed: () async {
                    final n =
                        await _pedirNombre(context, titulo: 'Nuevo puesto');
                    if (n != null) await store.crearPuesto(n);
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (lista.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Aún no hay puestos en el catálogo. Mientras tanto, el '
                    'puesto de cada colaborador se captura como texto libre.',
                  ),
                ),
              ),
            ...lista.map((p) {
              final n = store.empleadosDePuesto(p.id).length;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.badge_outlined),
                  title: Text(p.nombre),
                  subtitle: Text('$n colaborador(es)'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (accion) async {
                      if (accion == 'renombrar') {
                        final nuevo = await _pedirNombre(
                          context,
                          titulo: 'Renombrar puesto',
                          inicial: p.nombre,
                        );
                        if (nuevo != null) {
                          await store.guardarPuesto(
                            Puesto(id: p.id, nombre: nuevo),
                          );
                        }
                      } else if (accion == 'eliminar') {
                        if (!await _confirmar(
                          context,
                          '¿Eliminar el puesto "${p.nombre}"?',
                        )) {
                          return;
                        }
                        final err = await store.eliminarPuesto(p.id);
                        if (err != null && context.mounted) {
                          _aviso(context, err);
                        }
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'renombrar',
                        child: Text('Renombrar'),
                      ),
                      PopupMenuItem(
                        value: 'eliminar',
                        child: Text('Eliminar'),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}

class _CalendarioTab extends StatefulWidget {
  const _CalendarioTab();

  @override
  State<_CalendarioTab> createState() => _CalendarioTabState();
}

class _CalendarioTabState extends State<_CalendarioTab> {
  int _anio = DateTime.now().year;

  static const _diasSemana = [
    'lunes',
    'martes',
    'miércoles',
    'jueves',
    'viernes',
    'sábado',
    'domingo',
  ];

  Future<void> _nuevoDia() async {
    final store = TalentoHumanoStore.instance;
    final fecha = await showDatePicker(
      context: context,
      initialDate: DateTime(_anio, DateTime.now().month, DateTime.now().day),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (fecha == null || !mounted) return;

    final res = await showDialog<_DatosDia>(
      context: context,
      builder: (_) => _DialogoDia(fecha: fecha),
    );
    if (res != null) {
      await store.agregarDiaFestivo(
        fecha,
        res.descripcion.isEmpty ? 'Día inhábil' : res.descripcion,
        esFestivo: res.esFestivo,
      );
      if (mounted) setState(() => _anio = fecha.year);
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = TalentoHumanoStore.instance;
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final dias =
            store.diasCalendario.where((d) => d.fecha.year == _anio).toList();
        final festivos = dias.where((d) => d.esFestivo).length;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => setState(() => _anio--),
                  icon: const Icon(Icons.chevron_left),
                ),
                Text(
                  'Calendario $_anio',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() => _anio++),
                  icon: const Icon(Icons.chevron_right),
                ),
                const Spacer(),
                FilledButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Día'),
                  onPressed: _nuevoDia,
                ),
              ],
            ),
            Text('$festivos día(s) festivo(s) registrados'),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.flag_outlined),
              label: Text('Cargar días de descanso oficiales $_anio (LFT)'),
              onPressed: () async {
                final n = await store.cargarFestivosOficiales(_anio);
                if (!context.mounted) return;
                _aviso(
                  context,
                  n == 0
                      ? 'Los días oficiales ya estaban registrados.'
                      : 'Se agregaron $n día(s) oficiales.',
                );
              },
            ),
            const SizedBox(height: 12),
            if (dias.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No hay días registrados para este año.'),
                ),
              ),
            ...dias.map(
              (d) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(
                    d.esFestivo ? Icons.celebration : Icons.event_note,
                    color: d.esFestivo ? Colors.orange.shade700 : null,
                  ),
                  title: Text(d.descripcion),
                  subtitle: Text(
                    '${_diasSemana[d.fecha.weekday - 1]} '
                    '${TalentoHumanoStore.fmtFecha(d.fecha)}'
                    '${d.esFestivo ? ' • festivo' : ''}',
                  ),
                  trailing: IconButton(
                    tooltip: 'Eliminar',
                    icon: Icon(
                      Icons.delete_outline,
                      color: Colors.red.shade700,
                    ),
                    onPressed: () => store.eliminarDiaCalendario(d.id),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DatosDia {
  final String descripcion;
  final bool esFestivo;
  const _DatosDia(this.descripcion, this.esFestivo);
}

class _DialogoDia extends StatefulWidget {
  final DateTime fecha;
  const _DialogoDia({required this.fecha});

  @override
  State<_DialogoDia> createState() => _DialogoDiaState();
}

class _DialogoDiaState extends State<_DialogoDia> {
  final _descCtrl = TextEditingController();
  bool _esFestivo = true;

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Día ${TalentoHumanoStore.fmtFecha(widget.fecha)}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _descCtrl,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Descripción',
              border: OutlineInputBorder(),
            ),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Es festivo / inhábil'),
            value: _esFestivo,
            onChanged: (v) => setState(() => _esFestivo = v),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(
            context,
            _DatosDia(_descCtrl.text.trim(), _esFestivo),
          ),
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
