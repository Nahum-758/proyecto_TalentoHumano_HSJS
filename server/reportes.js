// Reporte: generado por un AdministradorRH.
import { calcularAntiguedad, resumenVacaciones } from './empleados.js';

export const TIPOS_REPORTE = [
  'PLANTILLA',
  'BAJAS',
  'SOLICITUDES',
  'VACACIONES',
  'INCIDENCIAS',
];

function enRango(fechaISO, desde, hasta) {
  if (!fechaISO) return true;
  const f = new Date(fechaISO).getTime();
  if (desde && f < new Date(desde).getTime()) return false;
  if (hasta && f > new Date(hasta).getTime() + 86_399_999) return false;
  return true;
}

/** Arma los datos de un reporte a partir del estado actual. */
export function construirReporte(estado, { tipoReporte, desde, hasta, idDepartamento } = {}, hoy = new Date()) {
  const tipo = String(tipoReporte || '').toUpperCase();
  if (!TIPOS_REPORTE.includes(tipo)) {
    throw new Error(`Tipo de reporte inválido. Usa: ${TIPOS_REPORTE.join(', ')}`);
  }
  const delDepto = (e) => !idDepartamento || e.idDepartamento === idDepartamento;
  const empPorId = new Map(estado.empleados.map((e) => [e.id, e]));
  let filas;

  switch (tipo) {
    case 'PLANTILLA':
      filas = estado.empleados
        .filter((e) => e.activo !== false && delDepto(e))
        .map((e) => ({
          numeroEmpleado: e.numeroEmpleado,
          nombre: e.nombre,
          puesto: e.puesto,
          idDepartamento: e.idDepartamento ?? null,
          estadoLaboral: e.estadoLaboral,
          antiguedad: calcularAntiguedad(e.fechaIngreso, hoy).texto,
        }));
      break;
    case 'BAJAS':
      filas = estado.empleados
        .filter((e) => e.activo === false && delDepto(e) && enRango(e.fechaBaja, desde, hasta))
        .map((e) => ({
          numeroEmpleado: e.numeroEmpleado,
          nombre: e.nombre,
          fechaBaja: e.fechaBaja,
          motivoBaja: e.motivoBaja,
        }));
      break;
    case 'SOLICITUDES':
      filas = estado.solicitudes.filter((s) => {
        const emp = empPorId.get(s.idEmpleado);
        if (idDepartamento && (!emp || emp.idDepartamento !== idDepartamento)) return false;
        return enRango(s.fechaCreacion || s.fechaAutorizadaInicio, desde, hasta);
      });
      break;
    case 'VACACIONES':
      filas = estado.empleados
        .filter((e) => e.activo !== false && delDepto(e))
        .map((e) => ({ nombre: e.nombre, ...resumenVacaciones(e) }));
      break;
    case 'INCIDENCIAS':
      filas = estado.incidencias.filter((i) => {
        if (idDepartamento) {
          const emp = estado.empleados.find((e) => e.nombre === i.nombreEmpleado);
          if (!emp || emp.idDepartamento !== idDepartamento) return false;
        }
        return enRango(i.fecha, desde, hasta);
      });
      break;
    default:
      filas = [];
  }

  return {
    tipoReporte: tipo,
    descripcion: `${tipo}: ${filas.length} registro(s)`,
    parametros: JSON.stringify({ desde: desde ?? null, hasta: hasta ?? null, idDepartamento: idDepartamento ?? null }),
    datos: filas,
  };
}
