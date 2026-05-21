import 'package:cloud_firestore/cloud_firestore.dart';

// Listas globales auxiliares
List<String> nombresPastillasGlobal = [];

// Instancia de conexión segura
FirebaseFirestore get firestoreInstance => FirebaseFirestore.instance;
