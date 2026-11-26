const ESTADO_INICIAL = {
  usuarios: [
    {
      id: 'adm_1',
      empleadoId: null,
      nombre: 'Dirección / Admin',
      correo: 'admin@talento.local',
      password: 'admin',
      rol: 'admin',
    },
    {
      id: 'emp_1',
      empleadoId: 'emp_1',
      nombre: 'Ana García',
      correo: 'ana@talento.local',
      password: '123',
      rol: 'empleado',
    },
  ],
  empleados: [
    {
      id: 'emp_1',
      nombre: 'Ana García',
      puesto: 'Operativo',
      fechaIngreso: '2024-06-15T00:00:00.000Z',
      vecesVacacionesAnio: 2,
      diasPorPeriodoVacaciones: 6,
      diasVacacionesUsados: 2,
      vigenciaVacaciones: '2026-12-31T00:00:00.000Z',
      permisosAnualesDerecho: 4,
      permisosUsados: 1,
      activo: true,
      fechaBaja: null,
      motivoBaja: null,
    },
    ...Array.from({ length: 8 }, (_, i) => {
      const num = i + 2;
      return {
        id: `emp_${num}`,
        nombre: `Colaborador ${num}`,
        puesto: num % 2 === 0 ? 'Operativo' : 'Administrativo',
        fechaIngreso: `2025-${String((num % 11) + 1).padStart(2, '0')}-10T00:00:00.000Z`,
        vecesVacacionesAnio: 2,
        diasPorPeriodoVacaciones: 6,
        diasVacacionesUsados: 0,
        vigenciaVacaciones: '2026-12-31T00:00:00.000Z',
        permisosAnualesDerecho: 3,
        permisosUsados: 0,
        activo: true,
        fechaBaja: null,
        motivoBaja: null,
      };
    }),
  ],
  solicitudes: [
    {
      id: 'sol_1',
      idEmpleado: 'emp_1',
      nombreEmpleado: 'Ana García',
      tipo: 'Permiso',
      motivo: 'Cita médica por la mañana',
      diasSolicitados: 1,
      estatus: 'PENDIENTE',
      fechaAutorizadaInicio: null,
      fechaAutorizadaFin: null,
    },
  ],
  incidencias: [
    {
      id: 'inc_1',
      nombreEmpleado: 'Ana García',
      tipo: 'Reconocimiento',
      titulo: 'Puntualidad y asistencia perfecta',
      descripcion: 'Cumplimiento del 100% en el trimestre.',
      fecha: '2026-10-15T00:00:00.000Z',
    },
  ],
};

let estadoActual = structuredClone(ESTADO_INICIAL);

function normalizarClaveUsuario(valor) {
  return String(valor || '')
    .trim()
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '');
}

export async function obtenerEstado() {
  return {
    empleados: estadoActual.empleados,
    solicitudes: estadoActual.solicitudes,
    incidencias: estadoActual.incidencias,
  };
}

export async function autenticarUsuario({ correo, password }) {
  const clave = normalizarClaveUsuario(correo);
  let usuario = estadoActual.usuarios.find(
    (u) => normalizarClaveUsuario(u.correo) === clave
  );

  if (!usuario) {
    const prefijo = clave.split('@')[0];
    usuario = estadoActual.usuarios.find(
      (u) => normalizarClaveUsuario(u.correo).split('@')[0] === prefijo
    );
  }

  if (!usuario) {
    throw new Error('Usuario o correo no encontrado');
  }
  if (password && usuario.password !== password) {
    throw new Error('Contraseña incorrecta');
  }
  const { password: _pwd, ...sinPassword } = usuario;
  return sinPassword;
}

export async function crearEmpleado({
  nombre,
  puesto,
  fechaIngreso,
  correo,
  password,
  vecesVacacionesAnio,
  diasPorPeriodoVacaciones,
  vigenciaVacaciones,
  permisosAnualesDerecho,
}) {
  const nombreLimpio = String(nombre || '').trim();
  if (!nombreLimpio) {
    throw new Error('El nombre del empleado es obligatorio');
  }

  const nuevoId = `emp_${Date.now()}`;
  const nuevoEmpleado = {
    id: nuevoId,
    nombre: nombreLimpio,
    puesto: String(puesto || 'Operativo').trim() || 'Operativo',
    fechaIngreso: fechaIngreso || new Date().toISOString(),
    vecesVacacionesAnio: Number(vecesVacacionesAnio ?? 2),
    diasPorPeriodoVacaciones: Number(diasPorPeriodoVacaciones ?? 6),
    diasVacacionesUsados: 0,
    vigenciaVacaciones: vigenciaVacaciones || '2026-12-31T00:00:00.000Z',
    permisosAnualesDerecho: Number(permisosAnualesDerecho ?? 3),
    permisosUsados: 0,
    activo: true,
    fechaBaja: null,
    motivoBaja: null,
  };

  estadoActual.empleados.push(nuevoEmpleado);

  if (correo && String(correo).trim()) {
    const correoLimpio = String(correo).trim().toLowerCase();
    const claveNueva = normalizarClaveUsuario(correoLimpio);
    const existente = estadoActual.usuarios.find(
      (u) => normalizarClaveUsuario(u.correo) === claveNueva
    );
    if (existente) {
      existente.empleadoId = nuevoId;
      existente.nombre = nuevoEmpleado.nombre;
      if (password) existente.password = String(password);
    } else {
      estadoActual.usuarios.push({
        id: `usr_${Date.now()}`,
        empleadoId: nuevoId,
        nombre: nuevoEmpleado.nombre,
        correo: correoLimpio,
        password: String(password || '123'),
        rol: 'empleado',
      });
    }
  }

  return nuevoEmpleado;
}

export async function editarEmpleado(empleadoId, datos = {}) {
  const emp = estadoActual.empleados.find((e) => e.id === empleadoId);
  if (!emp) throw new Error('Empleado no encontrado');

  if (datos.nombre !== undefined) {
    const limpio = String(datos.nombre).trim();
    if (!limpio) throw new Error('El nombre no puede estar vacío');
    emp.nombre = limpio;
  }
  if (datos.puesto !== undefined) {
    emp.puesto = String(datos.puesto).trim() || emp.puesto;
  }
  if (datos.fechaIngreso !== undefined && datos.fechaIngreso) {
    emp.fechaIngreso = datos.fechaIngreso;
  }
  if (datos.vecesVacacionesAnio !== undefined) {
    emp.vecesVacacionesAnio = Number(datos.vecesVacacionesAnio);
  }
  if (datos.diasPorPeriodoVacaciones !== undefined) {
    emp.diasPorPeriodoVacaciones = Number(datos.diasPorPeriodoVacaciones);
  }
  if (datos.vigenciaVacaciones !== undefined && datos.vigenciaVacaciones) {
    emp.vigenciaVacaciones = datos.vigenciaVacaciones;
  }
  if (datos.permisosAnualesDerecho !== undefined) {
    emp.permisosAnualesDerecho = Number(datos.permisosAnualesDerecho);
  }
  if (datos.activo !== undefined) {
    emp.activo = Boolean(datos.activo);
    if (emp.activo) {
      emp.fechaBaja = null;
      emp.motivoBaja = null;
    }
  }

  return emp;
}

export async function darDeBajaEmpleado(empleadoId, { motivoBaja } = {}) {
  const emp = estadoActual.empleados.find((e) => e.id === empleadoId);
  if (!emp) throw new Error('Empleado no encontrado');

  emp.activo = false;
  emp.fechaBaja = new Date().toISOString();
  emp.motivoBaja = motivoBaja ? String(motivoBaja).trim() : 'Baja registrada';

  return emp;
}

export async function actualizarVacacionesEmpleado({
  empleadoId,
  vecesAlAnio,
  diasPorPeriodo,
  vigencia,
}) {
  const emp = estadoActual.empleados.find((e) => e.id === empleadoId);
  if (!emp) throw new Error('Empleado no encontrado');

  emp.vecesVacacionesAnio = Number(vecesAlAnio);
  emp.diasPorPeriodoVacaciones = Number(diasPorPeriodo);
  if (vigencia) emp.vigenciaVacaciones = vigencia;

  return emp;
}

export async function crearSolicitud({
  idEmpleado,
  tipo,
  motivo,
  diasSolicitados,
}) {
  const emp = estadoActual.empleados.find((e) => e.id === idEmpleado);
  if (!emp) throw new Error('Empleado no encontrado');
  if (emp.activo === false) {
    throw new Error('No se pueden crear solicitudes para un empleado dado de baja');
  }

  const nueva = {
    id: `sol_${Date.now()}`,
    idEmpleado: emp.id,
    nombreEmpleado: emp.nombre,
    tipo: tipo || 'Permiso',
    motivo: motivo || '',
    diasSolicitados: Number(diasSolicitados) || 1,
    estatus: 'PENDIENTE',
    fechaAutorizadaInicio: null,
    fechaAutorizadaFin: null,
  };

  estadoActual.solicitudes.unshift(nueva);
  return nueva;
}

export async function responderSolicitud({
  solicitudId,
  autorizar,
  fechaInicio,
  fechaFin,
}) {
  const sol = estadoActual.solicitudes.find((s) => s.id === solicitudId);
  if (!sol) throw new Error('Solicitud no encontrada');

  sol.estatus = autorizar ? 'AUTORIZADO' : 'RECHAZADO';
  if (autorizar) {
    sol.fechaAutorizadaInicio = fechaInicio || null;
    sol.fechaAutorizadaFin = fechaFin || null;

    const emp = estadoActual.empleados.find((e) => e.id === sol.idEmpleado);
    if (emp) {
      if (sol.tipo === 'Vacaciones') {
        emp.diasVacacionesUsados =
          Number(emp.diasVacacionesUsados || 0) + Number(sol.diasSolicitados || 1);
      } else {
        emp.permisosUsados = Number(emp.permisosUsados || 0) + 1;
      }
    }
  }

  return { solicitud: sol };
}

export async function crearIncidencia({
  nombreEmpleado,
  tipo,
  titulo,
  descripcion,
}) {
  const nueva = {
    id: `inc_${Date.now()}`,
    nombreEmpleado: nombreEmpleado || 'Empleado',
    tipo: tipo || 'Reconocimiento',
    titulo: titulo || '',
    descripcion: descripcion || '',
    fecha: new Date().toISOString(),
  };

  estadoActual.incidencias.unshift(nueva);
  return nueva;
}