import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/repository_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/schedule_format.dart';
import '../../core/widgets/day_chips.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/pill_chip.dart';
import '../../domain/failures/app_failure.dart';
import '../../domain/models/class_entry.dart';
import '../../logic/class_validation.dart';
import '../auth/auth_providers.dart';
import 'timetable_providers.dart';

/// Add a class, or edit one when [classId] is given.
class ClassFormScreen extends ConsumerWidget {
  const ClassFormScreen({this.classId, super.key});

  final String? classId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classes = ref.watch(myClassesProvider);
    return classes.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(
        appBar: AppBar(),
        body: EmptyState(
          title: 'Couldn’t load your classes',
          message: error is AppFailure ? error.message : 'Please try again.',
        ),
      ),
      data: (list) {
        ClassEntry? initial;
        if (classId != null) {
          initial = list.where((c) => c.id == classId).firstOrNull;
          if (initial == null) {
            return Scaffold(
              appBar: AppBar(),
              body: const EmptyState(
                title: 'Class not found',
                message: 'It may have been deleted.',
              ),
            );
          }
        }
        return _ClassForm(initial: initial, existing: list);
      },
    );
  }
}

class _ClassForm extends ConsumerStatefulWidget {
  const _ClassForm({required this.initial, required this.existing});

  final ClassEntry? initial;
  final List<ClassEntry> existing;

  @override
  ConsumerState<_ClassForm> createState() => _ClassFormState();
}

class _ClassFormState extends ConsumerState<_ClassForm> {
  late final TextEditingController _name;
  late final TextEditingController _room;
  late Set<int> _days;
  late int _start;
  late int _end;
  late int _colorValue;
  int? _reminder; // null means "use the default"
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final c = widget.initial;
    _name = TextEditingController(text: c?.name ?? '');
    _room = TextEditingController(text: c?.room ?? '');
    _days = c == null ? {DateTime.now().weekday} : {...c.days};
    _start = c?.startMinute ?? 540;
    _end = c?.endMinute ?? 600;
    _colorValue = c?.colorValue ?? AppColors.light.classColors.first.toARGB32();
    _reminder = c?.reminderMinutes;
  }

  @override
  void dispose() {
    _name.dispose();
    _room.dispose();
    super.dispose();
  }

  int get _defaultReminder =>
      ref.read(authStateProvider).value?.defaultReminderMinutes ?? 10;

  void _clearError() {
    if (_error != null) setState(() => _error = null);
  }

  Future<void> _pickTime({required bool start}) async {
    final current = start ? _start : _end;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: current ~/ 60 % 24, minute: current % 60),
    );
    if (picked == null || !mounted) return;
    final minutes = picked.hour * 60 + picked.minute;
    setState(() {
      _error = null;
      if (start) {
        // Moving the start keeps the class the same length.
        final length = max(_end - _start, 15);
        _start = minutes;
        _end = min(1440, minutes + length);
      } else {
        _end = minutes;
      }
    });
  }

  Future<void> _save() async {
    final room = _room.text.trim();
    final draft = ClassEntry(
      id: widget.initial?.id ?? '',
      name: _name.text.trim(),
      days: _days.toList()..sort(),
      startMinute: _start,
      endMinute: _end,
      colorValue: _colorValue,
      room: room.isEmpty ? null : room,
      reminderMinutes: _reminder,
      sharedClassId: widget.initial?.sharedClassId,
    );

    final problem = validateClass(
      draft,
      existing: widget.existing,
      defaultReminderMinutes: _defaultReminder,
    );
    if (problem != null) {
      setState(() => _error = problem);
      return;
    }

    final repo = ref.read(classRepositoryProvider);
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      if (widget.initial == null) {
        await repo.addClass(draft);
      } else {
        await repo.updateClass(draft);
      }
      messenger.showSnackBar(const SnackBar(content: Text('Class saved')));
      router.pop();
    } on AppFailure catch (failure) {
      _fail(failure.message);
    } catch (_) {
      _fail('Something went wrong. Please try again.');
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete this class?'),
        content: Text(
          '“${widget.initial!.name}” will be removed from your timetable.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final repo = ref.read(classRepositoryProvider);
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    setState(() => _busy = true);
    try {
      await repo.deleteClass(widget.initial!.id);
      messenger.showSnackBar(const SnackBar(content: Text('Class deleted')));
      router.pop();
    } on AppFailure catch (failure) {
      _fail(failure.message);
    } catch (_) {
      _fail('Something went wrong. Please try again.');
    }
  }

  void _fail(String message) {
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = message;
    });
  }

  String _minutesLabel(int minutes) =>
      minutes == 60 ? '1 hour' : '$minutes min';

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.l, bottom: AppSpacing.s),
      child: Text(text, style: Theme.of(context).textTheme.bodySmall),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final editing = widget.initial != null;
    final defaultMinutes =
        ref.watch(authStateProvider).value?.defaultReminderMinutes ?? 10;
    final lead = _reminder ?? defaultMinutes;

    return Scaffold(
      appBar: AppBar(
        title: Text(editing ? 'Edit class' : 'New class'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Close',
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('Class or event'),
              TextField(
                controller: _name,
                textCapitalization: TextCapitalization.sentences,
                maxLength: 60,
                decoration: const InputDecoration(
                  hintText: 'e.g. Calculus II',
                  counterText: '',
                ),
                onChanged: (_) => _clearError(),
              ),
              _label('Room'),
              TextField(
                controller: _room,
                textCapitalization: TextCapitalization.sentences,
                maxLength: 60,
                decoration: const InputDecoration(
                  hintText: 'Optional',
                  counterText: '',
                ),
              ),
              _label('Repeats on'),
              DayChips(
                isSelected: _days.contains,
                onTap: (d) => setState(() {
                  _error = null;
                  _days.contains(d) ? _days.remove(d) : _days.add(d);
                }),
              ),
              _label('Time'),
              Row(
                children: [
                  Expanded(
                    child: _TimeButton(
                      label: 'Starts',
                      minutes: _start,
                      onTap: () => _pickTime(start: true),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.m),
                  Expanded(
                    child: _TimeButton(
                      label: 'Ends',
                      minutes: _end,
                      onTap: () => _pickTime(start: false),
                    ),
                  ),
                ],
              ),
              _label('Color'),
              Row(
                children: [
                  for (final color in AppColors.light.classColors)
                    Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.m),
                      child: Semantics(
                        button: true,
                        selected: color.toARGB32() == _colorValue,
                        label: 'Class color',
                        child: InkResponse(
                          radius: 24,
                          onTap: () =>
                              setState(() => _colorValue = color.toARGB32()),
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                width: 3,
                                color: color.toARGB32() == _colorValue
                                    ? theme.colorScheme.onSurface
                                    : Colors.transparent,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              _label('Remind me before start'),
              Wrap(
                spacing: AppSpacing.s,
                runSpacing: AppSpacing.s,
                children: [
                  PillChip(
                    label: 'Default (${_minutesLabel(defaultMinutes)})',
                    selected: _reminder == null,
                    onTap: () => setState(() {
                      _error = null;
                      _reminder = null;
                    }),
                  ),
                  for (final option in const [10, 30, 60])
                    if (option != defaultMinutes)
                      PillChip(
                        label: _minutesLabel(option),
                        selected: _reminder == option,
                        onTap: () => setState(() {
                          _error = null;
                          _reminder = option;
                        }),
                      ),
                ],
              ),
              const SizedBox(height: AppSpacing.s),
              Text(
                'Reminder at ${formatMinutes(max(0, _start - lead))}',
                style: theme.textTheme.bodySmall,
              ),
              if (_error != null) ...[
                const SizedBox(height: AppSpacing.m),
                Text(
                  _error!,
                  style: TextStyle(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              FilledButton(
                onPressed: _busy ? null : _save,
                child: _busy
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save class'),
              ),
              if (editing)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.s),
                  child: TextButton(
                    onPressed: _busy ? null : _delete,
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: const Text('Delete class'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimeButton extends StatelessWidget {
  const _TimeButton({
    required this.label,
    required this.minutes,
    required this.onTap,
  });

  final String label;
  final int minutes;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Text(formatMinutes(minutes)),
      ),
    );
  }
}
