import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. Crear el Usuario (Familiar)
  Future<void> crearUsuarioInicial() async {
    // Usamos un ID manual por ahora, luego usarás el de FirebaseAuth
    String userId = "user_123"; 
    
    await _db.collection('usuarios').doc(userId).set({
      'nombre': 'Jairo',
      'email': 'jairo@correo.com',
      'rol': 'Familiar',
      'dispositivos_asignados': ['minidoc_mac_001'],
    });
    print("Usuario creado");
  }

  // 2. Crear el Dispositivo y sus Slots (La parte vital para el Arduino)
  Future<void> crearDispositivoConSlots() async {
    String deviceId = "minidoc_mac_001";

    // A. Creamos el documento principal del hardware
    await _db.collection('dispositivos').doc(deviceId).set({
      'paciente_nombre': 'María',
      'estado_conexion': 'Conectado',
      'ultima_sincronizacion': FieldValue.serverTimestamp(),
      'nivel_bateria': 95,
      'alarma_activa': false,
    });

    // B. Creamos la subcolección 'slots' DENTRO del dispositivo
    // SLOT 1: Paracetamol
    await _db.collection('dispositivos').doc(deviceId).collection('slots').doc('slot_1').set({
      'medicamento': 'Paracetamol',
      'cantidad_restante': 7,
      'dosis': 1,
      'hora_toma': '08:00',
      'dias_activos': ['L', 'M', 'X', 'J', 'V', 'S', 'D'],
      'estado_slot': 'Operativo',
    });

    // SLOT 2: Naproxeno
    await _db.collection('dispositivos').doc(deviceId).collection('slots').doc('slot_2').set({
      'medicamento': 'Naproxeno',
      'cantidad_restante': 30,
      'dosis': 1,
      'hora_toma': '12:00',
      'dias_activos': ['L', 'M', 'X', 'J', 'V', 'S', 'D'],
      'estado_slot': 'Operativo',
    });
    
    print("Dispositivo y Slots creados");
  }

  // 3. Crear un registro de prueba en el Historial
  Future<void> simularTomaDePastilla() async {
    // Usamos .add() para que Firebase genere un ID único automático (Hash)
    await _db.collection('historial_tomas').add({
      'dispositivo_id': 'minidoc_mac_001',
      'slot_id': 'slot_1',
      'medicamento': 'Paracetamol',
      'hora_programada': FieldValue.serverTimestamp(), // En la vida real será la hora exacta
      'hora_accion_real': FieldValue.serverTimestamp(),
      'estado_toma': 'Tomado', // O "Omitido"
    });
    print("Historial registrado");
  }
}