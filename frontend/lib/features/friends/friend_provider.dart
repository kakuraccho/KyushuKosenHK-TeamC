import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'friend_model.dart';
import 'friend_repository.dart';

final pendingRequestsProvider =
    AsyncNotifierProvider<PendingRequestsNotifier, List<FriendRequest>>(
  PendingRequestsNotifier.new,
);

class PendingRequestsNotifier extends AsyncNotifier<List<FriendRequest>> {
  @override
  FutureOr<List<FriendRequest>> build() async {
    return ref.read(friendRepositoryProvider).fetchPendingRequests();
  }

  Future<void> respond(String id, {required bool accept}) async {
    await ref
        .read(friendRepositoryProvider)
        .respondToRequest(id, accept: accept);
    final current = state.valueOrNull ?? [];
    state = AsyncValue.data(current.where((r) => r.id != id).toList());
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(friendRepositoryProvider).fetchPendingRequests(),
    );
  }
}

final friendsProvider =
    AsyncNotifierProvider<FriendsNotifier, List<FriendRequest>>(
  FriendsNotifier.new,
);

class FriendsNotifier extends AsyncNotifier<List<FriendRequest>> {
  @override
  FutureOr<List<FriendRequest>> build() async {
    return ref.read(friendRepositoryProvider).fetchFriends();
  }

  Future<void> sendRequest(String followingId) async {
    await ref.read(friendRepositoryProvider).sendRequest(followingId);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(friendRepositoryProvider).fetchFriends(),
    );
  }
}
