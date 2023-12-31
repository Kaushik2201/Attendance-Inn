import 'package:attendance_in/models/user.dart';
import 'package:attendance_in/screens/authenticate/authenticate.dart';
import 'package:attendance_in/screens/home/home.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<Userdef?>(context);

    // Return either Home or Authenticate
    if (user == null) {
      return Authenticate();
    } else {
      return Home();
    }
  }
}
