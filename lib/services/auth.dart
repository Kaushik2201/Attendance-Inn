import 'package:attendance_in/models/user.dart';
import 'package:attendance_in/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Userdef? _userFromFirebaseUser(User? user) {
    return user != null ? Userdef(uid: user.uid) : null;
  }

  Stream<Userdef?> get user {
    return _auth
        .authStateChanges()
        .map((User? user) => _userFromFirebaseUser(user!));
  }

  Future signInAnon() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      User? user = result.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future registerWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;

      List<Map<String, dynamic>> semesters = [
        {
          'semesterName': 'Semester 1',
          'courses': [
            {
              'courseName': 'Course A',
              'attendance': {
                'presentDates': [],
                'totalPresentCount': 0,
                'absentDates': [],
                'totalAbsentCount': 0,
                'totalClassesConducted': 0,
              },
            },
          ],
        },
      ];

      await DatabaseService(uid: user!.uid).updateUserProfile(semesters);
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
    }
  }

  Future<List<Map<String, dynamic>>> getUserSemesters() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userData =
            await _firestore.collection('Users').doc(user.uid).get();
        if (userData.exists) {
          dynamic semestersData = userData['semesters'];

          // Ensure semestersData is a List<Map<String, dynamic>>
          if (semestersData is List &&
              semestersData.isNotEmpty &&
              semestersData[0] is Map) {
            return List<Map<String, dynamic>>.from(semestersData);
          } else {
            // Handle the case where the data is not in the expected format
            print("Invalid format for semesters data");
            return [];
          }
        }
      }
      return [];
    } catch (e) {
      print(e.toString());
      return [];
    }
  }

  Future updateUserSemesters(List<Map<String, dynamic>> semesters) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await DatabaseService(uid: user.uid).updateUserSemesters(semesters);
      }
    } catch (e) {
      print(e.toString());
    }
  }
}












// import 'package:attendance_in/models/user.dart';
// import 'package:attendance_in/services/database.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class AuthService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   Userdef? _userFromFirebaseUser(User? user) {
//     return user != null ? Userdef(uid: user.uid) : null;
//   }

//   Stream<Userdef?> get user {
//     return _auth
//         .authStateChanges()
//         .map((User? user) => _userFromFirebaseUser(user!));
//   }

//   Future signInAnon() async {
//     try {
//       UserCredential result = await _auth.signInAnonymously();
//       User? user = result.user;
//       return _userFromFirebaseUser(user);
//     } catch (e) {
//       print(e.toString());
//       return null;
//     }
//   }

//   Future signInWithEmailAndPassword(String email, String password) async {
//     try {
//       UserCredential result = await _auth.signInWithEmailAndPassword(
//           email: email, password: password);
//       User? user = result.user;
//       return _userFromFirebaseUser(user);
//     } catch (e) {
//       print(e.toString());
//       return null;
//     }
//   }

//   Future registerWithEmailAndPassword(String email, String password) async {
//     try {
//       UserCredential result = await _auth.createUserWithEmailAndPassword(
//           email: email, password: password);
//       User? user = result.user;

//       List<Map<String, dynamic>> semesters = [
//         {
//           'semesterName': 'Semester 1',
//           'courses': [
//             {
//               'courseName': 'Course A',
//               'attendance': {
//                 'presentDates': [],
//                 'totalPresentCount': 0,
//                 'absentDates': [],
//                 'totalAbsentCount': 0,
//                 'totalClassesConducted': 0,
//               },
//             },
//           ],
//         },
//       ];

//       await DatabaseService(uid: user!.uid).updateUserProfile(semesters);
//       return _userFromFirebaseUser(user);
//     } catch (e) {
//       print(e.toString());
//       return null;
//     }
//   }

//   Future signOut() async {
//     try {
//       return await _auth.signOut();
//     } catch (e) {
//       print(e.toString());
//     }
//   }

//   Future<List<Map<String, dynamic>>> getUserSemesters() async {
//     try {
//       User? user = _auth.currentUser;
//       if (user != null) {
//         DocumentSnapshot userData =
//             await _firestore.collection('Users').doc(user.uid).get();
//         if (userData.exists) {
//           dynamic semestersData = userData['semesters'];

//           // Ensure semestersData is a List<Map<String, dynamic>>
//           if (semestersData is List &&
//               semestersData.isNotEmpty &&
//               semestersData[0] is Map) {
//             return List<Map<String, dynamic>>.from(semestersData);
//           } else {
//             // Handle the case where the data is not in the expected format
//             print("Invalid format for semesters data");
//             return [];
//           }
//         }
//       }
//       return [];
//     } catch (e) {
//       print(e.toString());
//       return [];
//     }
//   }

//   Future updateUserSemesters(List<Map<String, dynamic>> semesters) async {
//     try {
//       User? user = _auth.currentUser;
//       if (user != null) {
//         await DatabaseService(uid: user.uid).updateUserSemesters(semesters);
//       }
//     } catch (e) {
//       print(e.toString());
//     }
//   }
// }
// this is my authentication logic 