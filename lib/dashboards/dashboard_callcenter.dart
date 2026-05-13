import 'package:flutter/material.dart';
import 'dart:async';
import '../../auth_service.dart';
import '../../login.dart';

// ══════════════════════════════════════════════════════════════════════════════
// DASHBOARD CALL CENTER — Atención médica por llamada
// ══════════════════════════════════════════════════════════════════════════════

class DashboardCallCenter extends StatefulWidget {
  final SesionUsuario sesion;
  const DashboardCallCenter({super.key, required this.sesion});

  @override
  State<DashboardCallCenter> createState() => _DashboardCallCenterState();
}

class _DashboardCallCenterState extends State<DashboardCallCenter> {
  int _tab = 0;
  final _auth = AuthService();

  static const _ambar = Color(0xFFBA7517);
  static const _ambarLight = Color(0xFFFAEEDA);

  Future<void> _cerrarSesion() async {
    await _auth.cerrarSesion();
    if (mounted) {
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (_) => const PantallaLogin()), (_) => false);
    }
  }

  void _abrirLlamada(Map<String, dynamic> paciente) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PantallaLlamada(paciente: paciente),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                  color: _ambar, borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.medication, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            const Text('MedDispenser',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
                color: _ambarLight, borderRadius: BorderRadius.circular(20)),
            child: const Row(
              children: [
                Icon(Icons.headset_mic_outlined, color: _ambar, size: 14),
                SizedBox(width: 4),
                Text('Call Center',
                    style: TextStyle(
                        color: _ambar, fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: _ambarLight,
              child: Text(
                widget.sesion.nombre.isNotEmpty
                    ? widget.sesion.nombre[0].toUpperCase()
                    : 'C',
                style: const TextStyle(
                    color: _ambar, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
          IconButton(
              icon: const Icon(Icons.logout_outlined, size: 20),
              onPressed: _cerrarSesion),
        ],
      ),
      body: IndexedStack(
        index: _tab,
        children: [
          _TabLlamadas(onLlamar: _abrirLlamada),
          _TabHistorial(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        backgroundColor: Colors.white,
        indicatorColor: _ambarLight,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.phone_outlined),
            selectedIcon: Icon(Icons.phone, color: _ambar),
            label: 'Llamadas',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history, color: _ambar),
            label: 'Historial',
          ),
        ],
      ),
    );
  }
}

// ─── TAB 0: LISTA DE LLAMADAS PENDIENTES ─────────────────────────────────────
class _TabLlamadas extends StatelessWidget {
  final void Function(Map<String, dynamic>) onLlamar;
  const _TabLlamadas({required this.onLlamar});

  static const _pacientes = [
    {'nombre': 'Rosa Torres Vega',  'iniciales': 'RT', 'dx': 'HTA + diabetes', 'dispositivo': '#03', 'prioridad': 'alta',   'motivo': 'Slot vacío — sin medicamento'},
    {'nombre': 'Carlos Medina',     'iniciales': 'CM', 'dx': 'Hipertensión', 'dispositivo': '#12', 'prioridad': 'alta',   'motivo': 'No confirmó presencia (08:00)'},
    {'nombre': 'Jorge Castillo',    'iniciales': 'JC', 'dx': 'Osteoporosis', 'dispositivo': '#14', 'prioridad': 'alta',   'motivo': 'Dispositivo sin conexión'},
    {'nombre': 'Luis Pérez Ríos',   'iniciales': 'LP', 'dx': 'Diabetes tipo 2', 'dispositivo': '#07', 'prioridad': 'media',  'motivo': 'Stock bajo en Slot 2 (8%)'},
    {'nombre': 'María Gutiérrez',   'iniciales': 'MG', 'dx': 'Fibrilación auricular', 'dispositivo': '#19', 'prioridad': 'media',  'motivo': 'Consulta de seguimiento'},
    {'nombre': 'Ana Soria',         'iniciales': 'AS', 'dx': 'Parkinson', 'dispositivo': '#22', 'prioridad': 'normal', 'motivo': 'Control mensual programado'},
  ];

  Color _colorPrioridad(String p) => switch (p) {
        'alta'   => const Color(0xFFA32D2D),
        'media'  => const Color(0xFFBA7517),
        _        => const Color(0xFF2D7A4F),
      };

  Color _bgPrioridad(String p) => switch (p) {
        'alta'   => const Color(0xFFFCEBEB),
        'media'  => const Color(0xFFFAEEDA),
        _        => const Color(0xFFE8F5EE),
      };

  String _labelPrioridad(String p) => switch (p) {
        'alta'  => '⬆ Alta',
        'media' => '→ Media',
        _       => '✓ Normal',
      };

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Métricas rápidas ──────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              _MiniMetric(label: 'Prioridad alta', value: '3', color: const Color(0xFFA32D2D), bg: const Color(0xFFFCEBEB)),
              const SizedBox(width: 10),
              _MiniMetric(label: 'Prioridad media', value: '2', color: const Color(0xFFBA7517), bg: const Color(0xFFFAEEDA)),
              const SizedBox(width: 10),
              _MiniMetric(label: 'Llamadas hoy', value: '12', color: const Color(0xFF2D7A4F), bg: const Color(0xFFE8F5EE)),
            ],
          ),
        ),

        // ── Lista de pacientes ────────────────────────────────────────────
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _pacientes.length,
            itemBuilder: (context, i) {
              final p = _pacientes[i];
              final prioridad = p['prioridad'] as String;
              final color = _colorPrioridad(prioridad);
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: prioridad == 'alta'
                      ? BorderSide(color: color.withOpacity(0.4))
                      : BorderSide.none,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: const Color(0xFFFAEEDA),
                        child: Text(p['iniciales']!,
                            style: const TextStyle(
                                color: Color(0xFFBA7517),
                                fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 12),
                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p['nombre']!,
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 2),
                            Text('Disp. ${p['dispositivo']} · ${p['dx']}',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[600])),
                            const SizedBox(height: 4),
                            Text(p['motivo']!,
                                style: TextStyle(
                                    fontSize: 12, color: color, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Prioridad + botón
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _bgPrioridad(prioridad),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(_labelPrioridad(prioridad),
                                style: TextStyle(
                                    color: color,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(height: 6),
                          ElevatedButton.icon(
                            onPressed: () => onLlamar(p),
                            icon: const Icon(Icons.phone, size: 14),
                            label: const Text('Llamar', style: TextStyle(fontSize: 12)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFBA7517),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              minimumSize: const Size(0, 32),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─── TAB 1: HISTORIAL ─────────────────────────────────────────────────────────
class _TabHistorial extends StatelessWidget {
  final _historial = const [
    {'paciente': 'Carlos Medina',   'hora': '08:45', 'duracion': '4m 12s', 'motivo': 'No confirmó dosis',    'resultado': 'Resuelto'},
    {'paciente': 'Rosa Torres',     'hora': '09:10', 'duracion': '2m 55s', 'motivo': 'Stock vacío',          'resultado': 'Derivado'},
    {'paciente': 'Luis Pérez',      'hora': '10:30', 'duracion': '1m 08s', 'motivo': 'Consulta general',     'resultado': 'Resuelto'},
    {'paciente': 'María Gutiérrez', 'hora': '11:00', 'duracion': '6m 40s', 'motivo': 'Reacción adversa',    'resultado': 'Escalado'},
    {'paciente': 'Ana Soria',       'hora': '12:15', 'duracion': '3m 22s', 'motivo': 'Control mensual',      'resultado': 'Resuelto'},
  ];

  Color _colorResultado(String r) => switch (r) {
        'Resuelto' => const Color(0xFF2D7A4F),
        'Derivado' => const Color(0xFFBA7517),
        _          => const Color(0xFFA32D2D),
      };

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Historial de llamadas de hoy',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ..._historial.map((h) {
          final color = _colorResultado(h['resultado']!);
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(h['hora']!,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(h['duracion']!,
                      style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                ],
              ),
              title: Text(h['paciente']!),
              subtitle: Text(h['motivo']!, style: const TextStyle(fontSize: 12)),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(h['resultado']!,
                    style: TextStyle(
                        color: color, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ),
          );
        }),
      ],
    );
  }
}

// ─── WIDGET MINI MÉTRICA ──────────────────────────────────────────────────────
class _MiniMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final Color bg;
  const _MiniMetric({required this.label, required this.value, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            Text(label,
                style: TextStyle(fontSize: 10, color: color.withOpacity(0.8)),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// PANTALLA DE LLAMADA EN CURSO (BottomSheet)
// ══════════════════════════════════════════════════════════════════════════════

class _PantallaLlamada extends StatefulWidget {
  final Map<String, dynamic> paciente;
  const _PantallaLlamada({required this.paciente});

  @override
  State<_PantallaLlamada> createState() => _PantallaLlamadaState();
}

class _PantallaLlamadaState extends State<_PantallaLlamada> {
  bool _llamando = true;
  bool _silenciado = false;
  int _segundos = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Simula que contesta a los 2 segundos
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _llamando = false);
        _timer = Timer.periodic(const Duration(seconds: 1), (_) {
          if (mounted) setState(() => _segundos++);
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _timerStr {
    final m = (_segundos ~/ 60).toString().padLeft(2, '0');
    final s = (_segundos % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.55,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFFAEEDA),
              shape: BoxShape.circle,
              border: Border.all(
                  color: const Color(0xFFBA7517).withOpacity(0.3), width: 3),
            ),
            child: Center(
              child: Text(
                widget.paciente['iniciales'] as String,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFBA7517),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Text(widget.paciente['nombre'] as String,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            _llamando ? 'Llamando…' : _timerStr,
            style: TextStyle(
              fontSize: _llamando ? 14 : 22,
              color: _llamando ? const Color(0xFFBA7517) : const Color(0xFF2D7A4F),
              fontWeight: _llamando ? FontWeight.normal : FontWeight.bold,
              fontFamily: _llamando ? null : 'monospace',
            ),
          ),
          if (!_llamando)
            const Text('En llamada',
                style: TextStyle(fontSize: 12, color: Color(0xFF2D7A4F))),

          const SizedBox(height: 32),

          // Motivo de la llamada
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFAEEDA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline,
                    color: Color(0xFFBA7517), size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(widget.paciente['motivo'] as String,
                      style: const TextStyle(
                          color: Color(0xFFBA7517), fontSize: 13)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Botones de acción
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Silenciar
              _BotonLlamada(
                icono: _silenciado ? Icons.mic_off : Icons.mic,
                color: Colors.grey[700]!,
                bg: Colors.grey[100]!,
                onTap: () => setState(() => _silenciado = !_silenciado),
                label: _silenciado ? 'Activo' : 'Silenciar',
              ),
              const SizedBox(width: 24),
              // Colgar
              _BotonLlamada(
                icono: Icons.call_end,
                color: Colors.white,
                bg: const Color(0xFFA32D2D),
                onTap: () => Navigator.pop(context),
                label: 'Colgar',
                grande: true,
              ),
              const SizedBox(width: 24),
              // Notas
              _BotonLlamada(
                icono: Icons.note_add_outlined,
                color: Colors.grey[700]!,
                bg: Colors.grey[100]!,
                onTap: () {},
                label: 'Notas',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BotonLlamada extends StatelessWidget {
  final IconData icono;
  final Color color;
  final Color bg;
  final VoidCallback onTap;
  final String label;
  final bool grande;

  const _BotonLlamada({
    required this.icono,
    required this.color,
    required this.bg,
    required this.onTap,
    required this.label,
    this.grande = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = grande ? 64.0 : 52.0;
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            child: Icon(icono, color: color, size: grande ? 28 : 22),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
      ],
    );
  }
}