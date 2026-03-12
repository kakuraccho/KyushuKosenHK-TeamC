import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../features/friends/friend_model.dart';
import '../features/friends/friend_provider.dart';

class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _userIdController = TextEditingController();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _userIdController.dispose();
    super.dispose();
  }

  Future<void> _sendRequest() async {
    final id = _userIdController.text.trim();
    if (id.isEmpty) return;
    setState(() => _isSending = true);
    try {
      await ref.read(friendsProvider.notifier).sendRequest(id);
      if (!mounted) return;
      _userIdController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Friend request sent')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send request')),
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        foregroundColor: AppColors.onSurface,
        title: const Text('Friends',
            style: TextStyle(color: AppColors.onSurface)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.secondary,
          unselectedLabelColor: AppColors.onSurfaceVariant,
          indicatorColor: AppColors.secondary,
          tabs: const [
            Tab(text: 'Requests'),
            Tab(text: 'Friends'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const _RequestsTab(),
          _FriendsTab(
            userIdController: _userIdController,
            isSending: _isSending,
            onSend: _sendRequest,
          ),
        ],
      ),
    );
  }
}

// ── Requests tab ──────────────────────────────────────────

class _RequestsTab extends ConsumerWidget {
  const _RequestsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(pendingRequestsProvider);

    return requestsAsync.when(
      loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.secondary)),
      error: (e, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Failed to load',
                style: TextStyle(color: AppColors.onSurface)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () =>
                  ref.read(pendingRequestsProvider.notifier).refresh(),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryContainer,
                  foregroundColor: AppColors.onSurface),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (requests) {
        if (requests.isEmpty) {
          return const Center(
            child: Text('No pending requests',
                style: TextStyle(color: AppColors.onSurfaceVariant)),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) =>
              _RequestTile(request: requests[index]),
        );
      },
    );
  }
}

class _RequestTile extends ConsumerWidget {
  const _RequestTile({required this.request});
  final FriendRequest request;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.person, color: AppColors.secondary, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              request.followerId,
              overflow: TextOverflow.ellipsis,
              style:
                  const TextStyle(color: AppColors.onSurface, fontSize: 13),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.check, color: Colors.greenAccent),
            onPressed: () => ref
                .read(pendingRequestsProvider.notifier)
                .respond(request.id, accept: true),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.redAccent),
            onPressed: () => ref
                .read(pendingRequestsProvider.notifier)
                .respond(request.id, accept: false),
          ),
        ],
      ),
    );
  }
}

// ── Friends tab ──────────────────────────────────────────

class _FriendsTab extends ConsumerWidget {
  const _FriendsTab({
    required this.userIdController,
    required this.isSending,
    required this.onSend,
  });

  final TextEditingController userIdController;
  final bool isSending;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friendsAsync = ref.watch(friendsProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: userIdController,
                  style: const TextStyle(color: AppColors.onSurface),
                  decoration: InputDecoration(
                    hintText: 'User ID (UUID)',
                    hintStyle: TextStyle(
                        color:
                            AppColors.onSurfaceVariant.withValues(alpha: 0.6)),
                    filled: true,
                    fillColor: AppColors.surfaceContainer,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: isSending ? null : onSend,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryContainer,
                  foregroundColor: AppColors.onSurface,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: isSending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.onSurface))
                    : const Text('Add'),
              ),
            ],
          ),
        ),
        Expanded(
          child: friendsAsync.when(
            loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.secondary)),
            error: (e, _) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Failed to load',
                      style: TextStyle(color: AppColors.onSurface)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () =>
                        ref.read(friendsProvider.notifier).refresh(),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondaryContainer,
                        foregroundColor: AppColors.onSurface),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
            data: (friends) {
              if (friends.isEmpty) {
                return const Center(
                  child: Text('No friends yet',
                      style: TextStyle(color: AppColors.onSurfaceVariant)),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: friends.length,
                itemBuilder: (context, index) =>
                    _FriendTile(friend: friends[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FriendTile extends StatelessWidget {
  const _FriendTile({required this.friend});
  final FriendRequest friend;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.person, color: AppColors.secondary, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              friend.followingId,
              overflow: TextOverflow.ellipsis,
              style:
                  const TextStyle(color: AppColors.onSurface, fontSize: 13),
            ),
          ),
          const Icon(Icons.check_circle, color: Colors.greenAccent, size: 18),
        ],
      ),
    );
  }
}
