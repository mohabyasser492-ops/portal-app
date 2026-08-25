import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_app/core/storage/database/app_database.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  test('stores and returns a valid cache entry', () async {
    final now = DateTime.utc(2026, 8, 24, 10);

    await database.saveCacheEntry(
      key: 'employee-summary',
      category: 'employeeSummary',
      payload: '{"displayName":"Test Employee"}',
      cachedAt: now,
      expiresAt: now.add(const Duration(minutes: 30)),
      clearOnLogout: true,
    );

    final result = await database.getValidCacheEntry(
      'employee-summary',
      currentTime: now.add(const Duration(minutes: 5)),
    );

    expect(result, isNotNull);
    expect(result!.category, 'employeeSummary');
    expect(result.payload, contains('Test Employee'));
  });

  test('does not return an expired cache entry', () async {
    final now = DateTime.utc(2026, 8, 24, 10);

    await database.saveCacheEntry(
      key: 'leave-balance',
      category: 'leaveBalances',
      payload: '{"available":10}',
      cachedAt: now,
      expiresAt: now.add(const Duration(minutes: 15)),
      clearOnLogout: true,
    );

    final result = await database.getValidCacheEntry(
      'leave-balance',
      currentTime: now.add(const Duration(minutes: 20)),
    );

    expect(result, isNull);
  });

  test('removes expired cache entries', () async {
    final now = DateTime.utc(2026, 8, 24, 10);

    await database.saveCacheEntry(
      key: 'expired-entry',
      category: 'requestSummaries',
      payload: '{}',
      cachedAt: now,
      expiresAt: now.add(const Duration(minutes: 5)),
      clearOnLogout: true,
    );

    final deletedCount = await database.deleteExpiredCacheEntries(
      currentTime: now.add(const Duration(minutes: 10)),
    );

    final result = await database.getValidCacheEntry(
      'expired-entry',
      currentTime: now.add(const Duration(minutes: 10)),
    );

    expect(deletedCount, 1);
    expect(result, isNull);
  });

  test('keeps public cache while clearing protected cache', () async {
    final now = DateTime.utc(2026, 8, 24, 10);

    await database.saveCacheEntry(
      key: 'employee-profile',
      category: 'employeeSummary',
      payload: '{}',
      cachedAt: now,
      expiresAt: now.add(const Duration(hours: 1)),
      clearOnLogout: true,
    );

    await database.saveCacheEntry(
      key: 'service-catalog',
      category: 'serviceCatalog',
      payload: '{}',
      cachedAt: now,
      expiresAt: now.add(const Duration(hours: 12)),
      clearOnLogout: false,
    );

    final deletedCount = await database.clearProtectedCache();

    final protectedEntry = await database.getValidCacheEntry(
      'employee-profile',
      currentTime: now,
    );

    final publicEntry = await database.getValidCacheEntry(
      'service-catalog',
      currentTime: now,
    );

    expect(deletedCount, 1);
    expect(protectedEntry, isNull);
    expect(publicEntry, isNotNull);
  });

  test('creates and updates a request draft', () async {
    final createdAt = DateTime.utc(2026, 8, 24, 10);

    await database.saveRequestDraft(
      id: 'draft-1',
      requestType: 'leave',
      payload: '{"reason":"Initial reason"}',
      createdAt: createdAt,
      updatedAt: createdAt,
    );

    await database.saveRequestDraft(
      id: 'draft-1',
      requestType: 'leave',
      payload: '{"reason":"Updated reason"}',
      createdAt: createdAt,
      updatedAt: createdAt.add(const Duration(minutes: 5)),
    );

    final result = await database.getRequestDraft('draft-1');

    expect(result, isNotNull);
    expect(result!.requestType, 'leave');
    expect(result.payload, contains('Updated reason'));
  });

  test('returns drafts ordered by most recently updated', () async {
    final now = DateTime.utc(2026, 8, 24, 10);

    await database.saveRequestDraft(
      id: 'draft-1',
      requestType: 'leave',
      payload: '{}',
      createdAt: now,
      updatedAt: now,
    );

    await database.saveRequestDraft(
      id: 'draft-2',
      requestType: 'permission',
      payload: '{}',
      createdAt: now,
      updatedAt: now.add(const Duration(minutes: 10)),
    );

    final results = await database.getAllRequestDrafts();

    expect(results, hasLength(2));
    expect(results.first.id, 'draft-2');
    expect(results.last.id, 'draft-1');
  });

  test('deletes a request draft', () async {
    final now = DateTime.utc(2026, 8, 24, 10);

    await database.saveRequestDraft(
      id: 'draft-1',
      requestType: 'leave',
      payload: '{}',
      createdAt: now,
      updatedAt: now,
    );

    await database.deleteRequestDraft('draft-1');

    final result = await database.getRequestDraft('draft-1');

    expect(result, isNull);
  });
}
