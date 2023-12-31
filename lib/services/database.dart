import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String uid;
  DatabaseService({required this.uid});
  //collection reference
  final CollectionReference userscollection =
      FirebaseFirestore.instance.collection('Users');

  Future updateUserProfile(List<Map<String, dynamic>> semesters) async {
    return await userscollection.doc(uid).set({
      'semesters': semesters,
    });
  }

  Future updateUserSemesters(List<Map<String, dynamic>> semesters) async {
    return await userscollection.doc(uid).update({
      'semesters': semesters,
    });
  }

  Future updateUserCourse(Map<String, dynamic> course) async {
    try {
      await userscollection
          .doc(uid)
          .collection('semesters') // Adjust to your Firestore structure
          .doc(course['semesterName']) // Adjust to your Firestore structure
          .collection('courses') // Adjust to your Firestore structure
          .doc(course['courseName'])
          .set(course);
    } catch (e) {
      print('Error updating course: $e');
    }
  }
}























// import 'package:cloud_firestore/cloud_firestore.dart';

// class DatabaseService {
//   final String uid;
//   DatabaseService({required this.uid});
//   //collection reference
//   final CollectionReference userscollection =
//       FirebaseFirestore.instance.collection('Users');

//   Future updateUserProfile(List<Map<String, dynamic>> semesters) async {
//     return await userscollection.doc(uid).set({
//       'semesters': semesters,
//     });
//   }

//   Future updateUserSemesters(List<Map<String, dynamic>> semesters) async {
//     return await userscollection.doc(uid).update({
//       'semesters': semesters,
//     });
//   }

//   Future updateUserCourse(Map<String, dynamic> course) async {
//     try {
//       await userscollection
//           .doc(uid)
//           .collection('semesters') // Adjust to your Firestore structure
//           .doc(course['semesterName']) // Adjust to your Firestore structure
//           .collection('courses') // Adjust to your Firestore structure
//           .doc(course['courseName'])
//           .set(course);
//     } catch (e) {
//       print('Error updating course: $e');
//     }
//   }
// }



// New DB Logic
