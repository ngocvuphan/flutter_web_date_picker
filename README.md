## Flutter date picker package for web application

[![Pub.Dev](https://img.shields.io/pub/v/vph_web_date_picker?color=blue&style=flat-square)](https://pub.dev/packages/vph_web_date_picker)
[![Demo Web](https://img.shields.io/badge/demo-web-green?style=flat-square)](https://ngocvuphan.github.io/demo_web_date_picker/)

### Showcase

<img src="https://user-images.githubusercontent.com/756333/220562689-c232ce03-877e-48eb-83f5-0ed208ee0854.gif" width=400>

### Usage

```dart
    final textFieldKey = GlobalKey();
    ...
    TextField(
        key: textFieldKey,
        controller: _controller,
        readOnly: true,
        onTap: () async {
            final pickedDateRange = await showWebDatePicker(
                context: textFieldKey.currentContext!,
                initialDate: _selectedDateRange.start,
                initialDate2: _selectedDateRange.end,
                firstDate: DateTime.now().subtract(const Duration(days: 7)),
                lastDate: DateTime.now().add(const Duration(days: 14000)),
                // width: 400,
                // withoutActionButtons: true,
                weekendDaysColor: Colors.red,
                // selectedDayColor: Colors.brown
                // firstDayOfWeekIndex: 1,
                asDialog: _asDialog,
                enableDateRangeSelection: _enableDateRangeSelection,
            );
            if (pickedDateRange != null) {
                _selectedDateRange = pickedDateRange;
                if (_enableDateRangeSelection) {
                _controller.text = "From ${_selectedDateRange.start.toString().split(' ')[0]} to ${_selectedDateRange.end.toString().split(' ')[0]}";
                } else {
                _controller.text = _selectedDateRange.start.toString().split(' ')[0];
                }
            }
        },
    ),
    ...
```

`showWebDatePicker` shows a dialog containing a date picker.

The returned [`Future`](https://api.flutter.dev/flutter/dart-async/Future-class.html) resolves to the date selected by the user when the
user confirms the dialog. If the user cancels the dialog, null is returned.

When the date picker is first displayed, it will show the month of
`initialDate`, with `initialDate` selected.

The `firstDate` is the earliest allowable date. The `lastDate` is the latest
allowable date. `initialDate` must either fall between these dates,
or be equal to one of them

The `width` define the width of date picker dialog

The month view action buttons include:

- Reset button: jump to `initialDate` and select it
- Today button: jump to today and select it

The `withoutActionButtons` is `true`, the action buttons are removed from the month view. Default is `false`

The `weekendDaysColor` defines the color of weekend days Saturday and Sunday. Default is `null`

The `firstDayOfWeekIndex` defines the first day of the week.
By default, firstDayOfWeekIndex = 0 indicates that Sunday is considered the first day of the week

The `selectedDayColor` defines the color of selected day. Default is `primary` color

The `confirmButtonColor` defines the color of confirm button. Default is `primary` color

The `cancelButtonColor` defines the color of cancel button. Default is `primary` color

The `asDialog` = `true` will show the picker as dialog. By default, the picker is show as dropdown

The `enableDateRangeSelection` is `true` to enable `DateRange` selection. The `initialDate` corresponds to `DateRange.start` and `initialDate2` corresponds to `DateRange.end`
