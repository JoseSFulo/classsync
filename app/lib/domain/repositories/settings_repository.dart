abstract interface class SettingsRepository {
  /// Changes the default reminder time. The current value is read from the
  /// profile that [AuthRepository.watchCurrentUser] emits.
  Future<void> setDefaultReminderMinutes(int minutes);
}
