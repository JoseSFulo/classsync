import 'package:classsync/data/fake/fake_friend_repository.dart';
import 'package:classsync/domain/failures/app_failure.dart';
import 'package:classsync/domain/models/sharing_level.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a wrong code is rejected', () async {
    final repo = FakeFriendRepository();

    await expectLater(
      repo.sendRequestByCode('NOPE-0000'),
      throwsA(isA<NotFound>()),
    );
  });

  test('sending the same request twice is rejected', () async {
    final repo = FakeFriendRepository();

    await repo.sendRequestByCode('noah-2048');
    await expectLater(
      repo.sendRequestByCode('NOAH-2048'),
      throwsA(isA<AlreadyExists>()),
    );
  });

  test('accepting a request adds a friend and clears the request', () async {
    final repo = FakeFriendRepository();

    await repo.acceptRequest('req-1');

    final friends = await repo.watchFriends().first;
    final requests = await repo.watchIncomingRequests().first;
    expect(friends.any((f) => f.displayName == 'Sam Reyes'), isTrue);
    expect(requests, isEmpty);
  });

  test('changing the sharing level affects only that friend', () async {
    final repo = FakeFriendRepository();

    await repo.setSharingLevel('friend-ana', SharingLevel.full);

    final friends = await repo.watchFriends().first;
    final levels = {for (final f in friends) f.friendId: f.sharingLevel};
    expect(levels['friend-ana'], SharingLevel.full);
    expect(levels['friend-ben'], SharingLevel.busyOnly);
  });
}
