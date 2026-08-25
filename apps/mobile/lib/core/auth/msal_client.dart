class MsalAccountData {
  const MsalAccountData({
    required this.identifier,
    required this.displayName,
    required this.username,
    required this.tenantId,
  });

  final String identifier;
  final String displayName;
  final String username;
  final String tenantId;
}

class MsalTokenData {
  const MsalTokenData({
    required this.accessToken,
    required this.expiresAt,
    required this.account,
  });

  final String accessToken;
  final DateTime expiresAt;
  final MsalAccountData account;
}

abstract interface class MsalClient {
  Future<void> initialize();

  Future<MsalTokenData> acquireTokenInteractively({
    required List<String> scopes,
    required String authority,
  });

  Future<MsalTokenData?> acquireTokenSilently({
    required List<String> scopes,
    required String authority,
  });

  Future<bool> hasCurrentAccount();

  Future<void> signOut();
}
