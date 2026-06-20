import 'package:flutter/material.dart';
import '../auth_service.dart';
import '../login.dart';



class DashboardMonitor extends StatefulWidget {
  final SesionUsuario sesion;
  const DashboardMonitor({super.key, required this.sesion});

  @override
  State<DashboardMonitor> createState() => _DashboardMonitorState();
}

class _DashboardMonitorState extends State<DashboardMonitor> {
  int _tab = 0;
  final _auth = AuthService();

  static const _azul = Color(0xFF185FA5);
  static const _azulLight = Color(0xFFE6F1FB);

  Future<void> _cerrarSesion() async {
    await _auth.cerrarSesion();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const PantallaLogin()),
          (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                  color: _azul, borderRadius: BorderRadius.circular(8)),
              child:
                  const Icon(Icons.medication, color: Colors.white, size: 18),
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
                color: _azulLight, borderRadius: BorderRadius.circular(20)),
            child: const Row(
              children: [
                Icon(Icons.monitor_heart_outlined, color: _azul, size: 14),
                SizedBox(width: 4),
                Text('Monitor',
                    style: TextStyle(
                        color: _azul,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: _azulLight,
              child: Text(
                widget.sesion.nombre.isNotEmpty
                    ? widget.sesion.nombre[0].toUpperCase()
                    : 'M',
                style: const TextStyle(
                    color: _azul, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined, size: 20),
            onPressed: _cerrarSesion,
          ),
        ],
      ),
      body: IndexedStack(
        index: _tab,
        children: [_TabPacientes(), _TabConsumo()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        backgroundColor: Colors.white,
        indicatorColor: _azulLight,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people, color: _azul),
            label: 'Pacientes',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart, color: _azul),
            label: 'Consumo',
          ),
        ],
      ),
    );
  }
}

class _TabPacientes extends StatefulWidget {
  @override
  State<_TabPacientes> createState() => _TabPacientesState();
}

class _TabPacientesState extends State<_TabPacientes> {
  String _filtroEstado = 'todos';
  String _busqueda = '';

  final List<Map<String, dynamic>> _pacientes = const [
    {
      'nombre': 'Luis Pérez Ríos',
      'edad': 72,
      'dx': 'Diabetes tipo 2',
      'adherencia': 94,
      'estado': 'activo',
      'dispositivo': '#07'
    },
    {
      'nombre': 'Carlos Medina',
      'edad': 68,
      'dx': 'Hipertensión arterial',
      'adherencia': 71,
      'estado': 'alerta',
      'dispositivo': '#12'
    },
    {
      'nombre': 'Rosa Torres Vega',
      'edad': 80,
      'dx': 'HTA + diabetes',
      'adherencia': 43,
      'estado': 'critico',
      'dispositivo': '#03'
    },
    {
      'nombre': 'María Gutiérrez',
      'edad': 75,
      'dx': 'Fibrilación auricular',
      'adherencia': 88,
      'estado': 'activo',
      'dispositivo': '#19'
    },
    {
      'nombre': 'Jorge Castillo',
      'edad': 70,
      'dx': 'Osteoporosis',
      'adherencia': null,
      'estado': 'sin dispositivo',
      'dispositivo': null
    },
  ];

  List<Map<String, dynamic>> get _filtrados {
    return _pacientes.where((p) {
      final coincideBusqueda = p['nombre']
              .toString()
              .toLowerCase()
              .contains(_busqueda.toLowerCase()) ||
          p['dx'].toString().toLowerCase().contains(_busqueda.toLowerCase());
      final coincideEstado =
          _filtroEstado == 'todos' || p['estado'] == _filtroEstado;
      return coincideBusqueda && coincideEstado;
    }).toList();
  }

  Color _colorEstado(String estado) => switch (estado) {
        'activo' => const Color(0xFF2D7A4F),
        'alerta' => const Color(0xFFBA7517),
        'critico' => const Color(0xFFA32D2D),
        _ => Colors.grey,
      };

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            onChanged: (v) => setState(() => _busqueda = v),
            decoration: InputDecoration(
              hintText: 'Buscar por nombre o diagnóstico…',
              prefixIcon: const Icon(Icons.search),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),

        SizedBox(
          height: 38,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: ['todos', 'activo', 'alerta', 'critico']
                .map((estado) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label:
                            Text(estado[0].toUpperCase() + estado.substring(1)),
                        selected: _filtroEstado == estado,
                        onSelected: (_) =>
                            setState(() => _filtroEstado = estado),
                        selectedColor: const Color(0xFFE6F1FB),
                        labelStyle: TextStyle(
                          color: _filtroEstado == estado
                              ? const Color(0xFF185FA5)
                              : Colors.grey[700],
                          fontWeight: _filtroEstado == estado
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),

        const SizedBox(height: 8),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _filtrados.length,
            itemBuilder: (context, i) {
              final p = _filtrados[i];
              final estado = p['estado'] as String;
              final color = _colorEstado(estado);
              final adherencia = p['adherencia'] as int?;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: color.withValues(alpha: 0.12),
                    child: Text(
                      (p['nombre'] as String).substring(0, 2).toUpperCase(),
                      style:
                          TextStyle(color: color, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Row(
                    children: [
                      Expanded(child: Text(p['nombre'])),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          estado[0].toUpperCase() + estado.substring(1),
                          style: TextStyle(
                              color: color,
                              fontSize: 11,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('${p['edad']} años · ${p['dx']}',
                          style: const TextStyle(fontSize: 12)),
                      if (adherencia != null) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: adherencia / 100,
                                  backgroundColor: Colors.grey[200],
                                  color: color,
                                  minHeight: 5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text('$adherencia%',
                                style: TextStyle(
                                    color: color,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12)),
                          ],
                        ),
                      ],
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

class _TabConsumo extends StatelessWidget {
  final List<Map<String, dynamic>> _pastillas = const [
    {'nombre': 'Metformina', 'dosis': 312},
    {'nombre': 'Enalapril', 'dosis': 287},
    {'nombre': 'Losartán', 'dosis': 245},
    {'nombre': 'Atorvastatina', 'dosis': 198},
    {'nombre': 'Amlodipino', 'dosis': 176},
    {'nombre': 'Aspirina', 'dosis': 142},
  ];

  @override
  Widget build(BuildContext context) {
    final maxDosis = _pastillas
        .map((p) => p['dosis'] as int)
        .reduce((a, b) => a > b ? a : b);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Análisis de consumo',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const Text('Pastillas más dispensadas · último mes',
            style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 16),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Por medicamento',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                ..._pastillas.map((p) {
                  final pct = (p['dosis'] as int) / maxDosis;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 100,
                          child: Text(p['nombre'],
                              style: const TextStyle(fontSize: 12),
                              overflow: TextOverflow.ellipsis),
                        ),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: pct,
                              backgroundColor: Colors.grey[200],
                              color: const Color(0xFF185FA5),
                              minHeight: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('${p['dosis']}',
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF185FA5))),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        const Text('Alertas de stock',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const _StockAlerta(
            paciente: 'Rosa T.',
            slot: 'Slot 1',
            pct: 0,
            color: Color(0xFFA32D2D),
            bg: Color(0xFFFCEBEB)),
        const _StockAlerta(
            paciente: 'Luis P.',
            slot: 'Slot 2',
            pct: 8,
            color: Color(0xFFA32D2D),
            bg: Color(0xFFFCEBEB)),
        const _StockAlerta(
            paciente: 'Carlos M.',
            slot: 'Slot 3',
            pct: 22,
            color: Color(0xFFBA7517),
            bg: Color(0xFFFAEEDA)),
      ],
    );
  }
}

class _StockAlerta extends StatelessWidget {
  final String paciente;
  final String slot;
  final int pct;
  final Color color;
  final Color bg;
  const _StockAlerta(
      {required this.paciente,
      required this.slot,
      required this.pct,
      required this.color,
      required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: color, size: 18),
          const SizedBox(width: 10),
          Text('$paciente — $slot', style: TextStyle(color: color)),
          const Spacer(),
          Text('$pct%',
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}
