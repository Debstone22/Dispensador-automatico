import 'package:flutter/material.dart';
import '../../auth_service.dart';
import '../../login.dart';

// ══════════════════════════════════════════════════════════════════════════════
// DASHBOARD ADMINISTRADOR
// Todas las funciones disponibles: usuarios, dispositivos, horarios, alertas
// ══════════════════════════════════════════════════════════════════════════════

class DashboardAdmin extends StatefulWidget {
  final SesionUsuario sesion;
  const DashboardAdmin({super.key, required this.sesion});

  @override
  State<DashboardAdmin> createState() => _DashboardAdminState();
}

class _DashboardAdminState extends State<DashboardAdmin> {
  int _tab = 0;
  final _auth = AuthService();

  static const _verde = Color(0xFF2D7A4F);
  static const _verdeLight = Color(0xFFE8F5EE);

  Future<void> _cerrarSesion() async {
    await _auth.cerrarSesion();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const PantallaLogin()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _verde,
                borderRadius: BorderRadius.circular(8),
              ),
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
              color: _verdeLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.shield_outlined, color: _verde, size: 14),
                const SizedBox(width: 4),
                const Text('Administrador',
                    style: TextStyle(color: _verde, fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(width: 4),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: _verdeLight,
              child: Text(
                widget.sesion.nombre.isNotEmpty
                    ? widget.sesion.nombre[0].toUpperCase()
                    : 'A',
                style: const TextStyle(color: _verde, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined, size: 20),
            onPressed: _cerrarSesion,
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: IndexedStack(
        index: _tab,
        children: [
          _TabResumen(sesion: widget.sesion),
          _TabUsuarios(),
          _TabDispositivos(),
          _TabHorarios(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        backgroundColor: Colors.white,
        indicatorColor: _verdeLight,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard, color: _verde),
            label: 'Resumen',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people, color: _verde),
            label: 'Usuarios',
          ),
          NavigationDestination(
            icon: Icon(Icons.device_hub_outlined),
            selectedIcon: Icon(Icons.device_hub, color: _verde),
            label: 'Dispositivos',
          ),
          NavigationDestination(
            icon: Icon(Icons.schedule_outlined),
            selectedIcon: Icon(Icons.schedule, color: _verde),
            label: 'Horarios',
          ),
        ],
      ),
    );
  }
}

// ─── TAB 0: RESUMEN ───────────────────────────────────────────────────────────
class _TabResumen extends StatelessWidget {
  final SesionUsuario sesion;
  const _TabResumen({required this.sesion});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Hola, ${sesion.nombre.split(' ').first} 👋',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const Text('Panel general · hoy', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 16),

        // ── Métricas ──────────────────────────────────────────────────────
        GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.6,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            _MetricCard(label: 'Pacientes', value: '48', icon: Icons.person, color: Color(0xFF185FA5)),
            _MetricCard(label: 'Dispositivos activos', value: '31 / 35', icon: Icons.device_hub, color: Color(0xFF2D7A4F)),
            _MetricCard(label: 'Dosis dispensadas hoy', value: '127', icon: Icons.medication_liquid, color: Color(0xFFBA7517)),
            _MetricCard(label: 'Alertas pendientes', value: '4', icon: Icons.warning_amber, color: Color(0xFFA32D2D)),
          ],
        ),

        const SizedBox(height: 20),

        // ── Alertas activas ────────────────────────────────────────────────
        const _SeccionTitulo('Alertas activas'),
        const SizedBox(height: 8),
        _AlertaItem(
          tipo: 'critico',
          texto: 'Slot 2 de Luis P. — stock bajo (8%)',
          icono: Icons.medication_outlined,
        ),
        _AlertaItem(
          tipo: 'advertencia',
          texto: 'Carlos M. no confirmó presencia (08:00)',
          icono: Icons.notifications_off_outlined,
        ),
        _AlertaItem(
          tipo: 'advertencia',
          texto: 'Dispositivo #14 sin conexión a internet',
          icono: Icons.wifi_off_outlined,
        ),
        _AlertaItem(
          tipo: 'critico',
          texto: 'Slot 1 de Rosa T. — compartimento vacío',
          icono: Icons.error_outline,
        ),
      ],
    );
  }
}

// ─── TAB 1: USUARIOS ──────────────────────────────────────────────────────────
class _TabUsuarios extends StatelessWidget {
  final List<Map<String, dynamic>> _pacientes = const [
    {'nombre': 'Luis Pérez Ríos', 'dispositivo': '#07', 'adherencia': 94, 'estado': 'activo'},
    {'nombre': 'Carlos Medina',   'dispositivo': '#12', 'adherencia': 71, 'estado': 'alerta'},
    {'nombre': 'Rosa Torres Vega','dispositivo': '#03', 'adherencia': 43, 'estado': 'critico'},
    {'nombre': 'María Gutiérrez', 'dispositivo': '#19', 'adherencia': 88, 'estado': 'activo'},
    {'nombre': 'Jorge Castillo',  'dispositivo': null,  'adherencia': null, 'estado': 'sin dispositivo'},
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _SeccionTitulo('Gestión de usuarios'),
        const SizedBox(height: 12),
        ..._pacientes.map((p) => _PacienteCard(datos: p)),
      ],
    );
  }
}

// ─── TAB 2: DISPOSITIVOS ──────────────────────────────────────────────────────
class _TabDispositivos extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _SeccionTitulo('Dispositivos y slots'),
        const SizedBox(height: 12),
        _DispositivoCard(
          id: '#07',
          paciente: 'Luis Pérez',
          conectado: true,
          bateria: 88,
          slots: const [
            {'nombre': 'Metformina', 'pct': 62},
            {'nombre': 'Enalapril', 'pct': 8},
            {'nombre': 'Losartán', 'pct': 78},
            {'nombre': 'Aspirina', 'pct': 45},
          ],
        ),
        const SizedBox(height: 12),
        _DispositivoCard(
          id: '#12',
          paciente: 'Carlos Medina',
          conectado: true,
          bateria: 55,
          slots: const [
            {'nombre': 'Enalapril', 'pct': 55},
            {'nombre': 'Amlodipino', 'pct': 22},
            {'nombre': 'Atorvastatina', 'pct': 3},
            {'nombre': '—', 'pct': 0},
          ],
        ),
      ],
    );
  }
}

// ─── TAB 3: HORARIOS ──────────────────────────────────────────────────────────
class _TabHorarios extends StatefulWidget {
  @override
  State<_TabHorarios> createState() => _TabHorariosState();
}

class _TabHorariosState extends State<_TabHorarios> {
  final List<Map<String, dynamic>> _horarios = [
    {'hora': '07:00', 'medicamento': 'Metformina 850mg', 'slot': 'Slot 1', 'paciente': 'Luis Pérez', 'activo': true},
    {'hora': '08:00', 'medicamento': 'Enalapril 10mg', 'slot': 'Slot 2', 'paciente': 'Carlos Medina', 'activo': true},
    {'hora': '12:00', 'medicamento': 'Atorvastatina 20mg', 'slot': 'Slot 3', 'paciente': 'Rosa Torres', 'activo': false},
    {'hora': '14:00', 'medicamento': 'Metformina 850mg', 'slot': 'Slot 1', 'paciente': 'Luis Pérez', 'activo': true},
    {'hora': '20:00', 'medicamento': 'Losartán 50mg', 'slot': 'Slot 4', 'paciente': 'María Gutiérrez', 'activo': true},
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _SeccionTitulo('Horarios de dispensación'),
        const SizedBox(height: 12),
        ..._horarios.asMap().entries.map((e) {
          final h = e.value;
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Text(h['hora'],
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D7A4F),
                      fontSize: 16)),
              title: Text(h['medicamento']),
              subtitle: Text('${h['slot']} · ${h['paciente']}',
                  style: const TextStyle(fontSize: 12)),
              trailing: Switch(
                value: h['activo'],
                activeColor: const Color(0xFF2D7A4F),
                onChanged: (val) => setState(() => _horarios[e.key]['activo'] = val),
              ),
            ),
          );
        }),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// WIDGETS COMPARTIDOS
// ══════════════════════════════════════════════════════════════════════════════

class _SeccionTitulo extends StatelessWidget {
  final String texto;
  const _SeccionTitulo(this.texto);
  @override
  Widget build(BuildContext context) => Text(texto,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold));
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _MetricCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const Spacer(),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: TextStyle(fontSize: 11, color: color.withOpacity(0.8))),
        ],
      ),
    );
  }
}

class _AlertaItem extends StatelessWidget {
  final String tipo;
  final String texto;
  final IconData icono;
  const _AlertaItem({required this.tipo, required this.texto, required this.icono});

  @override
  Widget build(BuildContext context) {
    final esCritico = tipo == 'critico';
    final color = esCritico ? const Color(0xFFA32D2D) : const Color(0xFFBA7517);
    final bg = esCritico ? const Color(0xFFFCEBEB) : const Color(0xFFFAEEDA);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icono, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(texto, style: TextStyle(color: color, fontSize: 13))),
        ],
      ),
    );
  }
}

class _PacienteCard extends StatelessWidget {
  final Map<String, dynamic> datos;
  const _PacienteCard({required this.datos});

  Color get _color {
    return switch (datos['estado'] as String) {
      'activo'          => const Color(0xFF2D7A4F),
      'alerta'          => const Color(0xFFBA7517),
      'critico'         => const Color(0xFFA32D2D),
      _                 => Colors.grey,
    };
  }

  @override
  Widget build(BuildContext context) {
    final adherencia = datos['adherencia'] as int?;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _color.withOpacity(0.15),
          child: Text(
            (datos['nombre'] as String).substring(0, 2).toUpperCase(),
            style: TextStyle(color: _color, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(datos['nombre']),
        subtitle: Text(datos['dispositivo'] != null
            ? 'Dispositivo ${datos['dispositivo']}'
            : 'Sin dispositivo asignado'),
        trailing: adherencia != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('$adherencia%',
                      style: TextStyle(
                          color: _color,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                  Text('adherencia',
                      style: TextStyle(color: Colors.grey[500], fontSize: 10)),
                ],
              )
            : const Icon(Icons.device_unknown_outlined, color: Colors.grey),
      ),
    );
  }
}

class _DispositivoCard extends StatelessWidget {
  final String id;
  final String paciente;
  final bool conectado;
  final int bateria;
  final List<Map<String, dynamic>> slots;

  const _DispositivoCard({
    required this.id,
    required this.paciente,
    required this.conectado,
    required this.bateria,
    required this.slots,
  });

  Color _slotColor(int pct) {
    if (pct > 50) return const Color(0xFF2D7A4F);
    if (pct > 20) return const Color(0xFFBA7517);
    return const Color(0xFFA32D2D);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.device_hub, size: 18),
                const SizedBox(width: 6),
                Text('Dispositivo $id · $paciente',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                Icon(Icons.circle,
                    size: 10,
                    color: conectado ? const Color(0xFF2D7A4F) : Colors.grey),
                const SizedBox(width: 4),
                Text(conectado ? 'Conectado' : 'Offline',
                    style: TextStyle(
                        fontSize: 12,
                        color: conectado ? const Color(0xFF2D7A4F) : Colors.grey)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: slots.asMap().entries.map((e) {
                final s = e.value;
                final pct = s['pct'] as int;
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(left: e.key == 0 ? 0 : 6),
                    child: Column(
                      children: [
                        Text('Slot ${e.key + 1}',
                            style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                        const SizedBox(height: 4),
                        Container(
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          alignment: Alignment.bottomCenter,
                          child: FractionallySizedBox(
                            heightFactor: pct / 100,
                            child: Container(
                              decoration: BoxDecoration(
                                color: _slotColor(pct),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text('$pct%',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: _slotColor(pct))),
                        Text(s['nombre'],
                            style: TextStyle(fontSize: 9, color: Colors.grey[500]),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}