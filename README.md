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
        onTap: () async {
            final pickedDate = await showWebDatePicker(
                context: textFieldKey.currentContext!,
                initialDate: _selectedDate,
                firstDate: DateTime.now().subtract(const Duration(days: 7)),
                lastDate: DateTime.now().add(const Duration(days: 14000)),
                //width: 300,
                //withoutActionButtons: true,
                //weekendDaysColor: Colors.red,
                //firstDayOfWeekIndex: 1,
            );
            if (pickedDate != null) {
                _selectedDate = pickedDate;
                _controller.text = pickedDate.toString();
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
