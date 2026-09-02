import 'package:flutter/material.dart';
import 'database/database.dart';
//import 'screens/clientes/clientes_page.dart';
import 'screens/ordenes/ordenes_page.dart';
import 'screens/ordenes/nueva_orden_dialog.dart';

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
      final resultado = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return const NuevaOrdenDialog();
        },
      );

      if (resultado == true && mounted) {
        await cargarResumen();

        setState(() {
          paginaSeleccionada = 0;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Orden creada correctamente'),
          ),
        );
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