// datos_medicamentos.dart
import 'package:cloud_firestore/cloud_firestore.dart';

// Listas globales que se rellenan dinámicamente desde Firebase
List<String> nombresPastillasGlobal = [];
List<Map<String, dynamic>> slotsGlobal = [];

// Instancia global de Firestore
final FirebaseFirestore firestoreInstance = FirebaseFirestore.instance;
