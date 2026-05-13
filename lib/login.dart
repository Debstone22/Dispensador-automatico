import 'package:flutter/material.dart';
import 'pantalla_principal.dart'; 
import 'dart:async';
import 'auth_service.dart';

class BannerAnimado extends StatefulWidget {
  const BannerAnimado({super.key});

  @override
  State<BannerAnimado> createState() => _BannerAnimadoState();
}

class _BannerAnimadoState extends State<BannerAnimado> {
  late PageController _pageController;
  int _currentPage = 0;
  late Timer _timer;

  // Lista de imágenes para el bucle (puedes usar la misma varias veces)
  final List<String> _images = [
    'https://t3.ftcdn.net/jpg/06/48/69/42/360_F_648694278_haC94bdL26EedqLMIbMpLACqzxwuvq4f.jpg', 
    'https://www.shutterstock.com/image-photo/portrait-smiling-doctor-isolated-on-600nw-2473504357.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

    _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (_currentPage < _images.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 1500), // Movimiento más suave
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

@override
Widget build(BuildContext context) {
  return SizedBox(
    height: double.infinity, //toda la pantalla de alto
    width: double.infinity,
    child: Stack(
      children: [
        // CAPA 1: La imagen que corre desde internet
        PageView.builder(
          controller: _pageController,
          itemCount: _images.length,
          itemBuilder: (context, index) {
            return Image.network(
              _images[index],
              fit: BoxFit.cover,
              // Indicador de carga mientras se baja la imagen
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                    color: const Color(0xFF4CAF50),
                  ),
                );
              },
              // En caso de que el link se rompa o no haya internet
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey[300],
                child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
              ),
            );
          },
        ),
          
         // CAPA 2: El filtro verde degradado (Overlay)
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF4CAF50).withOpacity(0.6), // Verde arriba
                const Color(0xFFF1F8E9).withOpacity(0.9), // Fondo sólido abajo
              ],
            ),
          ),
        ),
          
          /// CAPA 3: Texto de impacto
        const Positioned(
          bottom: 30,
          left: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "MiniDoc",
                style: TextStyle(
                  color: Color.fromARGB(255, 62, 131, 65),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(blurRadius: 15, color: Colors.black45)],
                ),
              ),
              Text(
                "Tu dispensador automático en casa",
                style: TextStyle(
                  color: Color.fromARGB(179, 41, 110, 49),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        ],
      ),
    );
  }
}

class PantallaLogin extends StatefulWidget {
  const PantallaLogin({super.key});

  @override
  State<PantallaLogin> createState() => _PantallaLoginState();
}

class _PantallaLoginState extends State<PantallaLogin> {
  // Controladores para capturar lo que el usuario escribe
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  bool _isObscure = true; // Para mostrar/ocultar la contraseña
  bool _isLoading = false; //para mostrar que esta cargando


@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Stack(
      children: [
        // Background en movimiento
        const BannerAnimado(),

        // --- FORMULARIO ENCIMA ---
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              children: [
                const SizedBox(height: 50),
                // --- IMAGEN CIRCULAR DEL LOGO O USUARIO ---
                // Usamos Container con sombra para darle profundidad sobre el fondo
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 8), // Sombra hacia abajo
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 45, // Un poco más grande para que resalte
                    backgroundColor: Colors.white, // Fondo por si la imagen es transparente
                    
                    // CAPA 1: La imagen desde URL (Reemplaza por el logo de tu app o foto)
                    // Tip de ingeniería: usa un link que sea cuadrado para que no se deforme
                    backgroundImage: const NetworkImage(
                      'https://www.shutterstock.com/image-illustration/3d-doctor-character-holding-tablet-600nw-2411126917.jpg', 
                    ),
                    
                  ),
                ),

                const SizedBox(height: 25), // Espacio ajustado para que luzca mejor
                const Text(
                  "Bienvenido de nuevo",
                  style: TextStyle(
                    fontSize: 28, 
                    fontWeight: FontWeight.bold, 
                    color: Colors.white, // Blanco para que resalte sobre el verde
                    shadows: [Shadow(blurRadius: 10, color: Colors.black45)]
                  ),
                ),
                const Text(
                  "Ingresa tus datos para continuar", 
                  style: TextStyle(color: Colors.white70)
                ),
                
                const SizedBox(height: 50),

                // Contenedor blanco para los inputs (opcional, le da un toque moderno)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9), // Blanco casi sólido
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _usuarioController,
                        decoration: InputDecoration(
                          labelText: "Usuario o Correo",
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _passController,
                        obscureText: _isObscure,
                        decoration: InputDecoration(
                          labelText: "Contraseña",
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_isObscure ? Icons.visibility : Icons.visibility_off),
                            onPressed: () => setState(() => _isObscure = !_isObscure),
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                ElevatedButton(
                  // Si está cargando, el botón se desactiva (null)
                  onPressed: _isLoading ? null : () async {
                    String email = _usuarioController.text.trim();
                    String password = _passController.text.trim();

                    // Validación rápida de campos vacíos
                    if (email.isEmpty || password.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Por favor, ingresa tu correo y contraseña.'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }

                    // Cambiamos el estado a "cargando"
                    setState(() {
                      _isLoading = true;
                    });

                    try {
                      // Instanciamos tu servicio
                      final authService = AuthService();
                      
                      // Intentamos iniciar sesión con Firebase
                      final sesion = await authService.iniciarSesion(email, password);

                      // Si funciona, mostramos mensaje de bienvenida y navegamos
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('¡Bienvenido ${sesion.nombre}!'),
                          backgroundColor: Colors.green,
                        ),
                      );

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const PantallaPrincipal()),
                      );

                    } catch (e) {
                      // Si falla (clave incorrecta, no existe, etc.), capturamos el error
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: Revise sus credenciales. ${e.toString().replaceAll('Exception: ', '')}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    } finally {
                      // Pase lo que pase (éxito o error), quitamos el estado de carga
                      if (mounted) {
                        setState(() {
                          _isLoading = false;
                        });
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 5,
                  ),
                  // Si está cargando, muestra el spinner, si no, el texto
                  child: _isLoading 
                      ? const SizedBox(
                          height: 25, 
                          width: 25, 
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
                        )
                      : const Text("Iniciar Sesión", style: TextStyle(fontSize: 18)),
                ),

                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    "¿No tienes cuenta? Regístrate aquí", 
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
}