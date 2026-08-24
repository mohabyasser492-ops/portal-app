class AuthenticatedUser {
  const AuthenticatedUser({
    required this.accountId,
    required this.displayName,
    required this.username,
    required this.tenantId,
  });

  final String accountId;
  final String displayName;
  final String username;
  final String tenantId;
}
