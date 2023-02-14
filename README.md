## Flutter Date Picker for Flutter Web application

[![Pub.Dev](https://img.shields.io/pub/v/vph_web_date_picker?color=blue&style=flat-square)](https://pub.dev/packages/vph_web_date_picker)
[![Demo Web](https://img.shields.io/badge/demo-web-green?style=flat-square)](https://ngocvuphan.github.io/demo_web_date_picker/)

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
            );
            if (pickedDate != null) {
                _selectedDate = pickedDate;
                _controller.text = pickedDate.toString();
            }
        },
    ),
    ...
```
