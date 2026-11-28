import express from 'express';
import cors from 'cors';
import {
  obtenerEstado,
  autenticarUsuario,
  crearEmpleado,
  editarEmpleado,
  darDeBajaEmpleado,
  actualizarVacacionesEmpleado,
  crearSolicitud,
  responderSolicitud,
  crearIncidencia,
  listarDepartamentos,
  crearDepartamento,
  editarDepartamento,
  eliminarDepartamento,
  listarPuestos,
  crearPuesto,
  editarPuesto,
  eliminarPuesto,
  listarNotificaciones,
  marcarNotificacionLeida,
  enviarNotificacion,
  listarCalendario,
  agregarDiaCalendario,
  eliminarDiaCalendario,
  cargarFestivosOficiales,
  calcularDiasHabiles,
  generarReporte,
  listarReportes,
  obtenerReporte,
} from './almacen.js';

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

app.get('/health', async (_req, res) => {
  res.status(200).json({ ok: true });
});

app.get('/estado', async (_req, res) => {
  try {
    const estado = await obtenerEstado();
    res.json(estado);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/auth/login', async (req, res) => {
  try {
    const { correo, password } = req.body || {};
    const usuario = await autenticarUsuario({ correo, password });
    res.json({ usuario });
  } catch (err) {
    res.status(401).json({ error: err.message });
  }
});

app.post('/empleados', async (req, res) => {
  try {
    const empleado = await crearEmpleado(req.body || {});
    res.status(201).json({ empleado });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

app.patch('/empleados/:id', async (req, res) => {
  try {
    const empleado = await editarEmpleado(req.params.id, req.body || {});
    res.json({ empleado });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

app.post('/empleados/:id/baja', async (req, res) => {
  try {
    const empleado = await darDeBajaEmpleado(req.params.id, req.body || {});
    res.json({ empleado });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

app.patch('/empleados/:id/vacaciones', async (req, res) => {
  try {
    const { vecesAlAnio, diasPorPeriodo, vigencia } = req.body || {};
    const empleado = await actualizarVacacionesEmpleado({
      empleadoId: req.params.id,
      vecesAlAnio,
      diasPorPeriodo,
      vigencia,
    });
    res.json({ empleado });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

app.post('/solicitudes', async (req, res) => {
  try {
    const solicitud = await crearSolicitud(req.body || {});
    res.status(201).json({ solicitud });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

app.post('/solicitudes/:id/responder', async (req, res) => {
  try {
    const { autorizar, fechaInicio, fechaFin } = req.body || {};
    const resultado = await responderSolicitud({
      solicitudId: req.params.id,
      autorizar,
      fechaInicio,
      fechaFin,
    });
    res.json(resultado);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

app.post('/incidencias', async (req, res) => {
  try {
    const incidencia = await crearIncidencia(req.body || {});
    res.status(201).json({ incidencia });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Envuelve un handler: responde JSON y traduce errores a 400 / 404.
const ruta = (fn, status = 200) => async (req, res) => {
  try {
    res.status(status).json(await fn(req));
  } catch (err) {
    const noEncontrado = /no encontrad/i.test(err.message);
    res.status(noEncontrado ? 404 : 400).json({ error: err.message });
  }
};

// Departamentos
app.get('/departamentos', ruta(async () => ({ departamentos: await listarDepartamentos() })));
app.post('/departamentos', ruta(async (req) => ({ departamento: await crearDepartamento(req.body || {}) }), 201));
app.patch('/departamentos/:id', ruta(async (req) => ({ departamento: await editarDepartamento(req.params.id, req.body || {}) })));
app.delete('/departamentos/:id', ruta(async (req) => ({ departamento: await eliminarDepartamento(req.params.id) })));

// Puestos
app.get('/puestos', ruta(async () => ({ puestos: await listarPuestos() })));
app.post('/puestos', ruta(async (req) => ({ puesto: await crearPuesto(req.body || {}) }), 201));
app.patch('/puestos/:id', ruta(async (req) => ({ puesto: await editarPuesto(req.params.id, req.body || {}) })));
app.delete('/puestos/:id', ruta(async (req) => ({ puesto: await eliminarPuesto(req.params.id) })));

// Notificaciones (?idEmpleado=emp_1 ; sin idEmpleado = notificaciones de RH)
app.get('/notificaciones', ruta(async (req) => ({
  notificaciones: await listarNotificaciones({
    idEmpleado: req.query.idEmpleado,
    soloNoLeidas: req.query.soloNoLeidas === 'true',
  }),
})));
app.post('/notificaciones', ruta(async (req) => ({ notificacion: await enviarNotificacion(req.body || {}) }), 201));
app.patch('/notificaciones/:id/leida', ruta(async (req) => ({ notificacion: await marcarNotificacionLeida(req.params.id) })));

// Calendario laboral
app.get('/calendario', ruta(async (req) => ({ dias: await listarCalendario({ anio: req.query.anio }) })));
app.post('/calendario', ruta(async (req) => ({ dia: await agregarDiaCalendario(req.body || {}) }), 201));
app.delete('/calendario/:id', ruta(async (req) => ({ dia: await eliminarDiaCalendario(req.params.id) })));
app.post('/calendario/festivos-oficiales/:anio', ruta(async (req) => ({ agregados: await cargarFestivosOficiales(req.params.anio) }), 201));
app.get('/calendario/dias-habiles', ruta(async (req) => calcularDiasHabiles(req.query)));

// Reportes
app.get('/reportes', ruta(async () => ({ reportes: await listarReportes() })));
app.get('/reportes/:id', ruta(async (req) => ({ reporte: await obtenerReporte(req.params.id) })));
app.post('/reportes', ruta(async (req) => ({ reporte: await generarReporte(req.body || {}) }), 201));

export default app;

if (process.env.NODE_ENV !== 'test') {
  app.listen(PORT, () => {
    console.log(`Servidor corriendo en puerto ${PORT}`);
  });
}