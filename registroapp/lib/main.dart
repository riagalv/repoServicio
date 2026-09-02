import 'package:flutter/material.dart';
import 'database/database.dart';
import 'models/orden.dart';
//import 'screens/clientes/clientes_page.dart';
import 'screens/ordenes/ordenes_page.dart';
import 'screens/ordenes/nueva_orden_dialog.dart';
import 'services/pdf_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DatabaseHelper.database;

  runApp(const SistemaTecnicoApp());
}

class SistemaTecnicoApp extends StatelessWidget {
  const SistemaTecnicoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sistema de Servicio Técnico',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
      ),
      home: const InicioPage(),
    );
  }
}

class InicioPage extends StatefulWidget {
  const InicioPage({super.key});

  @override
  State<InicioPage> createState() => _InicioPageState();
}

class _InicioPageState extends State<InicioPage> {
  int paginaSeleccionada = 0;
  String filtroOrdenes = 'Todas';

  final List<String> paginas = [
    'Inicio',
  ];

  int totalOrdenes = 0;
  int pendientes = 0;
  int enProceso = 0;
  int finalizadas = 0;

  bool cargandoResumen = true;

  @override
  void initState() {
    super.initState();
    cargarResumen();
  }

  void _navegarAOrdenes(String filtro) {
    setState(() {
      filtroOrdenes = filtro;
      paginaSeleccionada = 1;
    });
  }

  Future<void> cargarResumen() async {
    final ordenes = await DatabaseHelper.contarOrdenes();

    final ordenesPendientes =
        await DatabaseHelper.contarOrdenesPorEstado(
      'Pendiente',
    );

    final ordenesEnProceso =
        await DatabaseHelper.contarOrdenesPorEstado(
      'En proceso',
    );

    final ordenesFinalizadas =
        await DatabaseHelper.contarOrdenesPorEstado(
      'Finalizada',
    );

    if (!mounted) return;

    setState(() {
      totalOrdenes = ordenes;
      pendientes = ordenesPendientes;
      enProceso = ordenesEnProceso;
      finalizadas = ordenesFinalizadas;

      cargandoResumen = false;
    });
  }

  void _mostrarFolioCreado(Orden orden) {
    showDialog(
      context: context,
      builder: (context) {
        final fechaDisplay = orden.fecha.contains('T')
            ? orden.fecha.split('T').first
            : orden.fecha;

        return AlertDialog(
          icon: const Icon(Icons.check_circle, color: Colors.green, size: 50),
          title: const Text(
            '¡Orden registrada con éxito!',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: 550,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'FOLIO GENERADO',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        SelectableText(
                          orden.folio,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Detalles de la Orden',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const Divider(),
                  const SizedBox(height: 6),
                  _itemDetalleModal('Fecha:', fechaDisplay),
                  _itemDetalleModal('Cliente:', orden.clienteNombre ?? '-'),
                  _itemDetalleModal('Teléfono:', orden.clienteTelefono ?? '-'),
                  if (orden.clienteCorreo != null && orden.clienteCorreo!.isNotEmpty)
                    _itemDetalleModal('Correo:', orden.clienteCorreo!),
                  _itemDetalleModal('Equipo:', orden.equipo ?? '-'),
                  _itemDetalleModal('Problema:', orden.problema ?? '-'),
                  _itemDetalleModal('Estado:', orden.estado),
                  if (orden.diagnostico != null && orden.diagnostico!.isNotEmpty)
                    _itemDetalleModal('Diagnóstico:', orden.diagnostico!),
                  if (orden.observaciones != null && orden.observaciones!.isNotEmpty)
                    _itemDetalleModal('Observaciones:', orden.observaciones!),
                ],
              ),
            ),
          ),
          actions: [
            OutlinedButton.icon(
              onPressed: () async {
                final navigator = Navigator.of(context);
                navigator.pop();
                final resultado = await PdfService.exportarOrden(orden);
                if (mounted) {
                  if (resultado == 'correcto') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('PDF guardado correctamente')),
                    );
                  } else if (resultado == 'error') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Error al generar el PDF')),
                    );
                  }
                }
              },
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Exportar a PDF'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  Widget _itemDetalleModal(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              titulo,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 250,
            color: Colors.blue.shade900,
            child: Column(
              children: [
                const SizedBox(height: 35),

                const Icon(
                  Icons.build_circle,
                  size: 55,
                  color: Colors.white,
                ),

                const SizedBox(height: 12),

                const Text(
                  'SERVICIO TÉCNICO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 35),

                Expanded(
                  child: ListView.builder(
                    itemCount: paginas.length,
                    itemBuilder: (context, index) {
                      return _crearOpcionMenu(
                        icono: _obtenerIcono(index),
                        texto: paginas[index],
                        seleccionado: paginaSeleccionada == index,
                        onTap: () async {
                          setState(() {
                            paginaSeleccionada = index;
                          });

                          if (index == 0) {
                            await cargarResumen();
                          }
                        },
                      );
                    },
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'Sistema de gestión',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Column(
              children: [
                Container(
                  height: 70,
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      if (paginaSeleccionada == 1) ...[
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          tooltip: 'Volver al Inicio',
                          onPressed: () async {
                            setState(() {
                              paginaSeleccionada = 0;
                            });
                            await cargarResumen();
                          },
                        ),
                        const SizedBox(width: 8),
                      ],

                      Text(
                        paginaSeleccionada == 0 ? 'Inicio' : 'Órdenes',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const Spacer(),

                      const CircleAvatar(
                        child: Icon(Icons.person),
                      ),

                      const SizedBox(width: 12),

                      const Text(
                        'Técnico',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: _crearContenido(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _crearOpcionMenu({
    required IconData icono,
    required String texto,
    required bool seleccionado,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: seleccionado
            ? Colors.blue.shade700
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(
          icono,
          color: Colors.white,
        ),
        title: Text(
          texto,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  IconData _obtenerIcono(int index) {
    switch (index) {
      case 0:
        return Icons.home;
      default:
        return Icons.circle;
    }
  }

  Widget _crearContenido() {
    switch (paginaSeleccionada) {
      case 1:
        return OrdenesPage(
          filtroInicial: filtroOrdenes,
          key: ValueKey(filtroOrdenes),
        );
      case 0:
      default:
        return _inicio();
    }
  }

  Widget fichaResumen({
    required IconData icono,
    required String titulo,
    required int cantidad,
    required String descripcion,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Card(
        elevation: 3,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          hoverColor: color.withOpacity(0.04),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        icono,
                        size: 26,
                        color: color,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 13,
                      color: Colors.grey.shade400,
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                Text(
                  cantidad.toString(),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  descripcion,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _inicio() {
    Future<void> _mostrarNuevaOrden() async {
      final resultado = await showDialog<dynamic>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return const NuevaOrdenDialog();
        },
      );

      if (resultado != null && mounted) {
        await cargarResumen();

        setState(() {
          paginaSeleccionada = 0;
        });

        if (resultado is Orden) {
          _mostrarFolioCreado(resultado);
        } else if (resultado == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Orden creada correctamente'),
            ),
          );
        }
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bienvenido',
                    style: TextStyle(
                      fontSize: 32,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Administra la información de tus servicios técnicos.',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              FilledButton.icon(
                onPressed: _mostrarNuevaOrden,
                icon: const Icon(Icons.add),
                label: const Text('Nueva orden'),
              ),
            ],
          ),

          const SizedBox(height: 30),

          if (cargandoResumen)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              ),
            )
          else
            Column(
              children: [
                Row(
                  children: [
                    fichaResumen(
                      icono: Icons.assignment,
                      titulo: 'Órdenes',
                      cantidad: totalOrdenes,
                      descripcion: 'Ver todas las órdenes',
                      color: Colors.blue.shade700,
                      onTap: () => _navegarAOrdenes('Todas'),
                    ),

                    const SizedBox(width: 20),

                    fichaResumen(
                      icono: Icons.schedule,
                      titulo: 'Pendientes',
                      cantidad: pendientes,
                      descripcion: 'Órdenes por atender',
                      color: Colors.orange.shade800,
                      onTap: () => _navegarAOrdenes('Pendiente'),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    fichaResumen(
                      icono: Icons.build_outlined,
                      titulo: 'En proceso',
                      cantidad: enProceso,
                      descripcion: 'Órdenes en reparación',
                      color: Colors.indigo.shade700,
                      onTap: () => _navegarAOrdenes('En proceso'),
                    ),

                    const SizedBox(width: 20),

                    fichaResumen(
                      icono: Icons.check_circle_outline,
                      titulo: 'Finalizadas',
                      cantidad: finalizadas,
                      descripcion: 'Órdenes completadas',
                      color: Colors.green.shade700,
                      onTap: () => _navegarAOrdenes('Finalizada'),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }
}