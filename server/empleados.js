export function calcularAntiguedad(fechaIngresoISO, hoy = new Date()) {
  const ingreso = new Date(fechaIngresoISO);
  let anios = hoy.getFullYear() - ingreso.getFullYear();
  let meses = hoy.getMonth() - ingreso.getMonth();

  if (hoy.getDate() < ingreso.getDate()) {
    meses -= 1;
  }
  if (meses < 0) {
    anios -= 1;
    meses += 12;
  }

  return {
    anios: Math.max(0, anios),
    meses: Math.max(0, meses),
    texto: `${Math.max(0, anios)} año(s), ${Math.max(0, meses)} mes(es)`,
  };
}

export function resumenVacaciones(empleado) {
  const vecesAlAnio = Number(empleado.vecesVacacionesAnio || 0);
  const diasPorPeriodo = Number(empleado.diasPorPeriodoVacaciones || 0);
  const usados = Number(empleado.diasVacacionesUsados || 0);
  const totales = vecesAlAnio * diasPorPeriodo;
  const restantes = Math.max(0, totales - usados);

  return {
    vecesAlAnio,
    diasPorPeriodo,
    totales,
    usados,
    restantes,
    vigencia: empleado.vigenciaVacaciones || null,
  };
}

export function enriquecerEmpleado(empleado, hoy = new Date()) {
  const { password, ...sinPassword } = empleado;
  const derechoPermisos = Number(empleado.permisosAnualesDerecho || 0);
  const permisosUsados = Number(empleado.permisosUsados || 0);

  return {
    ...sinPassword,
    antiguedad: calcularAntiguedad(empleado.fechaIngreso, hoy),
    vacaciones: resumenVacaciones(empleado),
    permisos: {
      derecho: derechoPermisos,
      usados: permisosUsados,
      restantes: Math.max(0, derechoPermisos - permisosUsados),
    },
  };
}