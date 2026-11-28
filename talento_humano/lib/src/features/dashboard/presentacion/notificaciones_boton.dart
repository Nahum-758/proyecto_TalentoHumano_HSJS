import 'package:flutter/material.dart';
import 'package:talento_humano/src/core/talento_humano_store.dart';

/// Campana con contador de notificaciones no leídas.
/// [idEmpleado] = null muestra las notificaciones dirigidas a RH.
class NotificacionesBoton extends StatelessWidget {
  final String? idEmpleado;

  const NotificacionesBoton({super.key, required this.idEmpleado});

  @override
  Widget build(BuildContext context) {
    final store = TalentoHumanoStore.instance;
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final noLeidas = store.noLeidasDe(idEmpleado);
        return IconButton(
          tooltip: 'Notificaciones',
          onPressed: () => _abrir(context),
          icon: Badge(
            isLabelVisible: noLeidas > 0,
            label: Text(noLeidas > 99 ? '99+' : '$noLeidas'),
            child: Icon(
              noLeidas > 0
                  ? Icons.notifications_active
                  : Icons.notifications_none,
            ),
          ),
        );
      },
    );
  }

  void _abrir(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => FractionallySizedBox(
        heightFactor: 0.75,
        child: _ListaNotificaciones(idEmpleado: idEmpleado),
      ),
    );
  }
}

class _ListaNotificaciones extends StatelessWidget {
  final String? idEmpleado;

  const _ListaNotificaciones({required this.idEmpleado});

  String _fmt(DateTime d) {
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '${TalentoHumanoStore.fmtFecha(d)} $h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final store = TalentoHumanoStore.instance;
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final lista = store.notificacionesDe(idEmpleado);
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 8, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Notificaciones',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: lista.any((n) => !n.leida)
                        ? () => store.marcarTodasLeidas(idEmpleado)
                        : null,
                    icon: const Icon(Icons.done_all),
                    label: const Text('Marcar todas'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: lista.isEmpty
                  ? const Center(child: Text('No tienes notificaciones.'))
                  : ListView.separated(
                      itemCount: lista.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final n = lista[i];
                        return ListTile(
                          leading: Icon(
                            n.leida
                                ? Icons.mark_email_read_outlined
                                : Icons.mark_email_unread,
                            color: n.leida ? Colors.grey : null,
                          ),
                          title: Text(
                            n.mensaje,
                            style: TextStyle(
                              fontWeight: n.leida
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(_fmt(n.fechaEnvio)),
                          onTap: () => store.marcarNotificacionLeida(n.id),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
