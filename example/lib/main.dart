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
  late DateTimeRange _selectedDateRange;
  Locale? _locale;
  bool _asDialog = false;
  bool _enableDateRangeSelection = true;

  static const _supportedLocales = [
    Locale('en', 'US'),
    Locale('vi', 'VN'),
    Locale('es', 'ES'),
    Locale('it', 'IT'),
  ];

  @override
  void initState() {
    super.initState();
    _selectedDateRange = DateTimeRange(start: DateTime.now(), end: DateTime.now());
    _controller = TextEditingController(
        text: _enableDateRangeSelection
            ? "From ${_selectedDateRange.start.toString().split(' ')[0]} to ${_selectedDateRange.end.toString().split(' ')[0]}"
            : _selectedDateRange.start.toString().split(' ')[0]);
    _locale = _supportedLocales[0];
  }

  @override
  Widget build(BuildContext context) {
    final textFieldKey = GlobalKey();
    return MaterialApp(
      supportedLocales: _supportedLocales,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      locale: _locale,
      title: 'Web Date Picker Demo',
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(32),
          child: SizedBox(
            width: 400,
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
                Row(
                  children: [
                    Checkbox(
                      value: _enableDateRangeSelection,
                      onChanged: (v) => setState(() {
                        _enableDateRangeSelection = v!;
                      }),
                    ),
                    const Text("enableDateRangeSelection"),
                  ],
                ),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
