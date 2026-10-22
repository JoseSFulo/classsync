import 'sharing_level.dart';

class Friend {
  const Friend({
    required this.friendId,
    required this.displayName,
    this.sharingLevel = SharingLevel.busyOnly,
  });

  final String friendId;
  final String displayName;

  /// What YOU allow this friend to see.
  final SharingLevel sharingLevel;
}
