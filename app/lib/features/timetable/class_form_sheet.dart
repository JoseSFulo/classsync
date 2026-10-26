import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/repository_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/schedule_format.dart';
import '../../domain/models/class_entry.dart';
import 'timetable_providers.dart';

class ClassFormSheet extends ConsumerStatefulWidget {
  const ClassFormSheet({this.initialEntry, super.key});

  final ClassEntry? initialEntry;

  static Future<void> show(BuildContext context, {ClassEntry? entry}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ClassFormSheet(initialEntry: entry),
    );
  }

  @override
  ConsumerState<ClassFormSheet> createState() => _ClassFormSheetState();
}

class _ClassFormSheetState extends ConsumerState<ClassFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _roomController;

  late Set<int> _selectedDays;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late int _selectedColor;
  int? _reminderMinutes;

  String? _overlapError;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final entry = widget.initialEntry;

    _nameController = TextEditingController(text: entry?.name ?? '');
    _roomController = TextEditingController(text: entry?.room ?? '');
    _selectedDays = Set.from(entry?.days ?? [DateTime.now().weekday]);

    final startMins = entry?.startMinute ?? 540; // 9:00 AM
    final endMins = entry?.endMinute ?? 600;    // 10:00 AM

    _startTime = TimeOfDay(hour: startMins ~/ 60, minute: startMins % 60);
    _endTime = TimeOfDay(hour: endMins ~/ 60, minute: endMins % 60);
    _selectedColor = entry?.colorValue ?? 0xFF2E7D6B;
    _reminderMinutes = entry?.reminderMinutes;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _roomController.dispose();
    super.dispose();
  }

  int _toMinutes(TimeOfDay time) => time.hour * 60 + time.minute;

  bool _checkOverlap(List<ClassEntry> existingClasses) {
    final startM = _toMinutes(_startTime);
    final endM = _toMinutes(_endTime);

    for (final existing in existingClasses) {
      if (widget.initialEntry != null && existing.id == widget.initialEntry!.id) {
        continue; // Ignore current class when editing
      }

      // Check for overlapping weekdays
      final sharedDays = existing.days.toSet().intersection(_selectedDays);
      if (sharedDays.isNotEmpty) {
        // Check for overlapping time bounds
        if (startM < existing.endMinute && endM > existing.startMinute) {
          setState(() {
            _overlapError = 'This overlaps with ${existing.name}.';
          });
          return true;
        }
      }
    }
    return false;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDays.isEmpty) {
      setState(() => _overlapError = 'Please select at least one day.');
      return;
    }

    final startM = _toMinutes(_startTime);
    final endM = _toMinutes(_endTime);

    if (endM <= startM) {
      setState(() => _overlapError = 'End time must be after start time.');
      return;
    }

    final existingClasses = ref.read(myClassesProvider).value ?? [];
    if (_checkOverlap(existingClasses)) return;

    setState(() {
      _overlapError = null;
      _isSaving = true;
    });

    final repo = ref.read(classRepositoryProvider);
    final draft = ClassEntry(
      id: widget.initialEntry?.id ?? '',
      name: _nameController.text.trim(),
      days: _selectedDays.toList()..sort(),
      startMinute: startM,
      endMinute: endM,
      colorValue: _selectedColor,
      room: _roomController.text.trim(),
      reminderMinutes: _reminderMinutes,
    );

    try {
      if (widget.initialEntry == null) {
        await repo.addClass(draft);
      } else {
        await repo.updateClass(draft);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _overlapError = 'Failed to save class. Please try again.';
        });
      }
    }
  }

  Future<void> _delete() async {
    if (widget.initialEntry == null) return;
    setState(() => _isSaving = true);
    await ref.read(classRepositoryProvider).deleteClass(widget.initialEntry!.id);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = context.appColors;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.sheet),
        ),
      ),
      padding: EdgeInsets.only(
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        top: AppSpacing.xl,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.initialEntry == null ? 'New class' : 'Edit class',
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.l),
              
              // Class Name Input
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Class or event',
                  hintText: 'e.g. Calculus II',
                ),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Enter a name' : null,
              ),
              const SizedBox(height: AppSpacing.m),

              // Room Input
              TextFormField(
                controller: _roomController,
                decoration: const InputDecoration(
                  labelText: 'Room',
                  hintText: 'Optional',
                ),
              ),
              const SizedBox(height: AppSpacing.l),

              // Day Selector
              Text('Repeats on', style: theme.textTheme.bodySmall),
              const SizedBox(height: AppSpacing.s),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (int d = 1; d <= 7; d++)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          if (_selectedDays.contains(d)) {
                            if (_selectedDays.length > 1) _selectedDays.remove(d);
                          } else {
                            _selectedDays.add(d);
                          }
                        });
                      },
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: _selectedDays.contains(d)
                            ? theme.colorScheme.primary
                            : appColors.soft,
                        child: Text(
                          weekdayInitial(d),
                          style: TextStyle(
                            color: _selectedDays.contains(d)
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.l),

              // Start and End Time Pickers
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text('Starts'),
                      subtitle: Text(_startTime.format(context)),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: _startTime,
                        );
                        if (picked != null) setState(() => _startTime = picked);
                      },
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: const Text('Ends'),
                      subtitle: Text(_endTime.format(context)),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: _endTime,
                        );
                        if (picked != null) setState(() => _endTime = picked);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.l),

              // Color Palette Picker
              Text('Color', style: theme.textTheme.bodySmall),
              const SizedBox(height: AppSpacing.s),
              Row(
                children: [
                  for (final color in appColors.classColors)
                    Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.m),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedColor = color.toARGB32()),
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: color,
                          child: _selectedColor == color.toARGB32()
                              ? const Icon(Icons.check, color: Colors.white, size: 18)
                              : null,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.l),

              // Overlap Error Banner (Screen 09)
              if (_overlapError != null) ...[
                Text(
                  _overlapError!,
                  style: TextStyle(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.m),
              ],

              // Save Button
              FilledButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const CircularProgressIndicator()
                    : const Text('Save and set reminder'),
              ),

              // Delete Button (Shown only when editing)
              if (widget.initialEntry != null) ...[
                const SizedBox(height: AppSpacing.s),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                    minimumSize: const Size.fromHeight(52),
                  ),
                  onPressed: _isSaving ? null : _delete,
                  child: const Text('Delete class'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}