import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:talento_humano/src/core/talento_humano_store.dart';

/// Apartado de generación y consulta de reportes de RH.
class AdminReportesView extends StatefulWidget {
  const AdminReportesView({super.key});

  @override
  State<AdminReportesView> createState() => _AdminReportesViewState();
}

class _AdminReportesViewState extends State<AdminReportesView> {
  String _tipo = TiposReporte.plantilla;
  String? _departamentoId;
  DateTime? _desde;
  DateTime? _hasta;

  bool get _usaFechas =>
      _tipo == TiposReporte.bajas ||
      _tipo == TiposReporte.solicitudes ||
      _tipo == TiposReporte.incidencias;

  Future<void> _elegirFecha(bool esDesde) async {
    final f = await showDatePicker(
      context: context,
      initialDate: (esDesde ? _desde : _hasta) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (f == null) return;
    setState(() {
      if (esDesde) {
        _desde = f;
      } else {
        _hasta = f;
      }
    });
  }

  Future<void> _generar() async {
    final store = TalentoHumanoStore.instance;
    final rep = await store.generarReporte(
      _tipo,
      desde: _usaFechas ? _desde : null,
      hasta: _usaFechas ? _hasta : null,
      departamentoId: _departamentoId,
    );
    if (mounted) _verReporte(rep);
  }

  String _describirParametros(Reporte r) {
    try {
      final m = jsonDecode(r.parametros) as Map<String, dynamic>;
      final partes = <String>[];
      if (m['departamento_id'] != null) {
        partes.add(TalentoHumanoStore.instance
            .nombreDepartamento(m['departamento_id'].toString()));
      }
      final d = DateTime.tryParse('${m['desde']}');
      final h = DateTime.tryParse('${m['hasta']}');
      if (d != null) partes.add('desde ${TalentoHumanoStore.fmtFecha(d)}');
      if (h != null) partes.add('hasta ${TalentoHumanoStore.fmtFecha(h)}');
      return partes.isEmpty ? 'Sin filtros' : partes.join(' • ');
    } catch (_) {
      return r.parametros.isEmpty ? 'Sin filtros' : r.parametros;
    }
  }

  void _verReporte(Reporte r) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(r.tipoReporte),
        content: SizedBox(
          width: 520,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Generado: ${TalentoHumanoStore.fmtFecha(r.fechaGeneracion)} • '
                  '${_describirParametros(r)}',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 10),
                SelectableText(r.descripcion),
              ],
            ),
          ),
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.copy),
            label: const Text('Copiar'),
            onPressed: () async {
              await Clipboard.setData(
                ClipboardData(text: '${r.tipoReporte}\n\n${r.descripcion}'),
              );
              if (ctx.mounted) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Reporte copiado.')),
                );
              }
            },
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = TalentoHumanoStore.instance;
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final reportes = store.reportes;
        final deptos = store.departamentos;
        if (_departamentoId != null &&
            !deptos.any((d) => d.id == _departamentoId)) {
          _departamentoId = null;
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Generar reporte',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: _tipo,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de reporte',
                        border: OutlineInputBorder(),
                      ),
                      items: TiposReporte.todos
                          .map(
                            (t) => DropdownMenuItem(value: t, child: Text(t)),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _tipo = v);
                      },
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String?>(
                      key: ValueKey('dep_${deptos.length}'),
                      initialValue: _departamentoId,
                      decoration: const InputDecoration(
                        labelText: 'Departamento',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('Todos'),
                        ),
                        ...deptos.map(
                          (d) => DropdownMenuItem<String?>(
                            value: d.id,
                            child: Text(d.nombre),
                          ),
                        ),
                      ],
                      onChanged: (v) => setState(() => _departamentoId = v),
                    ),
                    if (_usaFechas) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _elegirFecha(true),
                              child: Text(
                                _desde == null
                                    ? 'Desde: —'
                                    : 'Desde: ${TalentoHumanoStore.fmtFecha(_desde!)}',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _elegirFecha(false),
                              child: Text(
                                _hasta == null
                                    ? 'Hasta: —'
                                    : 'Hasta: ${TalentoHumanoStore.fmtFecha(_hasta!)}',
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Quitar fechas',
                            onPressed: () => setState(() {
                              _desde = null;
                              _hasta = null;
                            }),
                            icon: const Icon(Icons.clear),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      icon: const Icon(Icons.summarize),
                      label: const Text('Generar'),
                      onPressed: _generar,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Reportes generados (${reportes.length})',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (reportes.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Aún no se ha generado ningún reporte.'),
                ),
              ),
            ...reportes.map(
              (r) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: Text(r.tipoReporte),
                  subtitle: Text(
                    '${TalentoHumanoStore.fmtFecha(r.fechaGeneracion)} • '
                    '${_describirParametros(r)}',
                  ),
                  onTap: () => _verReporte(r),
                  trailing: IconButton(
                    tooltip: 'Eliminar',
                    icon: Icon(
                      Icons.delete_outline,
                      color: Colors.red.shade700,
                    ),
                    onPressed: () => store.eliminarReporte(r.id),
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
