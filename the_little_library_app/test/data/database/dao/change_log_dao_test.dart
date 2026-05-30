import 'package:flutter_test/flutter_test.dart';
import 'package:thelittlelibrary/data/database/database.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.memory();
  });

  tearDown(() async {
    await db.close();
  });

  group('ChangeLogDao — CRUD', () {
    test('should append a change log event with all fields', () async {
      await db.changeLogDao.append(
        eventId: 'evnt0000-0000-0000-0000-000000000001',
        entityType: 'book',
        entityId: 'booktest-0000-0000-0000-000000000001',
        eventType: 'create',
        fieldName: 'title',
        oldValue: null,
        newValue: 'Test Book',
        deviceUser: 'test-user',
      );

      final events = await db.select(db.changeLogEvents).get();
      expect(events.length, 1);
      expect(events.first.eventType, 'create');
      expect(events.first.deviceUser, 'test-user');
    });

    test('should query events since a given timestamp sorted desc', () async {
      final now = DateTime.now();
      final past = now.subtract(const Duration(hours: 1));

      await db.changeLogDao.append(
        eventId: 'evnt0000-0000-0000-0000-000000000002',
        entityType: 'book',
        entityId: 'bookold0-0000-0000-0000-000000000001',
        eventType: 'update',
        fieldName: 'title',
        oldValue: null,
        newValue: 'Old',
        deviceUser: 'test-user',
      );

      final events = await db.changeLogDao.querySince(
        past.toIso8601String(),
      );
      expect(events.isNotEmpty, isTrue);
    });

    test('should query events for a specific entity type and id', () async {
      await db.changeLogDao.append(
        eventId: 'evnt0000-0000-0000-0000-000000000003',
        entityType: 'book',
        entityId: 'mybookid-0000-0000-0000-000000000001',
        eventType: 'create',
        fieldName: '*',
        newValue: 'Created',
        deviceUser: 'test-user',
      );

      final events = await db.changeLogDao.getEventsForEntity(
        'book',
        'mybookid-0000-0000-0000-000000000001',
      );
      expect(events.length, 1);
      expect(events.first.entityId, 'mybookid-0000-0000-0000-000000000001');
    });

    test('should support pagination on querySince (limit + offset)', () async {
      final now = DateTime.now();
      final past = now.subtract(const Duration(days: 1));

      await db.changeLogDao.append(
        eventId: 'evnt0000-0000-0000-0000-000000000004',
        entityType: 'book',
        entityId: 'bookpag1-0000-0000-0000-000000000001',
        eventType: 'create',
        fieldName: '*',
        newValue: '1',
        deviceUser: 'test-user',
      );
      await db.changeLogDao.append(
        eventId: 'evnt0000-0000-0000-0000-000000000005',
        entityType: 'book',
        entityId: 'bookpag2-0000-0000-0000-000000000001',
        eventType: 'create',
        fieldName: '*',
        newValue: '2',
        deviceUser: 'test-user',
      );

      final events = await db.changeLogDao.querySince(
        past.toIso8601String(),
        limit: 1,
      );
      expect(events.length, 1);
    });

    test('should return empty list when no events since timestamp', () async {
      final future = DateTime.now().add(const Duration(hours: 1));
      final events = await db.changeLogDao.querySince(
        future.toIso8601String(),
      );
      expect(events, isEmpty);
    });

    test('should record deviceUser on every event', () async {
      await db.changeLogDao.append(
        eventId: 'evnt0000-0000-0000-0000-000000000006',
        entityType: 'book',
        entityId: 'bookdev0-0000-0000-0000-000000000001',
        eventType: 'create',
        fieldName: '*',
        newValue: 'Test',
        deviceUser: 'alice@example.com',
      );

      final events = await db.select(db.changeLogEvents).get();
      expect(events.first.deviceUser, 'alice@example.com');
    });

    test('should record correct entityType for each operation', () async {
      await db.changeLogDao.append(
        eventId: 'evnt0000-0000-0000-0000-000000000007',
        entityType: 'genre',
        entityId: 'genreid0-0000-0000-0000-000000000001',
        eventType: 'create',
        fieldName: '*',
        newValue: 'Genre',
        deviceUser: 'test-user',
      );

      final events = await db.select(db.changeLogEvents).get();
      expect(events.first.entityType, 'genre');
    });

    test('should record correct eventType for each operation', () async {
      await db.changeLogDao.append(
        eventId: 'evnt0000-0000-0000-0000-000000000008',
        entityType: 'book',
        entityId: 'bookevt0-0000-0000-0000-000000000001',
        eventType: 'delete',
        fieldName: 'is_deleted',
        newValue: 'true',
        deviceUser: 'test-user',
      );

      final events = await db.select(db.changeLogEvents).get();
      expect(events.first.eventType, 'delete');
    });
  });
}
