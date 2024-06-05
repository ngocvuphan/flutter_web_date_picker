import 'package:flutter/material.dart';

import 'package:vph_common_widgets/vph_common_widgets.dart';

import 'helpers/extensions.dart';

const kSlideTransitionDuration = Duration(milliseconds: 300);
const kActionHeight = 36.0;

const kNumberCellsOfMonth = 42;

/// Shows a dialog containing a date picker.
///
/// The returned [Future] resolves to the date selected by the user when the
/// user confirms the dialog. If the user cancels the dialog, null is returned.
///
/// When the date picker is first displayed, it will show the month of
/// [initialDate], with [initialDate] selected.
///
/// The [firstDate] is the earliest allowable date. The [lastDate] is the latest
/// allowable date. [initialDate] must either fall between these dates,
/// or be equal to one of them
///
/// The [width] defines the width of date picker dialog
///
/// The [firstDayOfWeekIndex] defines the first day of the week.
/// By default, firstDayOfWeekIndex = 0 indicates that Sunday is considered the first day of the week
///
Future<DateTime?> showWebDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
  double? width,
  bool? withoutActionButtons,
  Color? weekendDaysColor,
  int? firstDayOfWeekIndex,
}) {
  return showPopupDialog(
    context,
    (context) => _WebDatePicker(
      initialDate: initialDate,
      firstDate: firstDate ?? DateTime(0),
      lastDate: lastDate ?? DateTime(100000),
      withoutActionButtons: withoutActionButtons ?? false,
      weekendDaysColor: weekendDaysColor,
      firstDayOfWeekIndex: firstDayOfWeekIndex ?? 0,
    ),
    asDropDown: true,
    useTargetWidth: width != null ? false : true,
    dialogWidth: width,
  );
}

class _WebDatePicker extends StatefulWidget {
  const _WebDatePicker({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.withoutActionButtons,
    this.weekendDaysColor,
    required this.firstDayOfWeekIndex,
  });

  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final bool withoutActionButtons;
  final Color? weekendDaysColor;
  final int firstDayOfWeekIndex;

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
    final monthDateRange = _startDate.monthDateTimeRange(
      includeTrailingAndLeadingDates: true,
      firstDayOfWeekIndex: widget.firstDayOfWeekIndex,
    );

    final children = LocaleDateSymbols.narrowWeekdays(
            Localizations.localeOf(context).toString())
        .rotate(widget.firstDayOfWeekIndex)
        .asMap()
        .entries
        .map<Widget>(
      (e) {
        final weekday = (e.key + widget.firstDayOfWeekIndex) % 7;
        return Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(e.value,
              style: weekday == 0 || weekday == 6
                  ? widget.weekendDaysColor != null
                      ? textStyle?.copyWith(color: widget.weekendDaysColor)
                      : textStyle
                  : textStyle),
        );
      },
    ).toList();
    for (int i = 0; i < kNumberCellsOfMonth; i++) {
      final date = monthDateRange.start.add(Duration(days: i));
      if (_startDate.month == date.month) {
        final isEnabled = (date.dateCompareTo(widget.firstDate) >= 0) &&
            (date.dateCompareTo(widget.lastDate) <= 0);
        final isSelected = date.dateCompareTo(_selectedDate) == 0;
        final isNow = date.dateCompareTo(now) == 0;
        final isWeekend = date.weekday == DateTime.saturday ||
            date.weekday == DateTime.sunday;
        final color = isEnabled
            ? theme.colorScheme.primary
            : theme.colorScheme.primary.withOpacity(0.5);
        final cellTextStyle = isSelected
            ? textStyle?.copyWith(color: theme.colorScheme.onPrimary)
            : isEnabled
                ? isWeekend && widget.weekendDaysColor != null
                    ? textStyle?.copyWith(color: widget.weekendDaysColor)
                    : textStyle
                : textStyle?.copyWith(
                    color: isWeekend && widget.weekendDaysColor != null
                        ? widget.weekendDaysColor?.withOpacity(0.5)
                        : theme.disabledColor);
        Widget child = Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected ? color : null,
            border: isNow && !isSelected ? Border.all(color: color) : null,
          ),
          child: Text(date.day.toString(), style: cellTextStyle),
        );
        if (isEnabled) {
          child = InkWell(
            onTap: () => setState(() => _selectedDate = date),
            customBorder: const CircleBorder(),
            child: child,
          );
        }
        children.add(Padding(padding: const EdgeInsets.all(2.0), child: child));
      } else {
        children.add(Container());
      }
    }
    return children;
  }

  List<Widget> _buildMonthsOfYearCells(ThemeData theme) {
    final textStyle = theme.textTheme.bodySmall?.copyWith(color: Colors.black);
    final borderRadius = BorderRadius.circular(_childSize!.height / 4 - 32);
    final children = <Widget>[];
    final now = DateTime.now();
    for (int i = 1; i <= 12; i++) {
      final date = DateTime(_startDate.year, i);
      final isEnabled = (date.monthCompareTo(widget.firstDate) >= 0) &&
          (date.monthCompareTo(widget.lastDate) <= 0);
      final isSelected = date.monthCompareTo(_selectedDate) == 0;
      final isNow = date.monthCompareTo(now) == 0;
      final color = isEnabled
          ? theme.colorScheme.primary
          : theme.colorScheme.primary.withOpacity(0.5);
      final shortMonthNames = LocaleDateSymbols.shortMonths(
          Localizations.localeOf(context).toString());
      Widget child = Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? color : null,
          border: isNow && !isSelected ? Border.all(color: color) : null,
          borderRadius: borderRadius,
        ),
        child: Text(
          shortMonthNames[i - 1],
          style: isSelected
              ? textStyle?.copyWith(color: theme.colorScheme.onPrimary)
              : isEnabled
                  ? textStyle
                  : textStyle?.copyWith(color: theme.disabledColor),
        ),
      );
      if (isEnabled) {
        child = InkWell(
          onTap: () => _onViewModeChanged(next: false, date: date),
          borderRadius: borderRadius,
          child: child,
        );
      }
      children.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: child,
        ),
      );
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
      final isEnabled = (date.year >= widget.firstDate.year) &&
          (date.year <= widget.lastDate.year);
      final isSelected = date.year == _selectedDate.year;
      final isNow = date.year == now.year;
      final color = isEnabled
          ? theme.colorScheme.primary
          : theme.colorScheme.primary.withOpacity(0.5);
      Widget child = Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? color : null,
          border: isNow && !isSelected ? Border.all(color: color) : null,
          borderRadius: borderRadius,
        ),
        child: Text(
          (year + i).toString(),
          style: isSelected
              ? textStyle?.copyWith(color: theme.colorScheme.onPrimary)
              : isEnabled
                  ? textStyle
                  : textStyle?.copyWith(color: theme.disabledColor),
        ),
      );
      if (isEnabled) {
        child = InkWell(
          onTap: () => _onViewModeChanged(next: false, date: date),
          borderRadius: borderRadius,
          child: child,
        );
      }
      children.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: child,
        ),
      );
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
      final isEnabled = (widget.firstDate.year <= date.year ||
              (widget.firstDate.year - date.year) <= 20) &&
          (date.year + 20 <= widget.lastDate.year ||
              (date.year - widget.lastDate.year) <= 0);
      final isSelected = _selectedDate.year >= date.year &&
          (_selectedDate.year - date.year) < 20;
      final isNow = now.year >= date.year && (now.year - date.year) < 20;
      final color = isEnabled
          ? theme.colorScheme.primary
          : theme.colorScheme.primary.withOpacity(0.5);
      Widget child = Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? color : null,
          border: isNow && !isSelected ? Border.all(color: color) : null,
          borderRadius: borderRadius,
        ),
        child: Text(
          "${date.year} - ${date.year + 19}",
          style: isSelected
              ? textStyle?.copyWith(color: theme.colorScheme.onPrimary)
              : isEnabled
                  ? textStyle
                  : textStyle?.copyWith(color: theme.disabledColor),
        ),
      );
      if (isEnabled) {
        child = InkWell(
          onTap: () => _onViewModeChanged(next: false, date: date),
          borderRadius: borderRadius,
          child: child,
        );
      }
      children.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: child,
        ),
      );
    }
    return children;
  }

  Widget _buildChild(ThemeData theme) {
    switch (_viewMode) {
      case _PickerViewMode.day:
        return UniformGrid(
          key: _PickerKey(date: _startDate, viewMode: _viewMode),
          columnCount: 7,
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
    final localizations = MaterialLocalizations.of(context);
    Widget navTitle;
    bool isFirst = false, isLast = false, nextView = true;
    switch (_viewMode) {
      case _PickerViewMode.day:
        navTitle = Container(
          height: kActionHeight,
          alignment: Alignment.center,
          child: Text(
            localizations.formatMonthYear(_startDate),
            style: theme.textTheme.bodyLarge
                ?.copyWith(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        );
        final monthDateRange = _startDate.monthDateTimeRange(
          includeTrailingAndLeadingDates: false,
          numberCellsOfMonth: kNumberCellsOfMonth,
        );
        isFirst = widget.firstDate.dateCompareTo(monthDateRange.start) >= 0;
        isLast = widget.lastDate.dateCompareTo(monthDateRange.end) <= 0;
        nextView = widget.lastDate.difference(widget.firstDate).inDays > 28;
        break;
      case _PickerViewMode.month:
        navTitle = Container(
          height: kActionHeight,
          alignment: Alignment.center,
          child: Text(
            localizations.formatYear(_startDate),
            style: theme.textTheme.bodyLarge
                ?.copyWith(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        );
        isFirst = _startDate.year <= widget.firstDate.year;
        isLast = _startDate.year >= widget.lastDate.year;
        nextView = widget.lastDate.year != widget.firstDate.year;
        break;
      case _PickerViewMode.year:
        final year = _startDate.year - _startDate.year % 20;
        isFirst = year <= widget.firstDate.year;
        isLast = year + 20 >= widget.lastDate.year;
        navTitle = Container(
          height: kActionHeight,
          alignment: Alignment.center,
          child: Text(
            "$year - ${year + 19}",
            style: theme.textTheme.bodyLarge
                ?.copyWith(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        );
        nextView = widget.lastDate.year - widget.firstDate.year > 20;
        break;
      case _PickerViewMode.century:
        final year = _startDate.year - _startDate.year % 200;
        isFirst = year <= widget.firstDate.year;
        isLast = year + 200 >= widget.lastDate.year;
        navTitle = Container(
          height: kActionHeight,
          alignment: Alignment.center,
          child: Text(
            "$year - ${year + 199}",
            style: theme.textTheme.bodyLarge
                ?.copyWith(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        );
        nextView = false;
        break;
    }
    return Card(
      margin:
          const EdgeInsets.only(left: 1.0, top: 4.0, right: 1.0, bottom: 2.0),
      elevation: 1.0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            /// Navigation
            Row(
              children: [
                isFirst
                    ? _iconWidget(Icons.keyboard_arrow_left,
                        color: theme.disabledColor)
                    : _iconWidget(Icons.keyboard_arrow_left,
                        onTap: () => _onStartDateChanged(next: false)),
                nextView
                    ? Expanded(
                        child: InkWell(
                          onTap: () => _onViewModeChanged(next: true),
                          borderRadius: BorderRadius.circular(4.0),
                          child: navTitle,
                        ),
                      )
                    : Expanded(child: navTitle),
                isLast
                    ? _iconWidget(Icons.keyboard_arrow_right,
                        color: theme.disabledColor)
                    : _iconWidget(Icons.keyboard_arrow_right,
                        onTap: () => _onStartDateChanged(next: true)),
              ],
            ),

            /// Month view
            ClipRRect(
              child: AnimatedSwitcher(
                duration: kSlideTransitionDuration,
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

            /// Actions
            Row(
              children: [
                /// Reset
                if (!widget.withoutActionButtons)
                  _iconWidget(Icons.restart_alt,
                      tooltip: localizations.backButtonTooltip,
                      onTap: _onResetState),
                if (!widget.withoutActionButtons) const SizedBox(width: 4.0),

                /// Today
                if (!widget.withoutActionButtons)
                  _iconWidget(Icons.today,
                      tooltip: localizations.currentDateLabel,
                      onTap: _onStartDateChanged),
                const Spacer(),

                /// CANCEL
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(localizations.cancelButtonLabel),
                ),

                /// OK
                if (_viewMode == _PickerViewMode.day) ...[
                  const SizedBox(width: 4.0),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(_selectedDate),
                    child: Text(localizations.okButtonLabel),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconWidget(IconData icon,
      {Color? color, String? tooltip, GestureTapCallback? onTap}) {
    final child = Container(
      height: kActionHeight,
      width: kActionHeight,
      alignment: Alignment.center,
      child: tooltip != null
          ? Tooltip(message: tooltip, child: Icon(icon, color: color))
          : Icon(icon, color: color),
    );
    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: child,
      );
    } else {
      return child;
    }
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

  void _onResetState() {
    setState(
      () {
        _slideDirection = widget.initialDate.isAfter(_startDate) ? 1.0 : -1.0;
        _startDate = widget.initialDate;
        _selectedDate = _startDate;
        _isViewModeChanged = _viewMode != _PickerViewMode.day;
        _viewMode = _PickerViewMode.day;
      },
    );
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
