import 'package:flutter/material.dart';
import '../../auth_service.dart';
import '../../login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: _verde,
                borderRadius: BorderRadius.circular(6),
              ),
              child:
                  const Icon(Icons.medication, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
            const Text('MedDispenser',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ],
        ),
        actions: [
          // ETIQUETA ADMIN COMPACTA
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: _verdeLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.shield_outlined, color: _verde, size: 12),
                SizedBox(width: 4),
                Text('Admin',
                    style: TextStyle(
                        color: _verde,
                        fontSize: 11,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(width: 6),
          // AVATAR
          Center(
            child: CircleAvatar(
              radius: 14,
              backgroundColor: _verdeLight,
              child: Text(
                widget.sesion.nombre.isNotEmpty
                    ? widget.sesion.nombre[0].toUpperCase()
                    : 'A',
                style: const TextStyle(
                    color: _verde, fontWeight: FontWeight.bold, fontSize: 11),
              ),
            ),
          ),
          // BOTÓN LOGOUT
          IconButton(
            icon: const Icon(Icons.logout_outlined, size: 18),
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
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(fontSize: 11, overflow: TextOverflow.ellipsis),
          ),
        ),
        child: NavigationBar(
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

        // GRID DE MÉTRICAS
        StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance
      .collection('usuario')
      .where('rol_usuario', isEqualTo: 'paciente')
      .snapshots(),
  builder: (context, snapshot) {
    if (!snapshot.hasData) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final totalPacientes = snapshot.data!.docs.length;

    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.35,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _MetricCard(
          label: 'Pacientes',
          value: totalPacientes.toString(),
          icon: Icons.person,
          color: const Color(0xFF185FA5),
        ),
        _MetricCard(
          label: 'Dispositivos activos',
          value: '$totalPacientes / 35',
          icon: Icons.device_hub,
          color: const Color(0xFF2D7A4F),
        ),
        const _MetricCard(
          label: 'Dosis dispensadas',
          value: '127',
          icon: Icons.medication_liquid,
          color: Color(0xFFBA7517),
        ),
        const _MetricCard(
          label: 'Alertas pendientes',
          value: '4',
          icon: Icons.warning_amber,
          color: Color(0xFFA32D2D),
        ),
      ],
    );
  },
),

        const SizedBox(height: 20),

        // SECCIÓN ALERTAS ACTIVAS
        const _SeccionTitulo('Alertas activas'),
        const SizedBox(height: 8),
        const _AlertaItem(
          tipo: 'critico',
          texto: 'Slot 2 de Luis P. — stock bajo (8%)',
          icono: Icons.medication_outlined,
        ),
        const _AlertaItem(
          tipo: 'advertencia',
          texto: 'Carlos M. no confirmó presencia (08:00)',
          icono: Icons.notifications_off_outlined,
        ),
        const _AlertaItem(
          tipo: 'advertencia',
          texto: 'Dispositivo #14 sin conexión a internet',
          icono: Icons.wifi_off_outlined,
        ),
        const _AlertaItem(
          tipo: 'critico',
          texto: 'Slot 1 de Rosa T. — compartimento vacío',
          icono: Icons.error_outline,
        ),
      ],
    );
  }
}

// ─── TAB 1: USUARIOS (CONECTADO A FIREBASE) ──────────────────────────────────
class _TabUsuarios extends StatelessWidget {
  const _TabUsuarios();

  @override
  Widget build(BuildContext context) {
    // Buscamos usuarios con rol 'familiar' (o el rol que uses para los que gestionan pacientes)
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('usuario')
          .where('rol_usuario', isEqualTo: 'familiar') // Ajusta según tu base de datos
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No hay familiares registrados."));
        }

        final familiares = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: familiares.length,
          itemBuilder: (context, index) {
            final data = familiares[index].data() as Map<String, dynamic>;
            final nombre = data['nombre_usuario'] ?? 'Sin nombre';
            final email = data['correo_usuario'] ?? '';

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ExpansionTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF2D7A4F).withOpacity(0.1),
                  child: Text(
                    nombre.isNotEmpty ? nombre[0].toUpperCase() : '?',
                    style: const TextStyle(color: Color(0xFF2D7A4F), fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(nombre, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(email, style: const TextStyle(fontSize: 12)),
                children: [
                  // Aquí se cargan dinámicamente los pacientes asociados a este email
                  _ListaPacientesPorFamiliar(correoFamiliar: email),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// Sub-widget para cargar los pacientes de un familiar específico
class _ListaPacientesPorFamiliar extends StatelessWidget {
  final String correoFamiliar;
  const _ListaPacientesPorFamiliar({required this.correoFamiliar});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('pacientes')
          .where('correo_familiar', isEqualTo: correoFamiliar)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        }
        
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const ListTile(
            title: Text("Sin pacientes registrados", style: TextStyle(fontSize: 13, color: Colors.grey)),
          );
        }

        return Column(
          children: snapshot.data!.docs.map((doc) {
            final p = doc.data() as Map<String, dynamic>;
            return ListTile(
              dense: true,
              leading: const Icon(Icons.person_pin, size: 20, color: Color(0xFF2D7A4F)),
              title: Text('${p['nombre_paciente'] ?? ''} ${p['apellido_paciente'] ?? ''}'),
              subtitle: Text('Sangre: ${p['tipo_sangre'] ?? 'N/A'}'),
            );
          }).toList(),
        );
      },
    );
  }
}

// ─── TAB 2: DISPOSITIVOS (CONECTADO A PACIENTES Y PASTILLAS) ──────────────────
class _TabDispositivos extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      // 1. Obtenemos todos los pacientes
      stream: FirebaseFirestore.instance.collection('pacientes').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        
        final pacientes = snapshot.data!.docs;
        if (pacientes.isEmpty) return const Center(child: Text("No hay pacientes."));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: pacientes.length,
          itemBuilder: (context, index) {
            final pData = pacientes[index].data() as Map<String, dynamic>;
            final pacienteId = pacientes[index].id;
            final nombreCompleto = '${pData['nombre_paciente'] ?? ''} ${pData['apellido_paciente'] ?? ''}';

            // 2. Por cada paciente, buscamos sus pastillas
            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('pastillas')
                  .where('paciente_id', isEqualTo: pacienteId)
                  .snapshots(),
              builder: (context, pillsSnapshot) {
                // Preparamos los datos de slots/medicamentos
                List<Map<String, dynamic>> slots = [];
                if (pillsSnapshot.hasData) {
                  slots = pillsSnapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return {
                      'nombre': data['nombre_pastilla'] ?? '?',
                      'pct': (data['cantidad_restante'] ?? 0) * 10, // Ejemplo: convertimos cantidad a % (ajusta a tu lógica)
                    };
                  }).toList();
                }

                return _DispositivoCard(
                  id: '00', // Podrías agregar un campo 'dispositivo_id' en la colección pacientes
                  paciente: nombreCompleto,
                  conectado: true, 
                  bateria: 100,
                  slots: slots,
                );
              },
            );
          },
        );
      },
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
    {
      'hora': '07:00',
      'medicamento': 'Metformina 850mg',
      'slot': 'Slot 1',
      'paciente': 'Luis Pérez',
      'activo': true
    },
    {
      'hora': '08:00',
      'medicamento': 'Enalapril 10mg',
      'slot': 'Slot 2',
      'paciente': 'Carlos Medina',
      'activo': true
    },
    {
      'hora': '12:00',
      'medicamento': 'Atorvastatina 20mg',
      'slot': 'Slot 3',
      'paciente': 'Rosa Torres',
      'activo': false
    },
    {
      'hora': '14:00',
      'medicamento': 'Metformina 850mg',
      'slot': 'Slot 1',
      'paciente': 'Luis Pérez',
      'activo': true
    },
    {
      'hora': '20:00',
      'medicamento': 'Losartán 50mg',
      'slot': 'Slot 4',
      'paciente': 'María Gutiérrez',
      'activo': true
    },
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
                onChanged: (val) =>
                    setState(() => _horarios[e.key]['activo'] = val),
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
  const _MetricCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: color,
                    height: 1.1),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                    fontSize: 11, color: color.withOpacity(0.85), height: 1.1),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AlertaItem extends StatelessWidget {
  final String tipo;
  final String texto;
  final IconData icono;
  const _AlertaItem(
      {required this.tipo, required this.texto, required this.icono});

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
          Expanded(
              child: Text(texto, style: TextStyle(color: color, fontSize: 13))),
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
      'activo' => const Color(0xFF2D7A4F),
      'alerta' => const Color(0xFFBA7517),
      'critico' => const Color(0xFFA32D2D),
      _ => Colors.grey,
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
        title:
            Text(datos['nombre'], overflow: TextOverflow.ellipsis, maxLines: 1),
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
                          fontSize: 15)),
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
                Expanded(
                  child: Text(
                    'Dispositivo $id · $paciente',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.circle,
                    size: 10,
                    color: conectado ? const Color(0xFF2D7A4F) : Colors.grey),
                const SizedBox(width: 4),
                Text(conectado ? 'Conectado' : 'Offline',
                    style: TextStyle(
                        fontSize: 12,
                        color:
                            conectado ? const Color(0xFF2D7A4F) : Colors.grey)),
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
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey[500])),
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
                            style:
                                TextStyle(fontSize: 9, color: Colors.grey[500]),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
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
