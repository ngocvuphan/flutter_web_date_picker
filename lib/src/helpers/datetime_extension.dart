import 'package:flutter/material.dart';

const kNumberCellsOfMonth = 42;
const kNumberOfWeekday = 7;
const kNumberOfMonth = 12;

const kWeekdayNames = <String>[
  "Sunday",
  "Monday",
  "Tuesday",
  "Wednesday",
  "Thursday",
  "Friday",
  "Saturday"
];
const kWeekdayShortNames = <String>[
  "Sun",
  "Mon",
  "Tue",
  "Wed",
  "Thu",
  "Fri",
  "Sat"
];
const kWeekdayAbbreviations = <String>["S", "M", "T", "W", "T", "F", "S"];
const kMonthNames = <String>[
  "January",
  "February",
  "March",
  "April",
  "May",
  "June",
  "July",
  "August",
  "September",
  "October",
  "November",
  "December"
];
const kMonthShortNames = <String>[
  "Jan",
  "Feb",
  "Mar",
  "Apr",
  "May",
  "Jun",
  "Jul",
  "Aug",
  "Sep",
  "Oct",
  "Nov",
  "Dec"
];

extension DateTimeExtension on DateTime {
  DateTime get nextMonth => DateTime(year, month + 1);
  DateTime get previousMonth => DateTime(year, month - 1);

  DateTime get nextYear => DateTime(year + 1);
  DateTime get previousYear => DateTime(year - 1);

  DateTimeRange monthDateTimeRange(
      {bool includeTrailingAndLeadingDates = false}) {
    DateTime start = DateTime(year, month);
    if (includeTrailingAndLeadingDates) {
      start = start.subtract(Duration(days: start.weekday % kNumberOfWeekday));
    }
    DateTime end = includeTrailingAndLeadingDates
        ? start.add(const Duration(days: kNumberCellsOfMonth))
        : DateTime(year, month + 1, 0);
    return DateTimeRange(start: start, end: end);
  }

  bool isInRange(DateTimeRange range) {
    return difference(range.start).inSeconds >= 0 &&
        difference(range.end).inSeconds <= 0;
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
