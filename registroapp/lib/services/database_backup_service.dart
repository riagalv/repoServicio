import 'dart:io';
import 'dart:typed_data';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'api_service.dart';

/// Servicio para exportar e importar la base de datos SQLite.
/// Funciona en modo local (copia directa del archivo .db) y en
/// modo servidor (descarga/subida via HTTP al servidor Node.js).
class DatabaseBackupService {
  // ─────────────────────────────────────────────────────────────────────────
  // EXPORTAR  (descargar / guardar copia)
  // ─────────────────────────────────────────────────────────────────────────

  /// Exporta la base de datos y pide al usuario dónde guardarla.
  /// Devuelve un mensaje descriptivo del resultado.
  static Future<String> exportarBaseDeDatos() async {
    try {
      final Uint8List bytes;

      if (ApiService.isServerMode) {
        bytes = await _descargarDbDesdeServidor();
      } else {
        bytes = await _leerDbLocal();
      }

      final String fileName =
          'registroapp_backup_${_timestampSuffix()}.db';

      final FileSaveLocation? location = await getSaveLocation(
        suggestedName: fileName,
        acceptedTypeGroups: [
          const XTypeGroup(
            label: 'Base de datos SQLite',
            extensions: ['db', 'sqlite'],
          ),
        ],
      );

      if (location == null) {
        return 'cancelado';
      }

      final File destino = File(location.path);
      await destino.writeAsBytes(bytes, flush: true);
      return 'correcto';
    } catch (e) {
      debugPrint('Error al exportar BD: $e');
      return 'error: $e';
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // IMPORTAR  (cargar / reemplazar la base de datos)
  // ─────────────────────────────────────────────────────────────────────────

  /// Importa un archivo .db seleccionado por el usuario.
  /// En modo local cierra la BD, reemplaza el archivo y la reinicia.
  /// En modo servidor sube el archivo al endpoint del servidor.
  /// Devuelve un mensaje descriptivo del resultado.
  static Future<String> importarBaseDeDatos() async {
    try {
      const XTypeGroup filtroDb = XTypeGroup(
        label: 'Base de datos SQLite',
        extensions: ['db', 'sqlite'],
      );

      final XFile? archivo = await openFile(acceptedTypeGroups: [filtroDb]);

      if (archivo == null) {
        return 'cancelado';
      }

      final Uint8List bytes = await archivo.readAsBytes();

      if (ApiService.isServerMode) {
        await _subirDbAlServidor(bytes);
      } else {
        await _reemplazarDbLocal(bytes);
      }

      return 'correcto';
    } catch (e) {
      debugPrint('Error al importar BD: $e');
      return 'error: $e';
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // HELPERS PRIVADOS
  // ─────────────────────────────────────────────────────────────────────────

  static String _timestampSuffix() {
    final now = DateTime.now();
    return '${now.year}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}'
        '_${now.hour.toString().padLeft(2, '0')}'
        '${now.minute.toString().padLeft(2, '0')}';
  }

  static Future<String> _rutaDbLocal() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    final dbPath = await databaseFactory.getDatabasesPath();
    return '$dbPath/registroapp.db';
  }

  static Future<Uint8List> _leerDbLocal() async {
    final path = await _rutaDbLocal();
    final file = File(path);
    if (!await file.exists()) {
      throw Exception('Archivo de base de datos no encontrado en: $path');
    }
    return await file.readAsBytes();
  }

  static Future<void> _reemplazarDbLocal(Uint8List bytes) async {
    final path = await _rutaDbLocal();

    // Cerrar la base de datos si está abierta
    try {
      final db = await databaseFactory.openDatabase(path);
      await db.close();
    } catch (_) {}

    // Escribir el nuevo archivo
    final file = File(path);
    await file.writeAsBytes(bytes, flush: true);
  }

  static Future<Uint8List> _descargarDbDesdeServidor() async {
    final url = '${ApiService.serverUrl}/api/db/export';
    final response = await http
        .get(Uri.parse(url))
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      return response.bodyBytes;
    }
    throw Exception(
        'El servidor respondió con código ${response.statusCode}');
  }

  static Future<void> _subirDbAlServidor(Uint8List bytes) async {
    final url = '${ApiService.serverUrl}/api/db/import';

    final request = http.MultipartRequest('POST', Uri.parse(url));
    request.files.add(
      http.MultipartFile.fromBytes(
        'database',
        bytes,
        filename: 'registroapp.db',
      ),
    );

    final streamedResponse =
        await request.send().timeout(const Duration(seconds: 60));

    if (streamedResponse.statusCode != 200) {
      final body = await streamedResponse.stream.bytesToString();
      throw Exception(
          'Error al subir la base de datos al servidor: $body');
    }
  }
}
