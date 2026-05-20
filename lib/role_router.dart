import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'pantalla_principal.dart';
import 'dashboards/dashboard_admin.dart';
import 'dashboards/dashboard_callcenter.dart';
import 'dashboards/dashboard_monitor.dart';

Widget buildHomeForRole(SesionUsuario sesion) {
  switch (sesion.rol) {
    case RolUsuario.administrador:
      return DashboardAdmin(sesion: sesion);
    case RolUsuario.callcenter:
      return DashboardCallCenter(sesion: sesion);
    case RolUsuario.monitor:
      return DashboardMonitor(sesion: sesion);
    case RolUsuario.familiar:
    case RolUsuario.paciente:
    case RolUsuario.desconocido:
      return PantallaPrincipal(
        nombreUsuario: sesion.nombre,
        sexoUsuario: sesion.sexo,
        correoUsuario: sesion.email,
        rolUsuario: rolToString(sesion.rol),
      );
  }
}

String rolToString(RolUsuario rol) {
  switch (rol) {
    case RolUsuario.administrador:
      return 'administrador';
    case RolUsuario.monitor:
      return 'monitor';
    case RolUsuario.callcenter:
      return 'callcenter';
    case RolUsuario.familiar:
      return 'familiar';
    case RolUsuario.paciente:
      return 'paciente';
    case RolUsuario.desconocido:
      return 'desconocido';
  }
}
