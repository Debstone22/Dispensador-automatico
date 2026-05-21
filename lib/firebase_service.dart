import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ──────────────────────────────────────────────────────────────────────────
  // USUARIOS
  // ──────────────────────────────────────────────────────────────────────────

  /// Crea un paciente/familiar vinculado a un dispositivo.
  /// El [userId] debe ser el UID que entrega Firebase Auth.
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

  /// Lee el perfil completo de un usuario.
  Future<Map<String, dynamic>?> obtenerPerfil(String userId) async {
    final doc = await _db.collection('usuarios').doc(userId).get();
    return doc.exists ? doc.data() : null;
  }

  /// Lista todos los usuarios con un rol determinado.
  Stream<QuerySnapshot> streamUsuariosPorRol(String rol) {
    return _db.collection('usuarios').where('rol', isEqualTo: rol).snapshots();
  }

  /// Lista TODOS los usuarios (para el administrador).
  Stream<QuerySnapshot> streamTodosLosUsuarios() {
    return _db.collection('usuarios').snapshots();
  }

  // ──────────────────────────────────────────────────────────────────────────
  // DISPOSITIVOS Y SLOTS
  // ──────────────────────────────────────────────────────────────────────────

  /// Crea el dispositivo principal con sus slots iniciales.
  Future<void> crearDispositivoConSlots({
    required String deviceId,
    required String pacienteNombre,
    required List<Map<String, dynamic>> slots,
  }) async {
    // Documento raíz del hardware
    await _db.collection('dispositivos').doc(deviceId).set({
      'paciente_nombre': pacienteNombre,
      'estado_conexion': 'Conectado',
      'ultima_sincronizacion': FieldValue.serverTimestamp(),
      'nivel_bateria': 100,
      'alarma_activa': false,
    });

    // Subcolección de slots
    for (int i = 0; i < slots.length; i++) {
      await _db
          .collection('dispositivos')
          .doc(deviceId)
          .collection('slots')
          .doc('slot_${i + 1}')
          .set(slots[i]);
    }
  }

  /// Stream en tiempo real de los slots de un dispositivo.
  Stream<QuerySnapshot> streamSlots(String deviceId) {
    return _db
        .collection('dispositivos')
        .doc(deviceId)
        .collection('slots')
        .snapshots();
  }

  /// Actualiza el porcentaje restante de un slot (lo llama el Arduino vía Node.js).
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

  /// Stream del documento de un dispositivo (para ver estado de conexión, batería, etc.)
  Stream<DocumentSnapshot> streamDispositivo(String deviceId) {
    return _db.collection('dispositivos').doc(deviceId).snapshots();
  }

  // ──────────────────────────────────────────────────────────────────────────
  // HISTORIAL DE TOMAS
  // ──────────────────────────────────────────────────────────────────────────

  /// Registra una toma en el historial.
  Future<void> registrarToma({
    required String dispositivoId,
    required String slotId,
    required String medicamento,
    required String estadoToma, // 'Tomado' | 'Omitido' | 'No confirmado'
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

  /// Stream del historial de un dispositivo específico.
  Stream<QuerySnapshot> streamHistorialDispositivo(String dispositivoId) {
    return _db
        .collection('historial_tomas')
        .where('dispositivo_id', isEqualTo: dispositivoId)
        .orderBy('hora_accion_real', descending: true)
        .limit(50)
        .snapshots();
  }

  /// Historial de TODOS los dispositivos (para el especialista en monitoreo).
  Stream<QuerySnapshot> streamHistorialGeneral({int limite = 100}) {
    return _db
        .collection('historial_tomas')
        .orderBy('hora_accion_real', descending: true)
        .limit(limite)
        .snapshots();
  }

  // ──────────────────────────────────────────────────────────────────────────
  // SEÑAL AL ARDUINO (comando de dispensación)
  // ──────────────────────────────────────────────────────────────────────────

  /// El app escribe aquí y el Arduino (vía Node.js) escucha este documento.
  Future<void> enviarComandoDispensacion({
    required String deviceId,
    required String slotId,
  }) async {
    await _db.collection('comandos').doc(deviceId).set({
      'accion': 'dispensar',
      'slot_id': slotId,
      'timestamp': FieldValue.serverTimestamp(),
      'confirmado_paciente': false, // El buzzer lo cambia a true
    });
  }

  /// Confirma que el paciente está presente (lo activa el buzzer/sensor).
  Future<void> confirmarPresencia(String deviceId) async {
    await _db.collection('comandos').doc(deviceId).update({
      'confirmado_paciente': true,
      'hora_confirmacion': FieldValue.serverTimestamp(),
    });
  }

  // ──────────────────────────────────────────────────────────────────────────
  // ALERTAS
  // ──────────────────────────────────────────────────────────────────────────

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

  // ──────────────────────────────────────────────────────────────────────────
  // MEDICAMENTOS (PASTILLAS) FILTRADOS POR USUARIO
  // ──────────────────────────────────────────────────────────────────────────

  /// Agrega un nuevo medicamento vinculado al usuario actual.
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

  /// Obtiene un Stream de las pastillas que le pertenecen ÚNICAMENTE al usuario.
  Stream<QuerySnapshot> streamMedicamentosPorUsuario(String userId) {
    return _db
        .collection('pastillas')
        .where('id_usuario', isEqualTo: userId)
        .snapshots();
  }
}
