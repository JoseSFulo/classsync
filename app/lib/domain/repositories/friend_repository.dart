import '../models/friend.dart';
import '../models/friend_request.dart';
import '../models/sharing_level.dart';

abstract interface class FriendRepository {
  Stream<List<Friend>> watchFriends();

  /// Requests sent to me that are still pending.
  Stream<List<FriendRequest>> watchIncomingRequests();

  /// Sends a request using the other person's invite code.
  /// Throws [NotFound] for a wrong code, [AlreadyExists] for a duplicate
  /// request or an existing friend.
  Future<void> sendRequestByCode(String inviteCode);

  Future<void> acceptRequest(String requestId);

  Future<void> declineRequest(String requestId);

  Future<void> removeFriend(String friendId);

  /// Changes what this friend may see of MY schedule.
  Future<void> setSharingLevel(String friendId, SharingLevel level);
}
