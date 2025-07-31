import 'package:flutter/material.dart';
import 'package:vph_web_date_picker/vph_web_date_picker.dart';
import 'package:intl/intl.dart';

class MonthPicker extends StatefulWidget {
  const MonthPicker({super.key});

  @override
  State<MonthPicker> createState() => _MonthPickerState();
}

class _MonthPickerState extends State<MonthPicker> {
  final TextEditingController _controller = TextEditingController();
  DateTime? _selectedDateRange;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      readOnly: true,
      onTap: () async {
        final pickedDateRange = await showWebMonthPicker(
          context: context,
          initialDate: _selectedDateRange ?? DateTime.now(),
          withoutActionButtons: true,
          width: 300,
          weekendDaysColor: Colors.red,
          selectedDayColor: Colors.brown,
        );
        if (pickedDateRange != null) {
          pickedDateRange;
          _selectedDateRange = pickedDateRange;
          DateFormat dateFormat = DateFormat("yyyy-MM");
          String date = dateFormat.format(_selectedDateRange!);
          _controller.text = date;
        }
      },
    );
  }
}
