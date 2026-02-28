import 'package:flutter/material.dart';

import 'package:vph_common_widgets/vph_common_widgets.dart';

import 'helpers/extensions.dart';

const kSlideTransitionDuration = Duration(milliseconds: 300);
const kActionHeight = 36.0;

const kNumberCellsOfMonth = 42;

/// Shows a dialog containing a date picker.

Future<DateTimeRange?> showWebDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  DateTime? initialDate2,
  DateTime? firstDate,
  DateTime? lastDate,
  double? width,
  Color? weekendDaysColor,
  Color? selectedDayColor,
  Color? confirmButtonColor,
  Color? cancelButtonColor,
  Color? backgroundColor,
  int? firstDayOfWeekIndex,
  bool asDialog = false,
  bool enableRangeSelection = false,
  List<DateTime>? blockedDates,
  PickerViewMode initViewMode = PickerViewMode.day,
  Size? initSize,
  bool showTodayButton = true,
  bool showResetButton = true,
  bool showOkButton = true,
  bool showCancelButton = true,
  bool autoCloseOnDateSelect = false,
  bool showDisabledCursor = false,
  void Function()? onReset,
  String? todayButtonText,
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
              weekendDaysColor: weekendDaysColor,
              firstDayOfWeekIndex: firstDayOfWeekIndex ?? 0,
              selectedDayColor: selectedDayColor,
              confirmButtonColor: confirmButtonColor,
              cancelButtonColor: cancelButtonColor,
              backgroundColor: backgroundColor,
              enableRangeSelection: enableRangeSelection,
              blockedDates: blockedDates ?? [],
              initViewMode: initViewMode,
              initSize: initSize,
              showTodayButton: showTodayButton,
              showResetButton: showResetButton,
              autoCloseOnDateSelect: autoCloseOnDateSelect,
              showOkButton: showOkButton,
              showCancelButton: showCancelButton,
              showDisabledCursor: showDisabledCursor,
              onReset: onReset,
              todayButtonText: todayButtonText,
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
        weekendDaysColor: weekendDaysColor,
        firstDayOfWeekIndex: firstDayOfWeekIndex ?? 0,
        selectedDayColor: selectedDayColor,
        confirmButtonColor: confirmButtonColor,
        cancelButtonColor: cancelButtonColor,
        backgroundColor: backgroundColor,
        enableRangeSelection: enableRangeSelection,
        blockedDates: blockedDates ?? [],
        initViewMode: initViewMode,
        initSize: initSize,
        showTodayButton: showTodayButton,
        showResetButton: showResetButton,
        autoCloseOnDateSelect: autoCloseOnDateSelect,
        showOkButton: showOkButton,
        showCancelButton: showCancelButton,
        showDisabledCursor: showDisabledCursor,
        onReset: onReset,
        todayButtonText: todayButtonText,
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
    required this.blockedDates,
    this.weekendDaysColor,
    required this.firstDayOfWeekIndex,
    this.selectedDayColor,
    this.confirmButtonColor,
    this.cancelButtonColor,
    this.backgroundColor,
    this.enableRangeSelection = false,
    this.initViewMode = PickerViewMode.day,
    this.initSize,
    this.showTodayButton = true,
    this.showResetButton = true,
    this.showOkButton = true,
    this.showCancelButton = true,
    this.autoCloseOnDateSelect = false,
    this.showDisabledCursor = false,
    this.onReset,
    this.todayButtonText,
  });

  final List<DateTime> blockedDates;
  final DateTime initialDate;
  final DateTime? initialDate2;
  final DateTime firstDate;
  final DateTime lastDate;
  final Color? weekendDaysColor;
  final int firstDayOfWeekIndex;
  final Color? selectedDayColor;
  final Color? confirmButtonColor;
  final Color? cancelButtonColor;
  final Color? backgroundColor;
  final bool enableRangeSelection;
  final PickerViewMode initViewMode;
  final Size? initSize;
  final bool showTodayButton;
  final bool showResetButton;
  final bool showOkButton;
  final bool showCancelButton;
  final bool autoCloseOnDateSelect;
  final bool showDisabledCursor;
  final void Function()? onReset;
  final String? todayButtonText;

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
  late PickerViewMode _curViewMode;
  bool _isViewModeChanged = false;
  Size? _childSize;

  @override
  void initState() {
    super.initState();
    _curViewMode = widget.initViewMode;
    _childSize = widget.initSize;
    if (_childSize == null && _curViewMode != PickerViewMode.day) {
      _childSize = Size(370, 350);
    }
    _selectedStartDate = _viewStartDate = DateTime(
      widget.initialDate.year,
      widget.initialDate.month,
      widget.initialDate.day,
    );
    _selectedEndDate = widget.enableRangeSelection
        ? DateTime(
            widget.initialDate2?.year ?? widget.initialDate.year,
            widget.initialDate2?.month ?? widget.initialDate.month,
            widget.initialDate2?.day ?? widget.initialDate.month,
          )
        : _selectedStartDate;
  }

  List<Widget> _buildDaysOfMonthCells(ThemeData theme) {
    final textStyle = theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface);
    final now = DateTime.now();
    final monthDateRange = _viewStartDate.monthDateTimeRange(
      includeTrailingAndLeadingDates: true,
      firstDayOfWeekIndex: widget.firstDayOfWeekIndex,
    );

    final children = LocaleDateSymbols.narrowWeekdays(Localizations.localeOf(context).toString()).rotate(widget.firstDayOfWeekIndex).asMap().entries.map<Widget>(
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
        final isEnabled = date.isInDateRange(widget.firstDate, widget.lastDate) && !date.isBlockedDate(widget.blockedDates, date);
        final isSelected = date.isInDateRange(_selectedStartDate, _selectedEndDate);
        final isSelectedLeft = isSelected && date.compareToEx(_selectedStartDate, DateTimeCompareMode.day) == 0;
        final isSelectedRight = isSelected && date.compareToEx(_selectedEndDate, DateTimeCompareMode.day) == 0;
        final isNow = date.compareToEx(now, DateTimeCompareMode.day) == 0;
        final isWeekend = date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
        final color = isEnabled ? widget.selectedDayColor ?? theme.colorScheme.primary : widget.selectedDayColor?.withAlpha(128) ?? theme.colorScheme.primary.withAlpha(128);
        final cellTextStyle = isSelected
            ? textStyle?.copyWith(color: theme.colorScheme.onPrimary)
            : isEnabled
                ? isWeekend && widget.weekendDaysColor != null
                    ? textStyle?.copyWith(color: widget.weekendDaysColor)
                    : textStyle
                : textStyle?.copyWith(color: isWeekend && widget.weekendDaysColor != null ? widget.weekendDaysColor?.withAlpha(128) : theme.disabledColor);

        final isHovered = widget.enableRangeSelection && _hoveredStartDate != null && _hoveredEndDate != null && date.isInDateRange(_hoveredStartDate!, _hoveredEndDate!);
        final isHoveredLeft = isHovered && date.compareToEx(_hoveredStartDate!, DateTimeCompareMode.day) == 0;
        final isHoveredRight = isHovered && date.compareToEx(_hoveredEndDate!, DateTimeCompareMode.day) == 0;
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
              if (widget.enableRangeSelection) {
                if (_selectedStartDate.compareToEx(_selectedEndDate, DateTimeCompareMode.day) < 0) {
                  setState(() {
                    _selectedStartDate = _selectedEndDate = date;
                    _hoveredStartDate = _hoveredEndDate = null;
                  });
                } else if (date.compareToEx(_selectedStartDate, DateTimeCompareMode.day) <= 0) {
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

                if (widget.autoCloseOnDateSelect) {
                  Navigator.of(context).pop(DateTimeRange(start: _selectedStartDate, end: _selectedEndDate));
                }
              }
            },
            onHover: (hovering) {
              if (widget.enableRangeSelection) {
                if (hovering) {
                  if (_selectedStartDate.compareToEx(_selectedEndDate, DateTimeCompareMode.day) < 0) {
                    setState(() => _hoveredStartDate = _hoveredEndDate = date);
                  } else if (date.compareToEx(_selectedStartDate, DateTimeCompareMode.day) <= 0) {
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
        } else if (widget.showDisabledCursor) {
          child = MouseRegion(
            cursor: SystemMouseCursors.forbidden,
            child: child,
          );
        }
        if (widget.enableRangeSelection) {
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
    final textStyle = theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface);
    final borderRadius = BorderRadius.circular(_childSize!.height / 4 - 32);
    final children = <Widget>[];
    final now = DateTime.now();
    for (int i = 1; i <= 12; i++) {
      final date = DateTime(_viewStartDate.year, i);
      final isEnabled = (date.compareToEx(widget.firstDate, DateTimeCompareMode.month) >= 0) && (date.compareToEx(widget.lastDate, DateTimeCompareMode.month) <= 0);
      final isSelected = date.compareToEx(_selectedStartDate, DateTimeCompareMode.month) == 0;
      final isNow = date.compareToEx(now, DateTimeCompareMode.month) == 0;
      final color = isEnabled ? widget.selectedDayColor ?? theme.colorScheme.primary : (widget.selectedDayColor ?? theme.colorScheme.primary).withAlpha(128);
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
          onTap: () {
            if (widget.initViewMode == PickerViewMode.month) {
              setState(() => _selectedStartDate = _selectedEndDate = date);
            } else {
              _onViewModeChanged(next: false, date: date);
            }
          },
          borderRadius: borderRadius,
          child: child,
        );
      } else {
        child = MouseRegion(
          cursor: SystemMouseCursors.forbidden,
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
    final textStyle = theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface);
    final borderRadius = BorderRadius.circular(_childSize!.height / 5 - 16);
    final children = <Widget>[];
    final now = DateTime.now();
    final year = _viewStartDate.year - _viewStartDate.year % 20;
    for (int i = 0; i < 20; i++) {
      final date = DateTime(year + i);
      final isEnabled = (date.year >= widget.firstDate.year) && (date.year <= widget.lastDate.year);
      final isSelected = date.year == _selectedStartDate.year;
      final isNow = date.year == now.year;
      final color = isEnabled ? widget.selectedDayColor ?? theme.colorScheme.primary : (widget.selectedDayColor ?? theme.colorScheme.primary).withAlpha(128);
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
          onTap: () {
            if (widget.initViewMode == PickerViewMode.year) {
              setState(() => _selectedStartDate = _selectedEndDate = date);
            } else {
              _onViewModeChanged(next: false, date: date);
            }
          },
          borderRadius: borderRadius,
          child: child,
        );
      } else if (widget.showDisabledCursor) {
        child = MouseRegion(
          cursor: SystemMouseCursors.forbidden,
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
    final textStyle = theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface);
    final borderRadius = BorderRadius.circular(_childSize!.height / 5 - 16);
    final children = <Widget>[];
    final now = DateTime.now();
    final year = _viewStartDate.year - _viewStartDate.year % 200;
    for (int i = 0; i < 10; i++) {
      final date = DateTime(year + i * 20);
      final isEnabled = (widget.firstDate.year <= date.year || (widget.firstDate.year - date.year) <= 20) && (date.year + 20 <= widget.lastDate.year || (date.year - widget.lastDate.year) <= 0);
      final isSelected = _selectedStartDate.year >= date.year && (_selectedStartDate.year - date.year) < 20;
      final isNow = now.year >= date.year && (now.year - date.year) < 20;
      final color = isEnabled ? widget.selectedDayColor ?? theme.colorScheme.primary : (widget.selectedDayColor ?? theme.colorScheme.primary).withAlpha(128);
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
          onTap: () {
            if (widget.initViewMode == PickerViewMode.century) {
              setState(() {
                _selectedStartDate = date;
                _selectedEndDate = DateTime(date.year + 19);
              });
            } else {
              _onViewModeChanged(next: false, date: date);
            }
          },
          borderRadius: borderRadius,
          child: child,
        );
      } else if (widget.showDisabledCursor) {
        child = MouseRegion(
          cursor: SystemMouseCursors.forbidden,
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
    switch (_curViewMode) {
      case PickerViewMode.day:
        return UniformGrid(
          key: _PickerKey(date: _viewStartDate, viewMode: _curViewMode),
          columnCount: 7,
          squareCell: true,
          onSizeChanged: _onSizeChanged,
          children: _buildDaysOfMonthCells(theme),
        );
      case PickerViewMode.month:
        return UniformGrid(
          key: _PickerKey(date: _viewStartDate, viewMode: _curViewMode),
          columnCount: 3,
          withHeader: false,
          fixedSize: _childSize,
          children: _buildMonthsOfYearCells(theme),
        );
      case PickerViewMode.year:
        return UniformGrid(
          key: _PickerKey(date: _viewStartDate, viewMode: _curViewMode),
          columnCount: 4,
          withHeader: false,
          fixedSize: _childSize,
          children: _buildYearsCells(theme),
        );
      case PickerViewMode.century:
        return UniformGrid(
          key: _PickerKey(date: _viewStartDate, viewMode: _curViewMode),
          columnCount: 2,
          withHeader: false,
          fixedSize: _childSize,
          children: _buildYearsOfCenturyCells(theme),
        );
    }
  }

  void _onSelectToday() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final isEnabled = today.isInDateRange(widget.firstDate, widget.lastDate) && 
                      !today.isBlockedDate(widget.blockedDates, today);

    if (!isEnabled) {
      setState(() {
        _viewStartDate = today;
        _curViewMode = PickerViewMode.day;
      });
      return; 
    }

    if (widget.enableRangeSelection) {
      setState(() {
        _viewStartDate = today;
        _curViewMode = PickerViewMode.day;
        _selectedStartDate = today;
        _selectedEndDate = today;
        _hoveredStartDate = null;
        _hoveredEndDate = null;
      });
    } else {
      setState(() {
        _viewStartDate = today;
        _curViewMode = PickerViewMode.day;
        _selectedStartDate = today;
        _selectedEndDate = today;
      });

      if (widget.autoCloseOnDateSelect) {
        Navigator.of(context).pop(DateTimeRange(start: _selectedStartDate, end: _selectedEndDate));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = MaterialLocalizations.of(context);
    Widget navTitle;
    bool isFirst = false, isLast = false, nextView = true;
    final txtDirection = Directionality.of(context);
    switch (_curViewMode) {
      case PickerViewMode.day:
        navTitle = Container(
          height: kActionHeight,
          alignment: Alignment.center,
          child: Text(
            localizations.formatMonthYear(_viewStartDate).capitalize(),
            style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold),
          ),
        );
        final monthDateRange = _viewStartDate.monthDateTimeRange(
          includeTrailingAndLeadingDates: false,
          numberCellsOfMonth: kNumberCellsOfMonth,
        );
        isFirst = widget.firstDate.compareToEx(monthDateRange.start, DateTimeCompareMode.day) >= 0;
        isLast = widget.lastDate.compareToEx(monthDateRange.end, DateTimeCompareMode.day) <= 0;
        nextView = widget.lastDate.difference(widget.firstDate).inDays > 28;
        break;
      case PickerViewMode.month:
        navTitle = Container(
          height: kActionHeight,
          alignment: Alignment.center,
          child: Text(
            localizations.formatYear(_viewStartDate),
            style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold),
          ),
        );
        isFirst = _viewStartDate.year <= widget.firstDate.year;
        isLast = _viewStartDate.year >= widget.lastDate.year;
        nextView = widget.lastDate.year != widget.firstDate.year;
        break;
      case PickerViewMode.year:
        final year = _viewStartDate.year - _viewStartDate.year % 20;
        isFirst = year <= widget.firstDate.year;
        isLast = year + 20 >= widget.lastDate.year;
        navTitle = Container(
          height: kActionHeight,
          alignment: Alignment.center,
          child: Text(
            "$year - ${year + 19}",
            style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold),
          ),
        );
        nextView = widget.lastDate.year - widget.firstDate.year > 20;
        break;
      case PickerViewMode.century:
        final year = _viewStartDate.year - _viewStartDate.year % 200;
        isFirst = year <= widget.firstDate.year;
        isLast = year + 200 >= widget.lastDate.year;
        navTitle = Container(
          height: kActionHeight,
          alignment: Alignment.center,
          child: Text(
            "$year - ${year + 199}",
            style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold),
          ),
        );
        nextView = false;
        break;
    }
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 1.0, vertical: 4.0),
      elevation: 1.0,
      color: widget.backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// Navigation
            Row(
              children: txtDirection == TextDirection.ltr
                  ? [
                      isFirst
                          ? _iconWidget(Icons.keyboard_arrow_left, color: theme.disabledColor)
                          : _iconWidget(
                              Icons.keyboard_arrow_left,
                              onTap: () => _onStartDateChanged(next: false),
                            ),
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
                          ? _iconWidget(
                              Icons.keyboard_arrow_right,
                              color: theme.disabledColor,
                            )
                          : _iconWidget(
                              Icons.keyboard_arrow_right,
                              onTap: () => _onStartDateChanged(next: true),
                            ),
                    ]
                  : [
                      isLast
                          ? _iconWidget(
                              Icons.keyboard_arrow_right,
                              color: theme.disabledColor,
                            )
                          : _iconWidget(
                              Icons.keyboard_arrow_right,
                              onTap: () => _onStartDateChanged(next: true),
                            ),
                      nextView
                          ? Expanded(
                              child: InkWell(
                                onTap: () => _onViewModeChanged(next: true),
                                borderRadius: BorderRadius.circular(4.0),
                                child: navTitle,
                              ),
                            )
                          : Expanded(child: navTitle),
                      isFirst ? _iconWidget(Icons.keyboard_arrow_left, color: theme.disabledColor) : _iconWidget(Icons.keyboard_arrow_left, onTap: () => _onStartDateChanged(next: false)),
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
                if (widget.showResetButton)
                  _iconWidget(
                    Icons.restart_alt,
                    tooltip: localizations.backButtonTooltip,
                    onTap: _onResetState,
                  ),
                if (widget.showResetButton && widget.showTodayButton) const SizedBox(width: 4.0),

                /// Today
                if (widget.showTodayButton)
                  if (widget.todayButtonText != null)
                    TextButton(
                      onPressed: _onSelectToday,
                      child: Text(
                        widget.todayButtonText!,
                        style: TextStyle(
                          color: widget.confirmButtonColor ?? theme.colorScheme.primary,
                        ),
                      ),
                    )
                  else
                    _iconWidget(
                      Icons.today,
                      tooltip: localizations.currentDateLabel,
                      onTap: _onSelectToday,
                    ),

                const Spacer(),

                /// CANCEL
                if (widget.showCancelButton)
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      localizations.cancelButtonLabel,
                      style: TextStyle(color: widget.cancelButtonColor ?? theme.colorScheme.primary),
                    ),
                  ),

                /// OK
                if (widget.showOkButton && _curViewMode == widget.initViewMode) ...[
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

  Widget _iconWidget(
    IconData icon, {
    Color? color,
    String? tooltip,
    GestureTapCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final iconColor = color ?? theme.colorScheme.onSurface;
    final child = Container(
      height: kActionHeight,
      width: kActionHeight,
      alignment: Alignment.center,
      child: tooltip != null ? Tooltip(message: tooltip, child: Icon(icon, color: iconColor)) : Icon(icon, color: iconColor),
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
      switch (_curViewMode) {
        case PickerViewMode.day:
          date = next ? _viewStartDate.nextMonth : _viewStartDate.previousMonth;
          break;
        case PickerViewMode.month:
          date = next ? _viewStartDate.nextYear : _viewStartDate.previousYear;
          break;
        case PickerViewMode.year:
          final year = _viewStartDate.year - _viewStartDate.year % 20;
          date = next ? DateTime(year + 20) : DateTime(year - 20);
          break;
        case PickerViewMode.century:
          final year = _viewStartDate.year - _viewStartDate.year % 200;
          date = next ? DateTime(year + 200) : DateTime(year - 200);
          break;
      }
    } else {
      final year20 = _viewStartDate.year - _viewStartDate.year % 20;
      final year200 = _viewStartDate.year - _viewStartDate.year % 200;
      date = DateTime.now();
      if (_curViewMode == PickerViewMode.day && date.month == _viewStartDate.month ||
          _curViewMode == PickerViewMode.month && date.year == _viewStartDate.year ||
          _curViewMode == PickerViewMode.year && date.year >= year20 && (date.year - year20) < 20 ||
          _curViewMode == PickerViewMode.century && date.year >= year200 && (date.year - year200) < 200) {
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
    final nextViewMode = next ? _curViewMode.next() : _curViewMode.previous(initViewMode: widget.initViewMode);
    if (nextViewMode != _curViewMode) {
      setState(() {
        _isViewModeChanged = true;
        _curViewMode = nextViewMode;
        if (date != null) {
          _viewStartDate = date;
        }
      });
    }
  }

  void _onResetState() {
    setState(
      () {
        _selectedStartDate = widget.initialDate;
        _viewStartDate = widget.initialDate;
        _selectedEndDate = widget.enableRangeSelection ? widget.initialDate2 ?? _selectedStartDate : _selectedStartDate;
        _isViewModeChanged = _curViewMode != widget.initViewMode;
        _curViewMode = widget.initViewMode;
        _slideDirection = widget.initialDate.isAfter(_viewStartDate) ? 1.0 : -1.0;
      },
    );
    if (widget.onReset != null) widget.onReset?.call();
  }

  void _onSizeChanged(Size size, Size cellSize) {
    // print("_onSizeChanged(size: $size, cellSize: $cellSize)");
    _childSize = size;
  }
}

enum PickerViewMode {
  day,
  month,
  year,
  century;

  PickerViewMode next() {
    switch (this) {
      case PickerViewMode.day:
        return PickerViewMode.month;
      case PickerViewMode.month:
        return PickerViewMode.year;
      case PickerViewMode.year:
        return PickerViewMode.century;
      case PickerViewMode.century:
        return PickerViewMode.century;
    }
  }

  PickerViewMode previous({PickerViewMode initViewMode = PickerViewMode.day}) {
    if (initViewMode == this) return this;
    switch (this) {
      case PickerViewMode.day:
        return PickerViewMode.day;
      case PickerViewMode.month:
        return PickerViewMode.day;
      case PickerViewMode.year:
        return PickerViewMode.month;
      case PickerViewMode.century:
        return PickerViewMode.year;
    }
  }
}

class _PickerKey extends LocalKey {
  const _PickerKey({required this.date, required this.viewMode});

  final DateTime date;
  final PickerViewMode viewMode;

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
