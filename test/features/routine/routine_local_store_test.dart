import 'package:flutter_test/flutter_test.dart';
import 'package:lg_hair_refresher/features/routine/data/api/routine_api.dart';
import 'package:lg_hair_refresher/features/routine/data/api/routine_local_store.dart';
import 'package:lg_hair_refresher/features/routine/data/model/routine.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RoutineLocalStore', () {
    late RoutineLocalStore store;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      store = const RoutineLocalStore();
    });

    test('persists routines locally', () async {
      const routine = Routine(
        id: 'r1',
        modeId: 'mode-1',
        modeName: '외부 냄새 리프레시',
        weekdays: {1, 3},
        hour: 19,
        minute: 0,
        isRepeating: true,
      );

      await store.saveAll([routine]);

      final loaded = await store.loadAll();
      expect(loaded, hasLength(1));
      expect(loaded.first.id, 'r1');
      expect(loaded.first.modeName, '외부 냄새 리프레시');
      expect(loaded.first.weekdays, {1, 3});
      expect(loaded.first.isRepeating, isTrue);
    });
  });

  group('RoutineApi local CRUD', () {
    late RoutineApi api;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      api = RoutineApi(localStore: const RoutineLocalStore());
    });

    test('create and fetch routines without login', () async {
      final created = await api.create(
        const Routine(
          modeId: 'mode-1',
          modeName: '먼지 케어',
          weekdays: {5},
          hour: 8,
          minute: 30,
          isRepeating: false,
        ),
      );

      expect(created.id, isNotNull);

      final all = await api.fetchAll();
      expect(all, hasLength(1));
      expect(all.first.modeName, '먼지 케어');
      expect(all.first.isRepeating, isFalse);
    });

    test('update and delete routines locally', () async {
      final created = await api.create(
        const Routine(modeId: 'mode-1', weekdays: {2}, hour: 10, minute: 0),
      );

      final updated = await api.update(
        created.copyWith(enabled: false, isRepeating: false),
      );
      expect(updated.enabled, isFalse);
      expect(updated.isRepeating, isFalse);

      await api.delete(created.id!);
      expect(await api.fetchAll(), isEmpty);
    });
  });
}
