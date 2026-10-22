class UserProfile {
  const UserProfile({
    required this.id,
    required this.displayName,
    required this.inviteCode,
    this.photoUrl,
    this.defaultReminderMinutes = 15,
  });

  final String id;
  final String displayName;
  final String? photoUrl;

  /// Short code friends enter to send you a request.
  final String inviteCode;

  /// Minutes before class to remind, unless a class overrides it.
  final int defaultReminderMinutes;
}
