import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 👈 Asegúrate de importar Firestore

class PantallaRegistro extends StatefulWidget {
  const PantallaRegistro({super.key});

  @override
  State<PantallaRegistro> createState() => _PantallaRegistroState();
}

class _PantallaRegistroState extends State<PantallaRegistro> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  // 👈 Variable para almacenar la selección de sexo (null por defecto)
  String? _sexoSeleccionado;

  @override
  void dispose() {
    _nombreController.dispose();
    _correoController.dispose();
    _passController.dispose();
    super.dispose();
  }

  // 👈 Función para registrar al usuario en Firestore
  Future<void> _registrarUsuario() async {
    // Validamos que ningún campo esté vacío
    if (_nombreController.text.isEmpty ||
        _correoController.text.isEmpty ||
        _passController.text.isEmpty ||
        _sexoSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text("Por favor, llena todos los campos, incluido el sexo.")),
      );
      return;
    }

    try {
      // Agrega el documento a tu colección 'usuario' tal como está en tu consola
      await FirebaseFirestore.instance.collection('usuario').add({
        'nombre_usuario': _nombreController.text.trim(),
        'correo_usuario': _correoController.text.trim(),
        'contraseña_usuario': _passController.text.trim(),
        'rol_usuario': 'paciente', // Por defecto según tu captura
        'sexo_usuario': _sexoSeleccionado, // 👈 Aquí se guarda "H" o "M"
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Usuario registrado con éxito")),
      );

      Navigator.pop(context); // Regresa al Login tras guardar
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al registrar: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1B5E20)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Crear Cuenta",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Ingresa tus datos para registrarte",
                style: TextStyle(color: Colors.black54, fontSize: 16),
              ),
              const SizedBox(height: 40),

              // Campo de Nombre
              _crearCampoTexto(
                icono: Icons.person,
                texto: "Nombre completo",
                controller: _nombreController,
              ),
              const SizedBox(height: 20),

              // Campo de Correo
              _crearCampoTexto(
                icono: Icons.email,
                texto: "Correo electrónico",
                controller: _correoController,
              ),
              const SizedBox(height: 20),

              // Campo de Contraseña
              _crearCampoTexto(
                icono: Icons.lock,
                texto: "Contraseña",
                esClave: true,
                controller: _passController,
              ),
              const SizedBox(height: 20),

              // 👈 NUEVO: Selector desplegable para Sexo (H / M)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: DropdownButtonFormField<String>(
                  value: _sexoSeleccionado,
                  hint: const Row(
                    children: [
                      Icon(Icons.wc, color: Colors.grey),
                      SizedBox(width: 10),
                      Text("Selecciona tu sexo",
                          style: TextStyle(color: Colors.black54)),
                    ],
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                  ),
                  items: const [
                    DropdownMenuItem(value: "H", child: Text("Hombre (H)")),
                    DropdownMenuItem(value: "M", child: Text("Mujer (M)")),
                  ],
                  onChanged: (valor) {
                    setState(() {
                      _sexoSeleccionado = valor;
                    });
                  },
                ),
              ),
              const SizedBox(height: 40),

              // Botón de Registrarse
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed:
                      _registrarUsuario, // 👈 Llama a la función de Firebase
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    "Registrarse",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _crearCampoTexto({
    required IconData icono,
    required String texto,
    required TextEditingController controller,
    bool esClave = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: esClave,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Icon(icono, color: Colors.grey),
        hintText: texto,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
