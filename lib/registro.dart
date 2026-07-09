import 'package:flutter/material.dart';
import 'auth_service.dart';

class PantallaRegistro extends StatefulWidget {
  const PantallaRegistro({super.key});

  @override
  State<PantallaRegistro> createState() => _PantallaRegistroState();
}

class _PantallaRegistroState extends State<PantallaRegistro> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  String? _sexoSeleccionado;

  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _nombreController.dispose();
    _correoController.dispose();
    _passController.dispose();
    super.dispose();
  }

  Future<void> _registrarUsuario() async {
    if (_nombreController.text.isEmpty ||
        _correoController.text.isEmpty ||
        _passController.text.isEmpty ||
        _sexoSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Por favor, llena todos los campos, incluido el sexo."),
        ),
      );
      return;
    }

    try {
      await _authService.registrarUsuarioConScrypt(
        email: _correoController.text,
        password: _passController.text,
        nombre: _nombreController.text,
        sexo: _sexoSeleccionado!,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Usuario registrado con exito y de forma segura"),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
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
              _crearCampoTexto(
                icono: Icons.person,
                texto: "Nombre completo",
                controller: _nombreController,
              ),
              const SizedBox(height: 20),
              _crearCampoTexto(
                icono: Icons.email,
                texto: "Correo electronico",
                controller: _correoController,
              ),
              const SizedBox(height: 20),
              _crearCampoTexto(
                icono: Icons.lock,
                texto: "Contrasena",
                esClave: true,
                controller: _passController,
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: DropdownButtonFormField<String>(
                  initialValue: _sexoSeleccionado,
                  hint: const Row(
                    children: [
                      Icon(Icons.wc, color: Colors.grey),
                      SizedBox(width: 10),
                      Text(
                        "Selecciona tu sexo",
                        style: TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                  decoration: const InputDecoration(border: InputBorder.none),
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
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _registrarUsuario,
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