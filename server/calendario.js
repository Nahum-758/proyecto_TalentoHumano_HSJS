// CalendarioLaboral: días festivos / inhábiles y cálculo de días hábiles.

function soloFecha(valor) {
  const d = new Date(valor);
  return `${d.getUTCFullYear()}-${String(d.getUTCMonth() + 1).padStart(2, '0')}-${String(d.getUTCDate()).padStart(2, '0')}`;
}

export function crearDiaCalendario({ fecha, descripcion, esFestivo = true }) {
  if (!fecha || Number.isNaN(new Date(fecha).getTime())) {
    throw new Error('La fecha del calendario es obligatoria y debe ser válida');
  }
  return {
    idDia: `dia_${Date.now()}_${Math.floor(Math.random() * 1000)}`,
    fecha: soloFecha(fecha),
    descripcion: String(descripcion || 'Día inhábil').trim(),
    esFestivo: esFestivo !== false,
  };
}

export function esFestivo(dias, fecha) {
  const clave = soloFecha(fecha);
  return dias.some((d) => d.esFestivo && d.fecha === clave);
}

export function esDiaHabil(dias, fecha) {
  const dow = new Date(fecha).getUTCDay(); // 0 domingo, 6 sábado
  return dow !== 0 && dow !== 6 && !esFestivo(dias, fecha);
}

/** Días hábiles entre inicio y fin (ambos incluidos). */
export function diasHabilesEntre(dias, inicio, fin) {
  const actual = new Date(`${soloFecha(inicio)}T00:00:00.000Z`);
  const limite = new Date(`${soloFecha(fin)}T00:00:00.000Z`);
  let total = 0;
  while (actual <= limite) {
    if (esDiaHabil(dias, actual)) total += 1;
    actual.setUTCDate(actual.getUTCDate() + 1);
  }
  return total;
}

/** Días de descanso obligatorio (LFT art. 74) para un año. */
export function festivosOficiales(anio) {
  const nLunes = (mes, n) => {
    const d = new Date(Date.UTC(anio, mes - 1, 1));
    while (d.getUTCDay() !== 1) d.setUTCDate(d.getUTCDate() + 1);
    d.setUTCDate(d.getUTCDate() + 7 * (n - 1));
    return soloFecha(d);
  };
  const f = (m, d) => `${anio}-${String(m).padStart(2, '0')}-${String(d).padStart(2, '0')}`;
  return [
    { fecha: f(1, 1), descripcion: 'Año Nuevo' },
    { fecha: nLunes(2, 1), descripcion: 'Día de la Constitución' },
    { fecha: nLunes(3, 3), descripcion: 'Natalicio de Benito Juárez' },
    { fecha: f(5, 1), descripcion: 'Día del Trabajo' },
    { fecha: f(9, 16), descripcion: 'Día de la Independencia' },
    { fecha: nLunes(11, 3), descripcion: 'Día de la Revolución' },
    { fecha: f(12, 25), descripcion: 'Navidad' },
  ];
}
