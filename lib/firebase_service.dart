import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;


  Future<void> crearPaciente({
    required String userId,
    required String nombre,
    required String email,
    String dispositivo = '',
  }) async {
    await _db.collection('usuarios').doc(userId).set({
      'nombre': nombre,
      'email': email,
      'rol': 'familiar',
      'dispositivos_asignados': dispositivo.isNotEmpty ? [dispositivo] : [],
      'creado_en': FieldValue.serverTimestamp(),
    });
  }

  Future<Map<String, dynamic>?> obtenerPerfil(String userId) async {
    final doc = await _db.collection('usuarios').doc(userId).get();
    return doc.exists ? doc.data() : null;
  }

  Stream<QuerySnapshot> streamUsuariosPorRol(String rol) {
    return _db.collection('usuarios').where('rol', isEqualTo: rol).snapshots();
  }

  Stream<QuerySnapshot> streamTodosLosUsuarios() {
    return _db.collection('usuarios').snapshots();
  }

  

  Future<void> crearDispositivoConSlots({
    required String deviceId,
    required String pacienteNombre,
    required List<Map<String, dynamic>> slots,
  }) async {
    await _db.collection('dispositivos').doc(deviceId).set({
      'paciente_nombre': pacienteNombre,
      'estado_conexion': 'Conectado',
      'ultima_sincronizacion': FieldValue.serverTimestamp(),
      'nivel_bateria': 100,
      'alarma_activa': false,
    });

    for (int i = 0; i < slots.length; i++) {
      await _db
          .collection('dispositivos')
          .doc(deviceId)
          .collection('slots')
          .doc('slot_${i + 1}')
          .set(slots[i]);
    }
  }

  Stream<QuerySnapshot> streamSlots(String deviceId) {
    return _db
        .collection('dispositivos')
        .doc(deviceId)
        .collection('slots')
        .snapshots();
  }

  Future<void> actualizarCantidadSlot({
    required String deviceId,
    required String slotId,
    required int nuevaCantidad,
  }) async {
    await _db
        .collection('dispositivos')
        .doc(deviceId)
        .collection('slots')
        .doc(slotId)
        .update({'cantidad_restante': nuevaCantidad});
  }

  Stream<DocumentSnapshot> streamDispositivo(String deviceId) {
    return _db.collection('dispositivos').doc(deviceId).snapshots();
  }

  
  Future<void> registrarToma({
    required String dispositivoId,
    required String slotId,
    required String medicamento,
    required String estadoToma, 
    String? pacienteId,
  }) async {
    await _db.collection('historial_tomas').add({
      'dispositivo_id': dispositivoId,
      'slot_id': slotId,
      'medicamento': medicamento,
      'paciente_id': pacienteId ?? '',
      'hora_programada': FieldValue.serverTimestamp(),
      'hora_accion_real': FieldValue.serverTimestamp(),
      'estado_toma': estadoToma,
    });
  }

  Stream<QuerySnapshot> streamHistorialDispositivo(String dispositivoId) {
    return _db
        .collection('historial_tomas')
        .where('dispositivo_id', isEqualTo: dispositivoId)
        .orderBy('hora_accion_real', descending: true)
        .limit(50)
        .snapshots();
  }

  Stream<QuerySnapshot> streamHistorialGeneral({int limite = 100}) {
    return _db
        .collection('historial_tomas')
        .orderBy('hora_accion_real', descending: true)
        .limit(limite)
        .snapshots();
  }

  
  Future<void> enviarComandoDispensacion({
    required String deviceId,
    required String slotId,
  }) async {
    await _db.collection('comandos').doc(deviceId).set({
      'accion': 'dispensar',
      'slot_id': slotId,
      'timestamp': FieldValue.serverTimestamp(),
      'confirmado_paciente': false, 
    });
  }

  Future<void> confirmarPresencia(String deviceId) async {
    await _db.collection('comandos').doc(deviceId).update({
      'confirmado_paciente': true,
      'hora_confirmacion': FieldValue.serverTimestamp(),
    });
  }

  

  Stream<QuerySnapshot> streamAlertas({bool soloActivas = true}) {
    Query query = _db.collection('alertas');
    if (soloActivas) query = query.where('resuelta', isEqualTo: false);
    return query.orderBy('creada_en', descending: true).snapshots();
  }

  Future<void> resolverAlerta(String alertaId) async {
    await _db.collection('alertas').doc(alertaId).update({
      'resuelta': true,
      'resuelta_en': FieldValue.serverTimestamp(),
    });
  }

  
  Future<void> agregarMedicamento({
    required String userId,
    required String nombrePastilla,
  }) async {
    await _db.collection('pastillas').add({
      'id_usuario': userId,
      'nombre_pastilla': nombrePastilla,
      'descripcion_pastillas': 'Medicamento registrado desde la app',
      'recomendaciones_pastillas': 'Sin recomendaciones adicionales',
      'creado_en': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> streamMedicamentosPorUsuario(String userId) {
    return _db
        .collection('pastillas')
        .where('id_usuario', isEqualTo: userId)
        .snapshots();
  }
}
