import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/repository_providers.dart';
import '../../domain/models/friend.dart';
import '../../domain/models/friend_request.dart';

final friendsProvider = StreamProvider<List<Friend>>((ref) {
  return ref.watch(friendRepositoryProvider).watchFriends();
});

final incomingRequestsProvider = StreamProvider<List<FriendRequest>>((ref) {
  return ref.watch(friendRepositoryProvider).watchIncomingRequests();
});
