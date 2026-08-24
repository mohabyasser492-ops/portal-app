class CachePolicy {
  const CachePolicy({required this.duration, this.clearOnLogout = true});

  final Duration duration;
  final bool clearOnLogout;

  static const employeeSummary = CachePolicy(duration: Duration(minutes: 30));

  static const announcements = CachePolicy(
    duration: Duration(hours: 2),
    clearOnLogout: false,
  );

  static const serviceCatalog = CachePolicy(
    duration: Duration(hours: 12),
    clearOnLogout: false,
  );

  static const requestSummaries = CachePolicy(duration: Duration(minutes: 15));

  static const leaveBalances = CachePolicy(duration: Duration(minutes: 15));
}
