import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:attendance_in/services/auth.dart';
import 'package:attendance_in/shared/constants.dart';
import 'package:attendance_in/shared/loading.dart';

class Register extends StatefulWidget {
  final Function toggleView;
  Register({required this.toggleView});

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  bool isObscure = true;

  // Text Field State
  String email = '';
  String password = '';
  String error = '';

  // Track whether the "Email already exists" error should be displayed
  bool showError = false;

  @override
  Widget build(BuildContext context) {
    // Get the current date
    String currentDate = DateFormat('dd-MM-yyyy').format(DateTime.now());

    return loading
        ? Loading()
        : Scaffold(
            backgroundColor: Colors.teal[100],
            appBar: AppBar(
              backgroundColor: Colors.teal,
              elevation: 0.0,
              title: Text(
                currentDate,
                style: TextStyle(color: Colors.black),
              ),
              actions: <Widget>[
                TextButton.icon(
                  onPressed: () {
                    widget.toggleView();
                  },
                  icon: Icon(
                    Icons.person,
                    color: Colors.black,
                  ),
                  label: Text(
                    "Log In",
                    style: TextStyle(color: Colors.black),
                  ),
                )
              ],
            ),
            body: Container(
              padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 20.0),
                  Text(
                    "Register to Attendance Inn",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          decoration: textInputDecoration.copyWith(
                            hintText: "Email",
                            icon: Icon(Icons.email, color: Colors.teal),
                          ),
                          validator: (val) {
                            if (val!.isEmpty) {
                              return "Enter an Email";
                            } else if (!RegExp(
                                    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                                .hasMatch(val)) {
                              return "Invalid Email";
                            } else if (!val.endsWith('.com') &&
                                !val.endsWith('.co.in') &&
                                !val.endsWith('.edu.in')) {
                              return "Invalid Email";
                            } else if ((val.contains('google') ||
                                    val.contains('hotmail') ||
                                    val.contains('rediffmail') ||
                                    val.contains('outlook')) &&
                                !val.endsWith('.com')) {
                              return "Invalid Email";
                            } else if (val.contains('yahoo') &&
                                !val.endsWith('.co.in')) {
                              return "Invalid Email";
                            }

                            return null;
                          },
                          onChanged: (val) {
                            setState(() {
                              email = val;
                              showError =
                                  false; // Hide the error on email change
                            });
                          },
                        ),
                        SizedBox(height: 20.0),
                        TextFormField(
                          decoration: textInputDecoration.copyWith(
                            hintText: "Password",
                            icon: Icon(Icons.lock, color: Colors.teal),
                            suffixIcon: IconButton(
                              icon: Icon(
                                isObscure
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.teal,
                              ),
                              onPressed: () {
                                setState(() {
                                  isObscure = !isObscure;
                                });
                              },
                            ),
                          ),
                          obscureText: isObscure,
                          validator: (val) => val!.length < 6
                              ? "Strong Password 6 Characters+"
                              : null,
                          onChanged: (val) {
                            setState(() => password = val);
                          },
                        ),
                        SizedBox(height: 20.0),
                        ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.green),
                            padding:
                                MaterialStateProperty.all<EdgeInsetsGeometry>(
                              EdgeInsets.all(15),
                            ),
                          ),
                          child: Text(
                            "Register",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                isObscure = true;
                                loading = true;
                              });
                              dynamic result =
                                  await _auth.registerWithEmailAndPassword(
                                      email, password);
                              if (result == null) {
                                setState(() {
                                  loading = false;
                                  // Clear only the password field on error
                                  _formKey.currentState?.reset();
                                  password = ''; // Clear the password field
                                  showError = true; // Show the error
                                });
                              } else {
                                showError =
                                    false; // Hide the error on successful registration
                              }
                            }
                          },
                        ),
                        SizedBox(
                          height: 12.0,
                        ),
                        if (showError)
                          Text(
                            "Email already exists",
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}


























// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:attendance_in/services/auth.dart';
// import 'package:attendance_in/shared/constants.dart';
// import 'package:attendance_in/shared/loading.dart';

// class Register extends StatefulWidget {
//   final Function toggleView;
//   Register({required this.toggleView});

//   @override
//   _RegisterState createState() => _RegisterState();
// }

// class _RegisterState extends State<Register> {
//   final AuthService _auth = AuthService();
//   final _formKey = GlobalKey<FormState>();
//   bool loading = false;

//   // Text Field State
//   String email = '';
//   String password = '';
//   String error = '';

//   // Track whether the "Email already exists" error should be displayed
//   bool showError = false;

//   @override
//   Widget build(BuildContext context) {
//     // Get the current date
//     String currentDate = DateFormat('dd-MM-yyyy').format(DateTime.now());

//     return loading
//         ? Loading()
//         : Scaffold(
//             backgroundColor: Colors.teal[100],
//             appBar: AppBar(
//               backgroundColor: Colors.teal,
//               elevation: 0.0,
//               title: Text(
//                 currentDate,
//                 style: TextStyle(color: Colors.black),
//               ),
//               actions: <Widget>[
//                 TextButton.icon(
//                   onPressed: () {
//                     widget.toggleView();
//                   },
//                   icon: Icon(
//                     Icons.person,
//                     color: Colors.black,
//                   ),
//                   label: Text(
//                     "Log In",
//                     style: TextStyle(color: Colors.black),
//                   ),
//                 )
//               ],
//             ),
//             body: Container(
//               padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: <Widget>[
//                   SizedBox(height: 20.0),
//                   Text(
//                     "Register to Attendance Inn",
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontSize: 24.0,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   SizedBox(height: 20.0),
//                   Form(
//                     key: _formKey,
//                     child: Column(
//                       children: <Widget>[
//                         TextFormField(
//                           decoration: textInputDecoration.copyWith(
//                             hintText: "Email",
//                             icon: Icon(Icons.email, color: Colors.teal),
//                           ),
//                           validator: (val) {
//                             if (val!.isEmpty) {
//                               return "Enter an Email";
//                             } else if (!RegExp(
//                                     r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
//                                 .hasMatch(val)) {
//                               return "Invalid Email";
//                             } else if (!val.endsWith('.com') &&
//                                 !val.endsWith('.co.in') &&
//                                 !val.endsWith('.edu.in')) {
//                               return "Invalid Email";
//                             } else if ((val.contains('google') ||
//                                     val.contains('hotmail') ||
//                                     val.contains('rediffmail') ||
//                                     val.contains('outlook')) &&
//                                 !val.endsWith('.com')) {
//                               return "Invalid Email";
//                             } else if (val.contains('yahoo') &&
//                                 !val.endsWith('.co.in')) {
//                               return "Invalid Email";
//                             }
//                             return null;
//                           },
//                           onChanged: (val) {
//                             setState(() {
//                               email = val;
//                               showError =
//                                   false; // Hide the error on email change
//                             });
//                           },
//                         ),
//                         SizedBox(height: 20.0),
//                         TextFormField(
//                           decoration: textInputDecoration.copyWith(
//                             hintText: "Password",
//                             icon: Icon(Icons.lock, color: Colors.teal),
//                           ),
//                           obscureText: true,
//                           validator: (val) => val!.length < 6
//                               ? "Strong Password 6 Characters+"
//                               : null,
//                           onChanged: (val) {
//                             setState(() => password = val);
//                           },
//                         ),
//                         SizedBox(height: 20.0),
//                         ElevatedButton(
//                           style: ButtonStyle(
//                             backgroundColor:
//                                 MaterialStateProperty.all<Color>(Colors.green),
//                             padding:
//                                 MaterialStateProperty.all<EdgeInsetsGeometry>(
//                               EdgeInsets.all(15),
//                             ),
//                           ),
//                           child: Text(
//                             "Register",
//                             style: TextStyle(
//                               color: Colors.black,
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           onPressed: () async {
//                             if (_formKey.currentState!.validate()) {
//                               setState(() => loading = true);
//                               dynamic result =
//                                   await _auth.registerWithEmailAndPassword(
//                                       email, password);
//                               if (result == null) {
//                                 setState(() {
//                                   loading = false;
//                                   // Clear only the password field on error
//                                   _formKey.currentState?.reset();
//                                   password = ''; // Clear the password field
//                                   showError = true; // Show the error
//                                 });
//                               } else {
//                                 showError =
//                                     false; // Hide the error on successful registration
//                               }
//                             }
//                           },
//                         ),
//                         SizedBox(
//                           height: 12.0,
//                         ),
//                         if (showError)
//                           Text(
//                             "Email already exists",
//                             style: TextStyle(
//                               color: Colors.red,
//                               fontSize: 14.0,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//   }
// }
