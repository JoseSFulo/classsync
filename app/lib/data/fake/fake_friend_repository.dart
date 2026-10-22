import '../../domain/failures/app_failure.dart';
import '../../domain/models/friend.dart';
import '../../domain/models/friend_request.dart';
import '../../domain/models/sharing_level.dart';
import '../../domain/repositories/friend_repository.dart';
import 'fake_store.dart';

class FakeFriendRepository implements FriendRepository {
  final _friends = FakeStore<List<Friend>>(const <Friend>[
    Friend(friendId: 'friend-1', displayName: 'Alex Santos'),
  ]);

  final _requests = FakeStore<List<FriendRequest>>(const <FriendRequest>[
    FriendRequest(id: 'req-1', fromId: 'friend-2', fromName: 'Sam Reyes'),
  ]);

  @override
  Stream<List<Friend>> watchFriends() => _friends.watch();

  @override
  Stream<List<FriendRequest>> watchIncomingRequests() => _requests.watch();

  @override
  Future<void> sendRequestByCode(String inviteCode) async {
    if (inviteCode != 'DEMO') throw const NotFound('No user has that code.');
    if (_friends.value.any((f) => f.friendId == 'friend-demo')) {
      throw const AlreadyExists('You are already friends.');
    }
    _friends.value = [
      ..._friends.value,
      const Friend(friendId: 'friend-demo', displayName: 'Demo Friend'),
    ];
  }

  @override
  Future<void> acceptRequest(String requestId) async {
    final request = _requests.value.firstWhere(
      (r) => r.id == requestId,
      orElse: () => throw const NotFound('Request not found.'),
    );
    _friends.value = [
      ..._friends.value,
      Friend(friendId: request.fromId, displayName: request.fromName),
    ];
    await declineRequest(requestId);
  }

  @override
  Future<void> declineRequest(String requestId) async {
    _requests.value = [
      for (final r in _requests.value)
        if (r.id != requestId) r,
    ];
  }

  @override
  Future<void> removeFriend(String friendId) async {
    _friends.value = [
      for (final f in _friends.value)
        if (f.friendId != friendId) f,
    ];
  }

  @override
  Future<void> setSharingLevel(String friendId, SharingLevel level) async {
    _friends.value = [
      for (final f in _friends.value)
        if (f.friendId == friendId)
          Friend(
            friendId: f.friendId,
            displayName: f.displayName,
            sharingLevel: level,
          )
        else
          f,
    ];
  }
}
