import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

enum RolUsuario {
  administrador,
  monitor,
  callcenter,
  familiar,
  paciente,
  desconocido,
}

class SesionUsuario {
  final String uid;
  final String email;
  final String nombre;
  final String sexo;
  final RolUsuario rol;

  const SesionUsuario({
    required this.uid,
    required this.email,
    required this.nombre,
    required this.sexo,
    required this.rol,
  });
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

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

    final rolString = (data['rol_usuario'] as String? ?? '').toLowerCase();
    final nombre = data['nombre_usuario'] as String? ?? 'Usuario';
    final sexo = data['sexo_usuario'] as String? ?? 'H';

    return SesionUsuario(
      uid: uid,
      email: email.trim(),
      nombre: nombre,
      sexo: sexo,
      rol: _parsearRol(rolString),
    );
  }

  Future<void> cerrarSesion() async {
    await _auth.signOut();
  }

  Future<void> recuperarContrasena(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } catch (e) {
      throw Exception('Error al enviar el correo de recuperacion.');
    }
  }

  Future<void> cambiarContrasena(String nuevaContrasena) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No hay usuario autenticado.');
    }

    try {
      await user.updatePassword(nuevaContrasena.trim());
    } catch (e) {
      throw Exception('Error al cambiar la contrasena: $e');
    }
  }

  Future<SesionUsuario?> obtenerSesionActual() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _db.collection('usuario').doc(user.uid).get();
    if (!doc.exists) return null;

    final data = doc.data()!;
    return SesionUsuario(
      uid: user.uid,
      email: user.email ?? '',
      nombre: data['nombre_usuario'] as String? ?? 'Usuario',
      sexo: data['sexo_usuario'] as String? ?? 'H',
      rol: _parsearRol((data['rol_usuario'] as String? ?? '').toLowerCase()),
    );
  }

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
      case 'paciente':
        return RolUsuario.paciente;
      default:
        return RolUsuario.desconocido;
    }
  }

  Future<void> registrarUsuarioConScrypt({
    required String email,
    required String password,
    required String nombre,
    required String sexo,
  }) async {
    try {
      UserCredential credencial = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      String uidGenerado = credencial.user!.uid;

      await _db.collection('usuario').doc(uidGenerado).set({
        'nombre_usuario': nombre.trim(),
        'correo_usuario': email.trim(),
        'rol_usuario': 'paciente',
        'sexo_usuario': sexo,
        'creado_en': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception("Error al registrar: ${e.toString()}");
    }
  }

  Future<SesionUsuario> iniciarSesionGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    if (googleUser == null) {
      throw Exception("Inicio de sesion cancelado");
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);

    final user = userCredential.user!;

    final docRef = _db.collection('usuario').doc(user.uid);

    final doc = await docRef.get();

    if (!doc.exists) {
      await docRef.set({
        'nombre_usuario': user.displayName ?? 'Usuario',
        'correo_usuario': user.email ?? '',
        'rol_usuario': 'paciente',
        'sexo_usuario': 'H',
        'creado_en': FieldValue.serverTimestamp(),
      });
    }

    final nuevoDoc = await docRef.get();
    final data = nuevoDoc.data()!;

    return SesionUsuario(
      uid: user.uid,
      email: user.email ?? '',
      nombre: data['nombre_usuario'] ?? 'Usuario',
      sexo: data['sexo_usuario'] ?? 'H',
      rol: _parsearRol(
        (data['rol_usuario'] ?? '').toLowerCase(),
      ),
    );
  }
}
