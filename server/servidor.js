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

app.listen(PORT, () => {
  console.log(`Servidor corriendo en puerto ${PORT}`);
});