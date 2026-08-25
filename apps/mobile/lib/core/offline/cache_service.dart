import 'dart:convert';

import '../storage/database/app_database.dart';
import 'cache_category.dart';
import 'cache_policy.dart';

class CacheService {
  const CacheService(this._database);

  final AppDatabase _database;

  Future<void> saveJson({
    required String key,
    required CacheCategory category,
    required Map<String, Object?> value,
    required CachePolicy policy,
    DateTime? currentTime,
  }) {
    final now = currentTime ?? DateTime.now().toUtc();

    return _database.saveCacheEntry(
      key: key,
      category: category.name,
      payload: jsonEncode(value),
      cachedAt: now,
      expiresAt: now.add(policy.duration),
      clearOnLogout: policy.clearOnLogout,
    );
  }

  Future<Map<String, Object?>?> readJson(
    String key, {
    DateTime? currentTime,
  }) async {
    final entry = await _database.getValidCacheEntry(
      key,
      currentTime: currentTime,
    );

    if (entry == null) {
      return null;
    }

    final decoded = jsonDecode(entry.payload);

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('The cached value is not a JSON object.');
    }

    return Map<String, Object?>.from(decoded);
  }

  Future<void> remove(String key) {
    return _database.deleteCacheEntry(key);
  }

  Future<int> removeExpired({DateTime? currentTime}) {
    return _database.deleteExpiredCacheEntries(currentTime: currentTime);
  }

  Future<int> clearProtectedData() {
    return _database.clearProtectedCache();
  }
}
