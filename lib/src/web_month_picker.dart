import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:vph_common_widgets/vph_common_widgets.dart';
import 'package:vph_web_date_picker/vph_web_date_picker.dart';

import 'helpers/extensions.dart';

/// Shows a dialog containing a month-year picker.
///
/// The returned [Future] resolves to the date selected by the user when the
/// user confirms the dialog. If the user cancels the dialog, null is returned.
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
Future<DateTime?> showWebMonthPicker({
  required BuildContext context,
  required DateTime initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
  double? width,
  bool withoutActionButtons = false,
  Color? weekendDaysColor,
  Color? selectedDayColor,
  Color? confirmButtonColor,
  Color? cancelButtonColor,
  Color? backgroundColor,
  int? firstDayOfWeekIndex,
  bool asDialog = false,
  List<DateTime>? blockedMonths,
}) {
  if (asDialog) {
    final renderBox = context.findRenderObject()! as RenderBox;
    return showDialog<DateTime?>(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        content: SingleChildScrollView(
          child: SizedBox(
            width: width ?? renderBox.size.width,
            child: _WebMonthPicker(
              initialDate: initialDate,
              firstDate: firstDate ?? DateTime(0),
              lastDate: lastDate ?? DateTime(100000),
              withoutActionButtons: withoutActionButtons,
              weekendDaysColor: weekendDaysColor,
              firstDayOfWeekIndex: firstDayOfWeekIndex ?? 0,
              selectedDayColor: selectedDayColor,
              confirmButtonColor: confirmButtonColor,
              cancelButtonColor: cancelButtonColor,
              backgroundColor: backgroundColor,
              blockedDates: blockedMonths ?? [],
            ),
          ),
        ),
      ),
    );
  } else {
    return showPopupDialog<DateTime?>(
      context,
      (context) => _WebMonthPicker(
        initialDate: initialDate,
        firstDate: firstDate ?? DateTime(0),
        lastDate: lastDate ?? DateTime(100000),
        withoutActionButtons: withoutActionButtons,
        weekendDaysColor: weekendDaysColor,
        firstDayOfWeekIndex: firstDayOfWeekIndex ?? 0,
        selectedDayColor: selectedDayColor,
        confirmButtonColor: confirmButtonColor,
        cancelButtonColor: cancelButtonColor,
        backgroundColor: backgroundColor,
        blockedDates: blockedMonths ?? [],
      ),
      asDropDown: true,
      useTargetWidth: width != null ? false : true,
      dialogWidth: width,
    );
  }
}

class _WebMonthPicker extends StatefulWidget {
  const _WebMonthPicker({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.blockedDates,
    this.withoutActionButtons = false,
    this.weekendDaysColor,
    required this.firstDayOfWeekIndex,
    this.selectedDayColor,
    this.confirmButtonColor,
    this.cancelButtonColor,
    this.backgroundColor,
  });

  final List<DateTime> blockedDates;
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final bool withoutActionButtons;
  final Color? weekendDaysColor;
  final int firstDayOfWeekIndex;
  final Color? selectedDayColor;
  final Color? confirmButtonColor;
  final Color? cancelButtonColor;
  final Color? backgroundColor;

  @override
  State<_WebMonthPicker> createState() => _WebMonthPickerState();
}

class _WebMonthPickerState extends State<_WebMonthPicker> {
  late DateTime _selectedStartDate;
  late DateTime _viewStartDate;

  double _slideDirection = 1.0;
  MonthPickerViewMode _viewMode = MonthPickerViewMode.month;
  bool _isViewModeChanged = false;
  Size? _childSize;

  @override
  void initState() {
    super.initState();
    _childSize = Size(250, 300);
    _selectedStartDate = _viewStartDate = DateTime(
      widget.initialDate.year,
      widget.initialDate.month,
      widget.initialDate.day,
    );
  }

  List<Widget> _buildMonthsOfYearCells(ThemeData theme) {
    final textStyle = theme.textTheme.bodySmall?.copyWith(color: Colors.black);
    final borderRadius = BorderRadius.circular(_childSize!.height / 4 - 32);
    final children = <Widget>[];
    final now = DateTime.now();
    for (int i = 1; i <= 12; i++) {
      final date = DateTime(_viewStartDate.year, i);
      final isEnabled = (date.monthCompareTo(widget.firstDate) >= 0) &&
          (date.monthCompareTo(widget.lastDate) <= 0);
      final isSelected = date.monthCompareTo(_selectedStartDate) == 0;
      final isNow = date.monthCompareTo(now) == 0;
      final color = isEnabled
          ? widget.selectedDayColor ?? theme.colorScheme.primary
          : (widget.selectedDayColor ?? theme.colorScheme.primary)
              .withOpacity(0.5);
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
            setState(() => _selectedStartDate = date);
          },
          customBorder: const CircleBorder(),
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
      final isEnabled = (date.year >= widget.firstDate.year) &&
          (date.year <= widget.lastDate.year);
      final isSelected = date.year == _selectedStartDate.year;
      final isNow = date.year == now.year;
      final color = isEnabled
          ? widget.selectedDayColor ?? theme.colorScheme.primary
          : (widget.selectedDayColor ?? theme.colorScheme.primary)
              .withOpacity(0.5);
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
      final isEnabled = (widget.firstDate.year <= date.year ||
              (widget.firstDate.year - date.year) <= 20) &&
          (date.year + 20 <= widget.lastDate.year ||
              (date.year - widget.lastDate.year) <= 0);
      final isSelected = _selectedStartDate.year >= date.year &&
          (_selectedStartDate.year - date.year) < 20;
      final isNow = now.year >= date.year && (now.year - date.year) < 20;
      final color = isEnabled
          ? widget.selectedDayColor ?? theme.colorScheme.primary
          : (widget.selectedDayColor ?? theme.colorScheme.primary)
              .withOpacity(0.5);
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
      case MonthPickerViewMode.month:
        return UniformGrid(
          key: _PickerKey(date: _viewStartDate, viewMode: _viewMode),
          columnCount: 3,
          withHeader: false,
          fixedSize: _childSize,
          children: _buildMonthsOfYearCells(theme),
        );
      case MonthPickerViewMode.year:
        return UniformGrid(
          key: _PickerKey(date: _viewStartDate, viewMode: _viewMode),
          columnCount: 4,
          withHeader: false,
          fixedSize: _childSize,
          children: _buildYearsCells(theme),
        );
      case MonthPickerViewMode.century:
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
    final txtDirection = Directionality.of(context);
    switch (_viewMode) {
      case MonthPickerViewMode.month:
        navTitle = Container(
          height: kActionHeight,
          alignment: Alignment.center,
          child: Text(
            localizations.formatYear(_viewStartDate),
            style: theme.textTheme.bodyLarge
                ?.copyWith(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        );
        isFirst = _viewStartDate.year <= widget.firstDate.year;
        isLast = _viewStartDate.year >= widget.lastDate.year;
        nextView = widget.lastDate.year != widget.firstDate.year;
        break;
      case MonthPickerViewMode.year:
        final year = _viewStartDate.year - _viewStartDate.year % 20;
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
      case MonthPickerViewMode.century:
        final year = _viewStartDate.year - _viewStartDate.year % 200;
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
              children: txtDirection == TextDirection.LTR
                  ? [
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
                    ]
                  : [
                      isLast
                          ? _iconWidget(Icons.keyboard_arrow_right,
                              color: theme.disabledColor)
                          : _iconWidget(Icons.keyboard_arrow_right,
                              onTap: () => _onStartDateChanged(next: true)),
                      nextView
                          ? Expanded(
                              child: InkWell(
                                onTap: () => _onViewModeChanged(next: true),
                                borderRadius: BorderRadius.circular(4.0),
                                child: navTitle,
                              ),
                            )
                          : Expanded(child: navTitle),
                      isFirst
                          ? _iconWidget(Icons.keyboard_arrow_left,
                              color: theme.disabledColor)
                          : _iconWidget(Icons.keyboard_arrow_left,
                              onTap: () => _onStartDateChanged(next: false)),
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
                    double dx = (child.key as _PickerKey).date == _viewStartDate
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
                  child: Text(
                    localizations.cancelButtonLabel,
                    style: TextStyle(
                        color: widget.cancelButtonColor ??
                            theme.colorScheme.primary),
                  ),
                ),

                /// OK
                if (_viewMode == MonthPickerViewMode.month) ...[
                  const SizedBox(width: 4.0),
                  TextButton(
                    onPressed: () =>
                        Navigator.of(context).pop(_selectedStartDate),
                    child: Text(
                      localizations.okButtonLabel,
                      style: TextStyle(
                          color: widget.confirmButtonColor ??
                              theme.colorScheme.primary),
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
        case MonthPickerViewMode.month:
          date = next ? _viewStartDate.nextYear : _viewStartDate.previousYear;
          break;
        case MonthPickerViewMode.year:
          final year = _viewStartDate.year - _viewStartDate.year % 20;
          date = next ? DateTime(year + 20) : DateTime(year - 20);
          break;
        case MonthPickerViewMode.century:
          final year = _viewStartDate.year - _viewStartDate.year % 200;
          date = next ? DateTime(year + 200) : DateTime(year - 200);
          break;
      }
    } else {
      final year20 = _viewStartDate.year - _viewStartDate.year % 20;
      final year200 = _viewStartDate.year - _viewStartDate.year % 200;
      date = DateTime.now();
      if (_viewMode == MonthPickerViewMode.month &&
              date.year == _viewStartDate.year ||
          _viewMode == MonthPickerViewMode.year &&
              date.year >= year20 &&
              (date.year - year20) < 20 ||
          _viewMode == MonthPickerViewMode.century &&
              date.year >= year200 &&
              (date.year - year200) < 200) {
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
        _slideDirection =
            widget.initialDate.isAfter(_viewStartDate) ? 1.0 : -1.0;
        _selectedStartDate = _viewStartDate = widget.initialDate;
        _isViewModeChanged = _viewMode != MonthPickerViewMode.month;
        _viewMode = MonthPickerViewMode.month;
      },
    );
  }
}

enum MonthPickerViewMode {
  month,
  year,
  century;

  MonthPickerViewMode next() {
    switch (this) {
      case MonthPickerViewMode.month:
        return MonthPickerViewMode.year;
      case MonthPickerViewMode.year:
        return MonthPickerViewMode.century;
      case MonthPickerViewMode.century:
        return MonthPickerViewMode.century;
    }
  }

  MonthPickerViewMode previous() {
    switch (this) {
      case MonthPickerViewMode.month:
        return MonthPickerViewMode.month;
      case MonthPickerViewMode.year:
        return MonthPickerViewMode.month;
      case MonthPickerViewMode.century:
        return MonthPickerViewMode.year;
    }
  }
}

class _PickerKey extends LocalKey {
  const _PickerKey({required this.date, required this.viewMode});

  final DateTime date;
  final MonthPickerViewMode viewMode;

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
