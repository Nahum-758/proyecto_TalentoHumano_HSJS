function enviarJson(res, status, payload) {
  res.status(status).json(payload);
}

function registrarEvento(evento, detalle) {
  console.log(`[EVENTO ${evento}] ${new Date().toISOString()}:`, detalle);
}

module.exports = { enviarJson, registrarEvento };