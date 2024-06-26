import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.teal[100],
      child: Center(
        child: SpinKitPouringHourGlass(
          color: Colors.teal,
          size: 200.0,
        ),
      ),
    );
  }
}
