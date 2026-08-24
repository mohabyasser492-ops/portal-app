import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_app/core/offline/cache_category.dart';
import 'package:portal_app/core/offline/cache_policy.dart';
import 'package:portal_app/core/offline/cache_service.dart';
import 'package:portal_app/core/storage/database/app_database.dart';

void main() {
  late AppDatabase database;
  late CacheService cacheService;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());

    cacheService = CacheService(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('stores and reads a JSON object', () async {
    final now = DateTime.utc(2026, 8, 24, 10);

    await cacheService.saveJson(
      key: 'employee-summary',
      category: CacheCategory.employeeSummary,
      value: {'displayName': 'Test Employee', 'department': 'Engineering'},
      policy: CachePolicy.employeeSummary,
      currentTime: now,
    );

    final result = await cacheService.readJson(
      'employee-summary',
      currentTime: now.add(const Duration(minutes: 5)),
    );

    expect(result, isNotNull);
    expect(result!['displayName'], 'Test Employee');
    expect(result['department'], 'Engineering');
  });

  test('returns null when the cache has expired', () async {
    final now = DateTime.utc(2026, 8, 24, 10);

    await cacheService.saveJson(
      key: 'leave-balance',
      category: CacheCategory.leaveBalances,
      value: {'available': 10},
      policy: CachePolicy.leaveBalances,
      currentTime: now,
    );

    final result = await cacheService.readJson(
      'leave-balance',
      currentTime: now.add(const Duration(minutes: 20)),
    );

    expect(result, isNull);
  });

  test('removes a cache entry by key', () async {
    final now = DateTime.utc(2026, 8, 24, 10);

    await cacheService.saveJson(
      key: 'announcement',
      category: CacheCategory.announcements,
      value: {'title': 'Company update'},
      policy: CachePolicy.announcements,
      currentTime: now,
    );

    await cacheService.remove('announcement');

    final result = await cacheService.readJson(
      'announcement',
      currentTime: now,
    );

    expect(result, isNull);
  });

  test('clears only protected cache data', () async {
    final now = DateTime.utc(2026, 8, 24, 10);

    await cacheService.saveJson(
      key: 'profile',
      category: CacheCategory.employeeSummary,
      value: {'displayName': 'Test Employee'},
      policy: CachePolicy.employeeSummary,
      currentTime: now,
    );

    await cacheService.saveJson(
      key: 'services',
      category: CacheCategory.serviceCatalog,
      value: {'count': 12},
      policy: CachePolicy.serviceCatalog,
      currentTime: now,
    );

    final deletedCount = await cacheService.clearProtectedData();

    final profile = await cacheService.readJson('profile', currentTime: now);

    final services = await cacheService.readJson('services', currentTime: now);

    expect(deletedCount, 1);
    expect(profile, isNull);
    expect(services, isNotNull);
  });
}
