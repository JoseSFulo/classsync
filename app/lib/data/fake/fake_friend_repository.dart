import '../../domain/failures/app_failure.dart';
import '../../domain/models/friend.dart';
import '../../domain/models/friend_request.dart';
import '../../domain/models/sharing_level.dart';
import '../../domain/repositories/friend_repository.dart';
import 'fake_store.dart';

class FakeFriendRepository implements FriendRepository {
  // Sharing level is what YOU let each friend see. Maya may see class names.
  final _friends = FakeStore<List<Friend>>(const <Friend>[
    Friend(
      friendId: 'friend-maya',
      displayName: 'Maya Reyes',
      sharingLevel: SharingLevel.full,
    ),
    Friend(friendId: 'friend-ana', displayName: 'Ana Ramos'),
    Friend(friendId: 'friend-ben', displayName: 'Ben Tan'),
  ]);

  final _requests = FakeStore<List<FriendRequest>>(const <FriendRequest>[
    FriendRequest(id: 'req-1', fromId: 'friend-sam', fromName: 'Sam Reyes'),
  ]);

  final _sentTo = <String>{};

  @override
  Stream<List<Friend>> watchFriends() => _friends.watch();

  @override
  Stream<List<FriendRequest>> watchIncomingRequests() => _requests.watch();

  /// The only code this fake accepts is NOAH-2048.
  @override
  Future<void> sendRequestByCode(String inviteCode) async {
    final code = inviteCode.toUpperCase();
    if (code != 'NOAH-2048') {
      throw const NotFound('No one has that code. Check it and try again.');
    }
    if (!_sentTo.add(code)) {
      throw const AlreadyExists('You already sent Noah a request.');
    }
  }

  @override
  Future<void> acceptRequest(String requestId) async {
    final request = _requests.value.where((r) => r.id == requestId).firstOrNull;
    if (request == null) {
      throw const NotFound('Request not found.');
    }
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
