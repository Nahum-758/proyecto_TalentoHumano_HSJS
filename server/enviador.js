export function enviarJson(res, status, payload) {
  res.status(status).json(payload);
}

export function registrarEvento(evento, detalle) {
  console.log(`[EVENTO ${evento}] ${new Date().toISOString()}:`, detalle);
}
