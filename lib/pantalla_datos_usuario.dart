import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

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
    super.dispose();
  }

  void _mostrarDialogoAnadir() {
    _nombreNuevoCtrl.clear();
    _apellidoNuevoCtrl.clear();
    _telefonoNuevoCtrl.clear();
    _edadNuevoCtrl.clear();
    _alergiaNuevoCtrl.clear();

    String? sangreSeleccionada;
    final List<String> opcionesSangre = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Añadir Nuevo Paciente'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: _nombreNuevoCtrl, decoration: const InputDecoration(labelText: 'Nombre', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: _apellidoNuevoCtrl, decoration: const InputDecoration(labelText: 'Apellido', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(
                  controller: _telefonoNuevoCtrl,
                  decoration: const InputDecoration(labelText: 'Teléfono (9 dígitos)', border: OutlineInputBorder(), hintText: '999888777'),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(9)],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _edadNuevoCtrl,
                  decoration: const InputDecoration(labelText: 'Edad (69 - 115 años)', border: OutlineInputBorder(), hintText: 'Ej: 75'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Tipo de Sangre', border: OutlineInputBorder()),
                  items: opcionesSangre.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (val) => setDialogState(() => sangreSeleccionada = val),
                ),
                const SizedBox(height: 12),
                TextField(controller: _alergiaNuevoCtrl, decoration: const InputDecoration(labelText: 'Alergias', border: OutlineInputBorder())),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                final querySnapshot = await _firestore
                    .collection('pacientes')
                    .where('correo_familiar', isEqualTo: widget.correoUsuario.trim())
                    .get();

                if (querySnapshot.docs.length >= 4) {
                  if (context.mounted) {
                    Navigator.pop(context);
                    _mostrarAlertaSuscripcion();
                  }
                  return;
                }

                if (_telefonoNuevoCtrl.text.length != 9) {
                  _mostrarError('El teléfono debe tener exactamente 9 dígitos.');
                  return;
                }

                int edad = int.tryParse(_edadNuevoCtrl.text) ?? 0;
                if (edad < 69 || edad > 115) {
                  _mostrarError('La edad permitida es entre 69 y 115 años.');
                  return;
                }

                if (_nombreNuevoCtrl.text.isEmpty || sangreSeleccionada == null) {
                  _mostrarError('Por favor, completa el nombre y tipo de sangre.');
                  return;
                }

                try {
                  DocumentReference pacienteRef = _firestore.collection('pacientes').doc();
                  DocumentReference dispositivoRef = _firestore.collection('dispositivo').doc();
                  WriteBatch batch = _firestore.batch();

                  batch.set(pacienteRef, {
                    'nombre_paciente': _nombreNuevoCtrl.text.trim(),
                    'apellido_paciente': _apellidoNuevoCtrl.text.trim(),
                    'num_telefono_paciente': _telefonoNuevoCtrl.text.trim(),
                    'edad_paciente': edad,
                    'alergia_paciente': _alergiaNuevoCtrl.text.trim(),
                    'tipo_sangre': sangreSeleccionada,
                    'descripcion_paciente': 'Registrado por familiar',
                    'correo_familiar': widget.correoUsuario.trim(),
                    'id_dispositivo_asignado': dispositivoRef.id,
                  });

                  batch.set(dispositivoRef, {
                    'id_paciente': pacienteRef.id,
                    'estado_dispensador': 'reposo',
                    'id_dispositivo': 'DISP-${pacienteRef.id.substring(0, 8).toUpperCase()}',
                    'nombre_paciente': _nombreNuevoCtrl.text.trim(),
                    'id_usuario': widget.usuarioId,
                  });

                  await batch.commit();
                  if (mounted) Navigator.pop(context);
                } catch (e) {
                  _mostrarError('Error al registrar: $e');
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2D7A4F)),
              child: const Text('Registrar Paciente', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarAlertaSuscripcion() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Límite de Pacientes Superado', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        content: const Text('Para añadir otro paciente mejora tu suscripción.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Aceptar')),
        ],
      ),
    );
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje), backgroundColor: Colors.redAccent));
  }

  void _mostrarDialogoEditarCuenta() {
    _nombreUserCtrl.text = widget.nombreUsuario;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Datos de Cuenta'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _nombreUserCtrl, decoration: const InputDecoration(labelText: 'Nombre', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _apellidoUserCtrl, decoration: const InputDecoration(labelText: 'Apellido', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _telefonoUserCtrl, decoration: const InputDecoration(labelText: 'Teléfono', border: OutlineInputBorder()), keyboardType: TextInputType.phone),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Guardar')),
        ],
      ),
    );
  }

  void _mostrarDialogoEditarPaciente(Map<String, dynamic> datos, String idValido) {
    _nombreEditCtrl.text = datos['nombre_paciente'] ?? '';
    _apellidoEditCtrl.text = datos['apellido_paciente'] ?? '';
    _telefonoEditCtrl.text = datos['num_telefono_paciente'] ?? '';
    _edadEditCtrl.text = (datos['edad_paciente'] ?? '').toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Datos del Paciente'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _nombreEditCtrl, decoration: const InputDecoration(labelText: 'Nombre', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(
                controller: _telefonoEditCtrl,
                decoration: const InputDecoration(labelText: 'Teléfono (9 dígitos)', border: OutlineInputBorder()),
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(9)]),
            const SizedBox(height: 12),
            TextField(controller: _edadEditCtrl, decoration: const InputDecoration(labelText: 'Edad (69-115)', border: OutlineInputBorder()), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              int edad = int.tryParse(_edadEditCtrl.text) ?? 0;
              if (_telefonoEditCtrl.text.length != 9 || edad < 69 || edad > 115) {
                _mostrarError('Verifica que el teléfono tenga 9 dígitos y la edad esté entre 69 y 115.');
                return;
              }
              await _firestore.collection('pacientes').doc(idValido).update({
                'nombre_paciente': _nombreEditCtrl.text.trim(),
                'apellido_paciente': _apellidoEditCtrl.text.trim(),
                'num_telefono_paciente': _telefonoEditCtrl.text.trim(),
                'edad_paciente': edad,
              });
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Guardar'),
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
        content: Text('¿Estás seguro de que deseas eliminar permanentemente a $nombre y su dispositivo asociado?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              try {
                final querySnapshot = await _firestore.collection('dispositivo').where('id_paciente', isEqualTo: idValido).get();
                WriteBatch batch = _firestore.batch();
                batch.delete(_firestore.collection('pacientes').doc(idValido));
                for (var doc in querySnapshot.docs) { batch.delete(doc.reference); }
                await batch.commit();
                if (mounted) Navigator.pop(context);
              } catch (e) {
                _mostrarError('Error al eliminar: $e');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTarjetaPaciente(Map<String, dynamic> datosPaciente, String idDocumentoReal) {
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
                  child: Text('${datosPaciente['nombre_paciente'] ?? ''} ${datosPaciente['apellido_paciente'] ?? ''}'.toUpperCase(),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2D7A4F))),
                ),
                if (widget.rolUsuario.trim().toLowerCase() == 'familiar')
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit, color: Colors.blue, size: 20), onPressed: () => _mostrarDialogoEditarPaciente(datosPaciente, idDocumentoReal)),
                      IconButton(icon: const Icon(Icons.delete_forever, color: Colors.red, size: 20), onPressed: () => _confirmarEliminarPaciente(idDocumentoReal, datosPaciente['nombre_paciente'] ?? 'este paciente')),
                    ],
                  ),
              ],
            ),
            const Divider(),
            _buildPerfilItem(Icons.phone_android, 'Teléfono', datosPaciente['num_telefono_paciente'] ?? 'No registrado'),
            _buildPerfilItem(Icons.bloodtype_outlined, 'Grupo Sanguíneo', datosPaciente['tipo_sangre'] ?? 'No especificado'),
            _buildPerfilItem(Icons.cake_outlined, 'Edad', '${datosPaciente['edad_paciente'] ?? '—'} años'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi Perfil'), backgroundColor: const Color(0xFF2D7A4F), foregroundColor: Colors.white, elevation: 0),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: const Color(0xFF2D7A4F),
              padding: const EdgeInsets.only(bottom: 24, top: 8),
              child: Column(
                children: [
                  const CircleAvatar(radius: 45, backgroundColor: Colors.white, child: Icon(Icons.person, size: 55, color: Color(0xFF2D7A4F))),
                  const SizedBox(height: 12),
                  Text(widget.nombreUsuario, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                  Text(widget.rolUsuario.toUpperCase(), style: const TextStyle(fontSize: 14, color: Colors.white70, letterSpacing: 1.2)),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Datos de Cuenta', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2D7A4F))),
                              IconButton(icon: const Icon(Icons.edit, color: Color(0xFF2D7A4F), size: 20), onPressed: _mostrarDialogoEditarCuenta),
                            ],
                          ),
                          const Divider(),
                          _buildPerfilItem(Icons.email_outlined, 'Correo', widget.correoUsuario),
                          _buildPerfilItem(Icons.wc_outlined, 'Sexo', widget.sexoUsuario),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Pacientes a mi cargo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      TextButton(
                          onPressed: () => setState(() => _mostrarTodosLosPacientes = !_mostrarTodosLosPacientes),
                          child: Text(_mostrarTodosLosPacientes ? 'Ver menos' : 'Ver todos', style: const TextStyle(color: Color(0xFF2D7A4F)))),
                    ],
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: _firestore.collection('pacientes').snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                      var listaFiltrada = snapshot.data!.docs.where((doc) {
                        var data = doc.data() as Map<String, dynamic>;
                        return (data['correo_familiar'] ?? '').toString().toLowerCase() == widget.correoUsuario.toLowerCase();
                      }).toList();

                      if (listaFiltrada.isEmpty) return const Padding(padding: EdgeInsets.all(20.0), child: Text('No tienes pacientes registrados.', textAlign: TextAlign.center));
                      var mostrar = _mostrarTodosLosPacientes ? listaFiltrada : [listaFiltrada.last];
                      return Column(children: mostrar.map((doc) => _buildTarjetaPaciente(doc.data() as Map<String, dynamic>, doc.id)).toList());
                    },
                  ),
                  if (widget.rolUsuario.trim().toLowerCase() == 'familiar')
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: ElevatedButton.icon(
                        onPressed: _mostrarDialogoAnadir,
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text('Añadir Paciente', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2D7A4F), padding: const EdgeInsets.symmetric(vertical: 12)),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}