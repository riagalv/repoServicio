import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String _prefServerUrlKey = 'server_url';
  static const String _prefUseServerKey = 'use_server_mode';

  static String _serverUrl = 'http://localhost:3000';
  static bool _useServerMode = false;
  static bool _initialized = false;

  static String get serverUrl => _serverUrl;
  static bool get isServerMode => _useServerMode;

  static Future<void> init() async {
    if (_initialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      _serverUrl = prefs.getString(_prefServerUrlKey) ?? 'http://localhost:3000';
      _useServerMode = prefs.getBool(_prefUseServerKey) ?? false;
      _initialized = true;
    } catch (_) {
      // Fallback
    }
  }

  static Future<void> setConfig({required bool useServer, required String url}) async {
    var cleanUrl = url.trim();
    if (cleanUrl.endsWith('/')) {
      cleanUrl = cleanUrl.substring(0, cleanUrl.length - 1);
    }
    if (!cleanUrl.startsWith('http://') && !cleanUrl.startsWith('https://')) {
      cleanUrl = 'http://$cleanUrl';
    }

    _useServerMode = useServer;
    _serverUrl = cleanUrl;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefServerUrlKey, _serverUrl);
      await prefs.setBool(_prefUseServerKey, _useServerMode);
    } catch (_) {}
  }

  static Future<bool> testConnection([String? testUrl]) async {
    var url = (testUrl ?? _serverUrl).trim();
    if (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'http://$url';
    }

    try {
      final response = await http
          .get(Uri.parse('$url/api/health'))
          .timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == 'ok';
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  // ==========================================
  // CLIENTES
  // ==========================================
  static Future<List<Map<String, dynamic>>> obtenerClientes() async {
    final response = await http.get(Uri.parse('$_serverUrl/api/clientes'));
    if (response.statusCode == 200) {
      final List<dynamic> list = jsonDecode(utf8.decode(response.bodyBytes));
      return list.map((e) => Map<String, dynamic>.from(e)).toList();
    }
    throw Exception('Error al obtener clientes del servidor: ${response.statusCode}');
  }

  static Future<int> insertarCliente(Map<String, dynamic> cliente) async {
    final response = await http.post(
      Uri.parse('$_serverUrl/api/clientes'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(cliente),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['id'] as int;
    }
    throw Exception('Error al insertar cliente en servidor: ${response.body}');
  }

  static Future<int> actualizarCliente(int id, Map<String, dynamic> cliente) async {
    final response = await http.put(
      Uri.parse('$_serverUrl/api/clientes/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(cliente),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['changes'] as int? ?? 1;
    }
    throw Exception('Error al actualizar cliente en servidor');
  }

  static Future<int> eliminarCliente(int id) async {
    final response = await http.delete(Uri.parse('$_serverUrl/api/clientes/$id'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['changes'] as int? ?? 1;
    }
    throw Exception('Error al eliminar cliente en servidor');
  }

  static Future<bool> existeTelefono(String telefono, {int? excluirId}) async {
    var url = '$_serverUrl/api/clientes/existe-telefono?telefono=${Uri.encodeComponent(telefono)}';
    if (excluirId != null) {
      url += '&excluirId=$excluirId';
    }

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['exists'] == true;
    }
    return false;
  }

  // ==========================================
  // ÓRDENES
  // ==========================================
  static Future<List<Map<String, dynamic>>> obtenerOrdenes() async {
    final response = await http.get(Uri.parse('$_serverUrl/api/ordenes'));
    if (response.statusCode == 200) {
      final List<dynamic> list = jsonDecode(utf8.decode(response.bodyBytes));
      return list.map((e) => Map<String, dynamic>.from(e)).toList();
    }
    throw Exception('Error al obtener órdenes del servidor: ${response.statusCode}');
  }

  static Future<Map<String, dynamic>?> obtenerOrden(int id) async {
    final response = await http.get(Uri.parse('$_serverUrl/api/ordenes/$id'));
    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(jsonDecode(utf8.decode(response.bodyBytes)));
    } else if (response.statusCode == 404) {
      return null;
    }
    throw Exception('Error al obtener orden del servidor');
  }

  static Future<int> insertarOrden(Map<String, dynamic> orden) async {
    final response = await http.post(
      Uri.parse('$_serverUrl/api/ordenes'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(orden),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['id'] as int;
    }
    throw Exception('Error al registrar orden en el servidor: ${response.body}');
  }

  static Future<int> actualizarOrden(int id, Map<String, dynamic> orden) async {
    final response = await http.put(
      Uri.parse('$_serverUrl/api/ordenes/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(orden),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['changes'] as int? ?? 1;
    }
    throw Exception('Error al actualizar orden en el servidor');
  }

  static Future<int> eliminarOrden(int id) async {
    final response = await http.delete(Uri.parse('$_serverUrl/api/ordenes/$id'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['changes'] as int? ?? 1;
    }
    throw Exception('Error al eliminar orden del servidor');
  }

  static Future<String> generarSiguienteFolio([DateTime? fecha]) async {
    final f = fecha ?? DateTime.now();
    final url = '$_serverUrl/api/ordenes/siguiente-folio?fecha=${f.toIso8601String()}';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['folio'] as String;
    }
    // Fallback si no responde
    final anio = f.year.toString();
    final mes = f.month.toString().padLeft(2, '0');
    final dia = f.day.toString().padLeft(2, '0');
    return '$anio$mes$dia-0001';
  }

  // ==========================================
  // ESTADÍSTICAS
  // ==========================================
  static Future<int> contarClientes() async {
    final stats = await _obtenerStats();
    return stats['totalClientes'] as int? ?? 0;
  }

  static Future<int> contarOrdenes() async {
    final stats = await _obtenerStats();
    return stats['totalOrdenes'] as int? ?? 0;
  }

  static Future<int> contarOrdenesPorEstado(String estado) async {
    final stats = await _obtenerStats();
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return stats['pendientes'] as int? ?? 0;
      case 'en proceso':
        return stats['enProceso'] as int? ?? 0;
      case 'terminada':
        return stats['terminadas'] as int? ?? 0;
      case 'cancelada':
        return stats['canceladas'] as int? ?? 0;
      default:
        return 0;
    }
  }

  static Future<Map<String, dynamic>> _obtenerStats() async {
    try {
      final response = await http.get(Uri.parse('$_serverUrl/api/stats'));
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(jsonDecode(response.body));
      }
    } catch (_) {}
    return {};
  }
}
