import test from 'node:test';
import assert from 'node:assert/strict';
import { calcularAntiguedad, resumenVacaciones } from '../empleados.js';
import { crearSolicitud, aplicarRespuestaSolicitud } from '../permisos.js';
import { crearIncidencia } from '../incidencias.js';

test('Calcula antigüedad y vacaciones restantes correctamente', () => {
  const emp = {
    fechaIngreso: '2024-05-10',
    vecesVacacionesAnio: 2,
    diasPorPeriodoVacaciones: 6,
    diasVacacionesUsados: 4,
    vigenciaVacaciones: '2026-12-31',
  };

  const ant = calcularAntiguedad('2024-05-10', new Date('2026-11-25'));
  assert.equal(ant.anios, 2);
  assert.equal(ant.meses, 6);

  const vac = resumenVacaciones(emp);
  assert.equal(vac.totales, 12);
  assert.equal(vac.restantes, 8);
});

test('Autoriza permiso anual y guarda rango de fechas', () => {
  const emp = {
    id: 'emp-1',
    nombre: 'Ana',
    permisosAnualesDerecho: 3,
    permisosUsados: 1,
  };
  const sol = crearSolicitud({
    empleado: emp,
    tipo: 'Permiso',
    motivo: 'Trámite',
    diasSolicitados: 1,
  });

  const res = aplicarRespuestaSolicitud(sol, emp, {
    autorizar: true,
    fechaInicio: '2026-12-01',
    fechaFin: '2026-12-02',
  });

  assert.equal(res.ok, true);
  assert.equal(res.solicitud.estatus, 'AUTORIZADO');
  assert.equal(res.solicitud.fechaAutorizadaInicio, '2026-12-01');
  assert.equal(res.solicitud.fechaAutorizadaFin, '2026-12-02');
  assert.equal(res.empleado.permisosUsados, 2);
});

test('Crea reconocimiento o sanción', () => {
  const inc = crearIncidencia({
    nombreEmpleado: 'Luis',
    tipo: 'Reconocimiento',
    titulo: 'Puntualidad',
    descripcion: 'Todo el mes sin retardos',
  });
  assert.equal(inc.tipo, 'Reconocimiento');
  assert.equal(inc.nombreEmpleado, 'Luis');
});