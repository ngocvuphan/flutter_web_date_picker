import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension ListExtension on List {
  List rotate(int start) {
    if (isEmpty || start == 0) return this;
    final i = start % length;
    return sublist(i)..addAll(sublist(0, i));
  }
}

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
    assert(start.dateCompareTo(end) <= 0);
    return dateCompareTo(start) >= 0 && dateCompareTo(end) <= 0;
  }

  int monthCompareTo(DateTime other) {
    if (year < other.year) {
      return -1;
    } else if (year > other.year) {
      return 1;
    } else {
      if (month < other.month) {
        return -1;
      } else if (month > other.month) {
        return 1;
      } else {
        return 0;
      }
    }
  }

  int dateCompareTo(DateTime other) {
    final cmp = monthCompareTo(other);
    if (cmp == 0) {
      if (day < other.day) {
        return -1;
      } else if (day > other.day) {
        return 1;
      } else {
        return 0;
      }
    } else {
      return cmp;
    }
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
