## Flutter date picker package for web application

[![Pub.Dev](https://img.shields.io/pub/v/vph_web_date_picker?color=blue&style=flat-square)](https://pub.dev/packages/vph_web_date_picker)
[![Demo Web](https://img.shields.io/badge/demo-web-green?style=flat-square)](https://ngocvuphan.github.io/demo_web_date_picker/)

### Showcase

<img src="https://user-images.githubusercontent.com/756333/220562689-c232ce03-877e-48eb-83f5-0ed208ee0854.gif" width=400>

## 📅 `showWebDatePicker`

A customizable date picker widget for Flutter Web that supports both single-date and range selection. It offers extensive appearance and behavior customization for seamless integration into your UI.

### ✅ Purpose

Displays a date picker interface and returns a `Future<DateTimeRange?>` that resolves to the selected date(s) or `null` if canceled.

---

### 🧩 Parameters

#### 🗓️ Date Configuration

- `context` _(required)_: The build context.
- `initialDate` _(required)_: The default date shown when the picker opens.
- `initialDate2`: Optional second date for range selection.
- `firstDate`: Earliest selectable date.
- `lastDate`: Latest selectable date.

#### 🎨 Appearance Customization

- `width`: Width of the picker.
- `weekendDaysColor`: Color used for weekend days.
- `selectedDayColor`: Color for selected date(s).
- `confirmButtonColor`: Color of the confirm button.
- `cancelButtonColor`: Color of the cancel button.
- `backgroundColor`: Background color of the picker.

#### 📐 Layout & View

- `firstDayOfWeekIndex`: Index of the first day of the week (e.g., 0 = Sunday).
- `initViewMode`: Initial view mode (`PickerViewMode.day`, `month`, etc.).
- `initSize`: Initial size of the picker widget.
- `asDialog`: If `true`, shows the picker as a modal dialog.

#### 🔄 Interaction Behavior

- `enableRangeSelection`: Enables selecting a date range.
- `blockedDates`: List of dates that are disabled and cannot be selected.
- `showTodayButton`: Displays a button to jump to today's date.
- `showResetButton`: Displays a button to reset the selection.
- `autoCloseOnDateSelect`: Automatically closes the picker **after selecting a date**.  
  **Note:** This only works when `enableRangeSelection` is `false` (i.e., single date selection mode).
- `onReset`: Callback triggered when the reset button is pressed.

---

### 🔁 Return Value

Returns a `Future<DateTimeRange?>`:

- If a date or range is selected → returns `DateTimeRange`.
- If the user cancels → returns `null`.

---

### 💡 Example Usage

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
            width: 400,
            weekendDaysColor: Colors.red,
            // selectedDayColor: Colors.brown,
            // backgroundColor: Colors.white,
            // firstDayOfWeekIndex: 1,
            asDialog: _asDialog,
            enableRangeSelection: _enableRangeSelection,
            blockedDates: [DateTime.now().add(Duration(days: 2))],
            initViewMode: _initViewMode,
            // initSize: Size(370, 350),
            showTodayButton: _showTodayButton,
            showResetButton: _showResetButton,
            autoCloseOnDateSelect: _autoCloseOnDateSelect,
            // onReset: () {
            //   print('Date selection reset');
            // },
        )
    ...
```
