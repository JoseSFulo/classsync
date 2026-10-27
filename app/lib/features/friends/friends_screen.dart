import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/repository_providers.dart';
import '../../core/router/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/initials_avatar.dart';
import '../../core/widgets/pill_chip.dart';
import '../../domain/failures/app_failure.dart';
import '../../domain/models/friend.dart';
import '../../domain/models/friend_request.dart';
import '../../domain/models/sharing_level.dart';
import '../auth/auth_providers.dart';
import 'friends_providers.dart';

class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen> {
  final _code = TextEditingController();
  final _busy = <String>{};
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  /// Runs [action]. Returns a message if it failed, or null if it worked.
  Future<String?> _attempt(Future<void> Function() action) async {
    try {
      await action();
      return null;
    } on AppFailure catch (failure) {
      return failure.message;
    } catch (_) {
      return 'Something went wrong. Please try again.';
    }
  }

  /// Runs one action at a time per [key], then shows its result.
  Future<void> _act(
    String key,
    Future<void> Function() action, {
    String? success,
  }) async {
    if (_busy.contains(key)) {
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy.add(key));
    final failure = await _attempt(action);
    if (!mounted) {
      return;
    }
    setState(() => _busy.remove(key));
    final message = failure ?? success;
    if (message != null) {
      messenger.showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _copy(String code) async {
    final messenger = ScaffoldMessenger.of(context);
    await Clipboard.setData(ClipboardData(text: code));
    messenger.showSnackBar(const SnackBar(content: Text('Code copied')));
  }

  Future<void> _sendRequest(String? ownCode) async {
    final code = _code.text.trim().toUpperCase();
    if (code.isEmpty) {
      setState(() => _error = 'Enter your friend’s code.');
      return;
    }
    if (code == ownCode?.toUpperCase()) {
      setState(() => _error = 'That’s your own code.');
      return;
    }

    final repo = ref.read(friendRepositoryProvider);
    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _sending = true;
      _error = null;
    });
    final failure = await _attempt(() => repo.sendRequestByCode(code));
    if (!mounted) {
      return;
    }
    setState(() {
      _sending = false;
      _error = failure;
    });
    if (failure == null) {
      _code.clear();
      messenger.showSnackBar(const SnackBar(content: Text('Request sent')));
    }
  }

  Future<void> _togglePrivacy(Friend friend) async {
    final turningOn = friend.sharingLevel == SharingLevel.busyOnly;
    final first = friend.displayName.split(' ').first;

    if (turningOn) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text('Show class names to ${friend.displayName}?'),
          content: Text(
            '$first will see the name, room, and time of every class in '
            'your timetable. You can turn this off any time.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Show names'),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) {
        return;
      }
    }

    final repo = ref.read(friendRepositoryProvider);
    await _act(
      'privacy-${friend.friendId}',
      () => repo.setSharingLevel(
        friend.friendId,
        turningOn ? SharingLevel.full : SharingLevel.busyOnly,
      ),
      success: turningOn
          ? '$first can now see your class names'
          : '$first now sees busy or free only',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ownCode = ref.watch(authStateProvider).value?.inviteCode;
    final friends = ref.watch(friendsProvider);
    final requests =
        ref.watch(incomingRequestsProvider).value ?? const <FriendRequest>[];
    final repo = ref.read(friendRepositoryProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Friends', style: theme.textTheme.headlineMedium),
              const SizedBox(height: AppSpacing.l),
              if (ownCode != null)
                _InviteCard(code: ownCode, onCopy: () => _copy(ownCode)),
              const SizedBox(height: AppSpacing.l),
              Text('Add a friend', style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.s),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _code,
                      textCapitalization: TextCapitalization.characters,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        hintText: 'Enter a code',
                      ),
                      onChanged: (_) {
                        if (_error != null) {
                          setState(() => _error = null);
                        }
                      },
                      onSubmitted: (_) => _sendRequest(ownCode),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(80, 52),
                    ),
                    onPressed: _sending ? null : () => _sendRequest(ownCode),
                    child: _sending
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Add'),
                  ),
                ],
              ),
              if (_error != null) ...[
                const SizedBox(height: AppSpacing.s),
                Text(
                  _error!,
                  style: TextStyle(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
              if (requests.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xl),
                Text('Requests', style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.s),
                for (final request in requests)
                  _RequestCard(
                    request: request,
                    busy: _busy.contains('request-${request.id}'),
                    onAccept: () => _act(
                      'request-${request.id}',
                      () => repo.acceptRequest(request.id),
                      success:
                          'You and ${request.fromName.split(' ').first} '
                          'are friends',
                    ),
                    onDecline: () => _act(
                      'request-${request.id}',
                      () => repo.declineRequest(request.id),
                    ),
                  ),
              ],
              const SizedBox(height: AppSpacing.xl),
              Text('Your friends', style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.s),
              friends.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(AppSpacing.l),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, _) => EmptyState(
                  title: 'Couldn’t load your friends',
                  message: error is AppFailure
                      ? error.message
                      : 'Please try again.',
                ),
                data: (list) => list.isEmpty
                    ? const EmptyState(
                        title: 'No friends yet',
                        message:
                            'Share your invite code, or enter a '
                            'friend’s code above.',
                      )
                    : Column(
                        children: [
                          for (final friend in list)
                            _FriendCard(
                              friend: friend,
                              busy: _busy.contains(
                                'privacy-${friend.friendId}',
                              ),
                              onView: () => context.push(
                                AppRoutes.friendScheduleFor(friend.friendId),
                              ),
                              onTogglePrivacy: () => _togglePrivacy(friend),
                            ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InviteCard extends StatelessWidget {
  const _InviteCard({required this.code, required this.onCopy});

  final String code;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(color: context.appColors.line),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your invite code', style: theme.textTheme.bodySmall),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Expanded(
                child: Text(
                  code,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    letterSpacing: 1,
                  ),
                ),
              ),
              PillChip(label: 'Copy', selected: false, onTap: onCopy),
            ],
          ),
        ],
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({
    required this.request,
    required this.busy,
    required this.onAccept,
    required this.onDecline,
  });

  final FriendRequest request;
  final bool busy;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.m),
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(color: context.appColors.line),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Row(
        children: [
          InitialsAvatar(name: request.fromName),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Text(request.fromName, style: theme.textTheme.titleMedium),
          ),
          PillChip(
            label: 'Accept',
            selected: true,
            onTap: busy ? () {} : onAccept,
          ),
          const SizedBox(width: AppSpacing.s),
          PillChip(
            label: 'Decline',
            selected: false,
            onTap: busy ? () {} : onDecline,
          ),
        ],
      ),
    );
  }
}

class _FriendCard extends StatelessWidget {
  const _FriendCard({
    required this.friend,
    required this.busy,
    required this.onView,
    required this.onTogglePrivacy,
  });

  final Friend friend;
  final bool busy;
  final VoidCallback onView;
  final VoidCallback onTogglePrivacy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final namesOn = friend.sharingLevel == SharingLevel.full;
    final first = friend.displayName.split(' ').first;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.m),
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(color: context.appColors.line),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        children: [
          Row(
            children: [
              InitialsAvatar(name: friend.displayName),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Text(
                  friend.displayName,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              TextButton(onPressed: onView, child: const Text('View ›')),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          Row(
            children: [
              Expanded(
                child: Text(
                  namesOn ? 'Sees your class names' : 'Sees busy or free only',
                  style: theme.textTheme.bodySmall,
                ),
              ),
              PillChip(
                label: namesOn ? 'Names on' : 'Names off',
                semanticLabel:
                    'Class names ${namesOn ? 'on' : 'off'} for $first',
                selected: namesOn,
                onTap: busy ? () {} : onTogglePrivacy,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
