import 'package:flutter/material.dart';
import 'package:vph_web_date_picker/vph_web_date_picker.dart';

import 'material_theme/color_schemes.g.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late TextEditingController _controller;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _controller =
        TextEditingController(text: _selectedDate.toString().split(' ')[0]);
  }

  @override
  Widget build(BuildContext context) {
    final textFieldKey = GlobalKey();
    return MaterialApp(
      title: 'Web Date Picker Demo',
      theme: ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
      darkTheme: ThemeData(useMaterial3: true, colorScheme: darkColorScheme),
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 32.0),
          child: SizedBox(
            width: 150,
            child: TextField(
              key: textFieldKey,
              controller: _controller,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: "yyyy-MM-dd",
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.today),
              ),
              onTap: () async {
                final pickedDate = await showWebDatePicker(
                  context: textFieldKey.currentContext!,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now().add(const Duration(days: 1)),
                  lastDate: DateTime.now().add(const Duration(days: 14000)),
                  width: 300,
                );
                if (pickedDate != null) {
                  _selectedDate = pickedDate;
                  _controller.text = pickedDate.toString().split(' ')[0];
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
