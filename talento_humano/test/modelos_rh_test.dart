import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talento_humano/src/core/talento_humano_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    TalentoHumanoStore.instance.reiniciarParaPruebas();
  });

  group('Empleado', () {
    test('calcularAntiguedad cuenta años completos', () {
      final e = Empleado(
        id: 'e1',
        nombre: 'Ana',
        puesto: 'Operativo',
        fechaIngreso: DateTime(2020, 6, 15),
      );
      expect(e.calcularAntiguedad(DateTime(2026, 6, 14)), 5);
      expect(e.calcularAntiguedad(DateTime(2026, 6, 15)), 6);
      expect(e.calcularAntiguedad(DateTime(2019, 1, 1)), 0);
    });

    test('estadoLaboral es BAJA cuando no está activo', () {
      final e = Empleado(
        id: 'e1',
        nombre: 'Ana',
        puesto: 'Operativo',
        fechaIngreso: DateTime(2020),
        activo: false,
        estadoLaboral: EstadoLaboral.incapacidad,
      );
      expect(e.estadoLaboral, EstadoLaboral.baja);
      final reactivado = e.copyWith(activo: true, fechaBaja: null);
      expect(reactivado.estadoLaboral, EstadoLaboral.activo);
    });

    test('toMap / fromMap conserva los campos nuevos', () {
      final e = Empleado(
        id: 'e1',
        numeroEmpleado: 'E0007',
        nombre: 'Ana',
        puesto: 'Enfermera',
        puestoId: 'pue_1',
        departamentoId: 'dep_1',
        estadoLaboral: EstadoLaboral.vacaciones,
        fechaIngreso: DateTime(2020),
      );
      final copia = Empleado.fromMap(e.toMap());
      expect(copia.numeroEmpleado, 'E0007');
      expect(copia.puestoId, 'pue_1');
      expect(copia.departamentoId, 'dep_1');
      expect(copia.estadoLaboral, EstadoLaboral.vacaciones);
    });

    test('copyWith puede limpiar el departamento', () {
      final e = Empleado(
        id: 'e1',
        nombre: 'Ana',
        puesto: 'X',
        departamentoId: 'dep_1',
        fechaIngreso: DateTime(2020),
      );
      expect(e.copyWith(departamentoId: null).departamentoId, isNull);
      expect(e.copyWith(nombre: 'Bea').departamentoId, 'dep_1');
    });
  });

  group('CalendarioLaboral', () {
    test('días hábiles excluyen fines de semana y festivos', () {
      final cal = CalendarioLaboral([
        DiaCalendario(
          id: 'd1',
          fecha: DateTime(2026, 12, 25),
          descripcion: 'Navidad',
        ),
      ]);
      // 21 al 27 de diciembre de 2026: 5 días entre semana, menos Navidad.
      expect(
        cal.diasHabilesEntre(DateTime(2026, 12, 21), DateTime(2026, 12, 27)),
        4,
      );
      expect(cal.esDiaHabil(DateTime(2026, 12, 26)), isFalse); // sábado
    });
  });

  group('TalentoHumanoStore', () {
    test('asigna número de empleado consecutivo', () async {
      final store = TalentoHumanoStore.instance;
      await store.guardarEmpleado(
        Empleado(id: 'a', nombre: 'A', puesto: 'X', fechaIngreso: DateTime(2020)),
      );
      await store.guardarEmpleado(
        Empleado(id: 'b', nombre: 'B', puesto: 'X', fechaIngreso: DateTime(2021)),
      );
      expect(store.buscarEmpleadoPorId('a')!.numeroEmpleado, 'E0001');
      expect(store.buscarEmpleadoPorId('b')!.numeroEmpleado, 'E0002');
    });

    test('no elimina un departamento con colaboradores', () async {
      final store = TalentoHumanoStore.instance;
      await store.crearDepartamento('Enfermería');
      final dep = store.departamentos.first;
      await store.guardarEmpleado(
        Empleado(
          id: 'a',
          nombre: 'A',
          puesto: 'X',
          departamentoId: dep.id,
          fechaIngreso: DateTime(2020),
        ),
      );
      expect(await store.eliminarDepartamento(dep.id), isNotNull);
      expect(store.departamentos, hasLength(1));
    });

    test('autorizar una solicitud notifica al empleado', () async {
      final store = TalentoHumanoStore.instance;
      await store.guardarEmpleado(
        Empleado(id: 'a', nombre: 'Ana', puesto: 'X', fechaIngreso: DateTime(2020)),
      );
      await store.crearSolicitud(
        SolicitudPermiso(
          id: 's1',
          idEmpleado: 'a',
          nombreEmpleado: 'Ana',
          tipo: 'Vacaciones',
          motivo: '',
          diasSolicitados: 2,
        ),
      );
      expect(store.noLeidasDe(null), 1); // RH recibe aviso
      await store.actualizarEstatusSolicitud('s1', 'AUTORIZADA');
      expect(store.noLeidasDe('a'), 1);
      expect(store.buscarEmpleadoPorId('a')!.diasVacacionesUsados, 2);
      await store.marcarTodasLeidas('a');
      expect(store.noLeidasDe('a'), 0);
    });

    test('no autoriza más días de cumpleaños de los disponibles', () async {
      final store = TalentoHumanoStore.instance;
      await store.guardarEmpleado(
        Empleado(id: 'a', nombre: 'Ana', puesto: 'X', fechaIngreso: DateTime(2020)),
      );
      expect(
        store.buscarEmpleadoPorId('a')!.saldoDisponiblePara('Día de cumpleaños'),
        1,
      );
      await store.crearSolicitud(
        SolicitudPermiso(
          id: 's2',
          idEmpleado: 'a',
          nombreEmpleado: 'Ana',
          tipo: 'Día de cumpleaños',
          motivo: '',
          diasSolicitados: 2,
        ),
      );
      final error = await store.actualizarEstatusSolicitud('s2', 'AUTORIZADA');
      expect(error, isNotNull);
      expect(store.solicitudes.first.estatus, 'PENDIENTE');
      expect(store.buscarEmpleadoPorId('a')!.diaCumpleanosUsados, 0);
    });

    test('genera reporte de plantilla', () async {
      final store = TalentoHumanoStore.instance;
      await store.guardarEmpleado(
        Empleado(id: 'a', nombre: 'Ana', puesto: 'X', fechaIngreso: DateTime(2020)),
      );
      final rep = await store.generarReporte(TiposReporte.plantilla);
      expect(rep.descripcion, contains('Colaboradores activos: 1'));
      expect(store.reportes, hasLength(1));
    });
  });
}
