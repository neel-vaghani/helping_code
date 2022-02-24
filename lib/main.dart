// Copyright 2019 Aleksander Woźniak
// SPDX-License-Identifier: Apache-2.0

import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  initializeDateFormatting().then((_) => runApp(MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TableCalendar Exadmple',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StartPage(),
    );
  }
}

class StartPage extends StatefulWidget {
  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: const [
            Text('TableCalendar Example'),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20.0),
            ElevatedButton(
              child: Text('Basics'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TableBasicsExample()),
              ),
            ),
            const SizedBox(height: 12.0),
          ],
        ),
      ),
    );
  }
}

class TableBasicsExample extends StatefulWidget {
  @override
  _TableBasicsExampleState createState() => _TableBasicsExampleState();
}

class _TableBasicsExampleState extends State<TableBasicsExample> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  Rx<DateTime> _focusedDay = DateTime.now().obs;
  DateTime? _selectedDay;
  final DateFormat formatter = DateFormat('MMMM yyyy');

  @override
  Widget build(BuildContext context) {
    RxString formatted = formatter.format(_focusedDay.value).obs;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.brown.shade100,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {
                setState(() {
                  if (_calendarFormat == CalendarFormat.week) {
                    _calendarFormat = CalendarFormat.month;
                  } else {
                    _calendarFormat = CalendarFormat.week;
                  }
                });
              },
              child: const Text('Month'),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Obx(
            () => Padding(
              padding: EdgeInsets.fromLTRB(6, 10, 6, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '2021',
                    style: TextStyle(color: Colors.blue.shade200),
                  ),
                  Text(
                    formatted.value,
                    style: TextStyle(color: Colors.blue.shade900),
                  ),
                  Text(
                    'March',
                    style: TextStyle(color: Colors.blue.shade200),
                  ),
                ],
              ),
            ),
          ),
          TableCalendar(
            pageAnimationEnabled: false,
            firstDay: kFirstDay,
            lastDay: kLastDay,
            focusedDay: _focusedDay.value,
            calendarFormat: _calendarFormat,
            headerVisible: false,
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red,
              ),
              rangeHighlightColor: Colors.red,
              selectedDecoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue,
              ),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: const TextStyle().copyWith(color: Colors.blue[900]),
              weekendStyle: const TextStyle().copyWith(color: Colors.blue[900]),
            ),
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _calendarFormat = CalendarFormat.week;
              });
              if (!isSameDay(_selectedDay, selectedDay)) {
                _focusedDay.value = focusedDay;
                setState(() {
                  _selectedDay = selectedDay;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay.value = focusedDay;
              formatted.value = formatter.format(_focusedDay.value);
            },
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(17, 10, 17, 10),
            padding: const EdgeInsets.all(2),
            child: IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TabButtonUi(
                    text: 'All',
                    selectedPage: true,
                    onTap: () {},
                  ),
                  VerticalDivider(
                    color: true
                        ? Colors.transparent
                        : Color.fromRGBO(142, 142, 147, 1),
                    indent: 8,
                    endIndent: 8,
                    width: 0.01,
                  ),
                  TabButtonUi(
                    text: 'Gym',
                    selectedPage: false,
                    onTap: () {},
                  ),
                  VerticalDivider(
                    color: false
                        ? Colors.transparent
                        : Color.fromRGBO(142, 142, 147, 1),
                    indent: 8,
                    endIndent: 8,
                    width: 0.01,
                  ),
                  TabButtonUi(
                    text: 'Online',
                    selectedPage: false,
                    onTap: () {},
                  ),
                ],
              ),
            ),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: const BorderRadius.all(
                Radius.circular(7),
              ),
            ),
          ),
          ScheduleCard(),
        ],
      ),
    );
  }
}

final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year, kToday.month - 3, kToday.day);
final kLastDay = DateTime(kToday.year, kToday.month + 3, kToday.day);

class TabButtonUi extends StatelessWidget {
  const TabButtonUi(
      {Key? key,
      required this.selectedPage,
      required this.onTap,
      required this.text})
      : super(key: key);
  final String text;
  final bool selectedPage;
  final void Function() onTap;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: selectedPage ? Colors.white : Colors.transparent,
          borderRadius: const BorderRadius.all(
            Radius.circular(6),
          ),
        ),
        child: InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                child: Text(
                  text,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ScheduleCard extends StatelessWidget {
  const ScheduleCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4),
      color: Colors.white,
      child: Container(
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
            // color: Colors.grey.shade300,
            border: Border.all(
              color: Colors.orange,
              width: 1.6,
            ),
            borderRadius: BorderRadius.all(Radius.circular(6))),
        child: Row(
          children: [
            Center(
              child: Container(
                color: Colors.red,
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  children: [
                    Text(
                      "7:45",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 6,
                    ),
                    Text('AM')
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 4, left: 6),
                          padding:
                              EdgeInsets.symmetric(vertical: 4, horizontal: 50),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.all(
                              Radius.circular(8),
                            ),
                          ),
                          child: Text(
                            'GLADIATOR',
                            style: TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 4),
                          padding:
                              EdgeInsets.symmetric(vertical: 4, horizontal: 30),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey.shade400,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(8),
                            ),
                          ),
                          child: Text(
                            '',
                            style: TextStyle(fontSize: 2, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(6, 10, 0, 10),
                      child: Text("7:45 AM - GLADIATOR"),
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 6,
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 4),
                          padding:
                              EdgeInsets.symmetric(vertical: 2, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(238, 238, 238, 1),
                            border: Border.all(
                              color: Colors.grey.shade400,
                              width: 1.3,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(100),
                            ),
                          ),
                          child: Text(
                            '7:45 AM - 8:45 AM',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 8,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 4,
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 4),
                          padding: EdgeInsets.symmetric(
                              vertical: 1.3, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            border: Border.all(
                              color: Colors.red.shade300,
                              width: 1.3,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(100),
                            ),
                          ),
                          child: Text(
                            'Canceled',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 8,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 4,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
