import 'package:cloud_firestore/cloud_firestore.dart';

List<String> nombresPastillasGlobal = [];
List<Map<String, dynamic>> slotsGlobal = [];

final FirebaseFirestore firestoreInstance = FirebaseFirestore.instance;
