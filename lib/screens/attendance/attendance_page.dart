import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:attendance_in/services/auth.dart';
import 'package:attendance_in/services/database.dart';

class AttendancePage extends StatefulWidget {
  final Map<String, dynamic> course;
  final List<Map<String, dynamic>> semesters;
  final Function(List<Map<String, dynamic>>) onSemestersUpdated;

  AttendancePage({
    required this.course,
    required this.semesters,
    required this.onSemestersUpdated,
  });

  @override
  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  late String _selectedCourse;
  late DateTime _selectedDate;
  int _totalClassesConducted = 0;

  @override
  void initState() {
    super.initState();
    _selectedCourse = widget.course['courseName'];
    _selectedDate = DateTime.now();
    _totalClassesConducted =
        widget.course['attendance']['totalClassesConducted'] ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[100],
      resizeToAvoidBottomInset: false, // Add this line
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text(
          _selectedCourse,
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.home, color: Colors.black), // Update color here
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        // Wrap with SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildMonthYearPicker(),
              SizedBox(height: 16),
              Center(
                child: _buildDateList(),
              ),
              SizedBox(height: 16),
              Center(
                child: Column(
                  children: [
                    Text(
                      'Classes Present: ${widget.course['attendance']['totalPresentCount']}',
                      style:
                          TextStyle(color: Colors.green.shade700, fontSize: 16),
                    ),
                    Text(
                      'Classes Absent: ${widget.course['attendance']['totalAbsentCount']}',
                      style:
                          TextStyle(color: Colors.red.shade700, fontSize: 16),
                    ),
                    Text(
                      'Total Classes Conducted: $_totalClassesConducted',
                      style: TextStyle(
                          color: Color(0xFF512DA8),
                          fontSize: 16), // Deep Purple
                    ),
                    Text(
                      'Attendance Percentage: ${_calculateAttendancePercentage()}%',
                      style: TextStyle(
                        color: _calculateAttendancePercentage() >= 75
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                        fontSize: 16,
                      ),
                    ),
                    if (_calculateAttendancePercentage() >= 75)
                      Text(
                        'Leaves Left: ${_calculateHoursYouCanMiss()}',
                        style: TextStyle(
                            color: Colors.blue.shade700, fontSize: 16),
                      ),
                    if (_calculateAttendancePercentage() < 75)
                      Text(
                        'YOU NEED ${_calculateClassesToAttend()} CLASSES TO BE SAFE',
                        style:
                            TextStyle(color: Colors.red.shade700, fontSize: 16),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthYearPicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              _selectedDate =
                  DateTime(_selectedDate.year, _selectedDate.month - 1);
            });
          },
        ),
        Text(
          DateFormat.yMMM().format(_selectedDate),
          style: TextStyle(fontSize: 18),
        ),
        IconButton(
          icon: Icon(Icons.arrow_forward),
          onPressed: () {
            setState(() {
              _selectedDate =
                  DateTime(_selectedDate.year, _selectedDate.month + 1);
            });
          },
        ),
      ],
    );
  }

  Widget _buildDateList() {
    List<Widget> dateWidgets = [];
    int daysInMonth =
        DateTime(_selectedDate.year, _selectedDate.month + 1, 0).day;

    for (int day = 1; day <= daysInMonth; day++) {
      DateTime currentDate =
          DateTime(_selectedDate.year, _selectedDate.month, day);

      // Determine the button color based on attendance
      Color buttonColor = _getButtonColor(currentDate);

      dateWidgets.add(
        ElevatedButton(
          onPressed: () async {
            await _handleDateSelection(currentDate);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            padding: EdgeInsets.all(16), // Adjust padding for better spacing
          ),
          child: Text(
            day.toString(),
            style: TextStyle(
              color: Colors.white, // Text color for better readability
            ),
          ),
        ),
      );
    }

    return Wrap(
      spacing: 8, // Adjust spacing between buttons
      runSpacing: 8, // Adjust spacing between rows
      children: dateWidgets,
    );
  }

  Color _getButtonColor(DateTime currentDate) {
    String formattedDate = DateFormat('yyyy-MM-dd').format(currentDate);

    // Check if the date is in presentDates or absentDates
    List<dynamic> presentDates =
        List<dynamic>.from(widget.course['attendance']['presentDates'] ?? []);
    List<dynamic> absentDates =
        List<dynamic>.from(widget.course['attendance']['absentDates'] ?? []);

    if (presentDates.any((date) => date.startsWith(formattedDate))) {
      return Colors.green;
    } else if (absentDates.any((date) => date.startsWith(formattedDate))) {
      return Colors.red;
    } else {
      // Use a pleasant color combination for default dates
      return Color.fromARGB(255, 13, 129, 224); // Light Blue
    }
  }

  Future<void> _handleDateSelection(DateTime selectedDate) async {
    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

    // Check if the date is in presentDates or absentDates
    List<dynamic> presentDates =
        List<dynamic>.from(widget.course['attendance']['presentDates'] ?? []);
    List<dynamic> absentDates =
        List<dynamic>.from(widget.course['attendance']['absentDates'] ?? []);

    if (presentDates.any((date) => date.startsWith(formattedDate)) ||
        absentDates.any((date) => date.startsWith(formattedDate))) {
      // Attendance is already marked for this date, show warning
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Warning"),
            content: Text(
                "Attendance for this date is already marked and cannot be altered."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
      return;
    }

    int hello = 5;

    // Use a local variable to store the hours
    int? hours = 0;

    // Show the first dialog to get hours attended
    hours = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        TextEditingController controller = TextEditingController();

        return AlertDialog(
          title: Text('Number of Hours :'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(int.tryParse(controller.text) ?? 0);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );

    // Check if the dialog was canceled or dismissed
    if (hours == null || hours == 0) {
      return;
    }

    bool? didAttend = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Did you attend today's class?"),
          actions: [
            TextButton(
              onPressed: () {
                setState(() => hello = 0);
                Navigator.of(context).pop(true);
              },
              child: Text("Yes"),
            ),
            TextButton(
              onPressed: () {
                setState(() => hello = 1);
                Navigator.of(context).pop(false);
              },
              child: Text("No"),
            ),
          ],
        );
      },
    );

    // Ask the user for attendance confirmation
    bool? confirmAttendance = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Attendance"),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Date: $formattedDate"),
              Text("Attended: ${hello == 0 ? 'Yes' : 'No'}"),
              Text("Hours: $hours"),
              SizedBox(height: 16),
              Text(
                "Once attendance is marked, it cannot be changed.",
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text("Confirm"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );

    // Check if the user confirmed the attendance
    if (confirmAttendance == null || !confirmAttendance) {
      return;
    }

    // Update the database and state based on user input
    if (hello == 0) {
      // Update presentDates and totalPresentCount
      widget.course['attendance']['presentDates'].add(formattedDate);
      widget.course['attendance']['totalPresentCount'] += hours;
    } else {
      // Update absentDates and totalAbsentCount
      widget.course['attendance']['absentDates'].add(formattedDate);
      widget.course['attendance']['totalAbsentCount'] += hours;
    }

    // Update totalClassesConducted
    widget.course['attendance']['totalClassesConducted'] =
        widget.course['attendance']['totalAbsentCount'] +
            widget.course['attendance']['totalPresentCount'];

    // Update the database
    await _updateDatabase();

    // Update the UI
    setState(() {
      _totalClassesConducted =
          widget.course['attendance']['totalClassesConducted'];
    });

    // Notify the parent widget about the updated semesters
    widget.onSemestersUpdated(widget.semesters);
  }

  Future<void> _updateDatabase() async {
    try {
      String currentUserUid = (await AuthService().user.first)?.uid ?? '';
      await DatabaseService(uid: currentUserUid)
          .updateUserSemesters(widget.semesters);
    } catch (e) {
      print('Error updating database: $e');
    }
  }

  double _calculateAttendancePercentage() {
    if (_totalClassesConducted == 0) {
      return 0.0;
    }
    double percentage =
        (widget.course['attendance']['totalPresentCount'] * 100) /
            widget.course['attendance']['totalClassesConducted'];
    return double.parse(percentage.toStringAsFixed(2));
  }

  int _calculateHoursYouCanMiss() {
    double c = (widget.course['attendance']['totalClassesConducted'] * 75.0);
    int requiredAttendance = (c / 100).round();
    int hoursYouCanMiss =
        widget.course['attendance']['totalPresentCount'] - requiredAttendance;

    return hoursYouCanMiss;
  }

  int _calculateClassesToAttend() {
    double curr_per = _calculateAttendancePercentage();
    int totalClasses = widget.course['attendance']['totalClassesConducted'];
    double req = 75.0;
    double per = req - curr_per;
    double classes = per * totalClasses;
    int classesToAttend = (classes / 25).round();
    return classesToAttend;
  }
}






























// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:attendance_in/services/auth.dart';
// import 'package:attendance_in/services/database.dart';

// class AttendancePage extends StatefulWidget {
//   final Map<String, dynamic> course;
//   final List<Map<String, dynamic>> semesters;
//   final Function(List<Map<String, dynamic>>) onSemestersUpdated;

//   AttendancePage({
//     required this.course,
//     required this.semesters,
//     required this.onSemestersUpdated,
//   });

//   @override
//   _AttendancePageState createState() => _AttendancePageState();
// }

// class _AttendancePageState extends State<AttendancePage> {
//   late String _selectedCourse;
//   late DateTime _selectedDate;
//   int _totalClassesConducted = 0;

//   @override
//   void initState() {
//     super.initState();
//     _selectedCourse = widget.course['courseName'];
//     _selectedDate = DateTime.now();
//     _totalClassesConducted =
//         widget.course['attendance']['totalClassesConducted'] ?? 0;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.teal[100],
//       resizeToAvoidBottomInset: false, // Add this line
//       appBar: AppBar(
//         backgroundColor: Colors.teal,
//         title: Text(
//           _selectedCourse,
//           style: TextStyle(color: Colors.black),
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.home, color: Colors.black), // Update color here
//             onPressed: () {
//               Navigator.popUntil(context, (route) => route.isFirst);
//             },
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         // Wrap with SingleChildScrollView
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               _buildMonthYearPicker(),
//               SizedBox(height: 16),
//               Center(
//                 child: _buildDateList(),
//               ),
//               SizedBox(height: 16),
//               Center(
//                 child: Column(
//                   children: [
//                     Text(
//                       'Classes Present: ${widget.course['attendance']['totalPresentCount']}',
//                       style:
//                           TextStyle(color: Colors.green.shade700, fontSize: 16),
//                     ),
//                     Text(
//                       'Classes Absent: ${widget.course['attendance']['totalAbsentCount']}',
//                       style:
//                           TextStyle(color: Colors.red.shade700, fontSize: 16),
//                     ),
//                     Text(
//                       'Total Classes Conducted: $_totalClassesConducted',
//                       style: TextStyle(
//                           color: Color(0xFF512DA8),
//                           fontSize: 16), // Deep Purple
//                     ),
//                     Text(
//                       'Attendance Percentage: ${_calculateAttendancePercentage()}%',
//                       style: TextStyle(
//                         color: _calculateAttendancePercentage() >= 75
//                             ? Colors.green.shade700
//                             : Colors.red.shade700,
//                         fontSize: 16,
//                       ),
//                     ),
//                     if (_calculateAttendancePercentage() >= 75)
//                       Text(
//                         'Leaves Left: ${_calculateHoursYouCanMiss()}',
//                         style: TextStyle(
//                             color: Colors.blue.shade700, fontSize: 16),
//                       ),
//                     if (_calculateAttendancePercentage() < 75)
//                       Text(
//                         'YOU NEED ${_calculateClassesToAttend()} CLASSES TO BE SAFE',
//                         style:
//                             TextStyle(color: Colors.red.shade700, fontSize: 16),
//                       ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildMonthYearPicker() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         IconButton(
//           icon: Icon(Icons.arrow_back),
//           onPressed: () {
//             setState(() {
//               _selectedDate =
//                   DateTime(_selectedDate.year, _selectedDate.month - 1);
//             });
//           },
//         ),
//         Text(
//           DateFormat.yMMM().format(_selectedDate),
//           style: TextStyle(fontSize: 18),
//         ),
//         IconButton(
//           icon: Icon(Icons.arrow_forward),
//           onPressed: () {
//             setState(() {
//               _selectedDate =
//                   DateTime(_selectedDate.year, _selectedDate.month + 1);
//             });
//           },
//         ),
//       ],
//     );
//   }

//   Widget _buildDateList() {
//     List<Widget> dateWidgets = [];
//     int daysInMonth =
//         DateTime(_selectedDate.year, _selectedDate.month + 1, 0).day;

//     for (int day = 1; day <= daysInMonth; day++) {
//       DateTime currentDate =
//           DateTime(_selectedDate.year, _selectedDate.month, day);

//       // Determine the button color based on attendance
//       Color buttonColor = _getButtonColor(currentDate);

//       dateWidgets.add(
//         ElevatedButton(
//           onPressed: () async {
//             await _handleDateSelection(currentDate);
//           },
//           style: ElevatedButton.styleFrom(
//             backgroundColor: buttonColor,
//             padding: EdgeInsets.all(16), // Adjust padding for better spacing
//           ),
//           child: Text(
//             day.toString(),
//             style: TextStyle(
//               color: Colors.white, // Text color for better readability
//             ),
//           ),
//         ),
//       );
//     }

//     return Wrap(
//       spacing: 8, // Adjust spacing between buttons
//       runSpacing: 8, // Adjust spacing between rows
//       children: dateWidgets,
//     );
//   }

//   Color _getButtonColor(DateTime currentDate) {
//     String formattedDate = DateFormat('yyyy-MM-dd').format(currentDate);

//     // Check if the date is in presentDates or absentDates
//     List<dynamic> presentDates =
//         List<dynamic>.from(widget.course['attendance']['presentDates'] ?? []);
//     List<dynamic> absentDates =
//         List<dynamic>.from(widget.course['attendance']['absentDates'] ?? []);

//     if (presentDates.any((date) => date.startsWith(formattedDate))) {
//       return Colors.green;
//     } else if (absentDates.any((date) => date.startsWith(formattedDate))) {
//       return Colors.red;
//     } else {
//       // Use a pleasant color combination for default dates
//       return Color.fromARGB(255, 13, 129, 224); // Light Blue
//     }
//   }

//   Future<void> _handleDateSelection(DateTime selectedDate) async {
//     String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

//     // Check if the date is in presentDates or absentDates
//     List<dynamic> presentDates =
//         List<dynamic>.from(widget.course['attendance']['presentDates'] ?? []);
//     List<dynamic> absentDates =
//         List<dynamic>.from(widget.course['attendance']['absentDates'] ?? []);

//     if (presentDates.any((date) => date.startsWith(formattedDate)) ||
//         absentDates.any((date) => date.startsWith(formattedDate))) {
//       // Attendance is already marked for this date, show warning
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: Text("Warning"),
//             content: Text(
//                 "Attendance for this date is already marked and cannot be altered."),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//                 child: Text("OK"),
//               ),
//             ],
//           );
//         },
//       );
//       return;
//     }

//     int hello = 5;

//     // Use a local variable to store the hours
//     int? hours = 0;

//     // Show the first dialog to get hours attended
//     hours = await showDialog<int>(
//       context: context,
//       builder: (BuildContext context) {
//         TextEditingController controller = TextEditingController();

//         return AlertDialog(
//           title: Text('Number of Hours :'),
//           content: TextField(
//             controller: controller,
//             keyboardType: TextInputType.number,
//           ),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(int.tryParse(controller.text) ?? 0);
//               },
//               child: Text('OK'),
//             ),
//           ],
//         );
//       },
//     );

//     // Check if the dialog was canceled or dismissed
//     if (hours == null || hours == 0) {
//       return;
//     }

//     bool? didAttend = await showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Did you attend today's class?"),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 setState(() => hello = 0);
//                 Navigator.of(context).pop(true);
//               },
//               child: Text("Yes"),
//             ),
//             TextButton(
//               onPressed: () {
//                 setState(() => hello = 1);
//                 Navigator.of(context).pop(false);
//               },
//               child: Text("No"),
//             ),
//           ],
//         );
//       },
//     );

//     // Ask the user for attendance confirmation
//     bool? confirmAttendance = await showDialog<bool>(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Confirm Attendance"),
//           content: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text("Date: $formattedDate"),
//               Text("Attended: ${hello == 0 ? 'Yes' : 'No'}"),
//               Text("Hours: $hours"),
//               SizedBox(height: 16),
//               Text(
//                 "Once attendance is marked, it cannot be changed.",
//                 style: TextStyle(color: Colors.red),
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(true);
//               },
//               child: Text("Confirm"),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(false);
//               },
//               child: Text("Cancel"),
//             ),
//           ],
//         );
//       },
//     );

//     // Check if the user confirmed the attendance
//     if (confirmAttendance == null || !confirmAttendance) {
//       return;
//     }

//     // Update the database and state based on user input
//     if (hello == 0) {
//       // Update presentDates and totalPresentCount
//       widget.course['attendance']['presentDates'].add(formattedDate);
//       widget.course['attendance']['totalPresentCount'] += hours;
//     } else {
//       // Update absentDates and totalAbsentCount
//       widget.course['attendance']['absentDates'].add(formattedDate);
//       widget.course['attendance']['totalAbsentCount'] += hours;
//     }

//     // Update totalClassesConducted
//     widget.course['attendance']['totalClassesConducted'] =
//         widget.course['attendance']['totalAbsentCount'] +
//             widget.course['attendance']['totalPresentCount'];

//     // Update the database
//     await _updateDatabase();

//     // Update the UI
//     setState(() {
//       _totalClassesConducted =
//           widget.course['attendance']['totalClassesConducted'];
//     });

//     // Notify the parent widget about the updated semesters
//     widget.onSemestersUpdated(widget.semesters);
//   }

//   Future<void> _updateDatabase() async {
//     try {
//       String currentUserUid = (await AuthService().user.first)?.uid ?? '';
//       await DatabaseService(uid: currentUserUid)
//           .updateUserSemesters(widget.semesters);
//     } catch (e) {
//       print('Error updating database: $e');
//     }
//   }

//   double _calculateAttendancePercentage() {
//     if (_totalClassesConducted == 0) {
//       return 0.0;
//     }
//     double percentage =
//         (widget.course['attendance']['totalPresentCount'] * 100) /
//             widget.course['attendance']['totalClassesConducted'];
//     return double.parse(percentage.toStringAsFixed(2));
//   }

//   int _calculateHoursYouCanMiss() {
//     double c = (widget.course['attendance']['totalClassesConducted'] * 75.0);
//     int requiredAttendance = (c / 100).round();
//     int hoursYouCanMiss =
//         widget.course['attendance']['totalPresentCount'] - requiredAttendance;

//     return hoursYouCanMiss;
//   }

//   int _calculateClassesToAttend() {
//     double curr_per = _calculateAttendancePercentage();
//     int totalClasses = widget.course['attendance']['totalClassesConducted'];
//     double req = 75.0;
//     double per = req - curr_per;
//     double classes = per * totalClasses;
//     int classesToAttend = (classes / 25).round();
//     return classesToAttend;
//   }
// }


