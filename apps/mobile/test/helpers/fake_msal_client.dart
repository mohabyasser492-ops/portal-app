import 'package:portal_app/core/auth/msal_client.dart';

class FakeMsalClient implements MsalClient {
  MsalTokenData? interactiveResult;
  MsalTokenData? silentResult;

  Object? initializeError;
  Object? interactiveError;
  Object? silentError;
  Object? accountError;
  Object? signOutError;

  bool initialized = false;
  bool signedOut = false;
  bool currentAccountExists = false;

  @override
  Future<void> initialize() async {
    final error = initializeError;

    if (error != null) {
      throw error;
    }

    initialized = true;
  }

  @override
  Future<MsalTokenData> acquireTokenInteractively({
    required List<String> scopes,
    required String authority,
  }) async {
    final error = interactiveError;

    if (error != null) {
      throw error;
    }

    final result = interactiveResult;

    if (result == null) {
      throw StateError('A synthetic interactive result must be configured.');
    }

    return result;
  }

  @override
  Future<MsalTokenData?> acquireTokenSilently({
    required List<String> scopes,
    required String authority,
  }) async {
    final error = silentError;

    if (error != null) {
      throw error;
    }

    return silentResult;
  }

  @override
  Future<bool> hasCurrentAccount() async {
    final error = accountError;

    if (error != null) {
      throw error;
    }

    return currentAccountExists;
  }

  @override
  Future<void> signOut() async {
    final error = signOutError;

    if (error != null) {
      throw error;
    }

    signedOut = true;
    currentAccountExists = false;
  }
}
