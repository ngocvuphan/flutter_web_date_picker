import 'package:flutter/material.dart';

import 'helpers/datetime_extension.dart';
import 'widgets/uniform_grid.dart';
import 'widgets/popup_dialog.dart';

const _kSlideTransitionDuration = Duration(milliseconds: 300);

Future<DateTime?> showWebDatePicker({
  required BuildContext context,
  required DateTime initialDate,
}) {
  //PopupMenuButton
  return showPopupDialog(
    context,
    (context) => _WebDatePicker(initialDate: initialDate),
    asDropDown: true,
    useTargetWidth: true,
  );
}

class _WebDatePicker extends StatefulWidget {
  const _WebDatePicker({
    required this.initialDate,
  });

  final DateTime initialDate;

  @override
  State<_WebDatePicker> createState() => _WebDatePickerState();
}

class _WebDatePickerState extends State<_WebDatePicker> {
  late DateTime _selectedDate;
  late DateTime _startDate;

  double _slideDirection = 1.0;
  _PickerViewMode _viewMode = _PickerViewMode.day;
  bool _isViewModeChanged = false;
  Size? _childSize;

  @override
  void initState() {
    super.initState();
    _selectedDate = _startDate = widget.initialDate;
  }

  List<Widget> _buildDaysOfMonthCells(ThemeData theme) {
    final textStyle = theme.textTheme.bodySmall?.copyWith(color: Colors.black);
    final now = DateTime.now();
    final monthDateRange =
        _startDate.monthDateTimeRange(includeTrailingAndLeadingDates: true);
    final children = kWeekdayAbbreviations
        .map<Widget>(
          (e) => Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(e, style: textStyle),
          ),
        )
        .toList();
    for (int i = 0; i < kNumberCellsOfMonth; i++) {
      final date = monthDateRange.start.add(Duration(days: i));
      final isSelected = date.dateCompareTo(_selectedDate) == 0;
      final isNow = date.dateCompareTo(now) == 0;
      final child = _startDate.month == date.month
          ? Padding(
              padding: const EdgeInsets.all(2.0),
              child: InkWell(
                onTap: () => setState(() => _selectedDate = date),
                customBorder: const CircleBorder(),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? theme.colorScheme.primary : null,
                    border: isNow
                        ? Border.all(color: theme.colorScheme.primary)
                        : null,
                  ),
                  child: Text(
                    date.day.toString(),
                    style: isSelected
                        ? textStyle?.copyWith(
                            color: theme.colorScheme.onPrimary)
                        : textStyle,
                  ),
                ),
              ),
            )
          : Center(
              child: Text(date.day.toString(),
                  style: textStyle?.copyWith(color: theme.disabledColor)));
      children.add(child);
    }
    return children;
  }

  List<Widget> _buildMonthsOfYearCells(ThemeData theme) {
    final textStyle = theme.textTheme.bodySmall?.copyWith(color: Colors.black);
    final borderRadius = BorderRadius.circular(_childSize!.height / 4 - 32);
    final children = <Widget>[];
    final now = DateTime.now();
    for (int i = 1; i <= kNumberOfMonth; i++) {
      final date = DateTime(_startDate.year, i);
      final isSelected = date.monthCompareTo(_selectedDate) == 0;
      final isNow = date.monthCompareTo(now) == 0;
      final child = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: InkWell(
          onTap: () => _onViewModeChanged(next: false, date: date),
          borderRadius: borderRadius,
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? theme.colorScheme.primary : null,
              border:
                  isNow ? Border.all(color: theme.colorScheme.primary) : null,
              borderRadius: borderRadius,
            ),
            child: Text(
              kMonthShortNames[i - 1],
              style: isSelected
                  ? textStyle?.copyWith(color: theme.colorScheme.onPrimary)
                  : textStyle,
            ),
          ),
        ),
      );
      children.add(child);
    }
    return children;
  }

  List<Widget> _buildYearsCells(ThemeData theme) {
    final textStyle = theme.textTheme.bodySmall?.copyWith(color: Colors.black);
    final borderRadius = BorderRadius.circular(_childSize!.height / 5 - 16);
    final children = <Widget>[];
    final now = DateTime.now();
    final year = _startDate.year - _startDate.year % 20;
    for (int i = 0; i < 20; i++) {
      final date = DateTime(year + i);
      final isSelected = date.year == _selectedDate.year;
      final isNow = date.year == now.year;
      final child = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: InkWell(
          onTap: () => _onViewModeChanged(next: false, date: date),
          borderRadius: borderRadius,
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? theme.colorScheme.primary : null,
              border:
                  isNow ? Border.all(color: theme.colorScheme.primary) : null,
              borderRadius: borderRadius,
            ),
            child: Text(
              (year + i).toString(),
              style: isSelected
                  ? textStyle?.copyWith(color: theme.colorScheme.onPrimary)
                  : textStyle,
            ),
          ),
        ),
      );
      children.add(child);
    }
    return children;
  }

  List<Widget> _buildYearsOfCenturyCells(ThemeData theme) {
    final textStyle = theme.textTheme.bodySmall?.copyWith(color: Colors.black);
    final borderRadius = BorderRadius.circular(_childSize!.height / 5 - 16);
    final children = <Widget>[];
    final now = DateTime.now();
    final year = _startDate.year - _startDate.year % 200;
    for (int i = 0; i < 10; i++) {
      final date = DateTime(year + i * 20);
      final isSelected = _selectedDate.year >= date.year &&
          (_selectedDate.year - date.year) < 20;
      final isNow = now.year >= date.year && (now.year - date.year) < 20;
      final child = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: InkWell(
          onTap: () => _onViewModeChanged(next: false, date: date),
          borderRadius: borderRadius,
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? theme.colorScheme.primary : null,
              border:
                  isNow ? Border.all(color: theme.colorScheme.primary) : null,
              borderRadius: borderRadius,
            ),
            child: Text(
              "${date.year} - ${date.year + 19}",
              style: isSelected
                  ? textStyle?.copyWith(color: theme.colorScheme.onPrimary)
                  : textStyle,
            ),
          ),
        ),
      );
      children.add(child);
    }
    return children;
  }

  Widget _buildChild(ThemeData theme) {
    switch (_viewMode) {
      case _PickerViewMode.day:
        return UniformGrid(
          key: _PickerKey(date: _startDate, viewMode: _viewMode),
          columnCount: kNumberOfWeekday,
          squareCell: true,
          onSizeChanged: _onSizeChanged,
          children: _buildDaysOfMonthCells(theme),
        );
      case _PickerViewMode.month:
        return UniformGrid(
          key: _PickerKey(date: _startDate, viewMode: _viewMode),
          columnCount: 3,
          withHeader: false,
          fixedSize: _childSize,
          children: _buildMonthsOfYearCells(theme),
        );
      case _PickerViewMode.year:
        return UniformGrid(
          key: _PickerKey(date: _startDate, viewMode: _viewMode),
          columnCount: 4,
          withHeader: false,
          fixedSize: _childSize,
          children: _buildYearsCells(theme),
        );
      case _PickerViewMode.century:
        return UniformGrid(
          key: _PickerKey(date: _startDate, viewMode: _viewMode),
          columnCount: 2,
          withHeader: false,
          fixedSize: _childSize,
          children: _buildYearsOfCenturyCells(theme),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String actionText;
    switch (_viewMode) {
      case _PickerViewMode.day:
        actionText = "${kMonthNames[_startDate.month - 1]} ${_startDate.year}";
        break;
      case _PickerViewMode.month:
        actionText = _startDate.year.toString();
        break;
      case _PickerViewMode.year:
        final year = _startDate.year - _startDate.year % 20;
        actionText = "$year - ${year + 19}";
        break;
      case _PickerViewMode.century:
        final year = _startDate.year - _startDate.year % 200;
        actionText = "$year - ${year + 199}";
        break;
    }
    return Container(
      padding: const EdgeInsets.all(1.0),
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Card(
        margin: const EdgeInsets.all(0.0),
        elevation: 1.0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () => _onStartDateChanged(next: false),
                    customBorder: const CircleBorder(),
                    child: Container(
                      height: 36.0,
                      width: 36.0,
                      alignment: Alignment.center,
                      child: const Icon(Icons.keyboard_arrow_left),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () => _onViewModeChanged(next: true),
                      borderRadius: BorderRadius.circular(4.0),
                      child: Container(
                        height: 36.0,
                        alignment: Alignment.center,
                        child: Text(
                          actionText,
                          style: theme.textTheme.bodyLarge?.copyWith(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => _onStartDateChanged(next: true),
                    customBorder: const CircleBorder(),
                    child: Container(
                      height: 36.0,
                      width: 36.0,
                      alignment: Alignment.center,
                      child: const Icon(Icons.keyboard_arrow_right),
                    ),
                  ),
                ],
              ),
              ClipRRect(
                child: AnimatedSwitcher(
                  duration: _kSlideTransitionDuration,
                  transitionBuilder: (child, animation) {
                    if (_isViewModeChanged) {
                      return ScaleTransition(
                        scale: animation,
                        child: child,
                      );
                    } else {
                      double dx = (child.key as _PickerKey).date == _startDate
                          ? 1.0
                          : -1.0;
                      return SlideTransition(
                        position: Tween<Offset>(
                                begin: Offset(dx * _slideDirection, 0.0),
                                end: const Offset(0.0, 0.0))
                            .animate(animation),
                        child: child,
                      );
                    }
                  },
                  child: _buildChild(theme),
                ),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () => _onStartDateChanged(),
                    child: const Text("TODAY"),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.secondary),
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text("CANCEL",
                        style: TextStyle(color: theme.colorScheme.onSecondary)),
                  ),
                  if (_viewMode == _PickerViewMode.day) ...[
                    const SizedBox(width: 8.0),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(_selectedDate),
                      child: const Text("OK"),
                    ),
                  ]
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onStartDateChanged({bool? next}) {
    DateTime date;
    if (next != null) {
      switch (_viewMode) {
        case _PickerViewMode.day:
          date = next ? _startDate.nextMonth : _startDate.previousMonth;
          break;
        case _PickerViewMode.month:
          date = next ? _startDate.nextYear : _startDate.previousYear;
          break;
        case _PickerViewMode.year:
          final year = _startDate.year - _startDate.year % 20;
          date = next ? DateTime(year + 20) : DateTime(year - 20);
          break;
        case _PickerViewMode.century:
          final year = _startDate.year - _startDate.year % 200;
          date = next ? DateTime(year + 200) : DateTime(year - 200);
          break;
      }
    } else {
      final year20 = _startDate.year - _startDate.year % 20;
      final year200 = _startDate.year - _startDate.year % 200;
      date = DateTime.now();
      if (_viewMode == _PickerViewMode.day && date.month == _startDate.month ||
          _viewMode == _PickerViewMode.month && date.year == _startDate.year ||
          _viewMode == _PickerViewMode.year &&
              date.year >= year20 &&
              (date.year - year20) < 20 ||
          _viewMode == _PickerViewMode.century &&
              date.year >= year200 &&
              (date.year - year200) < 200) {
        return;
      }
    }
    setState(
      () {
        _slideDirection = date.isAfter(_startDate) ? 1.0 : -1.0;
        _isViewModeChanged = false;
        _startDate = date;
      },
    );
  }

  void _onViewModeChanged({required bool next, DateTime? date}) {
    setState(() {
      _isViewModeChanged = true;
      _viewMode = next ? _viewMode.next() : _viewMode.previous();
      if (date != null) {
        _startDate = date;
      }
    });
  }

  void _onSizeChanged(Size size, Size cellSize) {
    _childSize = size;
  }
}

enum _PickerViewMode {
  day,
  month,
  year,
  century;

  _PickerViewMode next() {
    switch (this) {
      case _PickerViewMode.day:
        return _PickerViewMode.month;
      case _PickerViewMode.month:
        return _PickerViewMode.year;
      case _PickerViewMode.year:
        return _PickerViewMode.century;
      case _PickerViewMode.century:
        return _PickerViewMode.century;
    }
  }

  _PickerViewMode previous() {
    switch (this) {
      case _PickerViewMode.day:
        return _PickerViewMode.day;
      case _PickerViewMode.month:
        return _PickerViewMode.day;
      case _PickerViewMode.year:
        return _PickerViewMode.month;
      case _PickerViewMode.century:
        return _PickerViewMode.year;
    }
  }
}

class _PickerKey extends LocalKey {
  const _PickerKey({required this.date, required this.viewMode});

  final DateTime date;
  final _PickerViewMode viewMode;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is _PickerKey &&
        other.date == date &&
        other.viewMode == viewMode;
  }

  @override
  int get hashCode => Object.hash(runtimeType, date, viewMode);

  @override
  String toString() {
    return "_PickerKey(date: $date, viewMode: $viewMode)";
  }
}
