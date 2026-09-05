import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ServerConfigDialog extends StatefulWidget {
  const ServerConfigDialog({super.key});

  @override
  State<ServerConfigDialog> createState() => _ServerConfigDialogState();
}

class _ServerConfigDialogState extends State<ServerConfigDialog> {
  final _urlController = TextEditingController();
  bool _useServer = false;
  bool _probando = false;
  bool? _conexionExitosa;
  String _mensajeResultado = '';

  @override
  void initState() {
    super.initState();
    _useServer = ApiService.isServerMode;
    _urlController.text = ApiService.serverUrl;
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _probarConexion() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      setState(() {
        _conexionExitosa = false;
        _mensajeResultado = 'Por favor ingresa una dirección de servidor.';
      });
      return;
    }

    setState(() {
      _probando = true;
      _conexionExitosa = null;
      _mensajeResultado = 'Conectando con el servidor...';
    });

    final exito = await ApiService.testConnection(url);

    if (mounted) {
      setState(() {
        _probando = false;
        _conexionExitosa = exito;
        _mensajeResultado = exito
            ? '¡Conexión exitosa con el servidor!'
            : 'No se pudo conectar. Verifica que el servidor esté iniciado y la dirección sea correcta.';
      });
    }
  }

  Future<void> _guardarConfiguracion() async {
    await ApiService.setConfig(
      useServer: _useServer,
      url: _urlController.text.trim().isEmpty ? 'http://localhost:3000' : _urlController.text.trim(),
    );

    if (mounted) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_useServer
              ? 'Conectado a modo Servidor Remoto (${ApiService.serverUrl})'
              : 'Configurado en Modo Local (SQLite)'),
          backgroundColor: const Color(0xFF1E293B),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.dns_rounded, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Configuración de Servidor',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          'Conecta múltiples computadoras por red o Internet',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 12),

              // Switch Modo Local / Modo Servidor
              Container(
                decoration: BoxDecoration(
                  color: _useServer ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _useServer ? const Color(0xFF3B82F6) : Colors.grey.shade300,
                    width: _useServer ? 1.5 : 1.0,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Icon(
                      _useServer ? Icons.cloud_sync_rounded : Icons.computer_rounded,
                      color: _useServer ? const Color(0xFF2563EB) : const Color(0xFF64748B),
                      size: 28,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _useServer ? 'Modo Servidor Remoto' : 'Modo Local (Esta PC)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: _useServer ? const Color(0xFF1E3A8A) : const Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _useServer
                                ? 'La app compartirá datos en tiempo real con el servidor.'
                                : 'La app guarda todo en el disco de esta computadora.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: _useServer,
                      activeColor: const Color(0xFF2563EB),
                      onChanged: (value) {
                        setState(() {
                          _useServer = value;
                          _conexionExitosa = null;
                          _mensajeResultado = '';
                        });
                      },
                    ),
                  ],
                ),
              ),

              if (_useServer) ...[
                const SizedBox(height: 20),
                const Text(
                  'Dirección IP o URL del Servidor',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _urlController,
                  decoration: InputDecoration(
                    hintText: 'Ej: http://192.168.1.50:3000 o https://taller.trycloudflare.com',
                    prefixIcon: const Icon(Icons.link_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '• En la misma oficina/Wi-Fi: usa la IP local (ej: http://192.168.1.X:3000)\n'
                  '• Por Internet: usa la URL de Cloudflare Tunnel (ej: https://...trycloudflare.com)',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600, height: 1.4),
                ),
                const SizedBox(height: 14),

                // Botón Probar Conexión
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: _probando ? null : _probarConexion,
                      icon: _probando
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.wifi_find_rounded, size: 18),
                      label: Text(_probando ? 'Probando...' : 'Probar Conexión'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF2563EB),
                        side: const BorderSide(color: Color(0xFF2563EB)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),

                if (_mensajeResultado.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _conexionExitosa == true
                          ? const Color(0xFFDCFCE7)
                          : (_conexionExitosa == false
                              ? const Color(0xFFFEE2E2)
                              : const Color(0xFFF1F5F9)),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _conexionExitosa == true
                            ? const Color(0xFF22C55E)
                            : (_conexionExitosa == false
                                ? const Color(0xFFEF4444)
                                : Colors.grey.shade300),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _conexionExitosa == true
                              ? Icons.check_circle_rounded
                              : (_conexionExitosa == false
                                  ? Icons.error_rounded
                                  : Icons.info_rounded),
                          color: _conexionExitosa == true
                              ? const Color(0xFF16A34A)
                              : (_conexionExitosa == false
                                  ? const Color(0xFFDC2626)
                                  : const Color(0xFF64748B)),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _mensajeResultado,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: _conexionExitosa == true
                                  ? const Color(0xFF15803D)
                                  : (_conexionExitosa == false
                                      ? const Color(0xFFB91C1C)
                                      : const Color(0xFF334155)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 12),

              // Botones de acción
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: _guardarConfiguracion,
                    icon: const Icon(Icons.save_rounded, size: 18),
                    label: const Text('Guardar y Aplicar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
