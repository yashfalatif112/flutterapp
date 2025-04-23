import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalenderScreen extends StatefulWidget {
  const CalenderScreen({super.key});

  @override
  _CalenderScreenState createState() => _CalenderScreenState();
}

class _CalenderScreenState extends State<CalenderScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDate;
  int _selectedOptionIndex = -1;

  final List<String> _timeOptions = [
    "26 Aug 2020 9:16 AM",
    "Feb 21, 2023 03:05 pm",
    "Nov 4, 2023 12:13 am",
    "Jan 11, 2023 01:49 pm",
    "Aug 3, 2025 12:10 am",
    "Aug 3, 2023 12:10 am",
    "Oct 13, 2023 08:05 am",
    "Feb 21, 2023 03:05 pm",
    "Aug 18, 2023 04:12 pm",
    "Mar 13, 2023 08:05 am",
  ];

  void _onDaySelected(DateTime day) {
    if (!day.isBefore(DateTime.now().subtract(Duration(days: 1)))) {
      setState(() {
        _selectedDate = day;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF3F3E7),
      appBar: AppBar(
        backgroundColor: Color(0xFFF3F3E7),
        elevation: 0,
        centerTitle: true,
        title: Text("Book for later", style: TextStyle(color: Colors.black)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Icon(Icons.notifications_none, color: Colors.black),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios),
                        onPressed: () {
                          setState(() {
                            _focusedDay = DateTime(
                              _focusedDay.year,
                              _focusedDay.month - 1,
                            );
                          });
                        },
                      ),
                      Text(
                        DateFormat('MMMM yyyy').format(_focusedDay),
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: Icon(Icons.arrow_forward_ios),
                        onPressed: () {
                          setState(() {
                            _focusedDay = DateTime(
                              _focusedDay.year,
                              _focusedDay.month + 1,
                            );
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: DateUtils.getDaysInMonth(
                        _focusedDay.year, _focusedDay.month),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 5,
                    ),
                    itemBuilder: (context, index) {
                      DateTime currentDay = DateTime(
                          _focusedDay.year, _focusedDay.month, index + 1);
                      bool isPast = currentDay
                          .isBefore(DateTime.now().subtract(Duration(days: 1)));
                      bool isSelected = _selectedDate != null &&
                          currentDay.year == _selectedDate!.year &&
                          currentDay.month == _selectedDate!.month &&
                          currentDay.day == _selectedDate!.day;

                      return GestureDetector(
                        onTap: isPast ? null : () => _onDaySelected(currentDay),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color:
                                Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            "${index + 1}",
                            style: TextStyle(
                              color: isPast
                                  ? Colors.grey
                                  : isSelected
                                      ? Colors.green
                                      : Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    },
                  )
                ],
              ),
            ),
            SizedBox(height: 16),
            Text("Select Date & Time", style: TextStyle(fontSize: 16)),
            SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                itemCount: _timeOptions.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 3,
                ),
                itemBuilder: (context, index) {
                  bool isSelected = _selectedOptionIndex == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedOptionIndex = index;
                      });
                    },
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: isSelected ? Colors.green : Colors.grey),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(_timeOptions[index]),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12), color: Colors.green),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Center(
                  child: Text(
                    'Schedule Now',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            )
          ],
        ),
      ),
    );
  }
}
