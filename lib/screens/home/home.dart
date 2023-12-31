import 'package:attendance_in/screens/attendance/attendance_page.dart';
import 'package:attendance_in/shared/db_loading.dart';
import 'package:attendance_in/shared/refresh_loading.dart';
import 'package:flutter/material.dart';
import 'package:attendance_in/services/auth.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final AuthService _auth = AuthService();
  late List<Map<String, dynamic>> _semesters = [];
  String _selectedSemester = '';
  ScrollController _coursesScrollController = ScrollController();
  late GlobalKey _menuKey;
  late String _currentUserUid; // Add this line
  bool _isLoading = true; // Add this line
  bool _isRefreshing = false; // Add this line

  @override
  void initState() {
    super.initState();
    _menuKey = GlobalKey();
    _getUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[100],
      appBar: AppBar(
        title: Text("HOME"),
        backgroundColor: Colors.teal,
        elevation: 0.0,
        actions: <Widget>[
          SizedBox(width: 10),
          SizedBox(width: 20),
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: Colors.black,
            ),
            onPressed: () async {
              await _refreshUserData();
            },
          ),
          SizedBox(width: 20),
          TextButton.icon(
            onPressed: () async {
              bool shouldLogout = await _showLogoutConfirmationDialog();
              if (shouldLogout) {
                await _auth.signOut();
              }
            },
            icon: Icon(
              Icons.person,
              color: Colors.black,
            ),
            label: Text(
              "Logout",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.teal,
              ),
              child: Text(
                'More Options',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: Text('Add a Course'),
              onTap: () async {
                await _addCourse();
              },
            ),
            ListTile(
              title: Text('Add a Semester'),
              onTap: () async {
                await _addSemester();
              },
            ),
            ListTile(
              title: Text('Delete this Semester'),
              onTap: () async {
                await _deleteSemester();
              },
            )
          ],
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hello Student!!",
                  style: TextStyle(fontSize: 24, color: Colors.black),
                ),
                SizedBox(height: 20),
                _buildSemesterList(),
                SizedBox(height: 20),
                _selectedSemester.isNotEmpty
                    ? Expanded(child: _buildCoursesForSelectedSemester())
                    : Center(child: Text("No courses added")),
              ],
            ),
          ),
          if (_isLoading) DBLoading(),
          if (_isRefreshing) RefreshLoading(),
        ],
      ),
    );
  }

  Widget _buildSemesterList() {
    return _semesters.isEmpty
        ? Center(child: Text("No semesters added"))
        : Container(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _semesters.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedSemester = _semesters[index]['semesterName'];
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _selectedSemester == _semesters[index]['semesterName']
                              ? Colors.blue.shade500
                              : Colors.grey,
                      minimumSize: Size(120, 50),
                    ),
                    child: Text(
                      _semesters[index]['semesterName'],
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ),
                );
              },
            ),
          );
  }

  Widget _buildCoursesForSelectedSemester() {
    Map<String, dynamic>? selectedSemester = _semesters.firstWhere(
      (semester) => semester['semesterName'] == _selectedSemester,
      orElse: () => {},
    );

    if (selectedSemester != null &&
        selectedSemester.containsKey('courses') &&
        selectedSemester['courses'] != null) {
      List<Map<String, dynamic>> courses =
          (selectedSemester['courses'] as List<dynamic>)
              .cast<Map<String, dynamic>>();

      if (courses.isNotEmpty) {
        return SingleChildScrollView(
          controller: _coursesScrollController,
          child: Column(
            children:
                courses.map((course) => _buildCourseTile(course)).toList(),
          ),
        );
      } else {
        return Center(child: Text("No courses added"));
      }
    } else {
      return Center(child: Text("No courses added"));
    }
  }

  Widget _buildCourseTile(Map<String, dynamic> course) {
    double attendancePercentage = _calculateAttendancePercentage(course);

    return ListTile(
      title: Row(
        children: [
          Expanded(
            child: Text(
              course['courseName'],
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(width: 10),
          InkWell(
            onTap: () {
              _goToAttendancePage(course);
            },
            child: Container(
              width: 55,
              height: 65,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getAttendanceColor(attendancePercentage),
              ),
              child: Center(
                child: Text(
                  "${attendancePercentage.toStringAsFixed(1)}%",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 20),
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () async {
              await _editCourse(course);
            },
          ),
          SizedBox(width: 10),
          IconButton(
            icon: Icon(Icons.delete, size: 30),
            onPressed: () async {
              await _confirmDeleteCourse(course);
            },
          ),
        ],
      ),
    );
  }

  Future<bool> _showLogoutConfirmationDialog() async {
    bool shouldLogout = false;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Logout"),
          content: Text("Are you sure you want to log out?"),
          actions: [
            TextButton(
              onPressed: () {
                shouldLogout = true;
                Navigator.of(context).pop();
              },
              child: Text("Yes"),
            ),
            TextButton(
              onPressed: () {
                shouldLogout = false;
                Navigator.of(context).pop();
              },
              child: Text("No"),
            ),
          ],
        );
      },
    );
    return shouldLogout;
  }

  void _goToAttendancePage(Map<String, dynamic> course) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AttendancePage(
          course: course,
          semesters: _semesters,
          onSemestersUpdated: _handleSemestersUpdated,
        ),
      ),
    );
  }

  Color _getAttendanceColor(double percentage) {
    if (percentage >= 85) {
      return Colors.green.shade700;
    } else if (percentage >= 75) {
      return Colors.orange.shade700;
    } else {
      return Colors.red.shade700;
    }
  }

  double _calculateAttendancePercentage(Map<String, dynamic> course) {
    int totalPresentCount = course['attendance']['totalPresentCount'] ?? 0;
    int totalClassesConducted =
        course['attendance']['totalClassesConducted'] ?? 0;

    if (totalClassesConducted == 0) {
      return 0.0;
    }

    double percentage = (totalPresentCount * 100) / totalClassesConducted;
    return double.parse(percentage.toStringAsFixed(2));
  }

  Future<void> _markAttendance(Map<String, dynamic> course) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AttendancePage(
          course: course,
          semesters: _semesters,
          onSemestersUpdated: _handleSemestersUpdated,
        ),
      ),
    );
  }

  void _handleSemestersUpdated(List<Map<String, dynamic>> updatedSemesters) {
    setState(() {
      _semesters = updatedSemesters;
    });
  }

  Future<void> _editCourse(Map<String, dynamic> course) async {
    String currentCourseName = course['courseName'];
    String? newCourseName = await showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController controller =
            TextEditingController(text: currentCourseName);

        return AlertDialog(
          title: Text('Edit Course Name'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Course Name',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(controller.text);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );

    if (newCourseName != null && newCourseName.isNotEmpty) {
      if (newCourseName != currentCourseName &&
          _isCourseNameExists(newCourseName, _selectedSemester)) {
        _showWarningDialog(
            "You cannot have 2 courses of the same name within the selected semester.");
      } else {
        setState(() {
          course['courseName'] = newCourseName;
        });
        await _updateDatabase();
      }
    }
  }

  Future<void> _addSemester() async {
    int a = 0;
    TextEditingController controller = TextEditingController();
    bool shouldCreateSemester = false;

    // Prompt user to enter the semester name
    String? newSemesterName = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Semester Name'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Semester ${_semesters.length + 1}',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(controller.text);
                setState(() {
                  a = 10;
                });
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );

    if (newSemesterName != null && newSemesterName.isNotEmpty) {
      // Validate if the semester name already exists
      if (_semesters
          .any((semester) => semester['semesterName'] == newSemesterName)) {
        _showWarningDialog("You cannot have 2 semesters of the same name.");
      } else {
        // Confirm the creation of the new semester
        shouldCreateSemester = (await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Confirm Create Semester"),
                  content: Text(
                      "Do you want to create a new semester with the name: $newSemesterName?"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                      child: Text("Yes"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                      child: Text("No"),
                    ),
                  ],
                );
              },
            )) ??
            false;
      }
    } else if (a == 10) {
      newSemesterName = 'Semester ${_semesters.length + 1}';
      if (_semesters
          .any((semester) => semester['semesterName'] == newSemesterName)) {
        _showWarningDialog("You cannot have 2 semesters of the same name.");
      } else {
        // Confirm the creation of the new semester
        shouldCreateSemester = (await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Confirm Create Semester"),
                  content: Text(
                      "Do you want to create a new semester with the name: $newSemesterName?"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                      child: Text("Yes"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                      child: Text("No"),
                    ),
                  ],
                );
              },
            )) ??
            false;
      }
    } else {
      // If the user did not enter a name, use the next available semester name
      // shouldCreateSemester = true;
      // newSemesterName = 'Semester ${_semesters.length + 1}';
      return;
    }

    // Proceed with the creation of the new semester if confirmed
    if (shouldCreateSemester) {
      Map<String, dynamic> newSemester = {
        'semesterName': newSemesterName,
        'courses': [],
      };

      setState(() {
        _semesters.add(newSemester);
        _selectedSemester = newSemesterName!;
      });

      await _updateDatabase();
    }
  }

  Future<void> _addCourse() async {
    Map<String, dynamic>? selectedSemester = _semesters.firstWhere(
      (semester) => semester['semesterName'] == _selectedSemester,
      orElse: () => {},
    );

    if (selectedSemester != null) {
      String? newCourseName = await showDialog(
        context: context,
        builder: (BuildContext context) {
          TextEditingController controller = TextEditingController();

          return AlertDialog(
            title: Text('Enter Course Name'),
            content: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Course Name',
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(controller.text);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );

      if (newCourseName != null && newCourseName.isNotEmpty) {
        if (_isCourseNameExists(newCourseName, _selectedSemester)) {
          _showWarningDialog(
              "You cannot have 2 courses of the same name within the selected semester.");
        } else {
          Map<String, dynamic> newCourse = {
            'courseName': newCourseName,
            'attendance': {
              'presentDates': [],
              'totalPresentCount': 0,
              'absentDates': [],
              'totalAbsentCount': 0,
              'totalClassesConducted': 0,
            },
          };

          setState(() {
            selectedSemester['courses'].add(newCourse);
          });
          await _updateDatabase();
        }
      }
    }
  }

  bool _isCourseNameExists(String courseName, String semesterName) {
    Map<String, dynamic>? selectedSemester = _semesters.firstWhere(
      (semester) => semester['semesterName'] == semesterName,
      orElse: () => {},
    );

    if (selectedSemester != null) {
      return selectedSemester['courses'].any((course) {
        return course['courseName'] == courseName;
      });
    }

    return false;
  }

  Future<void> _deleteSemester() async {
    if (_selectedSemester == 'Semester 1') {
      // Show warning message for Semester 1
      _showWarningDialog("You cannot delete Semester 1.");
    } else {
      // Proceed with deletion or other actions for other semesters
      if (_semesters.length > 1) {
        bool? shouldDelete = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Confirm Delete"),
              content: Text("Do you really want to delete this semester?"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: Text("Yes"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text("No"),
                ),
              ],
            );
          },
        );

        if (shouldDelete != null && shouldDelete) {
          setState(() {
            _semesters.removeWhere(
              (semester) => semester['semesterName'] == _selectedSemester,
            );
            if (_semesters.isNotEmpty) {
              _selectedSemester = _semesters[0]['semesterName'];
            } else {
              _selectedSemester = '';
            }
          });
          await _updateDatabase();
        }
      }
    }
  }

  void _showWarningDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Warning"),
          content: Text(message),
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
  }

  Future<void> _confirmDeleteCourse(Map<String, dynamic> course) async {
    bool? shouldDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Delete"),
          content: Text("Do you really want to delete this course?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text("Yes"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text("No"),
            ),
          ],
        );
      },
    );

    if (shouldDelete != null && shouldDelete) {
      setState(() {
        _semesters.forEach((semester) {
          if (semester['semesterName'] == _selectedSemester) {
            semester['courses'].remove(course);
          }
        });
      });
      await _updateDatabase();
    }
  }

  Future<void> _updateDatabase() async {
    await _auth.updateUserSemesters(_semesters);
  }

  Future<void> _refreshUserData() async {
    try {
      setState(() {
        _isRefreshing =
            true; // Set _isRefreshing to true when refreshing starts
      });

      await _getUserData();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User data refreshed successfully.'),
        ),
      );
    } catch (e) {
      print('Error refreshing user data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error refreshing user data. Please try again.'),
        ),
      );
    } finally {
      setState(() {
        _isRefreshing =
            false; // Set _isRefreshing to false when refreshing is done
      });
    }
  }

  Future<void> _getUserData() async {
    try {
      _currentUserUid = (await _auth.user.first)?.uid ?? '';
      List<Map<String, dynamic>> semesters = await _auth.getUserSemesters();
      setState(() {
        _semesters = semesters;
        if (_semesters.isNotEmpty) {
          _selectedSemester = _semesters[0]['semesterName'];
        }
        _isLoading = false; // Set loading state to false after data is fetched
      });
    } catch (e) {
      print('Error getting user data: $e');
      throw e; // Rethrow the error for handling in _refreshUserData
    }
  }
}

void main() {
  runApp(MaterialApp(
    home: Home(),
  ));
}





















// import 'package:attendance_in/screens/attendance/attendance_page.dart';
// import 'package:attendance_in/shared/db_loading.dart';
// import 'package:attendance_in/shared/refresh_loading.dart';
// import 'package:flutter/material.dart';
// import 'package:attendance_in/services/auth.dart';

// class Home extends StatefulWidget {
//   @override
//   _HomeState createState() => _HomeState();
// }

// class _HomeState extends State<Home> {
//   final AuthService _auth = AuthService();
//   late List<Map<String, dynamic>> _semesters = [];
//   String _selectedSemester = '';
//   ScrollController _coursesScrollController = ScrollController();
//   late GlobalKey _menuKey;
//   late String _currentUserUid; // Add this line
//   bool _isLoading = true; // Add this line
//   bool _isRefreshing = false; // Add this line

//   @override
//   void initState() {
//     super.initState();
//     _menuKey = GlobalKey();
//     _getUserData();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.teal[100],
//       appBar: AppBar(
//         title: Text("HOME"),
//         backgroundColor: Colors.teal,
//         elevation: 0.0,
//         actions: <Widget>[
//           SizedBox(width: 10),
//           SizedBox(width: 20),
//           IconButton(
//             icon: Icon(
//               Icons.refresh,
//               color: Colors.black,
//             ),
//             onPressed: () async {
//               await _refreshUserData();
//             },
//           ),
//           SizedBox(width: 20),
//           TextButton.icon(
//             onPressed: () async {
//               bool shouldLogout = await _showLogoutConfirmationDialog();
//               if (shouldLogout) {
//                 await _auth.signOut();
//               }
//             },
//             icon: Icon(
//               Icons.person,
//               color: Colors.black,
//             ),
//             label: Text(
//               "Logout",
//               style: TextStyle(color: Colors.black),
//             ),
//           ),
//         ],
//       ),
//       drawer: Drawer(
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: [
//             DrawerHeader(
//               decoration: BoxDecoration(
//                 color: Colors.teal,
//               ),
//               child: Text(
//                 'More Options',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 24,
//                 ),
//               ),
//             ),
//             ListTile(
//               title: Text('Add a Course'),
//               onTap: () async {
//                 await _addCourse();
//               },
//             ),
//             ListTile(
//               title: Text('Add a Semester'),
//               onTap: () async {
//                 await _addSemester();
//               },
//             ),
//             ListTile(
//               title: Text('Delete this Semester'),
//               onTap: () async {
//                 await _deleteSemester();
//               },
//             )
//           ],
//         ),
//       ),
//       body: Stack(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   "Hello Student!!",
//                   style: TextStyle(fontSize: 24, color: Colors.black),
//                 ),
//                 SizedBox(height: 20),
//                 _buildSemesterList(),
//                 SizedBox(height: 20),
//                 _selectedSemester.isNotEmpty
//                     ? Expanded(child: _buildCoursesForSelectedSemester())
//                     : Center(child: Text("No courses added")),
//               ],
//             ),
//           ),
//           if (_isLoading) DBLoading(),
//           if (_isRefreshing) RefreshLoading(),
//         ],
//       ),
//     );
//   }

//   Widget _buildSemesterList() {
//     return _semesters.isEmpty
//         ? Center(child: Text("No semesters added"))
//         : Container(
//             height: 50,
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               itemCount: _semesters.length,
//               itemBuilder: (context, index) {
//                 return Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                   child: ElevatedButton(
//                     onPressed: () {
//                       setState(() {
//                         _selectedSemester = _semesters[index]['semesterName'];
//                       });
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor:
//                           _selectedSemester == _semesters[index]['semesterName']
//                               ? Colors.blue.shade500
//                               : Colors.grey,
//                       minimumSize: Size(120, 50),
//                     ),
//                     child: Text(
//                       _semesters[index]['semesterName'],
//                       style: TextStyle(fontSize: 16, color: Colors.black),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           );
//   }

//   Widget _buildCoursesForSelectedSemester() {
//     Map<String, dynamic>? selectedSemester = _semesters.firstWhere(
//       (semester) => semester['semesterName'] == _selectedSemester,
//       orElse: () => {},
//     );

//     if (selectedSemester != null &&
//         selectedSemester.containsKey('courses') &&
//         selectedSemester['courses'] != null) {
//       List<Map<String, dynamic>> courses =
//           (selectedSemester['courses'] as List<dynamic>)
//               .cast<Map<String, dynamic>>();

//       if (courses.isNotEmpty) {
//         return SingleChildScrollView(
//           controller: _coursesScrollController,
//           child: Column(
//             children:
//                 courses.map((course) => _buildCourseTile(course)).toList(),
//           ),
//         );
//       } else {
//         return Center(child: Text("No courses added"));
//       }
//     } else {
//       return Center(child: Text("No courses added"));
//     }
//   }

//   Widget _buildCourseTile(Map<String, dynamic> course) {
//     double attendancePercentage = _calculateAttendancePercentage(course);

//     return ListTile(
//       title: Row(
//         children: [
//           Expanded(
//             child: Text(
//               course['courseName'],
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//           ),
//           SizedBox(width: 10),
//           InkWell(
//             onTap: () {
//               _goToAttendancePage(course);
//             },
//             child: Container(
//               width: 55,
//               height: 65,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: _getAttendanceColor(attendancePercentage),
//               ),
//               child: Center(
//                 child: Text(
//                   "${attendancePercentage.toStringAsFixed(1)}%",
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 14,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           SizedBox(width: 20),
//           IconButton(
//             icon: Icon(Icons.edit),
//             onPressed: () async {
//               await _editCourse(course);
//             },
//           ),
//           SizedBox(width: 10),
//           IconButton(
//             icon: Icon(Icons.delete, size: 30),
//             onPressed: () async {
//               await _confirmDeleteCourse(course);
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Future<bool> _showLogoutConfirmationDialog() async {
//     bool shouldLogout = false;
//     await showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Confirm Logout"),
//           content: Text("Are you sure you want to log out?"),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 shouldLogout = true;
//                 Navigator.of(context).pop();
//               },
//               child: Text("Yes"),
//             ),
//             TextButton(
//               onPressed: () {
//                 shouldLogout = false;
//                 Navigator.of(context).pop();
//               },
//               child: Text("No"),
//             ),
//           ],
//         );
//       },
//     );
//     return shouldLogout;
//   }

//   void _goToAttendancePage(Map<String, dynamic> course) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => AttendancePage(
//           course: course,
//           semesters: _semesters,
//           onSemestersUpdated: _handleSemestersUpdated,
//         ),
//       ),
//     );
//   }

//   Color _getAttendanceColor(double percentage) {
//     if (percentage >= 85) {
//       return Colors.green.shade700;
//     } else if (percentage >= 75) {
//       return Colors.orange.shade700;
//     } else {
//       return Colors.red.shade700;
//     }
//   }

//   double _calculateAttendancePercentage(Map<String, dynamic> course) {
//     int totalPresentCount = course['attendance']['totalPresentCount'] ?? 0;
//     int totalClassesConducted =
//         course['attendance']['totalClassesConducted'] ?? 0;

//     if (totalClassesConducted == 0) {
//       return 0.0;
//     }

//     double percentage = (totalPresentCount * 100) / totalClassesConducted;
//     return double.parse(percentage.toStringAsFixed(2));
//   }

//   Future<void> _markAttendance(Map<String, dynamic> course) async {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => AttendancePage(
//           course: course,
//           semesters: _semesters,
//           onSemestersUpdated: _handleSemestersUpdated,
//         ),
//       ),
//     );
//   }

//   void _handleSemestersUpdated(List<Map<String, dynamic>> updatedSemesters) {
//     setState(() {
//       _semesters = updatedSemesters;
//     });
//   }

//   Future<void> _editCourse(Map<String, dynamic> course) async {
//     String currentCourseName = course['courseName'];
//     String? newCourseName = await showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         TextEditingController controller =
//             TextEditingController(text: currentCourseName);

//         return AlertDialog(
//           title: Text('Edit Course Name'),
//           content: TextField(
//             controller: controller,
//             decoration: InputDecoration(
//               hintText: 'Course Name',
//             ),
//           ),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(controller.text);
//               },
//               child: Text('OK'),
//             ),
//           ],
//         );
//       },
//     );

//     if (newCourseName != null && newCourseName.isNotEmpty) {
//       if (newCourseName != currentCourseName &&
//           _isCourseNameExists(newCourseName, _selectedSemester)) {
//         _showWarningDialog(
//             "You cannot have 2 courses of the same name within the selected semester.");
//       } else {
//         setState(() {
//           course['courseName'] = newCourseName;
//         });
//         await _updateDatabase();
//       }
//     }
//   }

//   Future<void> _addSemester() async {
//     // Find the next available semester number
//     int nextSemesterNumber = 1;
//     while (_semesters.any((semester) =>
//         semester['semesterName'] == 'Semester $nextSemesterNumber')) {
//       nextSemesterNumber++;
//     }

//     String newSemesterName = 'Semester $nextSemesterNumber';
//     Map<String, dynamic> newSemester = {
//       'semesterName': newSemesterName,
//       'courses': [],
//     };

//     setState(() {
//       _semesters.add(newSemester);
//       _selectedSemester = newSemesterName;
//     });

//     await _updateDatabase();
//   }

//   Future<void> _addCourse() async {
//     Map<String, dynamic>? selectedSemester = _semesters.firstWhere(
//       (semester) => semester['semesterName'] == _selectedSemester,
//       orElse: () => {},
//     );

//     if (selectedSemester != null) {
//       String? newCourseName = await showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           TextEditingController controller = TextEditingController();

//           return AlertDialog(
//             title: Text('Enter Course Name'),
//             content: TextField(
//               controller: controller,
//               decoration: InputDecoration(
//                 hintText: 'Course Name',
//               ),
//             ),
//             actions: <Widget>[
//               TextButton(
//                 onPressed: () {
//                   Navigator.of(context).pop(controller.text);
//                 },
//                 child: Text('OK'),
//               ),
//             ],
//           );
//         },
//       );

//       if (newCourseName != null && newCourseName.isNotEmpty) {
//         if (_isCourseNameExists(newCourseName, _selectedSemester)) {
//           _showWarningDialog(
//               "You cannot have 2 courses of the same name within the selected semester.");
//         } else {
//           Map<String, dynamic> newCourse = {
//             'courseName': newCourseName,
//             'attendance': {
//               'presentDates': [],
//               'totalPresentCount': 0,
//               'absentDates': [],
//               'totalAbsentCount': 0,
//               'totalClassesConducted': 0,
//             },
//           };

//           setState(() {
//             selectedSemester['courses'].add(newCourse);
//           });
//           await _updateDatabase();
//         }
//       }
//     }
//   }

//   bool _isCourseNameExists(String courseName, String semesterName) {
//     Map<String, dynamic>? selectedSemester = _semesters.firstWhere(
//       (semester) => semester['semesterName'] == semesterName,
//       orElse: () => {},
//     );

//     if (selectedSemester != null) {
//       return selectedSemester['courses'].any((course) {
//         return course['courseName'] == courseName;
//       });
//     }

//     return false;
//   }

//   Future<void> _deleteSemester() async {
//     if (_selectedSemester == 'Semester 1') {
//       // Show warning message for Semester 1
//       _showWarningDialog("You cannot delete Semester 1.");
//     } else {
//       // Proceed with deletion or other actions for other semesters
//       if (_semesters.length > 1) {
//         bool? shouldDelete = await showDialog(
//           context: context,
//           builder: (BuildContext context) {
//             return AlertDialog(
//               title: Text("Confirm Delete"),
//               content: Text("Do you really want to delete this semester?"),
//               actions: [
//                 TextButton(
//                   onPressed: () {
//                     Navigator.of(context).pop(true);
//                   },
//                   child: Text("Yes"),
//                 ),
//                 TextButton(
//                   onPressed: () {
//                     Navigator.of(context).pop(false);
//                   },
//                   child: Text("No"),
//                 ),
//               ],
//             );
//           },
//         );

//         if (shouldDelete != null && shouldDelete) {
//           setState(() {
//             _semesters.removeWhere(
//               (semester) => semester['semesterName'] == _selectedSemester,
//             );
//             if (_semesters.isNotEmpty) {
//               _selectedSemester = _semesters[0]['semesterName'];
//             } else {
//               _selectedSemester = '';
//             }
//           });
//           await _updateDatabase();
//         }
//       }
//     }
//   }

//   void _showWarningDialog(String message) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Warning"),
//           content: Text(message),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text("OK"),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Future<void> _confirmDeleteCourse(Map<String, dynamic> course) async {
//     bool? shouldDelete = await showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Confirm Delete"),
//           content: Text("Do you really want to delete this course?"),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(true);
//               },
//               child: Text("Yes"),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(false);
//               },
//               child: Text("No"),
//             ),
//           ],
//         );
//       },
//     );

//     if (shouldDelete != null && shouldDelete) {
//       setState(() {
//         _semesters.forEach((semester) {
//           if (semester['semesterName'] == _selectedSemester) {
//             semester['courses'].remove(course);
//           }
//         });
//       });
//       await _updateDatabase();
//     }
//   }

//   Future<void> _updateDatabase() async {
//     await _auth.updateUserSemesters(_semesters);
//   }

//   Future<void> _refreshUserData() async {
//     try {
//       setState(() {
//         _isRefreshing =
//             true; // Set _isRefreshing to true when refreshing starts
//       });

//       await _getUserData();

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('User data refreshed successfully.'),
//         ),
//       );
//     } catch (e) {
//       print('Error refreshing user data: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error refreshing user data. Please try again.'),
//         ),
//       );
//     } finally {
//       setState(() {
//         _isRefreshing =
//             false; // Set _isRefreshing to false when refreshing is done
//       });
//     }
//   }

//   Future<void> _getUserData() async {
//     try {
//       _currentUserUid = (await _auth.user.first)?.uid ?? '';
//       List<Map<String, dynamic>> semesters = await _auth.getUserSemesters();
//       setState(() {
//         _semesters = semesters;
//         if (_semesters.isNotEmpty) {
//           _selectedSemester = _semesters[0]['semesterName'];
//         }
//         _isLoading = false; // Set loading state to false after data is fetched
//       });
//     } catch (e) {
//       print('Error getting user data: $e');
//       throw e; // Rethrow the error for handling in _refreshUserData
//     }
//   }
// }

// void main() {
//   runApp(MaterialApp(
//     home: Home(),
//   ));
// }


// Home screen code 

