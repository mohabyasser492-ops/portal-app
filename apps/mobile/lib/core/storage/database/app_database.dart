import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

class CacheEntries extends Table {
  TextColumn get key => text()();

  TextColumn get category => text()();

  TextColumn get payload => text()();

  DateTimeColumn get cachedAt => dateTime()();

  DateTimeColumn get expiresAt => dateTime()();

  BoolColumn get clearOnLogout => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

class RequestDrafts extends Table {
  TextColumn get id => text()();

  TextColumn get requestType => text()();

  TextColumn get payload => text()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(tables: [CacheEntries, RequestDrafts])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  Future<void> saveCacheEntry({
    required String key,
    required String category,
    required String payload,
    required DateTime cachedAt,
    required DateTime expiresAt,
    required bool clearOnLogout,
  }) {
    return into(cacheEntries).insertOnConflictUpdate(
      CacheEntriesCompanion.insert(
        key: key,
        category: category,
        payload: payload,
        cachedAt: cachedAt,
        expiresAt: expiresAt,
        clearOnLogout: Value(clearOnLogout),
      ),
    );
  }

  Future<CacheEntry?> getValidCacheEntry(String key, {DateTime? currentTime}) {
    final now = currentTime ?? DateTime.now().toUtc();

    final query = select(cacheEntries)
      ..where(
        (entry) =>
            entry.key.equals(key) & entry.expiresAt.isBiggerThanValue(now),
      );

    return query.getSingleOrNull();
  }

  Future<void> deleteCacheEntry(String key) async {
    await (delete(cacheEntries)..where((entry) => entry.key.equals(key))).go();
  }

  Future<int> deleteExpiredCacheEntries({DateTime? currentTime}) {
    final now = currentTime ?? DateTime.now().toUtc();

    return (delete(
      cacheEntries,
    )..where((entry) => entry.expiresAt.isSmallerOrEqualValue(now))).go();
  }

  Future<int> clearProtectedCache() {
    return (delete(
      cacheEntries,
    )..where((entry) => entry.clearOnLogout.equals(true))).go();
  }

  Future<void> saveRequestDraft({
    required String id,
    required String requestType,
    required String payload,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) {
    return into(requestDrafts).insertOnConflictUpdate(
      RequestDraftsCompanion.insert(
        id: id,
        requestType: requestType,
        payload: payload,
        createdAt: createdAt,
        updatedAt: updatedAt,
      ),
    );
  }

  Future<RequestDraft?> getRequestDraft(String id) {
    final query = select(requestDrafts)..where((draft) => draft.id.equals(id));

    return query.getSingleOrNull();
  }

  Future<List<RequestDraft>> getAllRequestDrafts() {
    final query = select(requestDrafts)
      ..orderBy([(draft) => OrderingTerm.desc(draft.updatedAt)]);

    return query.get();
  }

  Future<void> deleteRequestDraft(String id) async {
    await (delete(requestDrafts)..where((draft) => draft.id.equals(id))).go();
  }

  Future<int> clearRequestDrafts() {
    return delete(requestDrafts).go();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationDocumentsDirectory();

    final file = File(path.join(directory.path, 'portal_app.sqlite'));

    return NativeDatabase.createInBackground(file);
  });
}
