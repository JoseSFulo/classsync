import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../utils/schedule_format.dart';

/// Seven weekday chips, M to S, in one row. Each takes an equal share of
/// the width, so they never wrap onto a second line.
class DayChips extends StatelessWidget {
  const DayChips({required this.isSelected, required this.onTap, super.key});

  final bool Function(int day) isSelected;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var day = 1; day <= 7; day++)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: _chip(context, day),
            ),
          ),
      ],
    );
  }

  Widget _chip(BuildContext context, int day) {
    final scheme = Theme.of(context).colorScheme;
    final selected = isSelected(day);
    return Semantics(
      button: true,
      selected: selected,
      label: weekdayName(day),
      onTap: () => onTap(day),
      excludeSemantics: true,
      child: Material(
        color: selected ? scheme.primary : scheme.surface,
        shape: StadiumBorder(
          side: BorderSide(
            color: selected ? scheme.primary : context.appColors.line,
          ),
        ),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: () => onTap(day),
          child: SizedBox(
            height: 40,
            child: Center(
              child: Text(
                weekdayInitial(day),
                style: TextStyle(
                  color: selected ? scheme.onPrimary : scheme.onSurface,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
