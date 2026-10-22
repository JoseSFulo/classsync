enum FriendRequestStatus { pending, accepted, declined }

class FriendRequest {
  const FriendRequest({
    required this.id,
    required this.fromId,
    required this.fromName,
    this.status = FriendRequestStatus.pending,
  });

  final String id;
  final String fromId;
  final String fromName;
  final FriendRequestStatus status;
}
