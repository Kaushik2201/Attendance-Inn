import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:attendance_in/services/auth.dart';
import 'package:attendance_in/shared/constants.dart';
import 'package:attendance_in/shared/loading.dart';

class SignIn extends StatefulWidget {
  final Function toggleView;
  SignIn({required this.toggleView});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  // Text Field State
  String email = "";
  String password = "";
  String error = '';
  bool isObscure = true; // Initially obscure the password

  // Store the original entered email
  String originalEmail = "";

  // Controller for the email input in the reset password popup
  TextEditingController _resetEmailController = TextEditingController();

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
                    "Register",
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
                    "Log In to Attendance Inn",
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
                          initialValue: originalEmail,
                          validator: (val) =>
                              val!.isEmpty ? "Enter an Email" : null,
                          onChanged: (val) {
                            setState(() {
                              email = val;
                              error = ''; // Clear the error when typing
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.green),
                                padding: MaterialStateProperty.all<
                                    EdgeInsetsGeometry>(
                                  EdgeInsets.all(15),
                                ),
                              ),
                              child: Text(
                                "Log In",
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
                                      await _auth.signInWithEmailAndPassword(
                                          email, password);
                                  if (result == null) {
                                    setState(() {
                                      error = "INVALID CREDENTIALS";
                                      loading = false;
                                      // Clear only the password field on error
                                      _formKey.currentState?.reset();
                                      email =
                                          originalEmail; // Restore the original email
                                    });
                                  }
                                }
                              },
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() => isObscure = !isObscure);
                                _showForgotPasswordPopup();
                              },
                              child: Text(
                                "Forgot Password?",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 12.0,
                        ),
                        Text(
                          error,
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

  // Function to show the "Forgot Password" popup
  void _showForgotPasswordPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Forgot Password"),
          content: Column(
            children: [
              Text("Enter your registered email ID to reset your password:"),
              SizedBox(height: 10),
              TextFormField(
                controller: _resetEmailController,
                decoration: textInputDecoration.copyWith(
                  hintText: "Email",
                  icon: Icon(Icons.email, color: Colors.teal),
                ),
                validator: (val) => val!.isEmpty ? "Enter an Email" : null,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                String resetEmail = _resetEmailController.text.trim();
                if (resetEmail.isNotEmpty) {
                  // Call the resetPassword method with the entered email
                  await _forgotPassword(resetEmail);
                  Navigator.of(context).pop();
                  setState(() => _resetEmailController.clear());
                  _showResetPasswordPopup();
                }
              },
              child: Text("Send"),
            ),
          ],
        );
      },
    );
  }

  // Function to handle the "Forgot Password" action
  Future<void> _forgotPassword(String email) async {
    // Implement Firebase reset password functionality
    try {
      await _auth.resetPassword(email);
    } catch (e) {
      print("Error sending reset password email: $e");
      // Handle error, e.g., display an error message to the user
    }
  }

  // Function to show a pop-up indicating that an email to reset the password has been sent
  void _showResetPasswordPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Password Reset Email Sent"),
          content: Text(
              "An email to reset your password has been sent to your registered email address."),
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
}
























// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:attendance_in/services/auth.dart';
// import 'package:attendance_in/shared/constants.dart';
// import 'package:attendance_in/shared/loading.dart';

// class SignIn extends StatefulWidget {
//   final Function toggleView;
//   SignIn({required this.toggleView});

//   @override
//   State<SignIn> createState() => _SignInState();
// }

// class _SignInState extends State<SignIn> {
//   final AuthService _auth = AuthService();
//   final _formKey = GlobalKey<FormState>();
//   bool loading = false;

//   // Text Field State
//   String email = "";
//   String password = "";
//   String error = '';

//   // Store the original entered email
//   String originalEmail = "";

//   // Controller for the email input in the reset password popup
//   TextEditingController _resetEmailController = TextEditingController();

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
//                     "Register",
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
//                     "Log In to Attendance Inn",
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
//                           initialValue: originalEmail,
//                           validator: (val) =>
//                               val!.isEmpty ? "Enter an Email" : null,
//                           onChanged: (val) {
//                             setState(() {
//                               email = val;
//                               error = ''; // Clear the error when typing
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
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             ElevatedButton(
//                               style: ButtonStyle(
//                                 backgroundColor:
//                                     MaterialStateProperty.all<Color>(
//                                         Colors.green),
//                                 padding: MaterialStateProperty.all<
//                                     EdgeInsetsGeometry>(
//                                   EdgeInsets.all(15),
//                                 ),
//                               ),
//                               child: Text(
//                                 "Log In",
//                                 style: TextStyle(
//                                   color: Colors.black,
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               onPressed: () async {
//                                 if (_formKey.currentState!.validate()) {
//                                   setState(() => loading = true);
//                                   dynamic result =
//                                       await _auth.signInWithEmailAndPassword(
//                                           email, password);
//                                   if (result == null) {
//                                     setState(() {
//                                       error = "INVALID CREDENTIALS";
//                                       loading = false;
//                                       // Clear only the password field on error
//                                       _formKey.currentState?.reset();
//                                       email =
//                                           originalEmail; // Restore the original email
//                                     });
//                                   }
//                                 }
//                               },
//                             ),
//                             TextButton(
//                               onPressed: () {
//                                 _showForgotPasswordPopup();
//                               },
//                               child: Text(
//                                 "Forgot Password?",
//                                 style: TextStyle(
//                                   color: Colors.black,
//                                   fontSize: 16,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         SizedBox(
//                           height: 12.0,
//                         ),
//                         Text(
//                           error,
//                           style: TextStyle(
//                             color: Colors.red,
//                             fontSize: 18.0,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//   }

//   // Function to show the "Forgot Password" popup
//   void _showForgotPasswordPopup() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Forgot Password"),
//           content: Column(
//             children: [
//               Text("Enter your registered email ID to reset your password:"),
//               SizedBox(height: 10),
//               TextFormField(
//                 controller: _resetEmailController,
//                 decoration: textInputDecoration.copyWith(
//                   hintText: "Email",
//                   icon: Icon(Icons.email, color: Colors.teal),
//                 ),
//                 validator: (val) => val!.isEmpty ? "Enter an Email" : null,
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text("Cancel"),
//             ),
//             TextButton(
//               onPressed: () async {
//                 String resetEmail = _resetEmailController.text.trim();
//                 if (resetEmail.isNotEmpty) {
//                   // Call the resetPassword method with the entered email
//                   await _forgotPassword(resetEmail);
//                   Navigator.of(context).pop();
//                   _showResetPasswordPopup();
//                 }
//               },
//               child: Text("Send"),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // Function to handle the "Forgot Password" action
//   Future<void> _forgotPassword(String email) async {
//     // Implement Firebase reset password functionality
//     try {
//       await _auth.resetPassword(email);
//     } catch (e) {
//       print("Error sending reset password email: $e");
//       // Handle error, e.g., display an error message to the user
//     }
//   }

//   // Function to show a pop-up indicating that an email to reset the password has been sent
//   void _showResetPasswordPopup() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Password Reset Email Sent"),
//           content: Text(
//               "An email to reset your password has been sent to your registered email address."),
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
// }