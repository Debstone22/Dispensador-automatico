import 'package:firebase_auth/firebase_auth.dart';      
import 'package:cloud_firestore/cloud_firestore.dart';  


/// Roles definidos en el sistema
enum RolUsuario { administrador, monitor, callcenter, familiar, desconocido }

/// Modelo que devuelve el login: uid + rol resuelto
class SesionUsuario {
  final String uid;
  final String email;
  final String nombre;
  final RolUsuario rol;

  const SesionUsuario({
    required this.uid,
    required this.email,
    required this.nombre,
    required this.rol,
  });
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── LOGIN CON EMAIL Y CONTRASEÑA ──────────────────────────────────────────
  Future<SesionUsuario> iniciarSesion(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    final uid = credential.user!.uid;
    final doc = await _db.collection('usuario').doc(uid).get();

    if (!doc.exists) {
      throw Exception('Usuario no encontrado en la base de datos.');
    }

    final data = doc.data()!;
    final rolString = (data['rol'] as String? ?? '').toLowerCase();
    final nombre = data['nombre'] as String? ?? 'Usuario';

    return SesionUsuario(
      uid: uid,
      email: email.trim(),
      nombre: nombre,
      rol: _parsearRol(rolString),
    );
  }

  // ─── CERRAR SESIÓN ─────────────────────────────────────────────────────────
  Future<void> cerrarSesion() async {
    await _auth.signOut();
  }

  // ─── SESIÓN ACTIVA AL ABRIR LA APP ────────────────────────────────────────
  Future<SesionUsuario?> obtenerSesionActual() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _db.collection('usuario').doc(user.uid).get();
    if (!doc.exists) return null;

    final data = doc.data()!;
    return SesionUsuario(
      uid: user.uid,
      email: user.email ?? '',
      nombre: data['nombre'] as String? ?? 'Usuario',
      rol: _parsearRol((data['rol'] as String? ?? '').toLowerCase()),
    );
  }

  // ─── HELPER ───────────────────────────────────────────────────────────────
  RolUsuario _parsearRol(String rol) {
    switch (rol) {
      case 'administrador':
        return RolUsuario.administrador;
      case 'monitor':
        return RolUsuario.monitor;
      case 'callcenter':
      case 'call center':
        return RolUsuario.callcenter;
      case 'familiar':
        return RolUsuario.familiar;
      default:
        return RolUsuario.desconocido;
    }
  }

  // ─── CREAR COLABORADOR (solo Admin) ───────────────────────────────────────
  Future<void> crearColaborador({
    required String email,
    required String password,
    required String nombre,
    required String rol,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await _db.collection('usuario').doc(cred.user!.uid).set({
      'nombre': nombre,
      'email': email,
      'rol': rol,
      'creado_en': FieldValue.serverTimestamp(),
      'dispositivos_asignados': [],
    });
  }
}
