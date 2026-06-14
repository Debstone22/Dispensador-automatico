import 'package:flutter/material.dart';
import 'dart:async';
import 'auth_service.dart';
import 'registro.dart';
import 'role_router.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class BannerAnimado extends StatefulWidget {
  const BannerAnimado({super.key});
  @override
  State<BannerAnimado> createState() => _BannerAnimadoState();
}

class _BannerAnimadoState extends State<BannerAnimado> {
  late PageController _pageController;
  int _currentPage = 0;
  late Timer _timer;

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
          duration: const Duration(milliseconds: 1500),
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
      height: double.infinity,
      width: double.infinity,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _images.length,
            itemBuilder: (context, index) =>
                Image.network(_images[index], fit: BoxFit.cover),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF4CAF50).withOpacity(0.6),
                  const Color(0xFFF1F8E9).withOpacity(0.9),
                ],
              ),
            ),
          ),
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
                  ),
                ),
                Text(
                  "Tu dispensador automatico en casa",
                  style: TextStyle(
                    color: Color.fromARGB(179, 41, 110, 49),
                    fontSize: 14,
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
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  bool _isObscure = true;
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  Future<void> _iniciarSesion() async {
    String inputUsuario = _usuarioController.text.trim();
    String inputPassword = _passController.text.trim();

    if (inputUsuario.isEmpty || inputPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, llena todos los campos')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final sesion = await _authService.iniciarSesion(
        inputUsuario,
        inputPassword,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bienvenido ${sesion.nombre}')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => buildHomeForRole(sesion),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al iniciar sesion: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _mostrarRecuperacion() async {
    final TextEditingController emailController = TextEditingController(
      text: _usuarioController.text.trim(),
    );

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Recuperar contrasena'),
          content: TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Correo',
              hintText: 'tucorreo@ejemplo.com',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final email = emailController.text.trim();
                if (email.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ingresa tu correo.')),
                  );
                  return;
                }

                try {
                  await _authService.recuperarContrasena(email);
                  if (!mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Revisa tu correo para restablecer la contrasena.',
                      ),
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al enviar correo: $e')),
                  );
                }
              },
              child: const Text('Enviar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const BannerAnimado(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                children: [
                  const SizedBox(height: 50),
                  const CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.white,
                    backgroundImage: NetworkImage(
                      'https://www.shutterstock.com/image-illustration/3d-doctor-character-holding-tablet-600nw-2411126917.jpg',
                    ),
                  ),
                  const SizedBox(height: 25),
                  const Text(
                    "Bienvenido de nuevo",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 50),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: _usuarioController,
                          decoration: const InputDecoration(
                            labelText: "Usuario o Correo",
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _passController,
                          obscureText: _isObscure,
                          decoration: InputDecoration(
                            labelText: "Contrasena",
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isObscure
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () =>
                                  setState(() => _isObscure = !_isObscure),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _mostrarRecuperacion,
                            child: const Text('Olvide mi clave'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _iniciarSesion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 55),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Iniciar Sesion"),
                  ),
                  const SizedBox(height: 15),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.g_mobiledata, size: 30),
                    label: const Text("Continuar con Google"),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 55),
                      backgroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      try {
                        final sesion = await _authService.iniciarSesionGoogle();

                        if (!mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Bienvenido ${sesion.nombre}'),
                          ),
                        );

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => buildHomeForRole(sesion),
                          ),
                        );
                      } catch (e) {
                        if (!mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error Google Sign-In: $e'),
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton.icon(
                    onPressed: () async {
                      setState(() {
                        _isLoading = true;
                      });

                      try {
                        final sesion =
                            await _authService.iniciarSesionFacebook();

                        if (!mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Bienvenido ${sesion.nombre}')),
                        );

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => buildHomeForRole(sesion),
                          ),
                        );
                      } catch (e) {
                        if (!mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error Facebook Sign-In: $e'),
                          ),
                        );
                      } finally {
                        if (mounted) {
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1877F2),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 55),
                    ),
                    icon: const Icon(Icons.facebook),
                    label: const Text("Continuar con Facebook"),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PantallaRegistro(),
                        ),
                      );
                    },
                    child: const Text(
                      "No tienes cuenta? Registrate aqui",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
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
