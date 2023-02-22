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
                firstDate: DateTime.now().add(const Duration(days: 1)),
                lastDate: DateTime.now().add(const Duration(days: 14000)),
                //width: 360,
            );
            if (pickedDate != null) {
                _selectedDate = pickedDate;
                _controller.text = pickedDate.toString();
            }
        },
    ),
    ...
```
