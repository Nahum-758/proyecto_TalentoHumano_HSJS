import { aplicarRespuestaSolicitud } from './permisos.js';
import { crearDiaCalendario, festivosOficiales, esFestivo, diasHabilesEntre } from './calendario.js';
import { construirReporte } from './reportes.js';
import { crearNotificacion } from './notificaciones.js';

export const ESTADOS_LABORALES = ['ACTIVO', 'VACACIONES', 'INCAPACIDAD', 'SUSPENDIDO', 'BAJA'];

const ESTADO_INICIAL = {
  departamentos: [
    { idDepartamento: 'dep_1', nombre: 'Enfermería' },
    { idDepartamento: 'dep_2', nombre: 'Administración' },
  ],
  puestos: [
    { idPuesto: 'pue_1', nombre: 'Operativo' },
    { idPuesto: 'pue_2', nombre: 'Administrativo' },
  ],
  administradores: [{ idAdmin: 'adm_1', area: 'Recursos Humanos' }],
  notificaciones: [],
  calendario: [],
  reportes: [],
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
      numeroEmpleado: 'E0001',
      nombre: 'Ana García',
      puesto: 'Operativo',
      idPuesto: 'pue_1',
      idDepartamento: 'dep_1',
      estadoLaboral: 'ACTIVO',
      fechaNacimiento: '1990-03-21T00:00:00.000Z',
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
        numeroEmpleado: `E${String(num).padStart(4, '0')}`,
        nombre: `Colaborador ${num}`,
        puesto: num % 2 === 0 ? 'Operativo' : 'Administrativo',
        idPuesto: num % 2 === 0 ? 'pue_1' : 'pue_2',
        idDepartamento: num % 2 === 0 ? 'dep_1' : 'dep_2',
        estadoLaboral: 'ACTIVO',
        fechaNacimiento: null,
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
      fechaCreacion: '2026-11-20T00:00:00.000Z',
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

/** Solo para pruebas: reinicia el estado en memoria. */
export function reiniciarEstado() {
  estadoActual = structuredClone(ESTADO_INICIAL);
}

function buscarEmpleado(id) {
  const emp = estadoActual.empleados.find((e) => e.id === id);
  if (!emp) throw new Error('Empleado no encontrado');
  return emp;
}

function siguienteNumeroEmpleado() {
  const max = estadoActual.empleados.reduce((m, e) => {
    const n = Number(String(e.numeroEmpleado || '').replace(/\D/g, '')) || 0;
    return n > m ? n : m;
  }, 0);
  return `E${String(max + 1).padStart(4, '0')}`;
}

function validarDepartamento(idDepartamento) {
  if (idDepartamento == null || idDepartamento === '') return null;
  if (!estadoActual.departamentos.some((d) => d.idDepartamento === idDepartamento)) {
    throw new Error('Departamento no encontrado');
  }
  return idDepartamento;
}

function resolverPuesto(idPuesto, puestoTexto) {
  if (idPuesto) {
    const p = estadoActual.puestos.find((x) => x.idPuesto === idPuesto);
    if (!p) throw new Error('Puesto no encontrado');
    return { idPuesto, puesto: p.nombre };
  }
  return { idPuesto: null, puesto: String(puestoTexto || 'Operativo').trim() || 'Operativo' };
}

function notificar(idEmpleado, mensaje) {
  const n = crearNotificacion({ idEmpleado, mensaje });
  estadoActual.notificaciones.unshift(n);
  return n;
}

export async function obtenerEstado() {
  return {
    empleados: estadoActual.empleados,
    solicitudes: estadoActual.solicitudes,
    incidencias: estadoActual.incidencias,
    departamentos: estadoActual.departamentos,
    puestos: estadoActual.puestos,
    calendario: estadoActual.calendario,
    reportes: estadoActual.reportes,
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
  idPuesto,
  idDepartamento,
  numeroEmpleado,
  fechaNacimiento,
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

  const numero = String(numeroEmpleado || '').trim() || siguienteNumeroEmpleado();
  if (estadoActual.empleados.some((e) => e.numeroEmpleado === numero)) {
    throw new Error(`El número de empleado ${numero} ya existe`);
  }
  const depto = validarDepartamento(idDepartamento);
  const puestoResuelto = resolverPuesto(idPuesto, puesto);

  const nuevoId = `emp_${Date.now()}`;
  const nuevoEmpleado = {
    id: nuevoId,
    numeroEmpleado: numero,
    nombre: nombreLimpio,
    ...puestoResuelto,
    idDepartamento: depto,
    estadoLaboral: 'ACTIVO',
    fechaNacimiento: fechaNacimiento || null,
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
  if (datos.idPuesto !== undefined) {
    Object.assign(emp, resolverPuesto(datos.idPuesto, datos.puesto ?? emp.puesto));
  } else if (datos.puesto !== undefined) {
    emp.puesto = String(datos.puesto).trim() || emp.puesto;
  }
  if (datos.idDepartamento !== undefined) {
    emp.idDepartamento = validarDepartamento(datos.idDepartamento);
  }
  if (datos.numeroEmpleado !== undefined) {
    const num = String(datos.numeroEmpleado).trim();
    if (!num) throw new Error('El número de empleado no puede estar vacío');
    if (estadoActual.empleados.some((e) => e.id !== emp.id && e.numeroEmpleado === num)) {
      throw new Error(`El número de empleado ${num} ya existe`);
    }
    emp.numeroEmpleado = num;
  }
  if (datos.fechaNacimiento !== undefined) {
    emp.fechaNacimiento = datos.fechaNacimiento || null;
  }
  if (datos.estadoLaboral !== undefined) {
    const estado = String(datos.estadoLaboral).toUpperCase();
    if (!ESTADOS_LABORALES.includes(estado)) {
      throw new Error(`Estado laboral inválido. Usa: ${ESTADOS_LABORALES.join(', ')}`);
    }
    if (estado === 'BAJA') {
      throw new Error('Para dar de baja usa POST /empleados/:id/baja');
    }
    if (estado !== emp.estadoLaboral) {
      emp.estadoLaboral = estado;
      emp.activo = true;
      emp.fechaBaja = null;
      emp.motivoBaja = null;
      notificar(emp.id, `Tu estado laboral cambió a ${estado}.`);
    }
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
      if (emp.estadoLaboral === 'BAJA') emp.estadoLaboral = 'ACTIVO';
    } else {
      emp.estadoLaboral = 'BAJA';
    }
  }

  return emp;
}

export async function darDeBajaEmpleado(empleadoId, { motivoBaja } = {}) {
  const emp = estadoActual.empleados.find((e) => e.id === empleadoId);
  if (!emp) throw new Error('Empleado no encontrado');

  emp.activo = false;
  emp.estadoLaboral = 'BAJA';
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
    fechaCreacion: new Date().toISOString(),
  };

  estadoActual.solicitudes.unshift(nueva);
  notificar(null, `${emp.nombre} solicitó ${nueva.tipo} (${nueva.diasSolicitados} día(s)).`);
  return nueva;
}

export async function responderSolicitud({
  solicitudId,
  autorizar,
  fechaInicio,
  fechaFin,
}) {
  const idx = estadoActual.solicitudes.findIndex((s) => s.id === solicitudId);
  if (idx === -1) throw new Error('Solicitud no encontrada');
  const sol = estadoActual.solicitudes[idx];
  if (sol.estatus !== 'PENDIENTE') {
    throw new Error(`La solicitud ya fue respondida (${sol.estatus})`);
  }
  const empIdx = estadoActual.empleados.findIndex((e) => e.id === sol.idEmpleado);
  if (empIdx === -1) throw new Error('Empleado no encontrado');

  // Valida saldos (vacaciones / permisos) antes de autorizar.
  const res = aplicarRespuestaSolicitud(sol, estadoActual.empleados[empIdx], {
    autorizar,
    fechaInicio,
    fechaFin,
  });
  if (!res.ok) throw new Error(res.error);

  estadoActual.solicitudes[idx] = res.solicitud;
  estadoActual.empleados[empIdx] = res.empleado;

  const rango = autorizar && fechaInicio
    ? ` (${fechaInicio}${fechaFin ? ` al ${fechaFin}` : ''})`
    : '';
  notificar(
    sol.idEmpleado,
    `Tu solicitud de ${sol.tipo} fue ${res.solicitud.estatus}${rango}.`
  );

  return { solicitud: res.solicitud };
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
  const emp = estadoActual.empleados.find((e) => e.nombre === nueva.nombreEmpleado);
  if (emp) {
    notificar(emp.id, `Se registró un(a) ${nueva.tipo.toLowerCase()} a tu nombre: ${nueva.titulo}.`);
  }
  return nueva;
}

// ---------------------------------------------------------------------------
// Departamentos y puestos
// ---------------------------------------------------------------------------

function crearCatalogo(lista, campoId, prefijo, nombre) {
  const limpio = String(nombre || '').trim();
  if (!limpio) throw new Error('El nombre es obligatorio');
  if (lista.some((x) => x.nombre.toLowerCase() === limpio.toLowerCase())) {
    throw new Error(`"${limpio}" ya existe`);
  }
  const nuevo = { [campoId]: `${prefijo}_${Date.now()}`, nombre: limpio };
  lista.push(nuevo);
  return nuevo;
}

function renombrarCatalogo(lista, campoId, id, nombre) {
  const item = lista.find((x) => x[campoId] === id);
  if (!item) throw new Error('Registro no encontrado');
  const limpio = String(nombre || '').trim();
  if (!limpio) throw new Error('El nombre es obligatorio');
  item.nombre = limpio;
  return item;
}

function eliminarCatalogo(lista, campoId, campoEmpleado, id) {
  const idx = lista.findIndex((x) => x[campoId] === id);
  if (idx === -1) throw new Error('Registro no encontrado');
  const asignados = estadoActual.empleados.filter((e) => e[campoEmpleado] === id).length;
  if (asignados > 0) {
    throw new Error(`No se puede eliminar: tiene ${asignados} empleado(s) asignado(s)`);
  }
  const [eliminado] = lista.splice(idx, 1);
  return eliminado;
}

export async function listarDepartamentos() {
  return estadoActual.departamentos.map((d) => ({
    ...d,
    totalEmpleados: estadoActual.empleados.filter(
      (e) => e.idDepartamento === d.idDepartamento && e.activo !== false
    ).length,
  }));
}
export async function crearDepartamento({ nombre }) {
  return crearCatalogo(estadoActual.departamentos, 'idDepartamento', 'dep', nombre);
}
export async function editarDepartamento(id, { nombre }) {
  return renombrarCatalogo(estadoActual.departamentos, 'idDepartamento', id, nombre);
}
export async function eliminarDepartamento(id) {
  return eliminarCatalogo(estadoActual.departamentos, 'idDepartamento', 'idDepartamento', id);
}

export async function listarPuestos() {
  return estadoActual.puestos;
}
export async function crearPuesto({ nombre }) {
  return crearCatalogo(estadoActual.puestos, 'idPuesto', 'pue', nombre);
}
export async function editarPuesto(id, { nombre }) {
  const p = renombrarCatalogo(estadoActual.puestos, 'idPuesto', id, nombre);
  estadoActual.empleados
    .filter((e) => e.idPuesto === id)
    .forEach((e) => { e.puesto = p.nombre; });
  return p;
}
export async function eliminarPuesto(id) {
  return eliminarCatalogo(estadoActual.puestos, 'idPuesto', 'idPuesto', id);
}

// ---------------------------------------------------------------------------
// Notificaciones
// ---------------------------------------------------------------------------

export async function listarNotificaciones({ idEmpleado, soloNoLeidas } = {}) {
  return estadoActual.notificaciones.filter((n) => {
    const destino = idEmpleado ? n.idEmpleado === idEmpleado : n.idEmpleado == null;
    return destino && (!soloNoLeidas || !n.leida);
  });
}

export async function marcarNotificacionLeida(idNotificacion) {
  const n = estadoActual.notificaciones.find((x) => x.idNotificacion === idNotificacion);
  if (!n) throw new Error('Notificación no encontrada');
  n.leida = true;
  return n;
}

export async function enviarNotificacion({ idEmpleado = null, mensaje }) {
  if (idEmpleado) buscarEmpleado(idEmpleado);
  return notificar(idEmpleado, mensaje);
}

// ---------------------------------------------------------------------------
// Calendario laboral
// ---------------------------------------------------------------------------

export async function listarCalendario({ anio } = {}) {
  const lista = anio
    ? estadoActual.calendario.filter((d) => d.fecha.startsWith(`${anio}-`))
    : estadoActual.calendario;
  return [...lista].sort((a, b) => a.fecha.localeCompare(b.fecha));
}

export async function agregarDiaCalendario(datos) {
  const dia = crearDiaCalendario(datos);
  if (estadoActual.calendario.some((d) => d.fecha === dia.fecha)) {
    throw new Error(`El día ${dia.fecha} ya está registrado`);
  }
  estadoActual.calendario.push(dia);
  return dia;
}

export async function eliminarDiaCalendario(idDia) {
  const idx = estadoActual.calendario.findIndex((d) => d.idDia === idDia);
  if (idx === -1) throw new Error('Día no encontrado');
  const [eliminado] = estadoActual.calendario.splice(idx, 1);
  return eliminado;
}

export async function cargarFestivosOficiales(anio) {
  const agregados = [];
  for (const f of festivosOficiales(Number(anio))) {
    if (!esFestivo(estadoActual.calendario, f.fecha)) {
      const dia = crearDiaCalendario(f);
      estadoActual.calendario.push(dia);
      agregados.push(dia);
    }
  }
  return agregados;
}

export async function calcularDiasHabiles({ inicio, fin }) {
  if (!inicio || !fin) throw new Error('inicio y fin son obligatorios');
  return { inicio, fin, diasHabiles: diasHabilesEntre(estadoActual.calendario, inicio, fin) };
}

// ---------------------------------------------------------------------------
// Reportes
// ---------------------------------------------------------------------------

export async function generarReporte({ tipoReporte, desde, hasta, idDepartamento, idAdmin } = {}) {
  const contenido = construirReporte(estadoActual, { tipoReporte, desde, hasta, idDepartamento });
  const reporte = {
    idReporte: `rep_${Date.now()}`,
    fechaGeneracion: new Date().toISOString(),
    generadoPor: idAdmin || 'adm_1',
    ...contenido,
  };
  estadoActual.reportes.unshift(reporte);
  return reporte;
}

export async function listarReportes() {
  return estadoActual.reportes.map(({ datos, ...resto }) => resto);
}

export async function obtenerReporte(idReporte) {
  const r = estadoActual.reportes.find((x) => x.idReporte === idReporte);
  if (!r) throw new Error('Reporte no encontrado');
  return r;
}