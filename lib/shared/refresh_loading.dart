import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class RefreshLoading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.teal[100],
      child: Center(
        child: SpinKitHourGlass(
          color: Colors.teal,
          size: 100.0,
        ),
      ),
    );
  }
}
