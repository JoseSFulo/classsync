import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/schedule_format.dart';
import '../../domain/models/class_entry.dart';

class WeekGrid extends StatelessWidget {
  const WeekGrid({required this.classes, required this.onTapClass, super.key});

  final List<ClassEntry> classes;
  final ValueChanged<ClassEntry> onTapClass;

  // Minimum visible range: 7:00 to 22:00, in minutes since midnight.
  static const _minStart = 420;
  static const _minEnd = 1320;
  static const _laneHeight = 380.0;

  /// Earliest class start, rounded down to a whole hour.
  int get _start {
    final earliest = classes.fold<int>(
      _minStart,
      (value, c) => min(value, c.startMinute),
    );
    return earliest ~/ 60 * 60;
  }

  /// Latest class end, rounded up to a whole hour.
  int get _end {
    final latest = classes.fold<int>(
      _minEnd,
      (value, c) => max(value, c.endMinute),
    );
    return (latest + 59) ~/ 60 * 60;
  }

  double _position(int minutes) {
    final fraction = (minutes - _start) / (_end - _start);
    return max(0.0, min(1.0, fraction)) * _laneHeight;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var day = 1; day <= 7; day++)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Semantics(
                        label: weekdayName(day),
                        excludeSemantics: true,
                        child: Text(
                          weekdayInitial(day),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Container(
                        height: _laneHeight,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          border: Border.all(color: context.appColors.line),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(9),
                          child: Stack(
                            children: [
                              for (final c in classes.where(
                                (c) => c.days.contains(day),
                              ))
                                _block(c),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.s),
        Text(
          '${formatMinutes(_start)} at the top, '
          '${formatMinutes(_end)} at the bottom.',
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _block(ClassEntry c) {
    final top = _position(c.startMinute);
    final height = max(6.0, _position(c.endMinute) - top);
    return Positioned(
      top: top,
      height: height,
      left: 2,
      right: 2,
      child: Material(
        color: Color(c.colorValue),
        borderRadius: BorderRadius.circular(6),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => onTapClass(c),
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: Text(
              c.name,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
