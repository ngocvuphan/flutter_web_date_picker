import 'package:flutter/widgets.dart';

class WebDayEvent {
  DateTime eventDate;
  Widget? customEventWidget;

  WebDayEvent({required this.eventDate, this.customEventWidget});
}
