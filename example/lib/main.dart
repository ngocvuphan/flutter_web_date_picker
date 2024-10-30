import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:vph_web_date_picker/vph_web_date_picker.dart';

// import 'material_theme/color_schemes.g.dart';

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
  Locale? _locale;
  bool _asDialog = false;

  static const _supportedLocales = [
    Locale('en', 'US'),
    Locale('vi', 'VN'),
    Locale('es', 'ES'),
    Locale('it', 'IT'),
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _controller =
        TextEditingController(text: _selectedDate.toString().split(' ')[0]);
    _locale = _supportedLocales[0];
  }

  @override
  Widget build(BuildContext context) {
    final textFieldKey = GlobalKey();
    return MaterialApp(
      supportedLocales: _supportedLocales,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
      ],
      locale: _locale,
      title: 'Web Date Picker Demo',
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(32),
          child: SizedBox(
            width: 300,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButton<Locale>(
                  isExpanded: true,
                  value: _locale,
                  items: _supportedLocales
                      .map(
                        (e) => DropdownMenuItem<Locale>(
                          value: e,
                          child: Text(e.toString()),
                        ),
                      )
                      .toList(),
                  onChanged: (e) {
                    setState(() {
                      _locale = e;
                    });
                  },
                ),
                Row(
                  children: [
                    Checkbox(
                      value: _asDialog,
                      onChanged: (v) => setState(() {
                        _asDialog = v!;
                      }),
                    ),
                    const Text("asDialog"),
                  ],
                ),
                TextField(
                  key: textFieldKey,
                  controller: _controller,
                  readOnly: true,
                  onTap: () async {
                    final pickedDate = await showWebDatePicker(
                      context: textFieldKey.currentContext!,
                      initialDate: _selectedDate,
                      firstDate:
                          DateTime.now().subtract(const Duration(days: 7)),
                      lastDate: DateTime.now().add(const Duration(days: 14000)),
                      // width: 400,
                      // withoutActionButtons: true,
                      weekendDaysColor: Colors.red,
                      // selectedDayColor: Colors.brown
                      // firstDayOfWeekIndex: 1,
                      asDialog: _asDialog,
                    );
                    if (pickedDate != null) {
                      _selectedDate = pickedDate;
                      _controller.text = pickedDate.toString().split(' ')[0];
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
