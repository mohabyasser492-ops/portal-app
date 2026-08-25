class AuthConfig {
  const AuthConfig({
    required this.tenantId,
    required this.clientId,
    required this.redirectUri,
    required this.apiScope,
  });

  final String tenantId;
  final String clientId;
  final String redirectUri;
  final String apiScope;

  String get authority => 'https://login.microsoftonline.com/$tenantId';

  List<String> get scopes => [apiScope];

  bool get isConfigured =>
      tenantId.trim().isNotEmpty &&
      clientId.trim().isNotEmpty &&
      redirectUri.trim().isNotEmpty &&
      apiScope.trim().isNotEmpty;
}
