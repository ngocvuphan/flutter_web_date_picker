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
/// The [asDialog] argument will show the picker as dialog. By default, the picker is show as dropdown
///
Future<DateTimeRange?> showWebDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  DateTime? initialDate2,
  DateTime? firstDate,
  DateTime? lastDate,
  double? width,
  bool withoutActionButtons = false,
  Color? weekendDaysColor,
  Color? selectedDayColor,
  Color? confirmButtonColor,
  Color? cancelButtonColor,
  int? firstDayOfWeekIndex,
  bool asDialog = false,
  bool enableDateRangeSelection = false,
}) {
  if (asDialog) {
    final renderBox = context.findRenderObject()! as RenderBox;
    return showDialog<DateTimeRange?>(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        content: SingleChildScrollView(
          child: SizedBox(
            width: width ?? renderBox.size.width,
            child: _WebDatePicker(
              initialDate: initialDate,
              initialDate2: initialDate2,
              firstDate: firstDate ?? DateTime(0),
              lastDate: lastDate ?? DateTime(100000),
              withoutActionButtons: withoutActionButtons,
              weekendDaysColor: weekendDaysColor,
              firstDayOfWeekIndex: firstDayOfWeekIndex ?? 0,
              selectedDayColor: selectedDayColor,
              confirmButtonColor: confirmButtonColor,
              cancelButtonColor: cancelButtonColor,
              enableDateRangeSelection: enableDateRangeSelection,
            ),
          ),
        ),
      ),
    );
  } else {
    return showPopupDialog<DateTimeRange?>(
      context,
      (context) => _WebDatePicker(
        initialDate: initialDate,
        initialDate2: initialDate2,
        firstDate: firstDate ?? DateTime(0),
        lastDate: lastDate ?? DateTime(100000),
        withoutActionButtons: withoutActionButtons,
        weekendDaysColor: weekendDaysColor,
        firstDayOfWeekIndex: firstDayOfWeekIndex ?? 0,
        selectedDayColor: selectedDayColor,
        confirmButtonColor: confirmButtonColor,
        cancelButtonColor: cancelButtonColor,
        enableDateRangeSelection: enableDateRangeSelection,
      ),
      asDropDown: true,
      useTargetWidth: width != null ? false : true,
      dialogWidth: width,
    );
  }
}

class _WebDatePicker extends StatefulWidget {
  const _WebDatePicker({
    required this.initialDate,
    this.initialDate2,
    required this.firstDate,
    required this.lastDate,
    this.withoutActionButtons = false,
    this.weekendDaysColor,
    required this.firstDayOfWeekIndex,
    this.selectedDayColor,
    this.confirmButtonColor,
    this.cancelButtonColor,
    this.enableDateRangeSelection = false,
  });

  final DateTime initialDate;
  final DateTime? initialDate2;
  final DateTime firstDate;
  final DateTime lastDate;
  final bool withoutActionButtons;
  final Color? weekendDaysColor;
  final int firstDayOfWeekIndex;
  final Color? selectedDayColor;
  final Color? confirmButtonColor;
  final Color? cancelButtonColor;
  final bool enableDateRangeSelection;

  @override
  State<_WebDatePicker> createState() => _WebDatePickerState();
}

class _WebDatePickerState extends State<_WebDatePicker> {
  late DateTime _selectedStartDate;
  late DateTime _selectedEndDate;
  late DateTime _viewStartDate;

  DateTime? _hoveredStartDate;
  DateTime? _hoveredEndDate;

  double _slideDirection = 1.0;
  _PickerViewMode _viewMode = _PickerViewMode.day;
  bool _isViewModeChanged = false;
  Size? _childSize;

  @override
  void initState() {
    super.initState();
    _selectedStartDate = _viewStartDate = widget.initialDate.toUtc();
    _selectedEndDate = widget.enableDateRangeSelection ? widget.initialDate2 ?? _selectedStartDate : _selectedStartDate;
  }

  List<Widget> _buildDaysOfMonthCells(ThemeData theme) {
    final textStyle = theme.textTheme.bodySmall?.copyWith(color: Colors.black);
    final now = DateTime.now();
    final monthDateRange = _viewStartDate.monthDateTimeRange(
      includeTrailingAndLeadingDates: true,
      firstDayOfWeekIndex: widget.firstDayOfWeekIndex,
    );

    final children =
        LocaleDateSymbols.narrowWeekdays(Localizations.localeOf(context).toString()).rotate(widget.firstDayOfWeekIndex).asMap().entries.map<Widget>(
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
    // print("_selectedStartDate: $_selectedStartDate, _selectedEndDate: $_selectedEndDate");
    // print("_hoveredStartDate: $_hoveredStartDate, _hoveredEndDate: $_hoveredEndDate");
    for (int i = 0; i < kNumberCellsOfMonth; i++) {
      final date = monthDateRange.start.add(Duration(days: i));
      if (_viewStartDate.month == date.month) {
        final isEnabled = date.isInDateRange(widget.firstDate, widget.lastDate);
        final isSelected = date.isInDateRange(_selectedStartDate, _selectedEndDate);
        final isSelectedLeft = isSelected && date.dateCompareTo(_selectedStartDate) == 0;
        final isSelectedRight = isSelected && date.dateCompareTo(_selectedEndDate) == 0;
        final isNow = date.dateCompareTo(now) == 0;
        final isWeekend = date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
        final color = isEnabled
            ? widget.selectedDayColor ?? theme.colorScheme.primary
            : widget.selectedDayColor?.withOpacity(0.5) ?? theme.colorScheme.primary.withOpacity(0.5);
        final cellTextStyle = isSelected
            ? textStyle?.copyWith(color: theme.colorScheme.onPrimary)
            : isEnabled
                ? isWeekend && widget.weekendDaysColor != null
                    ? textStyle?.copyWith(color: widget.weekendDaysColor)
                    : textStyle
                : textStyle?.copyWith(color: isWeekend && widget.weekendDaysColor != null ? widget.weekendDaysColor?.withOpacity(0.5) : theme.disabledColor);

        final isHovered =
            widget.enableDateRangeSelection && _hoveredStartDate != null && _hoveredEndDate != null && date.isInDateRange(_hoveredStartDate!, _hoveredEndDate!);
        final isHoveredLeft = isHovered && date.dateCompareTo(_hoveredStartDate!) == 0;
        final isHoveredRight = isHovered && date.dateCompareTo(_hoveredEndDate!) == 0;
        Widget child = Container(
          alignment: Alignment.center,
          margin: EdgeInsets.all(2.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected ? color : null,
            border: isNow && !isSelected ? Border.all(color: color) : null,
          ),
          child: Text(date.day.toString(), style: cellTextStyle),
        );
        if (isEnabled) {
          child = InkWell(
            onTap: () {
              if (widget.enableDateRangeSelection) {
                if (_selectedStartDate.dateCompareTo(_selectedEndDate) < 0) {
                  setState(() {
                    _selectedStartDate = _selectedEndDate = date;
                    _hoveredStartDate = _hoveredEndDate = null;
                  });
                } else if (date.dateCompareTo(_selectedStartDate) <= 0) {
                  setState(() {
                    _selectedStartDate = date;
                    _hoveredStartDate = _hoveredEndDate = null;
                  });
                } else {
                  setState(() {
                    _selectedEndDate = date;
                    _hoveredStartDate = _hoveredEndDate = null;
                  });
                }
              } else {
                setState(() => _selectedStartDate = _selectedEndDate = date);
              }
            },
            onHover: (hovering) {
              if (widget.enableDateRangeSelection) {
                if (hovering) {
                  if (_selectedStartDate.dateCompareTo(_selectedEndDate) < 0) {
                    setState(() => _hoveredStartDate = _hoveredEndDate = date);
                  } else if (date.dateCompareTo(_selectedStartDate) <= 0) {
                    setState(() {
                      _hoveredStartDate = date;
                      _hoveredEndDate = _selectedEndDate;
                    });
                  } else {
                    setState(() {
                      _hoveredStartDate = _selectedStartDate;
                      _hoveredEndDate = date;
                    });
                  }
                } else {
                  setState(() => _hoveredStartDate = _hoveredEndDate = null);
                }
              }
            },
            customBorder: const CircleBorder(),
            child: child,
          );
        }
        if (widget.enableDateRangeSelection) {
          final dfBorderSide = BorderSide(color: color, width: 1.0, style: BorderStyle.solid);
          final dfRadius = Radius.circular(_childSize?.height ?? 100);
          child = Stack(
            children: [
              Container(
                margin: EdgeInsets.only(
                  left: (isSelected && !isSelectedLeft || isHovered) && !isHoveredLeft ? 0.0 : 2.0,
                  top: 2.0,
                  right: (isSelected && !isSelectedRight || isHovered) && !isHoveredRight ? 0.0 : 2.0,
                  bottom: 2.0,
                ),
                decoration: BoxDecoration(
                  color: isSelected && !isHovered ? color : null,
                  border: Border(
                    top: isHovered ? dfBorderSide : BorderSide.none,
                    bottom: isHovered ? dfBorderSide : BorderSide.none,
                    left: isHoveredLeft ? dfBorderSide : BorderSide.none,
                    right: isHoveredRight ? dfBorderSide : BorderSide.none,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: isSelectedLeft && !isHovered || isHoveredLeft ? dfRadius : Radius.zero,
                    bottomLeft: isSelectedLeft && !isHovered || isHoveredLeft ? dfRadius : Radius.zero,
                    topRight: isSelectedRight && !isHovered || isHoveredRight ? dfRadius : Radius.zero,
                    bottomRight: isSelectedRight && !isHovered || isHoveredRight ? dfRadius : Radius.zero,
                  ),
                ),
              ),
              child,
            ],
          );
        }
        children.add(child);
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
      final date = DateTime(_viewStartDate.year, i);
      final isEnabled = (date.monthCompareTo(widget.firstDate) >= 0) && (date.monthCompareTo(widget.lastDate) <= 0);
      final isSelected = date.monthCompareTo(_selectedStartDate) == 0;
      final isNow = date.monthCompareTo(now) == 0;
      final color = isEnabled ? theme.colorScheme.primary : theme.colorScheme.primary.withOpacity(0.5);
      final shortMonthNames = LocaleDateSymbols.shortMonths(Localizations.localeOf(context).toString());
      Widget child = Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? color : null,
          border: isNow && !isSelected ? Border.all(color: color) : null,
          borderRadius: borderRadius,
        ),
        child: Text(
          shortMonthNames[i - 1].capitalize(),
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
    final year = _viewStartDate.year - _viewStartDate.year % 20;
    for (int i = 0; i < 20; i++) {
      final date = DateTime(year + i);
      final isEnabled = (date.year >= widget.firstDate.year) && (date.year <= widget.lastDate.year);
      final isSelected = date.year == _selectedStartDate.year;
      final isNow = date.year == now.year;
      final color = isEnabled ? theme.colorScheme.primary : theme.colorScheme.primary.withOpacity(0.5);
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
    final year = _viewStartDate.year - _viewStartDate.year % 200;
    for (int i = 0; i < 10; i++) {
      final date = DateTime(year + i * 20);
      final isEnabled = (widget.firstDate.year <= date.year || (widget.firstDate.year - date.year) <= 20) &&
          (date.year + 20 <= widget.lastDate.year || (date.year - widget.lastDate.year) <= 0);
      final isSelected = _selectedStartDate.year >= date.year && (_selectedStartDate.year - date.year) < 20;
      final isNow = now.year >= date.year && (now.year - date.year) < 20;
      final color = isEnabled ? theme.colorScheme.primary : theme.colorScheme.primary.withOpacity(0.5);
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
          key: _PickerKey(date: _viewStartDate, viewMode: _viewMode),
          columnCount: 7,
          squareCell: true,
          onSizeChanged: _onSizeChanged,
          children: _buildDaysOfMonthCells(theme),
        );
      case _PickerViewMode.month:
        return UniformGrid(
          key: _PickerKey(date: _viewStartDate, viewMode: _viewMode),
          columnCount: 3,
          withHeader: false,
          fixedSize: _childSize,
          children: _buildMonthsOfYearCells(theme),
        );
      case _PickerViewMode.year:
        return UniformGrid(
          key: _PickerKey(date: _viewStartDate, viewMode: _viewMode),
          columnCount: 4,
          withHeader: false,
          fixedSize: _childSize,
          children: _buildYearsCells(theme),
        );
      case _PickerViewMode.century:
        return UniformGrid(
          key: _PickerKey(date: _viewStartDate, viewMode: _viewMode),
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
            localizations.formatMonthYear(_viewStartDate).capitalize(),
            style: theme.textTheme.bodyLarge?.copyWith(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        );
        final monthDateRange = _viewStartDate.monthDateTimeRange(
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
            localizations.formatYear(_viewStartDate),
            style: theme.textTheme.bodyLarge?.copyWith(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        );
        isFirst = _viewStartDate.year <= widget.firstDate.year;
        isLast = _viewStartDate.year >= widget.lastDate.year;
        nextView = widget.lastDate.year != widget.firstDate.year;
        break;
      case _PickerViewMode.year:
        final year = _viewStartDate.year - _viewStartDate.year % 20;
        isFirst = year <= widget.firstDate.year;
        isLast = year + 20 >= widget.lastDate.year;
        navTitle = Container(
          height: kActionHeight,
          alignment: Alignment.center,
          child: Text(
            "$year - ${year + 19}",
            style: theme.textTheme.bodyLarge?.copyWith(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        );
        nextView = widget.lastDate.year - widget.firstDate.year > 20;
        break;
      case _PickerViewMode.century:
        final year = _viewStartDate.year - _viewStartDate.year % 200;
        isFirst = year <= widget.firstDate.year;
        isLast = year + 200 >= widget.lastDate.year;
        navTitle = Container(
          height: kActionHeight,
          alignment: Alignment.center,
          child: Text(
            "$year - ${year + 199}",
            style: theme.textTheme.bodyLarge?.copyWith(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        );
        nextView = false;
        break;
    }
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 1.0, vertical: 4.0),
      elevation: 1.0,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// Navigation
            Row(
              children: [
                isFirst
                    ? _iconWidget(Icons.keyboard_arrow_left, color: theme.disabledColor)
                    : _iconWidget(Icons.keyboard_arrow_left, onTap: () => _onStartDateChanged(next: false)),
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
                    ? _iconWidget(Icons.keyboard_arrow_right, color: theme.disabledColor)
                    : _iconWidget(Icons.keyboard_arrow_right, onTap: () => _onStartDateChanged(next: true)),
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
                    double dx = (child.key as _PickerKey).date == _viewStartDate ? 1.0 : -1.0;
                    return SlideTransition(
                      position: Tween<Offset>(begin: Offset(dx * _slideDirection, 0.0), end: const Offset(0.0, 0.0)).animate(animation),
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
                if (!widget.withoutActionButtons) _iconWidget(Icons.restart_alt, tooltip: localizations.backButtonTooltip, onTap: _onResetState),
                if (!widget.withoutActionButtons) const SizedBox(width: 4.0),

                /// Today
                if (!widget.withoutActionButtons) _iconWidget(Icons.today, tooltip: localizations.currentDateLabel, onTap: _onStartDateChanged),
                const Spacer(),

                /// CANCEL
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    localizations.cancelButtonLabel,
                    style: TextStyle(color: widget.cancelButtonColor ?? theme.colorScheme.primary),
                  ),
                ),

                /// OK
                if (_viewMode == _PickerViewMode.day) ...[
                  const SizedBox(width: 4.0),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(DateTimeRange(start: _selectedStartDate, end: _selectedEndDate)),
                    child: Text(
                      localizations.okButtonLabel,
                      style: TextStyle(color: widget.confirmButtonColor ?? theme.colorScheme.primary),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconWidget(IconData icon, {Color? color, String? tooltip, GestureTapCallback? onTap}) {
    final child = Container(
      height: kActionHeight,
      width: kActionHeight,
      alignment: Alignment.center,
      child: tooltip != null ? Tooltip(message: tooltip, child: Icon(icon, color: color)) : Icon(icon, color: color),
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
          date = next ? _viewStartDate.nextMonth : _viewStartDate.previousMonth;
          break;
        case _PickerViewMode.month:
          date = next ? _viewStartDate.nextYear : _viewStartDate.previousYear;
          break;
        case _PickerViewMode.year:
          final year = _viewStartDate.year - _viewStartDate.year % 20;
          date = next ? DateTime(year + 20) : DateTime(year - 20);
          break;
        case _PickerViewMode.century:
          final year = _viewStartDate.year - _viewStartDate.year % 200;
          date = next ? DateTime(year + 200) : DateTime(year - 200);
          break;
      }
    } else {
      final year20 = _viewStartDate.year - _viewStartDate.year % 20;
      final year200 = _viewStartDate.year - _viewStartDate.year % 200;
      date = DateTime.now();
      if (_viewMode == _PickerViewMode.day && date.month == _viewStartDate.month ||
          _viewMode == _PickerViewMode.month && date.year == _viewStartDate.year ||
          _viewMode == _PickerViewMode.year && date.year >= year20 && (date.year - year20) < 20 ||
          _viewMode == _PickerViewMode.century && date.year >= year200 && (date.year - year200) < 200) {
        return;
      }
    }
    setState(
      () {
        _slideDirection = date.isAfter(_viewStartDate) ? 1.0 : -1.0;
        _isViewModeChanged = false;
        _viewStartDate = date;
      },
    );
  }

  void _onViewModeChanged({required bool next, DateTime? date}) {
    setState(() {
      _isViewModeChanged = true;
      _viewMode = next ? _viewMode.next() : _viewMode.previous();
      if (date != null) {
        _viewStartDate = date;
      }
    });
  }

  void _onResetState() {
    setState(
      () {
        _slideDirection = widget.initialDate.isAfter(_viewStartDate) ? 1.0 : -1.0;
        _selectedStartDate = _viewStartDate = widget.initialDate;
        _selectedEndDate = widget.enableDateRangeSelection ? widget.initialDate2 ?? _selectedStartDate : _selectedStartDate;
        _isViewModeChanged = _viewMode != _PickerViewMode.day;
        _viewMode = _PickerViewMode.day;
      },
    );
  }

  void _onSizeChanged(Size size, Size cellSize) {
    // print("_onSizeChanged(size: $size, cellSize: $cellSize)");
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
    return other is _PickerKey && other.date == date && other.viewMode == viewMode;
  }

  @override
  int get hashCode => Object.hash(runtimeType, date, viewMode);

  @override
  String toString() {
    return "_PickerKey(date: $date, viewMode: $viewMode)";
  }
}
