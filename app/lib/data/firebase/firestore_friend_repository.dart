import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/friend.dart';
import '../../domain/models/friend_request.dart';
import '../../domain/models/sharing_level.dart';
import '../../domain/repositories/friend_repository.dart';

/// Live implementation of [FriendRepository] backed by Firebase Firestore.
class FirestoreFriendRepository implements FriendRepository {
  FirestoreFriendRepository(this._firestore, this._userId);

  final FirebaseFirestore _firestore;
  final String _userId;

  CollectionReference get _friendsRef =>
      _firestore.collection('users').doc(_userId).collection('friends');

  CollectionReference get _requestsRef =>
      _firestore.collection('users').doc(_userId).collection('friend_requests');

  @override
  Stream<List<Friend>> watchFriends() {
    return _friendsRef.snapshots().map((snap) {
      return snap.docs.map<Friend>((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final levelStr = data['sharingLevel'] as String? ?? 'busyOnly';
        return Friend(
          friendId: doc.id,
          displayName: (data['displayName'] as String?) ?? 'Friend',
          sharingLevel: levelStr == 'full'
              ? SharingLevel.full
              : SharingLevel.busyOnly,
        );
      }).toList();
    });
  }

  @override
  Stream<List<FriendRequest>> watchIncomingRequests() {
    return _requestsRef.snapshots().map((snap) {
      return snap.docs.map<FriendRequest>((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return FriendRequest(
          id: doc.id,
          fromId: (data['fromUserId'] as String?) ?? '',
          fromName: (data['fromName'] as String?) ?? 'Student',
        );
      }).toList();
    });
  }

  @override
  Future<void> sendRequestByCode(String code) async {
    final query = await _firestore
        .collection('users')
        .where('inviteCode', isEqualTo: code)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      throw Exception('Invalid invite code. No user found.');
    }

    final targetUserId = query.docs.first.id;

    if (targetUserId == _userId) {
      throw Exception('You cannot add yourself as a friend.');
    }

    final myDoc = await _firestore.collection('users').doc(_userId).get();
    final myData = myDoc.data() ?? {};
    final myName = (myData['displayName'] as String?) ?? 'Student';

    await _firestore
        .collection('users')
        .doc(targetUserId)
        .collection('friend_requests')
        .doc(_userId)
        .set({
          'fromUserId': _userId,
          'fromName': myName,
          'createdAt': FieldValue.serverTimestamp(),
        });
  }

  @override
  Future<void> acceptRequest(String requestId) async {
    final reqDoc = await _requestsRef.doc(requestId).get();
    if (!reqDoc.exists) return;

    final data = reqDoc.data() as Map<String, dynamic>;
    final friendId = (data['fromUserId'] as String?) ?? requestId;
    final friendName = (data['fromName'] as String?) ?? 'Friend';

    final myDoc = await _firestore.collection('users').doc(_userId).get();
    final myData = myDoc.data() ?? {};
    final myName = (myData['displayName'] as String?) ?? 'Student';

    final batch = _firestore.batch();

    batch.set(_friendsRef.doc(friendId), {
      'displayName': friendName,
      'sharingLevel': 'busyOnly',
    });

    batch.set(
      _firestore
          .collection('users')
          .doc(friendId)
          .collection('friends')
          .doc(_userId),
      {'displayName': myName, 'sharingLevel': 'busyOnly'},
    );

    batch.delete(_requestsRef.doc(requestId));

    await batch.commit();
  }

  @override
  Future<void> declineRequest(String requestId) async {
    await _requestsRef.doc(requestId).delete();
  }

  @override
  Future<void> setSharingLevel(String friendId, SharingLevel level) async {
    await _friendsRef.doc(friendId).update({
      'sharingLevel': level == SharingLevel.full ? 'full' : 'busyOnly',
    });
  }

  @override
  Future<void> removeFriend(String friendId) async {
    final batch = _firestore.batch();

    batch.delete(_friendsRef.doc(friendId));

    batch.delete(
      _firestore
          .collection('users')
          .doc(friendId)
          .collection('friends')
          .doc(_userId),
    );

    await batch.commit();
  }
}
