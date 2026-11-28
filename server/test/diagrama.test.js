import test, { beforeEach } from 'node:test';
import assert from 'node:assert/strict';
import { diasHabilesEntre, festivosOficiales } from '../calendario.js';
import { construirReporte } from '../reportes.js';
import * as almacen from '../almacen.js';

beforeEach(() => almacen.reiniciarEstado());

test('CalendarioLaboral: días hábiles excluyen fines de semana y festivos', () => {
  const dias = [{ fecha: '2026-12-25', esFestivo: true, descripcion: 'Navidad' }];
  // 21 al 27 dic 2026: lun-vie = 5, menos Navidad (viernes) = 4
  assert.equal(diasHabilesEntre(dias, '2026-12-21', '2026-12-27'), 4);
});

test('CalendarioLaboral: festivos oficiales con lunes móviles', () => {
  const f = festivosOficiales(2026).map((d) => d.fecha);
  assert.ok(f.includes('2026-02-02'));
  assert.ok(f.includes('2026-03-16'));
  assert.ok(f.includes('2026-11-16'));
  assert.equal(f.length, 7);
});

test('Empleado: alta con número consecutivo, departamento y puesto', async () => {
  const emp = await almacen.crearEmpleado({
    nombre: 'Luis Pérez',
    idDepartamento: 'dep_2',
    idPuesto: 'pue_2',
  });
  assert.equal(emp.numeroEmpleado, 'E0010');
  assert.equal(emp.puesto, 'Administrativo');
  assert.equal(emp.estadoLaboral, 'ACTIVO');
  await assert.rejects(
    almacen.crearEmpleado({ nombre: 'X', idDepartamento: 'nope' }),
    /Departamento no encontrado/
  );
});

test('Baja cambia estadoLaboral y no permite eliminar depto con empleados', async () => {
  const emp = await almacen.darDeBajaEmpleado('emp_1', { motivoBaja: 'Renuncia' });
  assert.equal(emp.estadoLaboral, 'BAJA');
  await assert.rejects(almacen.eliminarDepartamento('dep_1'), /No se puede eliminar/);
});

test('Responder solicitud valida saldo y notifica al empleado', async () => {
  const sol = await almacen.crearSolicitud({
    idEmpleado: 'emp_1',
    tipo: 'Vacaciones',
    diasSolicitados: 50,
  });
  await assert.rejects(
    almacen.responderSolicitud({ solicitudId: sol.id, autorizar: true }),
    /insuficientes/
  );
  const rh = await almacen.listarNotificaciones();
  assert.ok(rh.some((n) => n.mensaje.includes('Ana García')));

  const ok = await almacen.crearSolicitud({ idEmpleado: 'emp_1', tipo: 'Vacaciones', diasSolicitados: 2 });
  const res = await almacen.responderSolicitud({
    solicitudId: ok.id,
    autorizar: true,
    fechaInicio: '2026-12-01',
    fechaFin: '2026-12-02',
  });
  assert.equal(res.solicitud.estatus, 'AUTORIZADO');
  const notifs = await almacen.listarNotificaciones({ idEmpleado: 'emp_1' });
  assert.equal(notifs.length, 1);
  assert.match(notifs[0].mensaje, /AUTORIZADO/);
  const leida = await almacen.marcarNotificacionLeida(notifs[0].idNotificacion);
  assert.equal(leida.leida, true);
});

test('Reporte: plantilla filtrada por departamento', async () => {
  const rep = await almacen.generarReporte({ tipoReporte: 'plantilla', idDepartamento: 'dep_2' });
  assert.equal(rep.tipoReporte, 'PLANTILLA');
  assert.ok(rep.datos.length > 0);
  assert.ok(rep.datos.every((e) => e.idDepartamento === 'dep_2'));
  assert.throws(() => construirReporte({ empleados: [], solicitudes: [], incidencias: [] }, { tipoReporte: 'X' }));
  const lista = await almacen.listarReportes();
  assert.equal(lista.length, 1);
  assert.equal(lista[0].datos, undefined);
});
