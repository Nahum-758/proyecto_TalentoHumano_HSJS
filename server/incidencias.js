export function crearIncidencia({ nombreEmpleado, tipo, titulo, descripcion }) {
  const tipoNormalizado =
    tipo === 'Sanción' || tipo === 'Sancion' ? 'Sanción' : 'Reconocimiento';
  return {
    id: `inc-${Date.now()}-${Math.floor(Math.random() * 1000)}`,
    nombreEmpleado,
    tipo: tipoNormalizado,
    titulo: titulo || '',
    descripcion: descripcion || '',
    fecha: new Date().toISOString(),
  };
}