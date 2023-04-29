import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fyp_admin_panel/data/resources.dart';

class Header extends StatefulWidget {
  const Header({Key? key}) : super(key: key);

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  final List<String> _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  void initState() {
    Timer.periodic(const Duration(seconds: 1), (timer) => datetimeNotifier.value = DateTime.now());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: ValueListenableBuilder(
            valueListenable: datetimeNotifier,
            builder: (_, datetime, __) {
              return Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: Row(
                  children: [
                    Text(
                      _date(datetime),
                      style: const TextStyle(
                        fontSize: 18.0,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Text(
                      _time(datetime),
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  'Logged in:',
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(width: 4.0),
                Text(
                  'Admin',
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  String _date(DateTime datetime) {
    final String year = datetime.year.toString();
    final String monthString = datetime.month.toString();
    final String month = monthString.length <= 1 ? monthString.padLeft(2, '0') : monthString;
    final String dayString = datetime.day.toString();
    final String day = dayString.length <= 1 ? dayString.padLeft(2, '0') : dayString;
    return '${_days[datetime.weekday - 1]}, $day-$month-$year';
  }

  String _time(DateTime dateTime) {
    final String hourString = dateTime.hour.toString();
    final String hour = hourString.length <= 1 ? hourString.padLeft(2, '0') : hourString;
    final String minuteString = dateTime.minute.toString();
    final String minute = minuteString.length <= 1 ? minuteString.padLeft(2, '0') : minuteString;
    final String secondString = dateTime.second.toString();
    final String second = secondString.length <= 1 ? secondString.padLeft(2, '0') : secondString;
    return '$hour:$minute:$second';
  }
}
