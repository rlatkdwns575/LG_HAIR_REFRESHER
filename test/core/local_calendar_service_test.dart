import 'package:flutter_test/flutter_test.dart';
import 'package:lg_hair_refresher/core/services/local_calendar_connection_store.dart';
import 'package:lg_hair_refresher/core/services/local_calendar_service.dart';

void main() {
  setUp(LocalCalendarConnectionStore.instance.clear);

  group('LocalCalendarService', () {
    const service = LocalCalendarService();

    test('starts disconnected', () async {
      final status = await service.fetchStatus();
      expect(status.isConnected, isFalse);
      expect(status.listRightLabel, '미연동');
    });

    test('requestAccess grants permission and verifies connection', () async {
      final status = await service.requestAccess();
      expect(status.permissionGranted, isTrue);
      expect(status.isConnected, isTrue);
      expect(status.todayEventCount, greaterThan(0));
      expect(status.listRightLabel, '연동됨');
    });

    test('disconnect clears connection state', () async {
      await service.requestAccess();
      final status = await service.disconnect();
      expect(status.isConnected, isFalse);
      expect(status.permissionGranted, isFalse);
    });
  });
}
