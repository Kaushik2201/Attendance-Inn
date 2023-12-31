import 'package:attendance_in/models/user.dart';
import 'package:attendance_in/screens/wrapper.dart';
import 'package:attendance_in/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamProvider<Userdef?>.value(
      value: AuthService().user,
      catchError: (_, __) {
        return null;
      },
      initialData: null,
      child: MaterialApp(
        home: Wrapper(),
      ),
    );
  }
}













// import 'package:attendance_in/models/user.dart';
// import 'package:attendance_in/screens/wrapper.dart';
// import 'package:attendance_in/services/auth.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:provider/provider.dart';
// import 'firebase_options.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return StreamProvider<Userdef?>.value(
//       value: AuthService().user,
//       catchError: (_, __) {
//         return null;
//       },
//       initialData: null,
//       child: MaterialApp(
//         home: Wrapper(),
//       ),
//     );
//   }
// }

