import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/repository_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../domain/models/friend.dart';
import '../../domain/models/friend_request.dart';
import '../../domain/models/sharing_level.dart';
import '../auth/auth_providers.dart';
import 'friend_schedule_screen.dart';

class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen> {
  final _codeController = TextEditingController();
  bool _isSending = false;
  String? _error;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _sendRequest() async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.isEmpty) return;

    setState(() {
      _isSending = true;
      _error = null;
    });

    try {
      await ref.read(friendRepositoryProvider).sendRequestByCode(code);
      _codeController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Friend added!')),
        );
      }
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = context.appColors;
    final user = ref.watch(authStateProvider).value;

    final friendsAsync = ref.watch(
      StreamProvider<List<Friend>>((ref) => ref.watch(friendRepositoryProvider).watchFriends()),
    );
    final requestsAsync = ref.watch(
      StreamProvider<List<FriendRequest>>((ref) => ref.watch(friendRepositoryProvider).watchIncomingRequests()),
    );

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Friends', style: theme.textTheme.headlineMedium),
              const SizedBox(height: AppSpacing.l),

              // Your Invite Code Card
              Container(
                padding: const EdgeInsets.all(AppSpacing.l),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  border: Border.all(color: appColors.line),
                  borderRadius: BorderRadius.circular(AppRadius.card),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Your invite code', style: theme.textTheme.bodySmall),
                          Text(
                            user?.inviteCode ?? 'CODE12',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: user?.inviteCode ?? ''));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Code copied to clipboard!')),
                        );
                      },
                      child: const Text('Copy'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Add Friend Input
              Text('Add a friend', style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.s),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _codeController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        hintText: 'Enter a code',
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.m),
                  FilledButton(
                    onPressed: _isSending ? null : _sendRequest,
                    child: _isSending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Add'),
                  ),
                ],
              ),
              if (_error != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
              ],
              const SizedBox(height: AppSpacing.xl),

              // Requests Section
              requestsAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (err, stack) => const SizedBox.shrink(),
                data: (requests) {
                  if (requests.isEmpty) return const SizedBox.shrink();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Requests', style: theme.textTheme.titleMedium),
                      const SizedBox(height: AppSpacing.m),
                      for (final req in requests)
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.m),
                          margin: const EdgeInsets.only(bottom: AppSpacing.s),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            border: Border.all(color: appColors.line),
                            borderRadius: BorderRadius.circular(AppRadius.card),
                          ),
                          child: Row(
                            children: [
                              Expanded(child: Text(req.fromName, style: theme.textTheme.titleMedium)),
                              FilledButton(
                                onPressed: () => ref.read(friendRepositoryProvider).acceptRequest(req.id),
                                child: const Text('Accept'),
                              ),
                              const SizedBox(width: AppSpacing.s),
                              OutlinedButton(
                                onPressed: () => ref.read(friendRepositoryProvider).declineRequest(req.id),
                                child: const Text('Decline'),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                  );
                },
              ),

              // Your Friends List
              Text('Your friends', style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.m),
              friendsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Text('Error: $err'),
                data: (friends) {
                  if (friends.isEmpty) {
                    return Text('No friends added yet.', style: theme.textTheme.bodySmall);
                  }
                  return Column(
                    children: [
                      for (final friend in friends)
                        Card(
                          margin: const EdgeInsets.only(bottom: AppSpacing.m),
                          child: ListTile(
                            title: Text(friend.displayName),
                            subtitle: Text(
                              friend.sharingLevel == SharingLevel.full
                                  ? 'Sees your class names'
                                  : 'Sees busy or free only',
                            ),
                            trailing: TextButton(
                              onPressed: () {
                                final nextLevel = friend.sharingLevel == SharingLevel.full
                                    ? SharingLevel.busyOnly
                                    : SharingLevel.full;
                                ref.read(friendRepositoryProvider).setSharingLevel(friend.friendId, nextLevel);
                              },
                              child: Text(
                                friend.sharingLevel == SharingLevel.full ? 'Names on' : 'Names off',
                              ),
                            ),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => FriendScheduleScreen(friend: friend),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}