export function crearSolicitud({ empleado, tipo, motivo, diasSolicitados }) {
  return {
    id: `sol-${Date.now()}-${Math.floor(Math.random() * 1000)}`,
    idEmpleado: empleado.id,
    nombreEmpleado: empleado.nombre,
    tipo,
    motivo: motivo || '',
    diasSolicitados: Number(diasSolicitados || 1),
    estatus: 'PENDIENTE',
    fechaAutorizadaInicio: null,
    fechaAutorizadaFin: null,
    fechaCreacion: new Date().toISOString(),
  };
}

export function aplicarRespuestaSolicitud(solicitud, empleado, { autorizar, fechaInicio, fechaFin }) {
  if (!autorizar) {
    return {
      ok: true,
      solicitud: {
        ...solicitud,
        estatus: 'RECHAZADO',
        fechaAutorizadaInicio: null,
        fechaAutorizadaFin: null,
      },
      empleado,
    };
  }

  if (solicitud.tipo === 'Vacaciones') {
    const restantes =
      Number(empleado.vecesVacacionesAnio || 0) *
        Number(empleado.diasPorPeriodoVacaciones || 0) -
      Number(empleado.diasVacacionesUsados || 0);

    if (solicitud.diasSolicitados > restantes) {
      return { ok: false, error: 'Días de vacaciones insuficientes' };
    }

    return {
      ok: true,
      solicitud: {
        ...solicitud,
        estatus: 'AUTORIZADO',
        fechaAutorizadaInicio: fechaInicio || null,
        fechaAutorizadaFin: fechaFin || null,
      },
      empleado: {
        ...empleado,
        diasVacacionesUsados:
          Number(empleado.diasVacacionesUsados || 0) + Number(solicitud.diasSolicitados || 0),
      },
    };
  }

  const permisosRestantes =
    Number(empleado.permisosAnualesDerecho || 0) - Number(empleado.permisosUsados || 0);

  if (permisosRestantes <= 0) {
    return { ok: false, error: 'Sin permisos anuales disponibles' };
  }

  return {
    ok: true,
    solicitud: {
      ...solicitud,
      estatus: 'AUTORIZADO',
      fechaAutorizadaInicio: fechaInicio || null,
      fechaAutorizadaFin: fechaFin || null,
    },
    empleado: {
      ...empleado,
      permisosUsados: Number(empleado.permisosUsados || 0) + 1,
    },
  };
}