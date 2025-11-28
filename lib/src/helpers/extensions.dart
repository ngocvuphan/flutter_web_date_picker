import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension ListExtension on List {
  List rotate(int start) {
    if (isEmpty || start == 0) return this;
    final i = start % length;
    return sublist(i)..addAll(sublist(0, i));
  }
}

enum DateTimeCompareMode { day, month, year }

extension DateTimeExtension on DateTime {
  DateTime get nextMonth => DateTime(year, month + 1);
  DateTime get previousMonth => DateTime(year, month - 1);

  DateTime get nextYear => DateTime(year + 1);
  DateTime get previousYear => DateTime(year - 1);

  DateTimeRange monthDateTimeRange({
    bool includeTrailingAndLeadingDates = false,
    int firstDayOfWeekIndex = 0,
    int numberCellsOfMonth = 42,
  }) {
    DateTime start = DateTime(year, month).toUtc();
    if (includeTrailingAndLeadingDates) {
      start = start.subtract(Duration(days: (start.weekday - firstDayOfWeekIndex + 7) % 7));
    }
    DateTime end = includeTrailingAndLeadingDates ? start.add(Duration(days: numberCellsOfMonth)).toUtc() : DateTime(year, month + 1, 0).toUtc();
    return DateTimeRange(start: start, end: end);
  }

  bool isInDateRange(DateTime start, DateTime end) {
    assert(start.compareToEx(end, DateTimeCompareMode.day) <= 0);
    return compareToEx(start, DateTimeCompareMode.day) >= 0 && compareToEx(end, DateTimeCompareMode.day) <= 0;
  }

  bool isBlockedDate(List<DateTime> blockedDates, DateTime currentDate) {
    return blockedDates.any((date) => date.year == currentDate.year && date.month == currentDate.month && date.day == currentDate.day);
  }

  int compareToEx(DateTime other, DateTimeCompareMode mode) {
    final yearCmp = year.compareTo(other.year);
    if (mode == DateTimeCompareMode.year || yearCmp != 0) {
      return yearCmp;
    }
    final monthCmp = month.compareTo(other.month);
    if (mode == DateTimeCompareMode.month || monthCmp != 0) {
      return monthCmp;
    }
    return day.compareTo(other.day);
  }
}

class LocaleDateSymbols {
  static List<String> narrowWeekdays(String localeName) {
    return DateFormat.EEEE(localeName).dateSymbols.NARROWWEEKDAYS;
  }

  static List<String> shortMonths(String localeName) {
    return DateFormat.MMMM(localeName).dateSymbols.SHORTMONTHS;
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
