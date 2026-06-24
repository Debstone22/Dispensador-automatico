import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PantallaDatosUsuario extends StatefulWidget {
  final String pacienteId;
  final String nombreUsuario;
  final String correoUsuario;
  final String sexoUsuario;
  final String rolUsuario;
  final String usuarioId;

  const PantallaDatosUsuario({
    super.key,
    required this.pacienteId,
    required this.nombreUsuario,
    required this.correoUsuario,
    required this.sexoUsuario,
    required this.rolUsuario,
    required this.usuarioId,
  });

  @override
  State<PantallaDatosUsuario> createState() => _PantallaDatosUsuarioState();
}

class _PantallaDatosUsuarioState extends State<PantallaDatosUsuario> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _mostrarTodosLosPacientes = false;

  final _nombreUserCtrl = TextEditingController();
  final _apellidoUserCtrl = TextEditingController();
  final _telefonoUserCtrl = TextEditingController();
  final _edadUserCtrl = TextEditingController();

  final _nombreEditCtrl = TextEditingController();
  final _apellidoEditCtrl = TextEditingController();
  final _telefonoEditCtrl = TextEditingController();
  final _edadEditCtrl = TextEditingController();


  final _nombreNuevoCtrl = TextEditingController();
  final _apellidoNuevoCtrl = TextEditingController();
  final _telefonoNuevoCtrl = TextEditingController();
  final _edadNuevoCtrl = TextEditingController();
  final _alergiaNuevoCtrl = TextEditingController();
  final _sangreNuevoCtrl = TextEditingController();

  @override
  void dispose() {
    _nombreUserCtrl.dispose();
    _apellidoUserCtrl.dispose();
    _telefonoUserCtrl.dispose();
    _edadUserCtrl.dispose();
    _nombreEditCtrl.dispose();
    _apellidoEditCtrl.dispose();
    _telefonoEditCtrl.dispose();
    _edadEditCtrl.dispose();
    _nombreNuevoCtrl.dispose();
    _apellidoNuevoCtrl.dispose();
    _telefonoNuevoCtrl.dispose();
    _edadNuevoCtrl.dispose();
    _alergiaNuevoCtrl.dispose();
    _sangreNuevoCtrl.dispose();
    super.dispose();
  }

  void _mostrarDialogoEditarCuenta() {
    _nombreUserCtrl.text = widget.nombreUsuario;
    _apellidoUserCtrl.text = '';
    _telefonoUserCtrl.text = '';
    _edadUserCtrl.text = '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Datos de Cuenta'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nombreUserCtrl,
                decoration: const InputDecoration(
                    labelText: 'Nombre', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _apellidoUserCtrl,
                decoration: const InputDecoration(
                    labelText: 'Apellido', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: TextEditingController(text: widget.correoUsuario),
                decoration: const InputDecoration(
                  labelText: 'Correo Electrónico',
                  helperText: 'Este campo no se puede modificar',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                enabled: false,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _telefonoUserCtrl,
                decoration: const InputDecoration(
                    labelText: 'Teléfono', border: OutlineInputBorder()),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _edadUserCtrl,
                decoration: const InputDecoration(
                    labelText: 'Edad', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content:
                        Text('Datos de cuenta actualizados correctamente')),
              );
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D7A4F)),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoEditarPaciente(
      Map<String, dynamic> datos, String idValido) {
    _nombreEditCtrl.text = datos['nombre_paciente'] ?? '';
    _apellidoEditCtrl.text = datos['apellido_paciente'] ?? '';
    _telefonoEditCtrl.text =
        datos['num_telefono_paciente'] ?? datos['num_telefono'] ?? '';
    _edadEditCtrl.text =
        (datos['edad_paciente'] ?? datos['edad'] ?? '').toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Datos del Paciente'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nombreEditCtrl,
                decoration: const InputDecoration(
                    labelText: 'Nombre', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _apellidoEditCtrl,
                decoration: const InputDecoration(
                    labelText: 'Apellido', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _telefonoEditCtrl,
                decoration: const InputDecoration(
                    labelText: 'Teléfono', border: OutlineInputBorder()),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _edadEditCtrl,
                decoration: const InputDecoration(
                    labelText: 'Edad', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _firestore.collection('pacientes').doc(idValido).update({
                'nombre_paciente': _nombreEditCtrl.text.trim(),
                'apellido_paciente': _apellidoEditCtrl.text.trim(),
                'num_telefono_paciente': _telefonoEditCtrl.text.trim(),
                'edad_paciente': int.tryParse(_edadEditCtrl.text.trim()) ?? 0,
              });
              if (mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D7A4F)),
            child: const Text('Guardar Cambios'),
          ),
        ],
      ),
    );
  }

  void _confirmarEliminarPaciente(String idValido, String nombre) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar Paciente?'),
        content: Text(
            '¿Estás seguro de que deseas eliminar permanentemente a $nombre de tu tutela?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _firestore.collection('pacientes').doc(idValido).delete();
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Paciente eliminado con éxito.')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al eliminar: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child:
                const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoAnadir() {
    _nombreNuevoCtrl.clear();
    _apellidoNuevoCtrl.clear();
    _telefonoNuevoCtrl.clear();
    _edadNuevoCtrl.clear();
    _alergiaNuevoCtrl.clear();
    _sangreNuevoCtrl.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Añadir Nuevo Paciente'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nombreNuevoCtrl,
                decoration: const InputDecoration(
                    labelText: 'Nombre', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _apellidoNuevoCtrl,
                decoration: const InputDecoration(
                    labelText: 'Apellido', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _telefonoNuevoCtrl,
                decoration: const InputDecoration(
                    labelText: 'Teléfono', border: OutlineInputBorder()),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _edadNuevoCtrl,
                decoration: const InputDecoration(
                    labelText: 'Edad', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _alergiaNuevoCtrl,
                decoration: const InputDecoration(
                    labelText: 'Alergias', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _sangreNuevoCtrl,
                decoration: const InputDecoration(
                    labelText: 'Tipo de Sangre', border: OutlineInputBorder()),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _firestore.collection('pacientes').add({
                'nombre_paciente': _nombreNuevoCtrl.text.trim(),
                'apellido_paciente': _apellidoNuevoCtrl.text.trim(),
                'num_telefono_paciente': _telefonoNuevoCtrl.text.trim(),
                'edad_paciente': int.tryParse(_edadNuevoCtrl.text.trim()) ?? 0,
                'alergia_paciente': _alergiaNuevoCtrl.text.trim(),
                'tipo_sangre': _sangreNuevoCtrl.text.trim(),
                'descripcion_paciente': 'Registrado por familiar',
                'correo_familiar': widget.correoUsuario.trim(),
              });
              if (mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D7A4F)),
            child: const Text('Registrar Paciente'),
          ),
        ],
      ),
    );
  }

  Widget _buildPerfilItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF2D7A4F), size: 24),
          const SizedBox(width: 14),
          Expanded(
            // Previene desbordamiento si el texto es muy extenso
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 1),
                Text(value,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTarjetaPaciente(
      Map<String, dynamic> datosPaciente, String idDocumentoReal) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${datosPaciente['nombre_paciente'] ?? ''} ${datosPaciente['apellido_paciente'] ?? ''}'
                        .toUpperCase(),
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D7A4F)),
                  ),
                ),
                if (widget.rolUsuario.trim().toLowerCase() == 'familiar')
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit,
                            color: Colors.blue, size: 20),
                        onPressed: () => _mostrarDialogoEditarPaciente(
                            datosPaciente, idDocumentoReal),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_forever,
                            color: Colors.red, size: 20),
                        onPressed: () => _confirmarEliminarPaciente(
                            idDocumentoReal,
                            datosPaciente['nombre_paciente'] ??
                                'este paciente'),
                      ),
                    ],
                  ),
              ],
            ),
            const Divider(),
            _buildPerfilItem(
                Icons.phone_android,
                'Teléfono de contacto',
                datosPaciente['num_telefono_paciente'] ??
                    datosPaciente['num_telefono'] ??
                    'No registrado'),
            _buildPerfilItem(Icons.bloodtype_outlined, 'Grupo Sanguíneo',
                datosPaciente['tipo_sangre'] ?? 'No especificado'),
            _buildPerfilItem(Icons.cake_outlined, 'Edad del Paciente',
                '${datosPaciente['edad_paciente'] ?? datosPaciente['edad'] ?? '—'} años'),
            if (datosPaciente['alergia_paciente'] != null &&
                datosPaciente['alergia_paciente'].toString().isNotEmpty)
              _buildPerfilItem(Icons.warning_amber_rounded,
                  'Alergias registradas', datosPaciente['alergia_paciente']),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: const Color(0xFF2D7A4F),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: const Color(0xFF2D7A4F),
              padding: const EdgeInsets.only(bottom: 24, top: 8),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.white,
                    child:
                        Icon(Icons.person, size: 55, color: Color(0xFF2D7A4F)),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.nombreUsuario,
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.rolUsuario.toUpperCase(),
                    style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        letterSpacing: 1.2),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Expanded(
                                child: Text('Datos de Cuenta',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2D7A4F))),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit,
                                    color: Color(0xFF2D7A4F), size: 20),
                                onPressed: _mostrarDialogoEditarCuenta,
                              ),
                            ],
                          ),
                          const Divider(height: 4),
                          _buildPerfilItem(Icons.email_outlined, 'Correo',
                              widget.correoUsuario),
                          _buildPerfilItem(
                              Icons.wc_outlined, 'Sexo', widget.sexoUsuario),
                          _buildPerfilItem(Icons.badge_outlined, 'Rol asignado',
                              widget.rolUsuario),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                          child: Text(
                            'Pacientes a mi cargo',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _mostrarTodosLosPacientes =
                                !_mostrarTodosLosPacientes;
                          });
                        },
                        child: Text(
                          _mostrarTodosLosPacientes ? 'Ver menos' : 'Ver todos',
                          style: const TextStyle(
                            color: Color(0xFF2D7A4F),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  StreamBuilder<QuerySnapshot>(
                    stream: _firestore.collection('pacientes').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                            child: Padding(
                                padding: EdgeInsets.all(20),
                                child: CircularProgressIndicator()));
                      }

                      List<DocumentSnapshot> listaFiltrada = [];

                      if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                        listaFiltrada = snapshot.data!.docs.where((doc) {
                          var data = doc.data() as Map<String, dynamic>;
                          return doc.id == widget.pacienteId.trim() ||
                              (data['correo_familiar'] != null &&
                                  data['correo_familiar']
                                          .toString()
                                          .trim()
                                          .toLowerCase() ==
                                      widget.correoUsuario
                                          .trim()
                                          .toLowerCase());
                        }).toList();
                      }

                      if (listaFiltrada.isEmpty) {
                        return Card(
                          color: Colors.grey[100],
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                const Text(
                                    'No tienes ningún paciente registrado bajo tu tutela.',
                                    textAlign: TextAlign.center),
                                const SizedBox(height: 12),
                                if (widget.rolUsuario.trim().toLowerCase() ==
                                    'familiar')
                                  ElevatedButton.icon(
                                    onPressed: _mostrarDialogoAnadir,
                                    icon: const Icon(Icons.add),
                                    label:
                                        const Text('Vincular/Añadir Paciente'),
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF2D7A4F),
                                        foregroundColor: Colors.white),
                                  ),
                              ],
                            ),
                          ),
                        );
                      }

                      List<DocumentSnapshot> documentosAMostrar =
                          _mostrarTodosLosPacientes
                              ? listaFiltrada
                              : [listaFiltrada.last];

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: documentosAMostrar.length,
                        itemBuilder: (context, index) {
                          var doc = documentosAMostrar[index];
                          var datos = doc.data() as Map<String, dynamic>;
                          return _buildTarjetaPaciente(datos, doc.id);
                        },
                      );
                    },
                  ),

                  if (widget.rolUsuario.trim().toLowerCase() == 'familiar') ...[
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _mostrarDialogoAnadir,
                      icon: const Icon(Icons.person_add_alt_1),
                      label: const Text('Añadir Otro Paciente'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(
                            color: Color(0xFF2D7A4F), width: 1.5),
                        foregroundColor: const Color(0xFF2D7A4F),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25)),
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 16),
                    const Center(
                      child: Text(
                        'La edición de pacientes está restringida a perfiles de tipo Familiar.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
