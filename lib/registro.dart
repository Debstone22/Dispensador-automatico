import 'package:flutter/material.dart';

class PantallaRegistro extends StatefulWidget {
  const PantallaRegistro({super.key});

  @override
  State<PantallaRegistro> createState() => _PantallaRegistroState();
}

class _PantallaRegistroState extends State<PantallaRegistro> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  @override
  void dispose() {
    _nombreController.dispose();
    _correoController.dispose();
    _passController.dispose();
    super.dispose();
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
                controller: _nombreController, // Pasamos el controlador
              ),
              const SizedBox(height: 20),

              // Campo de Correo
              _crearCampoTexto(
                icono: Icons.email,
                texto: "Correo electrónico",
                controller: _correoController, // Pasamos el controlador
              ),
              const SizedBox(height: 20),

              // Campo de Contraseña
              _crearCampoTexto(
                icono: Icons.lock,
                texto: "Contraseña",
                esClave: true,
                controller: _passController, // Pasamos el controlador
              ),
              const SizedBox(height: 40),

              // Botón de Registrarse
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    // Aquí ya puedes obtener los datos así:
                    print("Nombre: ${_nombreController.text}");
                    print("Correo: ${_correoController.text}");

                    // Simulación de registro exitoso
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Registro procesado con éxito"),
                      ),
                    );
                  },
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

  // 2. Modificamos el widget auxiliar para que reciba el controlador
  Widget _crearCampoTexto({
    required IconData icono,
    required String texto,
    required TextEditingController controller, // Ahora es obligatorio
    bool esClave = false,
  }) {
    return TextField(
      controller: controller, // Asignamos el controlador al TextField
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
