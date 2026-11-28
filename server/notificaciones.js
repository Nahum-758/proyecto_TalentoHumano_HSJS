// Notificacion: la recibe un Empleado (idEmpleado) o RH (idEmpleado = null).
export function crearNotificacion({ idEmpleado = null, mensaje }) {
  const texto = String(mensaje || '').trim();
  if (!texto) throw new Error('El mensaje de la notificación es obligatorio');
  return {
    idNotificacion: `not_${Date.now()}_${Math.floor(Math.random() * 1000)}`,
    idEmpleado,
    mensaje: texto,
    fechaEnvio: new Date().toISOString(),
    leida: false,
  };
}
